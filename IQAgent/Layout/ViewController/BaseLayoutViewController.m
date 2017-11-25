//
//  BaseLayoutViewController.m
//  IQAgent
//
//  Created by IanFan on 2016/10/5.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "BaseLayoutViewController.h"

@interface BaseLayoutViewController ()<SettingViewControllerDeleagte>
{
    BOOL _shouldUpdateLayout;
    BOOL _shouldUpdateSpeechToText;
    BOOL _shouldUpdateSpeakButton;
}
@end

@implementation BaseLayoutViewController

#pragma mark - LifeCycle

- (id)initWithFrame:(CGRect)frame {
    self  = [super init];
    if (self) {
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor whiteColor];
        
        [self getSettingBarButton];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    NSLog(@"didReceiveMemoryWarning: %@",NSStringFromClass([self class]));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_shouldUpdateLayout) {
        _shouldUpdateLayout = NO;
        if ([self.delegate respondsToSelector:@selector(layoutDelegateUpdateLayoutServiceBySetting)]) {
            [self.delegate layoutDelegateUpdateLayoutServiceBySetting];
        }
    }
    
    if (_shouldUpdateSpeechToText) {
        _shouldUpdateSpeechToText = NO;
        if ([self.delegate respondsToSelector:@selector(layoutDelegateUpdateSpeechToTextServiceBySetting)]) {
            [self.delegate layoutDelegateUpdateSpeechToTextServiceBySetting];
        }
    }
    
    if (_shouldUpdateSpeakButton) {
        _shouldUpdateSpeakButton = NO;
        if ([self.delegate respondsToSelector:@selector(layoutDelegateUpdateSpeechToTextSpeakButton)]) {
            [self.delegate layoutDelegateUpdateSpeechToTextSpeakButton];
        }
    }
    
    [[IQLog sharedInstance] logScreenName:NSStringFromClass([self class])];
}

- (void)getDefaultUI {
}

#pragma mark - Command

- (void)speechToTextButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(layoutDelegateSpeakButtonTapped)]) {
        [self.delegate layoutDelegateSpeakButtonTapped];
    }
}

#pragma mark - UI

#pragma mark SpeechToText

- (void)uiStartRecording {
}

- (void)uiStopRecording {
}

- (void)uiCancelRecording {
}

#pragma mark Agent

- (void)uiAgentQuestionWithQuestion:(NSString *)questionStr {
}

#pragma mark TextToSpeech

- (void)uiTextToSpeechWithText:(NSString *)text {
}

- (void)uiTextToSpeechWithText:(NSString *)text characterRange:(NSRange)range {
}

- (void)uiLayouthWithContentItem:(id)item {
}

#pragma mark - Setting

#pragma mark Command

- (void)settingTapped:(UIButton *)sender {
    SettingViewController *viewController = [[SettingViewController alloc] init];
    viewController.delegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark Delegate

- (void)settingViewControllerDeleagteUpdateLayout {
    _shouldUpdateLayout = YES;
}

- (void)settingViewControllerDeleagteUpdateSpeechToText {
    _shouldUpdateSpeechToText = YES;
}

- (void)settingViewControllerDeleagteUpdateSpeakButton {
    _shouldUpdateSpeakButton = YES;
}

#pragma mark - SpeakButton

- (void)updateSpeakButton {
}

#pragma mark - Factory

- (void)getSettingBarButton {
    UIImage *settingImage = [UIImage imageNamed:@"icon_setting.png"];
    CGRect settingFrame = CGRectMake(0, 0, 15, 15 );
    UIButton *settingsButton = [[UIButton alloc] initWithFrame:settingFrame];
    [settingsButton setBackgroundImage:settingImage forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(settingTapped:) forControlEvents:UIControlEventTouchUpInside];
    [settingsButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *settingButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    self.navigationItem.rightBarButtonItem = settingButtonItem;
}

@end
