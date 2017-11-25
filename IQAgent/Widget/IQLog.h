//
//  IQLog.h
//  IQAgent
//
//  Created by IanFan on 2016/10/3.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import <Foundation/Foundation.h>

//測試模式
//#warning Mark before release
//#define LOG_TEST_MODE

//一般資訊
#define APPLE_ID @"1156839184"//Apple Store ID

//GA
#define GOOGLE_TRACKING_ID       @"UA-85118205-1"
#define GOOGLE_TRACKING_ID_TEST  @"UA-85118205-2"

@interface IQLog : NSObject

+ (IQLog *)sharedInstance;

//開始連線:
- (void)startSession;//Project一啟動就從主執行緒呼叫

//開啟速度:
- (void)logLaunchTimeWithPeriodSec:(float)periodSec;

//問答:
- (void)logAskQuestionWithInputType:(NSString *)inputTypeStr question:(NSString *)questionStr answer:(NSString *)answerStr;

//滿意:
- (void)logSatisfactionWithSatisfaction:(NSString *)satisfactionStr question:(NSString *)questionStr answer:(NSString *)answerStr;

//音效:
- (void)logSoundPickSound:(NSString *)sound;

//追蹤畫面:
- (void)logScreenName:(NSString *)screenName;//埋在每個ViewController的-(void)viewWillAppear:(BOOL)animated

//廣告:
- (void)logAdClickBanner:(NSString *)adSource screenName:(NSString *)screenName;
- (void)logAdClickInterstitial:(NSString *)adSource screenName:(NSString *)screenName;
- (void)logAdClickNative:(NSString *)adSource screenName:(NSString *)screenName;

//回饋:
- (void)logFeedbackRate:(NSString *)str;//評分
- (void)logFeedbackSuggestion:(NSString *)str;//建議

//IAP商品:
//- (void)logIapClick:(NSInteger)productEnum;
//- (void)logIapPurchased:(NSInteger)productEnum;

//手動發送:
- (void)pauseDispatchLog;
- (void)autoDispatchLog;
- (void)manualDispatchLog;

@end
