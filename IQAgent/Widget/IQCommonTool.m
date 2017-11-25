//
//  IQCommonTool.m
//  IQAgent
//
//  Created by IanFan on 2016/10/3.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "IQCommonTool.h"

//DeviceModel
#import <sys/utsname.h>

//IP Address
#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation IQCommonTool

+ (BOOL)isiPhoneDevice {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? YES : NO);
}

+ (BOOL)isiPadDevice {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? YES : NO);
}

+ (BOOL)isPortrait {
    return ([IQCommonTool getScreenWidth] < [IQCommonTool getScreenHeight]) ? YES : NO;
}

+ (UIInterfaceOrientation)getInterfaceOrientation {
    return [IQCommonTool isPortrait]? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft;
}

+ (CGFloat)getScreenWidth {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    return screenRect.size.width;
}

+ (CGFloat)getScreenHeight {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    return screenRect.size.height;
}

+ (CGFloat)getStatusBarHeight {
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    return MIN(statusBarSize.width, statusBarSize.height);
}

+ (CGFloat)getNavigationBarHeightWithViewController:(UIViewController *)viewController {
    return viewController.navigationController.navigationBar.frame.size.height;
}

+ (CGFloat)getTabBarHeightWithViewController:(UIViewController *)viewController {
    return viewController.tabBarController.tabBar.frame.size.height;
}

+ (double)getiOSVersion
{
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    return version;
}

+ (NSString *)getVersion
{
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    return version;
}

+ (NSString *)getAppVersion
{
    NSString *version = @"App Version: ";
    version = [version stringByAppendingString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]];
    return version;
}

+ (NSString *)getAppBuild
{
    NSString *build = @"App Build: ";
    build = [build stringByAppendingString:[[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey]];
    return build;
}

+ (NSString *)getDeviceModel {
    NSString *deviceType;
    struct utsname systemInfo;
    uname(&systemInfo);
    deviceType = [NSString stringWithCString:systemInfo.machine
                                    encoding:NSUTF8StringEncoding];
    return [IQCommonTool deviceType:deviceType];
}

+ (NSString *)getDeviceName {
    NSString *deviceName = [[UIDevice currentDevice] name];
//    NSLog(@"User Device Name = %@", deviceName);
    return deviceName;
}

+ (NSString *)getIPAddress {
    NSString *address = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
//    NSLog(@"IP Address = %@",address);
    return address;
}

+ (NSString *)getAppDownloadLink
{
    return @"http://bit.ly/iqqiios";
}

+ (void)openOfficialWebsite {
    NSString *str = @"http://www.ibo.ai";
    NSURL *url = [NSURL URLWithString:str];
    [[UIApplication sharedApplication] openURL:url];
}

+ (void)openEmailFeedback {
    //example:
    //    NSString *recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
    //    NSString *body = @"&body=It is raining in sunny California!";
    NSString *emailAddress = @"iqqi.ios@iq-t.com";
    NSString *title = IQLocalizedString(@"[iOS] iBo.ai 問題與建議", nil);
    NSMutableString *content = [[NSMutableString alloc] init];
    [content appendString:@"\n"];
    [content appendString:@"--------------------"];
    [content appendString:@"\n"];
    [content appendString:[NSString stringWithFormat:@"iOS Version: %f",[IQCommonTool getiOSVersion]]];
    [content appendString:@"\n"];
    [content appendString:[IQCommonTool getAppVersion]];
    [content appendString:@"\n"];
    [content appendString:[IQCommonTool getAppBuild]];
    [content appendString:@"\n"];
    [content appendString:[IQCommonTool getDeviceModel]];
    [content appendString:@"\n"];
    [content appendString:@"--------------------"];
    
    NSString *recipients = [NSString stringWithFormat:@"mailto:%@?",emailAddress];
    NSString *subject = [NSString stringWithFormat:@"subject=%@",title];
    NSString *body = [NSString stringWithFormat:@"&body=%@",content];
    
    NSMutableString *email = [[NSMutableString alloc] init];
    [email appendString:recipients];
    [email appendString:subject];
    [email appendString:body];
    
    NSString *emailStr = [NSString stringWithFormat:@"%@",email];
    emailStr = [emailStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailStr]];
    
    //記錄 Log
    [[IQLog sharedInstance] logFeedbackSuggestion:nil];
}

+ (void)openEmailCooperation {
    NSString *emailAddress = @"bd@iq-t.com";
    NSString *title = IQLocalizedString(@"[iOS] iBo.ai 合作提案", nil);
    
    NSString *recipients = [NSString stringWithFormat:@"mailto:%@?",emailAddress];
    NSString *subject = [NSString stringWithFormat:@"subject=%@",title];
    
    NSMutableString *email = [[NSMutableString alloc] init];
    [email appendString:recipients];
    [email appendString:subject];
    
    NSString *emailStr = [NSString stringWithFormat:@"%@",email];
    emailStr = [emailStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailStr]];
}

+ (void)openAppStoreRate {
    NSString *str = @"itms-apps://itunes.apple.com/app/id1156839184";
    NSURL *url = [NSURL URLWithString:str];
    [[UIApplication sharedApplication] openURL:url];
}

+ (void)openSettingsApp {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL: url];
}

+ (void)openPhoneCall:(NSString *)phoneNumber {
    //    phoneNumber = [NSString stringWithFormat:@"tel://%@",phoneNumber];
    phoneNumber = [@"telprompt://" stringByAppendingString:phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

+ (void)openEmail:(NSString *)emailAddress {
    emailAddress = (emailAddress.length > 0)? emailAddress : @"";
    
    NSString *title = @"";
    NSString *content = @"";
    
    NSString *recipients = [NSString stringWithFormat:@"mailto:%@?",emailAddress];
    NSString *subject = [NSString stringWithFormat:@"subject=%@",title];
    NSString *body = [NSString stringWithFormat:@"&body=%@",content];
    
    NSMutableString *email = [[NSMutableString alloc] init];
    [email appendString:recipients];
    [email appendString:subject];
    [email appendString:body];
    
    NSString *emailStr = [NSString stringWithFormat:@"%@",email];
    emailStr = [emailStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailStr]];
}

+ (void)openWebsite:(NSString *)urlStr {
    //urlStr格式可為：
    //googleMap搜尋地名 @"http://maps.google.com/maps?q=London";
    //googleMap搜尋附近商家（需英文） @"https://www.google.com.tw/maps/search/McDonald";
    
    if (urlStr.length == 0) {
        return;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}

+ (NSString *) deviceType:(NSString *)deviceType
{
    if ([deviceType isEqualToString:@"iPhone1,1"])         return @"iPhone 1G";
    else if ([deviceType isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    else if ([deviceType isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    else if ([deviceType isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    else if ([deviceType isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    else if ([deviceType isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    else if ([deviceType isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    else if ([deviceType isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    else if ([deviceType isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    else if ([deviceType isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    else if ([deviceType isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    else if ([deviceType isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    else if ([deviceType isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    else if ([deviceType isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    else if ([deviceType isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    else if ([deviceType isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    else if ([deviceType isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    else if ([deviceType isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    else if ([deviceType isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    else if ([deviceType isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    else if ([deviceType isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    else if ([deviceType isEqualToString:@"iPad1,1"])      return @"iPad";
    else if ([deviceType isEqualToString:@"iPad2,1"])      return @"iPad 2 (Welse ifi)";
    else if ([deviceType isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    else if ([deviceType isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    else if ([deviceType isEqualToString:@"iPad2,4"])      return @"iPad 2 (Welse ifi)";
    else if ([deviceType isEqualToString:@"iPad2,5"])      return @"iPad Mini (Welse ifi)";
    else if ([deviceType isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    else if ([deviceType isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    else if ([deviceType isEqualToString:@"iPad3,1"])      return @"iPad 3 (Welse ifi)";
    else if ([deviceType isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    else if ([deviceType isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    else if ([deviceType isEqualToString:@"iPad3,4"])      return @"iPad 4 (Welse ifi)";
    else if ([deviceType isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    else if ([deviceType isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    else if ([deviceType isEqualToString:@"iPad4,1"])      return @"iPad Air (Welse ifi)";
    else if ([deviceType isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    else if ([deviceType isEqualToString:@"iPad4,3"])      return @"iPad Air";
    else if ([deviceType isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G (Welse ifi)";
    else if ([deviceType isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G (Cellular)";
    else if ([deviceType isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G";
    else if ([deviceType isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (Welse ifi)";
    else if ([deviceType isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Cellular)";
    else if ([deviceType isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (China)";
    else if ([deviceType isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (Welse ifi)";
    else if ([deviceType isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    else if ([deviceType isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2G";
    else if ([deviceType isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
    else if ([deviceType isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3 (2013)";
    else if ([deviceType isEqualToString:@"i386"])         return @"Simulator";
    else if ([deviceType isEqualToString:@"x86_64"])       return @"Simulator";
    return deviceType;
}

#pragma mark - Log

+ (void)logFrameWithView:(UIView *)view logString:(NSString *)logStr {
    NSLog(@"%@ = %f, %f, %f, %f",logStr,view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
}

+ (void)logColorWithColor:(UIColor *)color logString:(NSString *)logStr {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    NSLog(@"%@ = %f, %f, %f, %f",logStr,components[0],components[1],components[2],components[3]);
}

static CGFloat timeInterval = 0;
static CGFloat lastTimeInterval = 0;

+ (void)logTimeCountStart {
    NSLog(@"計時開始");
    timeInterval = [[NSDate date] timeIntervalSince1970];
    lastTimeInterval = timeInterval;
}

+ (void)logTimeCountFromLast:(NSString *)name {
    NSLog(@"計時間隔%0.3f秒 %@",[[NSDate date] timeIntervalSince1970] - lastTimeInterval, name);
    lastTimeInterval = [[NSDate date] timeIntervalSince1970];
}

+ (void)logTimeCountTotal {
    NSLog(@"計時總共%0.3f秒",[[NSDate date] timeIntervalSince1970] - timeInterval);
}

@end
