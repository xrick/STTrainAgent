//
//  IQAlert.m
//  IQAgent
//
//  Created by IanFan on 2016/10/14.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "IQAlert.h"

@implementation IQAlert

+ (void)showAlertView:(ALERTVIEW_TYPE)type superVC:(UIViewController *)superVC {
    NSString *title = @"";
    NSString *message = nil;
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    switch (type) {
        case ALERTVIEW_InternetOffline:
        {
            title = IQLocalizedString(@"沒有網路", nil);
            message = IQLocalizedString(@"請檢查網路連線", nil);
            
            UIAlertAction *action = [UIAlertAction
                                     actionWithTitle:IQLocalizedString(@"確定", nil)
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                     }];
            [actions addObject:action];
        }
            break;
            
        default:
            NSLog(@"error IQAlert showAlertView");
            break;
    }
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    for (int i=0; i<actions.count; i++) {
        UIAlertAction *action = [actions objectAtIndex:i];
        [alert addAction:action];
    }
    
    [superVC presentViewController:alert animated:YES completion:nil];
}

@end
