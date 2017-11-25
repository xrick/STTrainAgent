//
//  IQAlert.h
//  IQAgent
//
//  Created by IanFan on 2016/10/14.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ALERTVIEW_TYPE) {
    ALERTVIEW_None                       = 0,
    ALERTVIEW_InternetOffline               ,
};

@interface IQAlert : NSObject

+ (void)showAlertView:(ALERTVIEW_TYPE)type superVC:(UIViewController *)superVC;

@end
