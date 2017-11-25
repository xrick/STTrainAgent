//
//  ReachabilityFacade.h
//  IQAgent
//
//  Created by IanFan on 2016/10/28.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@protocol ReachabilityDelegate;

@interface ReachabilityFacade : NSObject
@property (assign, nonatomic) id<ReachabilityDelegate> delegate;
- (void)startReachability;//開始偵測網路狀態
@end

@protocol ReachabilityDelegate <NSObject>
- (void)reachabilityDelegateWithNetStatus:(NetworkStatus)netStatus;//只要網路狀態改變就通知
@end
