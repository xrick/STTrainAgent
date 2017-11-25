//
//  SoundInfo.h
//  IQAgent
//
//  Created by IanFan on 2016/10/4.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoundItem : NSObject

@property (nonatomic,copy) NSString *ID;//soundItem序號，補滿四位數，例如"0001"
@property (nonatomic,copy) NSString *NAME;//按鍵音效名稱
@property (nonatomic,copy) NSString *FILE_NAME;//按鍵音效檔名

+ (SoundItem *)copySoundItem:(SoundItem *)soundItem;

@end

@interface SoundInfo : NSObject

+ (NSMutableDictionary *)getDefaultSoundDic;

@end
