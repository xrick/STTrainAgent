//
//  IQCommonTool.h
//  IQAgent
//
//  Created by IanFan on 2016/10/3.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IQCommonTool : NSObject

+ (BOOL)isiPhoneDevice;
+ (BOOL)isiPadDevice;
+ (BOOL)isPortrait;
+ (UIInterfaceOrientation)getInterfaceOrientation;

+ (CGFloat)getScreenWidth;
+ (CGFloat)getScreenHeight;
+ (CGFloat)getStatusBarHeight;
+ (CGFloat)getNavigationBarHeightWithViewController:(UIViewController *)viewController;
+ (CGFloat)getTabBarHeightWithViewController:(UIViewController *)viewController;

+ (double)getiOSVersion;
+ (NSString *)getVersion;
+ (NSString *)getAppVersion;
+ (NSString *)getAppBuild;
+ (NSString *)getDeviceModel;
+ (NSString *)getDeviceName;
+ (NSString *)getIPAddress;

+ (NSString *)getAppDownloadLink;

//Open:
+ (void)openOfficialWebsite;
+ (void)openEmailFeedback;
+ (void)openEmailCooperation;
+ (void)openAppStoreRate;
+ (void)openSettingsApp;
+ (void)openPhoneCall:(NSString *)phoneNumber;
+ (void)openEmail:(NSString *)emailAddress;
+ (void)openWebsite:(NSString *)urlStr;

//NSLog:
+ (void)logFrameWithView:(UIView *)view logString:(NSString *)logStr;
+ (void)logColorWithColor:(UIColor *)color logString:(NSString *)logStr;

+ (void)logTimeCountStart;
+ (void)logTimeCountFromLast:(NSString *)name;
+ (void)logTimeCountTotal;

@end
