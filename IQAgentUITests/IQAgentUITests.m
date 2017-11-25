//
//  IQAgentUITests.m
//  IQAgentUITests
//
//  Created by IanFan on 2016/12/2.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ViewController.h"

@interface IQAgentUITests : XCTestCase
{
    XCUIApplication *app;
    
    BOOL _isTextMode;
}
@end

@implementation IQAgentUITests

#pragma mark - LifeCycle

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    app = [[XCUIApplication alloc] init];
    [app launch];
    
    _isTextMode = NO;
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    [self testTextGreeting];
    
    [self testTextQuestion];
    
    [self testSpeakQuestion];
}

#pragma mark - SwitchTextAndSpeechMode

- (void)testSwitchToTextMode {
    if (_isTextMode == NO) {
        _isTextMode = YES;
        XCUIElement *btnChangeVoiceState = app.buttons[@"btnChangeVoiceState"];
        [btnChangeVoiceState tap];
    }
}

- (void)testSwitchToSpeechMode {
    if (_isTextMode == YES) {
        _isTextMode = NO;
        XCUIElement *btnChangeVoiceState = app.buttons[@"btnChangeVoiceState"];
        [btnChangeVoiceState tap];
    }
}

- (void)testRepeatSwitchModeQuickly {
    [self testSwitchToTextMode];
    [self testSwitchToSpeechMode];
    [self testSwitchToTextMode];
    
    [self testSwipeDownChatTableView];
    [self testSwitchToSpeechMode];
}

#pragma mark - Text

- (void)testTextGreeting {
    [self testSwitchToTextMode];
    
    XCUIElement *btnChangeVoiceState = app.buttons[@"btnChangeVoiceState"];
    XCUIElement *textViewInput = app.textViews[@"textViewInput"];
    
    [textViewInput tap];
    
    [textViewInput typeText:@"你好"];
    
    [btnChangeVoiceState tap];
    
    sleep(2);
}

- (void)testTextQuestion {
    [self testSwitchToTextMode];
    
    XCUIElement *btnChangeVoiceState = app.buttons[@"btnChangeVoiceState"];
    XCUIElement *textViewInput = app.textViews[@"textViewInput"];
    
    [textViewInput tap];
    
    [textViewInput typeText:@"你叫什麼名字"];
    
    [btnChangeVoiceState tap];
    
    sleep(2);
}

- (void)testRepeatTextQuestionQuickly {
    [self testSwitchToTextMode];
    
    XCUIElement *btnChangeVoiceState = app.buttons[@"btnChangeVoiceState"];
    XCUIElement *textViewInput = app.textViews[@"textViewInput"];
    
    [textViewInput tap];
    
    [textViewInput typeText:@"今天天氣如何？"];
    [btnChangeVoiceState tap];
    
    [textViewInput typeText:@"明天天氣如何？"];
    [btnChangeVoiceState tap];
    
    [self testSwipeDownChatTableView];
    
    [textViewInput tap];
    
    [textViewInput typeText:@"後天天氣如何？"];
    [btnChangeVoiceState tap];
    
    sleep(2);
}

#pragma mark - Speak

- (void)testSpeakQuestion {
    [self testSwitchToSpeechMode];
    
    XCUIElement *speakButton = app.buttons[@"speakButton"];
    [speakButton pressForDuration:3.0];
    
    sleep(3);
}

- (void)testRepeatSpeakQuestionQuickly {
    [self testSwitchToSpeechMode];
    
    XCUIElement *speakButton = app.buttons[@"speakButton"];
    [speakButton pressForDuration:1.5];
    [speakButton pressForDuration:1.0];
    [speakButton pressForDuration:0.1];
    [speakButton tap];
}

#pragma mark - ChatTableView

- (void)testSwipeDownChatTableView {
    XCUIElement *chatTableView = app.tables[@"chatTableView"];
    [chatTableView swipeDown];
}


@end
