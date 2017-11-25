//
//  LayoutFacade.h
//  IQAgent
//
//  Created by IanFan on 2016/10/5.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LayoutDelegate.h"
#import "BaseLayoutViewController.h"

typedef NS_ENUM(NSInteger, Layout_Service) {
    Layout_Service_Demo       = 0,
    Layout_Service_Chat          ,
    Layout_Service_Train         ,
};

@interface LayoutFacade : NSObject
@property (assign, nonatomic) id<LayoutDelegate> delegate;
@property (retain, nonatomic) BaseLayoutViewController *layoutViewController;
@property (assign, nonatomic) Layout_Service service;

//Init
- (id)initWithSuperVC:(UIViewController *)superVC;

//UpdateLayout
- (void)updateLayoutViewControllerWithService:(Layout_Service)service;
- (void)updateLayoutViewControllerServiceBySetting;
- (void)updateLayoutSpeakButton;

//SpeechToText
- (void)uiStartRecording;
- (void)uiStopRecording;
- (void)uiCancelRecording;

//Agent
- (void)uiAgentQuestionWithQuestion:(NSString *)questionStr;

//TextToSpeech
- (void)uiTextToSpeechWithText:(NSString *)text;
- (void)uiTextToSpeechWithText:(NSString *)text characterRange:(NSRange)range;

- (void)uiLayoutWithContentItem:(ContentItem *)item;

@end
