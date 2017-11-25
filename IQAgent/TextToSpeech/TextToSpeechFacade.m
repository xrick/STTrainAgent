//
//  TextToSpeechFacade.m
//  IQAgent
//
//  Created by IanFan on 2016/9/20.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "TextToSpeechFacade.h"

#import <AVFoundation/AVFoundation.h>

/*
 static NSString *BCP47LanguageCodeFromISO681LanguageCode(NSString *ISO681LanguageCode) {
 if ([ISO681LanguageCode isEqualToString:@"ar"]) {
 return @"ar-SA";
 } else if ([ISO681LanguageCode hasPrefix:@"cs"]) {
 return @"cs-CZ";
 } else if ([ISO681LanguageCode hasPrefix:@"da"]) {
 return @"da-DK";
 } else if ([ISO681LanguageCode hasPrefix:@"de"]) {
 return @"de-DE";
 } else if ([ISO681LanguageCode hasPrefix:@"el"]) {
 return @"el-GR";
 } else if ([ISO681LanguageCode hasPrefix:@"en"]) {
 return @"en-US"; // en-AU, en-GB, en-IE, en-ZA
 } else if ([ISO681LanguageCode hasPrefix:@"es"]) {
 return @"es-ES"; // es-MX
 } else if ([ISO681LanguageCode hasPrefix:@"fi"]) {
 return @"fi-FI";
 } else if ([ISO681LanguageCode hasPrefix:@"fr"]) {
 return @"fr-FR"; // fr-CA
 } else if ([ISO681LanguageCode hasPrefix:@"hi"]) {
 return @"hi-IN";
 } else if ([ISO681LanguageCode hasPrefix:@"hu"]) {
 return @"hu-HU";
 } else if ([ISO681LanguageCode hasPrefix:@"id"]) {
 return @"id-ID";
 } else if ([ISO681LanguageCode hasPrefix:@"it"]) {
 return @"it-IT";
 } else if ([ISO681LanguageCode hasPrefix:@"ja"]) {
 return @"ja-JP";
 } else if ([ISO681LanguageCode hasPrefix:@"ko"]) {
 return @"ko-KR";
 } else if ([ISO681LanguageCode hasPrefix:@"nl"]) {
 return @"nl-NL"; // nl-BE
 } else if ([ISO681LanguageCode hasPrefix:@"no"]) {
 return @"no-NO";
 } else if ([ISO681LanguageCode hasPrefix:@"pl"]) {
 return @"pl-PL";
 } else if ([ISO681LanguageCode hasPrefix:@"pt"]) {
 return @"pt-BR"; // pt-PT
 } else if ([ISO681LanguageCode hasPrefix:@"ro"]) {
 return @"ro-RO";
 } else if ([ISO681LanguageCode hasPrefix:@"ru"]) {
 return @"ru-RU";
 } else if ([ISO681LanguageCode hasPrefix:@"sk"]) {
 return @"sk-SK";
 } else if ([ISO681LanguageCode hasPrefix:@"sv"]) {
 return @"sv-SE";
 } else if ([ISO681LanguageCode hasPrefix:@"th"]) {
 return @"th-TH";
 } else if ([ISO681LanguageCode hasPrefix:@"tr"]) {
 return @"tr-TR";
 } else if ([ISO681LanguageCode hasPrefix:@"zh"]) {
 return @"zh-CN"; // zh-HK, zh-TW
 } else {
 return nil;
 }
 }
 
 static NSString * BCP47LanguageCodeForString(NSString *string) {
 NSString *ISO681LanguageCode = (__bridge NSString *)CFStringTokenizerCopyBestStringLanguage((__bridge CFStringRef)string, CFRangeMake(0, [string length]));
 return BCP47LanguageCodeFromISO681LanguageCode(ISO681LanguageCode);
 }
 
 typedef NS_ENUM(NSInteger, SpeechUtteranceLanguage) {
 Arabic,
 Chinese,
 Czech,
 Danish,
 Dutch,
 German,
 Greek,
 English,
 Finnish,
 French,
 Hindi,
 Hungarian,
 Indonesian,
 Italian,
 Japanese,
 Korean,
 Norwegian,
 Polish,
 Portuguese,
 Romanian,
 Russian,
 Slovak,
 Spanish,
 Swedish,
 Thai,
 Turkish,
 };
 
 NSString * const SpeechUtterancesByLanguage[] = {
 [Arabic]        = @"لَيْسَ حَيَّاً مَنْ لَا يَحْلُمْ",
 [Chinese]       = @"風向轉變時、\n有人築牆、有人造風車。\n\n风向转变时、\n有人筑墙、有人造风车。",
 [Czech]         = @"Kolik jazyků znáš, tolikrát jsi člověkem.",
 [Danish]        = @"Enhver er sin egen lykkes smed.",
 [Dutch]         = @"Wie zijn eigen tuintje wiedt, ziet het onkruid van een ander niet.",
 [German]        = @"Die beste Bildung findet ein gescheiter Mensch auf Reisen.",
 [Greek]         = @"Ἐν οἴνῳ ἀλήθεια",
 [English]       = @"All the world's a stage, and all the men and women merely players.",
 [Finnish]       = @"On vähäkin tyhjää parempi.",
 [French]        = @"Le plus grand faible des hommes, c'est l'amour qu'ils ont de la vie.",
 [Hindi]         = @"जान है तो जहान है",
 [Hungarian]     = @"Ki korán kel, aranyat lel|Aki korán kel, aranyat lel.",
 [Indonesian]    = @"Jadilah kumbang, hidup sekali di taman bunga, jangan jadi lalat, hidup sekali di bukit sampah.",
 [Italian]       = @"Finché c'è vita c'è speranza.",
 [Japanese]      = @"天に星、地に花、人に愛",
 [Korean]        = @"손바닥으로 하늘을 가리려한다",
 [Norwegian]     = @"D'er mange ǿksarhogg, som eiki skal fella.",
 [Polish]        = @"Co lekko przyszło, lekko pójdzie.",
 [Portuguese]    = @"É de pequenino que se torce o pepino.",
 [Romanian]      = @"Cine se scoală de dimineață, departe ajunge.",
 [Russian]       = @"Челове́к рожда́ется жить, а не гото́виться к жи́зни.",
 [Slovak]        = @"Každy je sám svôjho št'astia kováč.",
 [Spanish]       = @"La vida no es la que uno vivió, sino la que uno recuerda, y cómo la recuerda para contarla.",
 [Swedish]       = @"Verkligheten överträffar dikten.",
 [Thai]          = @"ความลับไม่มีในโลก",
 [Turkish]       = @"Al elmaya taş atan çok olur."
 };
 */

@interface TextToSpeechFacade()<AVSpeechSynthesizerDelegate> {
    TextToSpeech_Service _service;
    
    //Apple
    NSString *_utteranceString;
    AVSpeechSynthesizer *_speechSynthesizer;
}
//@property (readwrite, nonatomic, copy)
//@property (readwrite, nonatomic, strong) AVSpeechSynthesizer *speechSynthesizer;
@end

@implementation TextToSpeechFacade

#pragma mark LifeCycle

- (id)init {
    self = [super init];
    if (self) {
#ifdef SPEECH_TO_TEXT_SERVICE_APPLE
        _service = TextToSpeech_Service_Apple;
#endif
        
#ifdef SPEECH_TO_TEXT_SERVICE_GOOGLE
        _service = TextToSpeech_Service_Google;
#endif
        
        switch (_service) {
            case TextToSpeech_Service_Apple:  [self appleInit];  break;
            case TextToSpeech_Service_Google: [self googleInit]; break;
            default: NSLog(@"error TextToSpeechFacade init"); break;
        }
    }
    return self;
}

#pragma mark - Command

- (void)textToSpeechWithText:(NSString *)text {
    switch (_service) {
        case TextToSpeech_Service_Apple:  [self appleTextToSpeechWithText:text];  break;
        case TextToSpeech_Service_Google: [self googleTextToSpeechWithText:text]; break;
        default: NSLog(@"error TextToSpeechFacade textToSpeechWithText"); break;
    }
}

- (void)stopSpeech {
    switch (_service) {
        case TextToSpeech_Service_Apple:  [self appleStopSpeech];  break;
        case TextToSpeech_Service_Google: [self googleStopSpeech]; break;
        default: NSLog(@"error TextToSpeechFacade textToSpeechWithText"); break;
    }
}

#pragma mark - Service

#pragma mark - Apple

- (void)appleInit {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                     withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                                           error:nil];
    
    if (!_speechSynthesizer) {
        _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
        _speechSynthesizer.delegate = self;
    }
}

- (void)appleTextToSpeechWithText:(NSString *)text {
    [self appleStopSpeech];
    
    _utteranceString = text;
    
    //    NSMutableString *mutableString = [self.utteranceString mutableCopy];
    //    CFStringTransform((__bridge CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, NO);
    //    CFStringTransform((__bridge CFMutableStringRef)mutableString, NULL, kCFStringTransformStripCombiningMarks, NO);
    //    self.transliterationLabel.text = mutableString;
    
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:_utteranceString];
    //    NSLog(@"BCP-47 Language Code: %@", BCP47LanguageCodeForString(utterance.speechString));
    
    //    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:BCP47LanguageCodeForString(utterance.speechString)];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:TEXT_TO_SPEECH_COUNTRY_CODE];
    utterance.pitchMultiplier = (float)[IQSetting sharedInstance].ITEM_TTS_PITCH.iDefault/100.0;
    utterance.volume = (float)[IQSetting sharedInstance].ITEM_TTS_VOLUME.iDefault/100.0;
    switch ([IQSetting sharedInstance].ITEM_TTS_SPEED.iDefault) {
        case -1: utterance.rate = AVSpeechUtteranceMinimumSpeechRate; break;
        case  0: utterance.rate = AVSpeechUtteranceDefaultSpeechRate; break;
        case  1: utterance.rate = AVSpeechUtteranceMaximumSpeechRate; break;
        default:
            break;
    }
    utterance.preUtteranceDelay = 0.2f;
    utterance.postUtteranceDelay = 0.2f;
    
    [_speechSynthesizer speakUtterance:utterance];
}

- (void)appleStopSpeech {
    if (_speechSynthesizer.isSpeaking) {
                [_speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
//        [_speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryWord];
    }
}

#pragma mark AVSpeechSynthesizerDelegate

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance
{
    //    NSLog(@"%@ %@", [self class], NSStringFromSelector(_cmd));
    if ([self.delegate respondsToSelector:@selector(textToSpeechFacadeDelegateStartSpeakText:)]) {
        [self.delegate textToSpeechFacadeDelegateStartSpeakText:utterance.speechString];
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance
{
    //    NSLog(@"%@ %@", [self class], NSStringFromSelector(_cmd));
    if ([self.delegate respondsToSelector:@selector(textToSpeechFacadeDelegateSpeakText:characterRange:)]) {
        [self.delegate textToSpeechFacadeDelegateSpeakText:utterance.speechString characterRange:characterRange];
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    //    NSLog(@"%@ %@", [self class], NSStringFromSelector(_cmd));
    if ([self.delegate respondsToSelector:@selector(textToSpeechFacadeDelegateEndSpeakText:)]) {
        [self.delegate textToSpeechFacadeDelegateEndSpeakText:utterance.speechString];
    }
}

#pragma mark - Google

- (void)googleInit {
    
}

- (void)googleTextToSpeechWithText:(NSString *)text {
    
}

- (void)googleStopSpeech {
    
}

@end
