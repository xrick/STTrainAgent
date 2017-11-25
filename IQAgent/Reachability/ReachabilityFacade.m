//
//  ReachabilityFacade.m
//  IQAgent
//
//  Created by IanFan on 2016/10/28.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "ReachabilityFacade.h"

@interface ReachabilityFacade ()
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@end

@implementation ReachabilityFacade

#pragma mark - LifeCycle

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

#pragma mark - Reachability

- (void)startReachability {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    //Change the host name here to change the server you want to monitor.
    
    {
        //        NSString *remoteHostName = @"www.apple.com";
        //        self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
        //        [self.hostReachability startNotifier];
        //        [self updateInterfaceWithReachability:self.hostReachability];
    }
    
    {
        self.internetReachability = [Reachability reachabilityForInternetConnection];
        [self.internetReachability startNotifier];
        [self updateInterfaceWithReachability:self.internetReachability];
    }
}

- (void) reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability {
    
    if (reachability == self.hostReachability) {
        [self configureWithReachability:reachability];
        
        BOOL connectionRequired = [reachability connectionRequired];
        
        if (connectionRequired) {
            NSLog(@"Cellular data network is available.\nInternet traffic will be routed through it after a connection is established.");
        }
        else {
            NSLog(@"Cellular data network is active.\nInternet traffic will be routed through it.");
        }
    }
    
    if (reachability == self.internetReachability) {
        [self configureWithReachability:reachability];
    }
}

- (void)configureWithReachability:(Reachability *)reachability {
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    
    BOOL connectionRequired = [reachability connectionRequired];
    
    switch (netStatus) {
        case NotReachable: {
            connectionRequired = NO;
            break;
        }
        
        case ReachableViaWWAN:
            break;
        case ReachableViaWiFi:
            break;
        default:
            NSLog(@"configureWithReachability = %d",(int)netStatus);
            break;
    }
    
    if (connectionRequired) {
        NSLog(@"Connection Required");
    }
    
    if ([self.delegate respondsToSelector:@selector(reachabilityDelegateWithNetStatus:)]) {
        [self.delegate reachabilityDelegateWithNetStatus:netStatus];
    }
}

@end
