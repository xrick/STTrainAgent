//
//  LayoutDelegate.h
//  IQAgent
//
//  Created by IanFan on 2016/10/5.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LayoutDelegate <NSObject>

//LayoutViewController
- (void)layoutDelegateSpeakButtonTapped;
- (void)layoutDelegateSpeakButtonBegin;
- (void)layoutDelegateSpeakButtonEnd;
- (void)layoutDelegateSpeakButtonCancel;
- (void)layoutDelegateQuestionText:(NSString *)text;
- (void)layoutDelegateUpdateLayoutServiceBySetting;
- (void)layoutDelegateUpdateSpeechToTextServiceBySetting;
- (void)layoutDelegateUpdateSpeechToTextSpeakButton;
@end
