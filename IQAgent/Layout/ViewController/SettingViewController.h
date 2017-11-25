//
//  SettingViewController.h
//  IQAgent
//
//  Created by IanFan on 2016/12/12.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingViewControllerDeleagte;

@interface SettingViewController : UIViewController
@property (assign, nonatomic) id<SettingViewControllerDeleagte> delegate;
@end

@protocol SettingViewControllerDeleagte <NSObject>
- (void)settingViewControllerDeleagteUpdateLayout;
- (void)settingViewControllerDeleagteUpdateSpeechToText;
- (void)settingViewControllerDeleagteUpdateSpeakButton;
@end
