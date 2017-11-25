//
//  ViewController.m
//  IQAgent
//
//  Created by IanFan on 2016/9/13.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    NSTimeInterval _launchTimeInterval;//App開啟時間
    
    BOOL _isRecording;//正在錄音
    
    int _inputType;//0:一般，1:哈拉，2:點餐...，由IQAgent提供清單，使用者可選擇。（暫定為0）
    NSString *_questionStr;//使用者問的問題
    NSString *_answerStr;//電腦人回答的答案
    
    ContentItem *_contentItem;//電腦人回答的item
}

@end

@implementation ViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _launchTimeInterval = [[NSDate date] timeIntervalSince1970];
    
    //Default
    [self updateDefault];
    
    //Agent
    [self getAgentFacade];
    //    [self agentDiagnosis];
    
    //SpeakToText
    [self getSpeechToTextFacade];
    [self speechToTextDelegateUpdateServiceBySetting];
    
    //TextToSpeech
    [self getTextToSpeechFacade];
    
    //Layout
    [self getLayoutFacade];
    [self layoutDelegateUpdateLayoutServiceBySetting];
    
    //Rechability
    [self getReachabilityFacade];
    
    //Test
    [self test];
    
    [[IQLog sharedInstance] logLaunchTimeWithPeriodSec:[[NSDate date] timeIntervalSince1970] - _launchTimeInterval];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    NSLog(@"didReceiveMemoryWarning: %@",NSStringFromClass([self class]));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[IQLog sharedInstance] logScreenName:NSStringFromClass([self class])];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self speechToTextStopRecording];
}

#pragma mark Default

- (void)updateDefault {
    _inputType = 0;
}

#pragma mark - Test

- (void)test {
    //Layout
//    [self performSelector:@selector(testLayoutUpdateLayout1) withObject:nil afterDelay:3.0];
//    [self performSelector:@selector(testLayoutUpdateLayout2) withObject:nil afterDelay:6.0];
    
    //Agent
//    [self performSelector:@selector(testAgentQuestion1) withObject:nil afterDelay:3.0];
//    [self performSelector:@selector(testAgentQuestion2) withObject:nil afterDelay:6.0];
//    [self performSelector:@selector(testAgentSatisfaction1) withObject:nil afterDelay:3.0];
//    [self performSelector:@selector(testAgentSatisfaction2) withObject:nil afterDelay:6.0];
}

#pragma mark Layout

- (void)testLayoutUpdateLayout1 {
    [_layoutFacade updateLayoutViewControllerWithService:Layout_Service_Demo];
}

- (void)testLayoutUpdateLayout2 {
    [_layoutFacade updateLayoutViewControllerWithService:Layout_Service_Chat];
}

#pragma mark Agent

- (void)testAgentQuestion1 {
    NSString *str = @"火車台北到高雄";
    [self agentQuestionWithQuestion:str];
    [self uiAgentQuestionWithQuestion:str];
}

- (void)testAgentQuestion2 {
    NSString *str = @"說一個笑話";
    [self agentQuestionWithQuestion:str];
    [self uiAgentQuestionWithQuestion:str];
}

- (void)testAgentSatisfaction1 {
    [self agentSatisfactionWithQuestion:@"你好" answer:@"你好!" satisfaction:1];
}

- (void)testAgentSatisfaction2 {
    [self agentSatisfactionWithQuestion:@"中華電信的股票多少錢" answer:@"您想查詢哪一支股票呢?" satisfaction:0];
}

#pragma mark - Reachability

#pragma mark Delegate

- (void)reachabilityDelegateWithNetStatus:(NetworkStatus)netStatus {
    switch (netStatus) {
        case NotReachable:
        {
            NSLog(@"Internet Not Reachable");
            [IQAlert showAlertView:ALERTVIEW_InternetOffline superVC:self];
        }
            break;
            
        case ReachableViaWWAN:
        case ReachableViaWiFi:
        {
            NSLog(@"Internet Reachable");
            
            if (![self isGotNecessaryData]) {
                [self agentAllTpyes];//要AllTypes與SessionID
            }
        }
            break;
            
        default:
            NSLog(@"error reachabilityDelegateWithNetStatus: %d",(int)netStatus);
            break;
    }
}

#pragma mark Factory

- (ReachabilityFacade *)getReachabilityFacade {
    if (!_reachabilityFacade) {
        ReachabilityFacade *facade = [[ReachabilityFacade alloc] init];
        facade.delegate = self;
        [facade startReachability];
        _reachabilityFacade = facade;
    }
    return _reachabilityFacade;
}

#pragma mark - Layout

#pragma mark Command

- (void)layoutUpdateService:(Layout_Service)service {
    [_layoutFacade updateLayoutViewControllerWithService:service];
}

#pragma mark Delegate

- (void)layoutDelegateSpeakButtonTapped {
    [self speechToTextSpeakButtonTapped];
}

- (void)layoutDelegateSpeakButtonBegin {
    [self speechToTextStartRecording];
}

- (void)layoutDelegateSpeakButtonEnd {
    [self speechToTextStopRecording];
}

- (void)layoutDelegateSpeakButtonCancel {
    [self speechToTextCancelRecording];
}

- (void)layoutDelegateQuestionText:(NSString *)text {
    [self speechToTextDelegateResultText:text];
}

- (void)layoutDelegateUpdateLayoutServiceBySetting {
    [_layoutFacade updateLayoutViewControllerServiceBySetting];
}

- (void)layoutDelegateUpdateSpeechToTextServiceBySetting {
    [_speechToTextFacade updateSpeechToTextServiceBySetting];
}

- (void)layoutDelegateUpdateSpeechToTextSpeakButton {
    [_layoutFacade updateLayoutSpeakButton];
}

#pragma mark Factory
//LayoutFacade *
- (void)getLayoutFacade {
    if (!_layoutFacade) {
        LayoutFacade *facade = [[LayoutFacade alloc] initWithSuperVC:self];
        facade.delegate = self;
        _layoutFacade = facade;
    }
    //return _layoutFacade;
}

#pragma mark - SpeechToText

#pragma mark Command

- (void)speechToTextSpeakButtonTapped {
    if (_isRecording == NO) {
        [self speechToTextStartRecording];
    } else {
        [self speechToTextStopRecording];
    }
}

- (void)speechToTextStartRecording {
    if (_isRecording == NO) {
        _isRecording = YES;
        
        [_textToSpeechFacade stopSpeech];
        
        [self uiSpeechToTextStartRecording];
        
        [_speechToTextFacade performSelector:@selector(startRecording) withObject:nil afterDelay:0.15];
        //[_speechToTextFacade startRecording];
    }
}

- (void)speechToTextStopRecording {
    if (_isRecording) {
        _isRecording = NO;
        
        [_speechToTextFacade stopRecording];
        
        [self uiSpeechToTextStopRecording];
    }
}

- (void)speechToTextCancelRecording {
    if (_isRecording) {
        [_speechToTextFacade cancelRecording];
        
        [self uiSpeechToTextCancelRecording];
        
        _isRecording = NO;
    }
}

#pragma mark UI

- (void)uiSpeechToTextStartRecording {
    [_layoutFacade uiStartRecording];
}

- (void)uiSpeechToTextStopRecording {
    [_layoutFacade uiStopRecording];
}

- (void)uiSpeechToTextCancelRecording {
    [_layoutFacade uiCancelRecording];
}

#pragma mark Delegate

- (void)speechToTextDelegateUpdateServiceBySetting {
    [_speechToTextFacade updateSpeechToTextServiceBySetting];
}

- (void)speechToTextDelegateStopRecording {
    if (_isRecording) {
        [self speechToTextStopRecording];
    }
}

//實作
- (void)speechToTextDelegateResultText:(NSString *)text {
    if (text.length == 0) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:@"請您再說一次"];
        [array addObject:@"對不起，我沒聽懂"];
        [array addObject:@"抱歉，我沒聽清楚"];
        [array addObject:@"抱歉，我不確定你說什麼"];
        [array addObject:@"我不確定你剛說什麼"];
        [array addObject:@"我不太確定你說了什麼"];
        [array addObject:@"我不太明白你的意思"];
        
        int random = arc4random()%array.count;
        text = [array objectAtIndex:random];
        
        [self textToSpeechWithText:text];
        [self uiTextToSpeechWithText:text];
    } else {
        [self agentQuestionWithQuestion:text]; //啟動agent
        [self uiAgentQuestionWithQuestion:text];//啟動 ui 的變更
    }
}

- (void)speechToTextDelegateInternetOffline {
    [IQAlert showAlertView:ALERTVIEW_InternetOffline superVC:self];
}

#pragma mark Factory

- (SpeechToTextFacade *)getSpeechToTextFacade {
    if (!_speechToTextFacade) {
        SpeechToTextFacade *facade = [[SpeechToTextFacade alloc] init];
        facade.delegate = self;
        _speechToTextFacade = facade;
    }
    return _speechToTextFacade;
}

#pragma mark - Agent

#pragma mark Command

- (void)agentUpdateInputType:(int)inputType {
    _inputType = inputType;
}

- (void)agentDiagnosis {
    [_agentFacade connectDiagnosis];
}

- (void)agentAllTpyes {
    [_agentFacade connectAllTypes];
}

- (void)agentQuestionWithQuestion:(NSString *)questionStr {
    _questionStr = questionStr;
    
//    [_agentFacade connectAskQuestion:questionStr intputType:_inputType];
    [_agentFacade connectAskPolyResults:questionStr intputType:_inputType];
}

- (void)agentSatisfactionWithQuestion:(NSString *)questionStr answer:(NSString *)answerStr satisfaction:(int)satisfactionInt {
    [_agentFacade connectSatisficationWithQuestion:questionStr answer:answerStr satisfation:satisfactionInt];
}

#pragma mark UI

- (void)uiAgentQuestionWithQuestion:(NSString *)questionStr {
    [_layoutFacade uiAgentQuestionWithQuestion:questionStr];
}

#pragma mark Delegate

- (void)agentFacadeDelegateContentItem:(ContentItem *)item {
    _contentItem = item;
    
    switch (item.agent.service) {
        case Agent_Service_Diagnosis:
        {
            
        }
            break;
            
        case Agent_Service_AllTypes:
        {
            
        }
            break;
            
        case Agent_Service_AskQuestion:
        {
            [self uiLayoutWithContentItem:item];
            
            [self textToSpeechWithText:item.agent.speakContent];
        }
            break;
            
        case Agent_Service_AskPolyResults: //鐵路的資料查詢
        {
            [self uiLayoutWithContentItem:item];
            
            [self textToSpeechWithText:item.agent.speakContent];
        }
            break;
            
        case Agent_Service_Satisfaction:
        {
            
        }
            break;
            
        default:
            NSLog(@"error agentFacadeDelegateResultItem");
            break;
    }
}

- (void)agentFacadeDelegateInternetOffline {
    [IQAlert showAlertView:ALERTVIEW_InternetOffline superVC:self];
}

#pragma mark Factory

- (AgentFacade *)getAgentFacade {
    if (!_agentFacade) {
        AgentFacade *facade = [[AgentFacade alloc] init];
        facade.delegate = self;
        _agentFacade = facade;
    }
    return _agentFacade;
}

#pragma mark Info

- (BOOL)isGotNecessaryData {
    return [_agentFacade isGotNecessaryData];
}

#pragma mark - TextToSpeech

#pragma mark Command

- (void)textToSpeechWithText:(NSString *)text {
    if (!_isRecording) {
        [_textToSpeechFacade textToSpeechWithText:text];
    }
}

#pragma mark UI

- (void)uiLayoutWithContentItem:(ContentItem *)item {
    [_layoutFacade uiLayoutWithContentItem:item];
}

- (void)uiTextToSpeechWithText:(NSString *)text {
    [_layoutFacade uiTextToSpeechWithText:text];
}

- (void)uiTextToSpeechWithText:(NSString *)text characterRange:(NSRange)range {
    [_layoutFacade uiTextToSpeechWithText:text characterRange:range];
}

#pragma mark Delegate

- (void)textToSpeechFacadeDelegateStartSpeakText:(NSString *)text {
        //[self textToSpeechUIWithText:text];
}

- (void)textToSpeechFacadeDelegateSpeakText:(NSString *)text characterRange:(NSRange)range {
    //    [self textToSpeechUIWithText:text characterRange:range];
}

- (void)textToSpeechFacadeDelegateEndSpeakText:(NSString *)text {
    //    [self textToSpeechUIWithText:text];
}

#pragma mark Factory

- (TextToSpeechFacade *)getTextToSpeechFacade {
    if (!_textToSpeechFacade) {
        TextToSpeechFacade *facade = [[TextToSpeechFacade alloc] init];
        facade.delegate = self;
        _textToSpeechFacade = facade;
    }
    return _textToSpeechFacade;
}

@end
