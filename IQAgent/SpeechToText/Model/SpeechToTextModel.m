//
//  SpeechToTextModel.m

#import "SpeechToTextModel.h"
#include "SpeechToTextFacade.h"

#define SAFE_PERFORM_SELECTOR_WITH_OBJECT(target,selector,obj) {if(target!=nil&&selector!=nil&&[target respondsToSelector:selector]){[target performSelector:selector withObject:obj];}}

#define	SAFE_RELEASE(ptr)	{if(ptr!=nil){if ([ptr respondsToSelector:@selector(setDelegate:)]) {[ptr performSelector:@selector(setDelegate:) withObject:nil];}[ptr release];ptr=nil;}}

#define FRAME_SIZE 110

@interface SpeechToTextModel ()

- (void)reset;
- (void)postByteData:(NSData *)data;
- (void)cleanUpProcessingThread;
@end

@implementation SpeechToTextModel

static void HandleInputBuffer (void *aqData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer,
                               const AudioTimeStamp *inStartTime, UInt32 inNumPackets,
                               const AudioStreamPacketDescription *inPacketDesc) {
    
    AQRecorderState *pAqData = (AQRecorderState *) aqData;
    
    if (inNumPackets == 0 && pAqData->mDataFormat.mBytesPerPacket != 0)
        inNumPackets = inBuffer->mAudioDataByteSize / pAqData->mDataFormat.mBytesPerPacket;
    
    // process speex
    int packets_per_frame = pAqData->speex_samples_per_frame;
    
    char cbits[FRAME_SIZE + 1];
    for (int i = 0; i < inNumPackets; i+= packets_per_frame) {
        speex_bits_reset(&(pAqData->speex_bits));
        
        speex_encode_int(pAqData->speex_enc_state, ((spx_int16_t*)inBuffer->mAudioData) + i, &(pAqData->speex_bits));
        int nbBytes = speex_bits_write(&(pAqData->speex_bits), cbits + 1, FRAME_SIZE);
        cbits[0] = nbBytes;
        
        [pAqData->encodedSpeexData appendBytes:cbits length:nbBytes + 1];
    }
    pAqData->mCurrentPacket += inNumPackets;
    
    if (!pAqData->mIsRunning)
        return;
    
    AudioQueueEnqueueBuffer(pAqData->mQueue, inBuffer, 0, NULL);
}

static void DeriveBufferSize (AudioQueueRef audioQueue, AudioStreamBasicDescription *ASBDescription, Float64 seconds, UInt32 *outBufferSize) {
    static const int maxBufferSize = 0x50000;
    
    int maxPacketSize = ASBDescription->mBytesPerPacket;
    if (maxPacketSize == 0) {
        UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
        AudioQueueGetProperty (audioQueue, kAudioQueueProperty_MaximumOutputPacketSize, &maxPacketSize, &maxVBRPacketSize);
    }
    
    Float64 numBytesForTime = ASBDescription->mSampleRate * maxPacketSize * seconds;
    *outBufferSize = (UInt32)(numBytesForTime < maxBufferSize ? numBytesForTime : maxBufferSize);
}

- (id)init {
    if ((self = [self initWithCustomDisplay:nil])) {
    }
    return self;
}

- (id)initWithCustomDisplay:(NSString *)nibName {
    if ((self = [super init])) {
        aqData.mDataFormat.mFormatID         = kAudioFormatLinearPCM;
        aqData.mDataFormat.mSampleRate       = 16000.0;
        aqData.mDataFormat.mChannelsPerFrame = 1;
        aqData.mDataFormat.mBitsPerChannel   = 16;
        aqData.mDataFormat.mBytesPerPacket   =
        aqData.mDataFormat.mBytesPerFrame =
        aqData.mDataFormat.mChannelsPerFrame * sizeof (SInt16);
        aqData.mDataFormat.mFramesPerPacket  = 1;
        
        aqData.mDataFormat.mFormatFlags =
        kLinearPCMFormatFlagIsSignedInteger
        | kLinearPCMFormatFlagIsPacked;
        
        memset(&(aqData.speex_bits), 0, sizeof(SpeexBits));
        speex_bits_init(&(aqData.speex_bits));
        aqData.speex_enc_state = speex_encoder_init(&speex_wb_mode);
        
        int quality = 8;
        speex_encoder_ctl(aqData.speex_enc_state, SPEEX_SET_QUALITY, &quality);
        int vbr = 1;
        speex_encoder_ctl(aqData.speex_enc_state, SPEEX_SET_VBR, &vbr);
        speex_encoder_ctl(aqData.speex_enc_state, SPEEX_GET_FRAME_SIZE, &(aqData.speex_samples_per_frame));
        aqData.mQueue = NULL;
        
        [self reset];
        aqData.selfRef = self;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
    [processingThread cancel];
    if (processing) {
        [self cleanUpProcessingThread];
    }
    
    speex_bits_destroy(&(aqData.speex_bits));
    speex_encoder_destroy(aqData.speex_enc_state);
    [aqData.encodedSpeexData release];
    AudioQueueDispose(aqData.mQueue, true);
    [volumeDataPoints release];
    SAFE_RELEASE(self.delegate);
}

- (BOOL)recording {
    return aqData.mIsRunning;
}

- (void)reset {
    if (aqData.mQueue != NULL)
        AudioQueueDispose(aqData.mQueue, true);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *configSessionError = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                  withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                        error:&configSessionError];
    if (configSessionError) {
        NSLog(@"Error setting category! %ld", (long)[configSessionError code]);
    }
    [audioSession setActive:YES error:&configSessionError];

    UInt32 enableLevelMetering = 1;
    AudioQueueNewInput(&(aqData.mDataFormat), HandleInputBuffer, &aqData, NULL, kCFRunLoopCommonModes, 0, &(aqData.mQueue));
    AudioQueueSetProperty(aqData.mQueue, kAudioQueueProperty_EnableLevelMetering, &enableLevelMetering, sizeof(UInt32));
    DeriveBufferSize(aqData.mQueue, &(aqData.mDataFormat), 0.5, &(aqData.bufferByteSize));
    
    for (int i = 0; i < kNumberBuffers; i++) {
        AudioQueueAllocateBuffer(aqData.mQueue, aqData.bufferByteSize, &(aqData.mBuffers[i]));
        AudioQueueEnqueueBuffer(aqData.mQueue, aqData.mBuffers[i], 0, NULL);
    }
    
    [aqData.encodedSpeexData release];
    aqData.encodedSpeexData = [[NSMutableData alloc] init];
    
    [meterTimer invalidate];
    [meterTimer release];
    samplesBelowSilence = 0;
    detectedSpeech = NO;
    
    [volumeDataPoints release];
    volumeDataPoints = [[NSMutableArray alloc] initWithCapacity:kNumVolumeSamples];
    for (int i = 0; i < kNumVolumeSamples; i++) {
        [volumeDataPoints addObject:[NSNumber numberWithFloat:kMinVolumeSampleValue]];
    }

}

- (void)beginRecording {
    @synchronized(self) {
        if (!self.recording && !processing) {
            aqData.mCurrentPacket = 0;
            aqData.mIsRunning = true;
            [self reset];
            AudioQueueStart(aqData.mQueue, NULL);
            meterTimer = [[NSTimer scheduledTimerWithTimeInterval:kVolumeSamplingInterval target:self selector:@selector(checkMeter) userInfo:nil repeats:YES] retain];
        }
    }
}

- (void)sineWaveDoneAction {
    if (self.recording)
        [self stopRecording:YES];
}

- (void)cleanUpProcessingThread {
    @synchronized(self) {
        [processingThread release];
        processingThread = nil;
        processing = NO;
    }
}

- (void)sineWaveCancelAction {
    if (self.recording) {
        [self stopRecording:NO];
    } else {
        if (processing) {
            [processingThread cancel];
            processing = NO;
        }
    }
}

- (void)stopRecording:(BOOL)startProcessing {
    @synchronized(self) {
        if (self.recording) {
            AudioQueueStop(aqData.mQueue, true);
            aqData.mIsRunning = false;
            [meterTimer invalidate];
            [meterTimer release];
            meterTimer = nil;
            if (startProcessing) {
                [self cleanUpProcessingThread];
                processing = YES;
                processingThread = [[NSThread alloc] initWithTarget:self selector:@selector(postByteData:) object:aqData.encodedSpeexData];
                [processingThread start];
                if (self.delegate && [self.delegate respondsToSelector:@selector(showLoadingView)])
                    [self.delegate showLoadingView];
            }
        }
    }
}

- (void)checkMeter {
    AudioQueueLevelMeterState meterState;
    AudioQueueLevelMeterState meterStateDB;
    UInt32 ioDataSize = sizeof(AudioQueueLevelMeterState);
    AudioQueueGetProperty(aqData.mQueue, kAudioQueueProperty_CurrentLevelMeter, &meterState, &ioDataSize);
    AudioQueueGetProperty(aqData.mQueue, kAudioQueueProperty_CurrentLevelMeterDB, &meterStateDB, &ioDataSize);
    
    [volumeDataPoints removeObjectAtIndex:0];
    float dataPoint;
    if (meterStateDB.mAveragePower > kSilenceThresholdDB) {
        detectedSpeech = YES;
        dataPoint = MIN(kMaxVolumeSampleValue, meterState.mPeakPower);
    } else {
        dataPoint = MAX(kMinVolumeSampleValue, meterState.mPeakPower);
    }
    [volumeDataPoints addObject:[NSNumber numberWithFloat:dataPoint]];
    
//    [sineWave updateWaveDisplay];
    
    if (detectedSpeech) {
        if (meterStateDB.mAveragePower < kSilenceThresholdDB) {
            samplesBelowSilence++;
            if (samplesBelowSilence > kSilenceThresholdNumSamples && [IQSetting sharedInstance].ITEM_ASR_TAP.iDefault == 0) {
                [self stopRecording:YES];
            }
        } else {
            samplesBelowSilence = 0;
        }
    }
}

- (void)postByteData:(NSData *)byteData {
    if ([self.delegate respondsToSelector:@selector(postVoiceData:)]) {
        [self.delegate postVoiceData:byteData];
    }
    
    [self cleanUpProcessingThread];
}

- (void)requestVoiceData:(NSData *)data urlStr:(NSString *)urlStr {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    [request addValue:@"audio/x-speex-with-header-byte; rate=16000" forHTTPHeaderField:@"Content-Type"];
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:10];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                // remove garbage data
                if (error) {
                    SAFE_PERFORM_SELECTOR_WITH_OBJECT(self.delegate, @selector(requestFailedWithError:), error);
                    return;
                }
                if ('.' == (char)((const char *)data.bytes)[data.length-1]) {
                    data = [data subdataWithRange:NSMakeRange(0, data.length-1)];
                }
                NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if ([jsonStr hasPrefix:GARBAGE_RESULT_VALUE]) {
                    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:GARBAGE_RESULT_VALUE withString:@""];
                }
                NSLog(@"voice jsonStr = %@",jsonStr);
                
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]
                                                                       options:NSJSONReadingAllowFragments
                                                                         error:nil];
                NSMutableArray *translates = nil;
                if (result) {
                    NSArray *results = result[@"result"];
                    if (results && 0 < results.count) {
                        NSArray *translatedInfos = results[0][@"alternative"];
                        if (translatedInfos && 0 < translatedInfos.count) {
                            translates = [NSMutableArray arrayWithCapacity:translatedInfos.count];
                            for (NSDictionary *translateInfo in translatedInfos) {
                                [translates addObject:translateInfo];
                            }
                        }
                    }
                }
                if (translates) {
                    SAFE_PERFORM_SELECTOR_WITH_OBJECT(self.delegate, @selector(didReceiveVoiceResponse:), [translates objectAtIndex:0]);
                } else {
                    SAFE_PERFORM_SELECTOR_WITH_OBJECT(self.delegate, @selector(didReceiveVoiceResponse:), nil);
                }
                
            }] resume];
}

@end
