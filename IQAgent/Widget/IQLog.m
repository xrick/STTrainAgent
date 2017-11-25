//
//  IQLog.m
//  IQAgent
//
//  Created by IanFan on 2016/10/3.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "IQLog.h"
#import "GAITracker.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
//#import "IQQIAppIAP.h"
#import "IQCommonTool.h"

static NSString *const kTrackingPreferenceKey = @"allowTracking";
static BOOL const kGaDryRun = NO;
static BOOL const kTrackUncaughtExceptions = YES;
static int const kGaDispatchPeriod = 120;

#define TAP_ACTION @"點擊"

@interface IQLog()
@end

@implementation IQLog

+ (IQLog *)sharedInstance {
    static IQLog *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[IQLog alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
    }
    
    return self;
}

#pragma mark - Connection

- (void)startSession {
    //GA
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = kTrackUncaughtExceptions;  // report uncaught exceptions
    //    gai.logger.logLevel = kGAILogLevelNone;  // remove before app release
    gai.dispatchInterval = kGaDispatchPeriod;//週期發出資訊，預設120，0需要手動發送
    gai.dryRun = kGaDryRun;//測試用，不會向GA發出任何數據，預設關閉
    
    //其它設定
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker setAllowIDFACollection:YES];// 啟用 IDFA 收集功能
    //    [tracker set:kGAISampleRate value:@"50.0"];//如果使用者過多，採抽樣50%，預設100%
    //    [tracker set:kGAIAnonymizeIp value:@"1"];//匿名化處理由SDK發送的IP資訊
    
#ifdef LOG_TEST_MODE
    [[GAI sharedInstance] trackerWithTrackingId:GOOGLE_TRACKING_ID_TEST];
#endif
    
#ifndef LOG_TEST_MODE
    [[GAI sharedInstance] trackerWithTrackingId:GOOGLE_TRACKING_ID];
#endif
}

#pragma mark - LaunchTime

- (void)logLaunchTimeWithPeriodSec:(float)periodSec {
    if (periodSec < 0) {
        NSLog(@"error logLaunchTimeWithPeriodSec = %f",periodSec);
        return;
    }
    else {
        NSLog(@"開啟速度: %.2f秒",periodSec);
    }
    
    NSString *deviceModel = [IQCommonTool getDeviceModel];
    
    NSString *category = @"開啟速度";
    NSString *action   = [NSString stringWithFormat:@"%@",deviceModel];
    NSString *label    = [NSString stringWithFormat:@"%@:%.2f秒", deviceModel, periodSec];
    
    [self logGaEventWithCategory:category
                          action:action
                           label:label
                           value:nil
     ];
}

#pragma mark - AskQuestion

- (void)logAskQuestionWithInputType:(NSString *)inputTypeStr question:(NSString *)questionStr answer:(NSString *)answerStr {
    NSString *category = @"問答";
    NSString *action   = [NSString stringWithFormat:@"%@",inputTypeStr];
    
    NSString *label = [NSString stringWithFormat:@"%@/%@/%@", inputTypeStr, questionStr, answerStr];
    
    [self logGaEventWithCategory:category
                          action:action
                           label:label
                           value:nil
     ];
}

#pragma mark - Satisfaction

- (void)logSatisfactionWithSatisfaction:(NSString *)satisfactionStr question:(NSString *)questionStr answer:(NSString *)answerStr {
    NSString *category = @"滿意";
    NSString *action   = [NSString stringWithFormat:@"%@",satisfactionStr];
    
    NSString *label = [NSString stringWithFormat:@"%@/%@/%@", satisfactionStr, questionStr, answerStr];
    
    [self logGaEventWithCategory:category
                          action:action
                           label:label
                           value:nil
     ];
}

#pragma mark - Sound

- (void)logSoundPickSound:(NSString *)sound {
    NSString *category = @"音效";
    NSString *action   = @"選擇音效";
    NSString *label = [NSString stringWithFormat:@"%@",sound];
    
    [self logGaEventWithCategory:category
                          action:action
                           label:label
                           value:nil
     ];
}

#pragma mark - 追蹤畫面

- (void)logScreenName:(NSString *)screenName {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - 廣告

- (void)logAdClickBanner:(NSString *)adSource screenName:(NSString *)screenName {
    [self logAdClickWithType:@"橫幅" sourceName:adSource screenName:screenName];
}

- (void)logAdClickInterstitial:(NSString *)adSource screenName:(NSString *)screenName {
    [self logAdClickWithType:@"插頁" sourceName:adSource screenName:screenName];
}

- (void)logAdClickNative:(NSString *)adSource screenName:(NSString *)screenName {
    [self logAdClickWithType:@"原生" sourceName:adSource screenName:screenName];
}

- (void)logAdClickWithType:(NSString *)typeName sourceName:(NSString *)sourceName screenName:(NSString *)screenName {
    NSString *category = @"廣告";
    NSString *action   = typeName;
    NSString *label = [NSString stringWithFormat:@"%@:位置%@,來源%@",@"點擊", screenName, typeName];
    label = (sourceName && ![sourceName isEqualToString:@"null"])? [NSString stringWithFormat:@"%@%@",label,sourceName] : label;
    
    [self logGaEventWithCategory:category
                          action:action
                           label:label
                           value:nil
     ];
}

#pragma mark - IAP商品

/*
 - (void)logIapClick:(NSInteger)productEnum {
 NSString *category = @"商品";
 NSString *action   = @"點擊";
 NSString *productID = [[IQQIAppIAP sharedInstance] getProductIdentifier:productEnum];
 NSString *label = [NSString stringWithFormat:@"點擊:%@",productID];
 
 [self logGaEventWithCategory:category
 action:action
 label:label
 value:nil
 ];
 }
 
 - (void)logIapPurchased:(NSInteger)productEnum {
 NSString *category = @"商品";
 NSString *action   = @"購買";
 NSString *productID = [[IQQIAppIAP sharedInstance] getProductIdentifier:productEnum];
 NSString *label = [NSString stringWithFormat:@"購買:%@",productID];
 
 [self logGaEventWithCategory:category
 action:action
 label:label
 value:nil
 ];
 }
 */

#pragma mark - 回饋

- (void)logFeedbackRate:(NSString *)str {
    NSString *category = @"回饋";
    NSString *action   = @"評分";
    NSString *label = (!str || [str isEqualToString:@""])? @"評分" : [NSString stringWithFormat:@"%@",str];
    
    [self logGaEventWithCategory:category
                          action:action
                           label:label
                           value:nil
     ];
}

- (void)logFeedbackSuggestion:(NSString *)str {
    NSString *category = @"回饋";
    NSString *action   = @"建議";
    NSString *label = (!str || [str isEqualToString:@""])? @"建議" : [NSString stringWithFormat:@"%@",str];
    
    [self logGaEventWithCategory:category
                          action:action
                           label:label
                           value:nil
     ];
}

#pragma mark - 手動發送

- (void)pauseDispatchLog {
    [GAI sharedInstance].dispatchInterval = 0;
}

- (void)autoDispatchLog {
    [GAI sharedInstance].dispatchInterval = kGaDispatchPeriod;
}

- (void)manualDispatchLog {
    [[GAI sharedInstance] dispatch];
}

#pragma mark - GA Methods

- (void)logGaEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category    //事件類別 NSString（必填）
                                                          action:action      //事件操作 NSString（必填）
                                                           label:label       //事件標籤 NSString（選填）
                                                           value:value       //事件數值 NSNumber（選填）
                    ] build]];
}

- (void)logGaTimeWithCategory:(NSString *)category interval:(NSTimeInterval)interval name:(NSString *)name label:(NSString *)label {
    NSNumber *intervalNum = [NSNumber numberWithInteger:(interval * 1000)];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:category    // 時間類別 NSString（必填）
                                                         interval:intervalNum // 時間間隔 NSNumber（必填）
                                                             name:name        // 時間名稱 NSString（選填）
                                                            label:label       // 時間標籤 NSString（選填）
                    ] build]];
}

@end
