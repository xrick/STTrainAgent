//
//  BaseLayoutViewController.h
//  IQAgent
//
//  Created by IanFan on 2016/10/5.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayoutDelegate.h"
#import "SettingViewController.h"

@interface BaseLayoutViewController : UIViewController
@property (assign, nonatomic) id<LayoutDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;
- (void)getDefaultUI;

//Command
- (void)speechToTextButtonTapped:(id)sender;

//SpeechToText
- (void)uiStartRecording;
- (void)uiStopRecording;
- (void)uiCancelRecording;

//Agent
- (void)uiAgentQuestionWithQuestion:(NSString *)questionStr;

//TextToSpeech
- (void)uiTextToSpeechWithText:(NSString *)text;
- (void)uiTextToSpeechWithText:(NSString *)text characterRange:(NSRange)range;

- (void)uiLayouthWithContentItem:(id)item;

//Setting
- (void)settingTapped:(UIButton *)sender;

//SpeakButton
- (void)updateSpeakButton;

@end
