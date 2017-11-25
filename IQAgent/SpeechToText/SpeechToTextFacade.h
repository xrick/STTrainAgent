//
//  SpeechToTextFacade.h
//  IQAgent
//
//  Created by IanFan on 2016/9/19.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SPEECH_TO_TEXT_COUNTRY_CODE @"zh-TW"

//僅選擇一項服務
#define SPEECH_TO_TEXT_SERVICE_APPLE //使用Apple服務(支援iOS 10+)
//#define SPEECH_TO_TEXT_SERVICE_GOOGLE //使用Google服務

typedef NS_ENUM(NSInteger, SpeechToText_Service) {
    SpeechToText_Service_Apple       = 0,
    SpeechToText_Service_Google         ,
};

@protocol SpeechToTextDelegate;

@interface SpeechToTextFacade : NSObject
@property (assign, nonatomic) id<SpeechToTextDelegate> delegate;
@property (assign, nonatomic) SpeechToText_Service service;
- (void)updateSpeechToTextServiceBySetting;
- (void)updateWithService:(SpeechToText_Service)service;
- (void)startRecording;//開始錄音
- (void)stopRecording;//停止錄音
- (void)cancelRecording;//取消錄音
@end

@protocol SpeechToTextDelegate <NSObject>
- (void)speechToTextDelegateStopRecording;
- (void)speechToTextDelegateResultText:(NSString *)text;
- (void)speechToTextDelegateInternetOffline;
@end
