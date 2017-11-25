//
//  SpeechToTextFacade.m
//  IQAgent
//
//  Created by IanFan on 2016/9/19.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "SpeechToTextFacade.h"
#import "SpeechToTextModel.h"

//Apple
#import <Speech/Speech.h>
#import <AVFoundation/AVFoundation.h>

#define GOOGLE_SPEECH_TO_TEXT_KEY @"AIzaSyAQzL96bL1SBjpBkYQcYPJUeJSsJuYN38I"//Ray1
//#define GOOGLE_SPEECH_TO_TEXT_KEY @"AIzaSyD4CGbaP3eHlfz03NszoQ9QdsEJa_EYTRM"//Ray2

@interface SpeechToTextFacade()<SpeechToTextModuleDelegate>  {
    BOOL _isRecording;
    
    //Apple服務
    //speech recognize
    SFSpeechRecognizer *_speechRecognizer;
    SFSpeechAudioBufferRecognitionRequest *_recognitionRequest;
    SFSpeechRecognitionTask *_recognitionTask;
    SFSpeechURLRecognitionRequest *_urlRequest;//
    //record speech using audio engine
    AVAudioInputNode *_inputNode;
    AVAudioEngine *_audioEngine;
    
    //Google服務
    //也偵測自動收音
    SpeechToTextModel *_speechToTextModel;
}
@end

@implementation SpeechToTextFacade

#pragma mark - LifeCycle

- (id)init {
    self  = [super init];
    if (self) {
        
#ifdef SPEECH_TO_TEXT_SERVICE_APPLE
        if ([IQCommonTool getiOSVersion] >= 10.0) {
            _service = [IQSetting sharedInstance].ITEM_ASR_SERVICE.iDefault;
        }
        else {
            _service = SpeechToText_Service_Google;
        }
#endif
        
#ifdef SPEECH_TO_TEXT_SERVICE_GOOGLE
        _service = SpeechToText_Service_Google;
#endif
    }
    return self;
}



- (void)dealloc {
    [self endService];
}

//設定使用何種Speech to Text 服務及設定 iOS上的Audio Session
- (void)updateSpeechToTextServiceBySetting {
    [self endService];
    
    switch ([IQSetting sharedInstance].ITEM_ASR_SERVICE.iDefault) {
        case 0: {
            if (_service != SpeechToText_Service_Google) {
                [self updateWithService:SpeechToText_Service_Apple];
            } else {
                [self updateWithService:SpeechToText_Service_Google];
            }
        }
            break;
        case 1: [self updateWithService:SpeechToText_Service_Google]; break;
        default: NSLog(@"error updateBySetting");break;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *configSessionError = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                  withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                        error:&configSessionError];
    if (configSessionError) {
        NSLog(@"configSessionError %ld", (long)[configSessionError code]);
    }
    [audioSession setActive:YES error:&configSessionError];
}

- (void)updateWithService:(SpeechToText_Service)service {
    _service = service;
    NSLog(@"SpeechToText服務: %@",[self getSpeechToTextServiceName:_service]);
    
    switch (_service) {
        case SpeechToText_Service_Apple:  [self appleInit];  break;
        case SpeechToText_Service_Google: [self googleInit]; break;
        default: NSLog(@"error SpeechToTextFacade init"); break;
    }
}

- (void)endService {
    switch (_service) {
        case SpeechToText_Service_Apple:  [self appleDealloc];  break;
        case SpeechToText_Service_Google: [self googleDealloc]; break;
        default: NSLog(@"error SpeechToTextFacade dealloc"); break;
    }
}

#pragma mark - Command

- (void)startRecording {
    if (_isRecording == NO) {
        _isRecording = YES;
        
        switch (_service) {
            case SpeechToText_Service_Apple:  [self appleStartRecording];  break;
            case SpeechToText_Service_Google: [self googleStartRecording]; break;
            default: NSLog(@"error SpeechToTextFacade startRecording"); break;
        }
    }
}

- (void)stopRecording {
    if (_isRecording) {
        switch (_service) {
            case SpeechToText_Service_Apple:  [self appleStopRecording];  break;
            case SpeechToText_Service_Google: [self googleStopRecording]; break;
            default: NSLog(@"error SpeechToTextFacade stopRecording"); break;
        }
        
        _isRecording = NO;
    }
}

- (void)cancelRecording {
    if (_isRecording) {
        switch (_service) {
            case SpeechToText_Service_Apple:  [self appleCancelRecording];  break;
            case SpeechToText_Service_Google: [self googleCancelRecording]; break;
            default: NSLog(@"error SpeechToTextFacade stopRecording"); break;
        }
        
        _isRecording = NO;
    }
}

#pragma mark - Service:

#pragma mark - Apple

- (void)appleInit {
    [self moduleInit];
    
    _audioEngine = [[AVAudioEngine alloc] init];
    
    //        for (NSLocale *locate in [SFSpeechRecognizer supportedLocales]) {
    //            NSLog(@"%@", [locate localizedStringForCountryCode:locate.countryCode]);
    //        }
    
    NSLocale *local = [[NSLocale alloc] initWithLocaleIdentifier:SPEECH_TO_TEXT_COUNTRY_CODE];
    _speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:local];
    
    // Check Authorization Status
    // Make sure you add "Privacy - Microphone Usage Description" key and reason in Info.plist to request micro permison
    // And "NSSpeechRecognitionUsageDescription" key for requesting Speech recognize permison
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case SFSpeechRecognizerAuthorizationStatusAuthorized: {
                    //user authorized
                }
                    break;
                case SFSpeechRecognizerAuthorizationStatusDenied:
                case SFSpeechRecognizerAuthorizationStatusRestricted:
                case SFSpeechRecognizerAuthorizationStatusNotDetermined: {
                }
                    break;
                default: {
                    NSLog(@"error SFSpeechRecognizer requestAuthorization");
                }
                    break;
            }
        });
        
    }];
}

- (void)appleDealloc {
    [self moduleDealloc];
    
    if (_recognitionTask) {
        [_recognitionTask cancel];
        _recognitionTask = nil;
    }
    
    if (_inputNode) {
        [_inputNode removeTapOnBus:0];
    }
    
    if (_audioEngine) {
        [_audioEngine stop];
    }
    
    if (_recognitionTask) {
        [_recognitionRequest endAudio];
    }
}

- (void)appleStartRecording {
    [self moduleStartRecording];
    
    if (_recognitionTask) {
        [_recognitionTask cancel];
        _recognitionTask = nil;
    }
    
    _inputNode = _audioEngine.inputNode;
    
    _recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    _recognitionRequest.shouldReportPartialResults = NO;
    //    recognitionRequest.detectMultipleUtterances = YES;
    AVAudioFormat *format = [_inputNode outputFormatForBus:0];
    
    [_inputNode installTapOnBus:0 bufferSize:1024 format:format block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [_recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    [_audioEngine prepare];
    NSError *audioEngineError;
    [_audioEngine startAndReturnError:&audioEngineError];
    
    if (audioEngineError) {
        NSLog(@"audioEngineError = %@", audioEngineError.description);
    }
}

- (void)appleStopRecording {
    [self moduleStopRecording];
    
    if (_audioEngine.isRunning) {
        _recognitionTask = [_speechRecognizer recognitionTaskWithRequest:_recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
            //            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (result != nil) {
                NSString *resultText = result.bestTranscription.formattedString;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //回傳resultText
                    if ([self.delegate respondsToSelector:@selector(speechToTextDelegateResultText:)]) {
                        NSLog(@"speechToText = %@",resultText);
                        [self.delegate speechToTextDelegateResultText:resultText];
                    }
                });
            }
            else {
                NSLog(@"error = %@",error);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //回傳resultText
                    if ([self.delegate respondsToSelector:@selector(speechToTextDelegateResultText:)]) {
                        [self.delegate speechToTextDelegateResultText:@""];
                    }
                });
                
            }
            
            [_audioEngine stop];
            [_recognitionTask cancel];
            _recognitionTask = nil;
            _recognitionRequest = nil;
        }];
        
        // make sure you release tap on bus else your app will crash the second time you record.
        [_inputNode removeTapOnBus:0];
        
        [_audioEngine stop];
        [_recognitionRequest endAudio];
    }
}

- (void)appleCancelRecording {
    [self moduleCancelRecording];
    
    if (_audioEngine.isRunning) {
        // make sure you release tap on bus else your app will crash the second time you record.
        [_inputNode removeTapOnBus:0];
        
        [_audioEngine stop];
        [_recognitionRequest endAudio];
        
        [_recognitionTask cancel];
        _recognitionTask = nil;
        _recognitionRequest = nil;
    }
}

#pragma mark - Google

- (void)googleInit {
    [self moduleInit];
}

- (void)googleDealloc {
    [self moduleDealloc];
}

- (void)googleStartRecording {
    [self moduleStartRecording];
}

- (void)googleStopRecording{
    [self moduleStopRecording];
}

- (void)googleCancelRecording{
    [self moduleCancelRecording];
}

#pragma mark - SpeechToTextModule

- (void)moduleInit {
    if (_speechToTextModel == nil) {
        _speechToTextModel = [[SpeechToTextModel alloc] initWithCustomDisplay:nil];
        _speechToTextModel.delegate = self;
    }
}

- (void)moduleDealloc {
    if (_speechToTextModel) {
        [self stopRecording];
//        _speechToTextModel = nil;
    }
}

- (void)moduleStartRecording {
    [_speechToTextModel beginRecording];
}

- (void)moduleStopRecording {
    [_speechToTextModel stopRecording:YES];
}

- (void)moduleCancelRecording {
    [_speechToTextModel stopRecording:NO];
}

#pragma mark SpeechToTextModuleDelegate

- (void)postVoiceData:(NSData *)data {
    switch (_service) {
        case SpeechToText_Service_Google:
        {
            NSString *urlStr = [NSString stringWithFormat:@"https://www.google.com/speech-api/v2/recognize?xjerr=1&maxresults=10&pFilter=0&output=json&&client=chromium&lang=%@&key=%@", SPEECH_TO_TEXT_COUNTRY_CODE,GOOGLE_SPEECH_TO_TEXT_KEY];
            [_speechToTextModel requestVoiceData:data urlStr:urlStr];
        }
            break;
            
        case SpeechToText_Service_Apple:
        default:
            if ([self.delegate respondsToSelector:@selector(speechToTextDelegateStopRecording)]) {
                [self.delegate speechToTextDelegateStopRecording];
            }
            break;
    }
}

- (BOOL)didReceiveVoiceResponse:(NSDictionary *)data {
    //    NSLog(@"didReceiveVoiceResponse %@",data);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(speechToTextDelegateStopRecording)]) {
            [self.delegate speechToTextDelegateStopRecording];
        }
        
        [self stopRecording];
    });
    
    NSString *resultText = @"";
    id tmp = data[@"transcript"];
    if ([tmp isKindOfClass:[NSNumber class]] || [tmp rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound) {
        // Spell out number
        // incase user spell number
        NSNumber *resultNumber = [NSNumber numberWithInteger:[tmp integerValue]];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterSpellOutStyle];
        resultText = [formatter stringFromNumber:resultNumber];
    } else {
        resultText = tmp;
    }
    
    float confidence = [data[@"confidence"] floatValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //回傳resultText與confidence
        if ([self.delegate respondsToSelector:@selector(speechToTextDelegateResultText:)]) {
            NSLog(@"speechToText: \"%@\", confidence: %f", resultText, confidence);
            [self.delegate speechToTextDelegateResultText:resultText];
        }
    });
    
    return YES;
}

- (void)requestFailedWithError:(NSError *)error {
    if (error != nil) {
        NSLog(@"requestFailedWithError: %@",error);
        
        if (error.code == -1009) {
            if ([self.delegate respondsToSelector:@selector(speechToTextDelegateInternetOffline)]) {
                [self.delegate speechToTextDelegateInternetOffline];
            }
        }
    }
}

#pragma mark - Info

- (NSString *)getSpeechToTextServiceName:(SpeechToText_Service)service {
    switch (service) {
        case SpeechToText_Service_Apple: return @"Apple";
        case SpeechToText_Service_Google: return @"Google";
        default: NSLog(@"error getSpeechToTextServiceName = %d",(int)service); return @"";
    }
}

@end
