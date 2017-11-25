//
//  URLSessionModel.m
//  IQAgent
//
//  Created by IanFan on 2016/9/29.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "URLSessionModel.h"

@interface URLSessionModel()<NSURLSessionDelegate, NSURLSessionDownloadDelegate>
@property (strong, nonatomic) NSString *urlStr;
@property NSInteger progressInt;
@end

@implementation URLSessionModel

#pragma mark - Command

- (void)connectToServerWithUrlStr:(NSString *)urlStr {
    _urlStr = urlStr;
    NSLog(@"urlStr = %@", urlStr);
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *inProcessSession = [NSURLSession sessionWithConfiguration:sessionConfig
                                                                   delegate:self
                                                              delegateQueue:nil];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLSessionDownloadTask *Task = [inProcessSession downloadTaskWithURL:url];
    [Task resume];
}

#pragma mark - Session

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    //    NSLog(@"totalBytesWritten = %d",(int)totalBytesWritten);
    //    NSLog(@"totalBytesExpectedToWrite   = %d",(int)totalBytesExpectedToWrite);
    
    double currentProgress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    
    //有時 totalBytesExpectedToWrite 為 -1
    if (totalBytesExpectedToWrite == -1) {
        currentProgress = 0.5;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _progressInt = (NSInteger)(currentProgress * 100);
        //        NSLog(@"_progressInt = %d",(int)_progressInt);
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSString *jsonStr = [[NSString alloc] initWithContentsOfFile:location.path encoding:NSUTF8StringEncoding error:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _progressInt = 100;
        
        if ([self.delegate respondsToSelector:@selector(urlSessionModelDelegateJsonStr:urlStr:)]) {
            [self.delegate urlSessionModelDelegateJsonStr:jsonStr urlStr:_urlStr];
        }
    });
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error != nil) {
        NSLog(@"didCompleteWithError: %@",error);
                
        if (error.code == -1009) {
            if ([self.delegate respondsToSelector:@selector(urlSessionModelDelegateInternetOffline)]) {
                [self.delegate urlSessionModelDelegateInternetOffline];
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _progressInt = 0;
    });
}

@end
