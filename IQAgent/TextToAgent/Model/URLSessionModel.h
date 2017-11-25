//
//  URLSessionModel.h
//  IQAgent
//
//  Created by IanFan on 2016/9/29.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol URLSessionModelDelegate;

@interface URLSessionModel : NSObject
@property (assign, nonatomic) id<URLSessionModelDelegate> delegate;
- (void)connectToServerWithUrlStr:(NSString *)urlStr;
@end

@protocol URLSessionModelDelegate <NSObject>
- (void)urlSessionModelDelegateJsonStr:(NSString *)jsonStr urlStr:(NSString *)urlStr;
- (void)urlSessionModelDelegateInternetOffline;
@end
