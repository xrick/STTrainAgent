//
//  DemoLayoutViewController.m
//  IQAgent
//
//  Created by IanFan on 2016/10/5.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "DemoLayoutViewController.h"
//widget
#import "IQSound.h"
//category
#import "UIImage+animatedGIF.h"

@interface DemoLayoutViewController () {
    UIButton *_speakButton;
    UIImageView *_speakAnimationImageView;
    UITextView *_agentTextView;
    UITextView *_userTextView;
}
@end

@implementation DemoLayoutViewController

#pragma mark - LifeCycle

- (id)initWithFrame:(CGRect)frame {
    self  = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)getDefaultUI {
    [self getNavigationBar];
    
    [self getSpeakButton];
    [self getSpeakAnimationImageView];
    
    [self getAgentTextView];
    [self getUserTextView];
}

#pragma mark - Command

#pragma mark - UI

#pragma mark SpeechToText

- (void)uiStartRecording {
    [[IQSound sharedInstance] playKeySound];
    //    [[IQSound sharedInstance] playVibration];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"recording_animate" withExtension:@"gif"];
    _speakAnimationImageView.image = [UIImage animatedImageWithAnimatedGIFURL:url];
    _speakAnimationImageView.hidden = NO;
}

- (void)uiStopRecording {
    [[IQSound sharedInstance] playKeySound];
    //    [[IQSound sharedInstance] playVibration];
    
    //    [_speakButton setImage:[UIImage imageNamed:@"mic-gray"] forState:UIControlStateNormal];
    _speakAnimationImageView.hidden = YES;
}

- (void)uiCancelRecording {
    [[IQSound sharedInstance] playKeySound];
    
    _speakAnimationImageView.hidden = YES;
}

#pragma mark Agent

- (void)uiAgentQuestionWithQuestion:(NSString *)questionStr {
    questionStr = [NSString stringWithFormat:@"「%@」", questionStr];
    _userTextView.text = questionStr;
}

#pragma mark Agent

- (void)uiTextToSpeechWithText:(NSString *)text {
    _agentTextView.text = text;
}

- (void)uiTextToSpeechWithText:(NSString *)text characterRange:(NSRange)range {
    if (range.length == 0) {
        _agentTextView.text = text;
    }
    else {
        NSMutableAttributedString *mutableAttributedStr = [[NSMutableAttributedString alloc] initWithString:text];
        [mutableAttributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:24.0] range:NSMakeRange(0, mutableAttributedStr.length)];
        [mutableAttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
        _agentTextView.attributedText = mutableAttributedStr;
    }
}

#pragma mark - Factory

- (void)getNavigationBar {
    self.navigationItem.hidesBackButton = YES;
}

- (UIButton *)getSpeakButton {
    if (!_speakButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"mic-gray"];
        [button setImage:image forState:UIControlStateNormal];
        UIImage *hightlightedImage = [UIImage imageNamed:@"mic-white"];
        [button setImage:hightlightedImage forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(speechToTextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
        _speakButton = button;
        _speakButton.frame = CGRectMake(0, 0, 100, 100);
        _speakButton.center = CGPointMake(self.view.center.x, self.view.frame.size.height - 100);
    }
    return _speakButton;
}

- (UIImageView *)getSpeakAnimationImageView {
    if (!_speakAnimationImageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.view addSubview:imageView];
        
        _speakAnimationImageView = imageView;
        _speakAnimationImageView.frame = CGRectMake(0, 0, 165, 165);
        _speakAnimationImageView.center = _speakButton.center;
        [self.view bringSubviewToFront:_speakButton];
    }
    return _speakAnimationImageView;
}

- (UITextView *)getAgentTextView {
    if (!_agentTextView) {
        UITextView *textView = [[UITextView alloc] init];
        textView.userInteractionEnabled = NO;
        textView.font = [UIFont systemFontOfSize:24.0];
        [self.view addSubview:textView];
        
        _agentTextView = textView;
        _agentTextView.frame = CGRectMake(10, 64+160, self.view.frame.size.width-20, 150);
    }
    return _agentTextView;
}

- (UITextView *)getUserTextView {
    if (!_userTextView) {
        UITextView *textView = [[UITextView alloc] init];
        textView.userInteractionEnabled = NO;
        textView.font = [UIFont systemFontOfSize:24.0];
        [textView setTextAlignment:NSTextAlignmentRight];
        [self.view addSubview:textView];
        
        _userTextView = textView;
        _userTextView.frame = CGRectMake(10, 64+10, self.view.frame.size.width-20, 150);
    }
    return _userTextView;
}

@end
