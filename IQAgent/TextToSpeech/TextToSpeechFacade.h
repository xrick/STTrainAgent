//
//  TextToSpeechFacade.h
//  IQAgent
//
//  Created by IanFan on 2016/9/20.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TEXT_TO_SPEECH_COUNTRY_CODE @"zh-TW"

//僅選擇一項服務
#define TEXT_TO_SPEECH_SERVICE_APPLE  //使用Apple服務(支援iOS 10+)
//#define TEXT_TO_SPEECH_SERVICE_GOOGLE //使用Google服務

typedef NS_ENUM(NSInteger, TextToSpeech_Service) {
    TextToSpeech_Service_Apple       = 0,
    TextToSpeech_Service_Google         ,
};

@protocol TextToSpeechFacadeDelegate;

@interface TextToSpeechFacade : NSObject
@property (assign, nonatomic) id<TextToSpeechFacadeDelegate> delegate;
- (void)textToSpeechWithText:(NSString *)text;//朗讀文字
- (void)stopSpeech;//停止朗讀
@end

@protocol TextToSpeechFacadeDelegate <NSObject>
- (void)textToSpeechFacadeDelegateStartSpeakText:(NSString *)text;
- (void)textToSpeechFacadeDelegateSpeakText:(NSString *)text characterRange:(NSRange)range;
- (void)textToSpeechFacadeDelegateEndSpeakText:(NSString *)text;
@end
