//
//  IQSetting.h
//  IQAgent
//
//  Created by IanFan on 2016/12/12.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import <Foundation/Foundation.h>

//#warning Mark before release
//#define ACADEMIA_SINICA_DEMO //中研院Demo模式，TINA

@interface SettingItem : NSObject
@property (nonatomic, retain)  NSString *key;
@property (nonatomic, assign) BOOL bDefault;
@property (nonatomic, assign) NSInteger iDefault;
@end

@interface IQSetting : NSObject
@property (nonatomic, assign) BOOL isEdited;
@property (nonatomic, retain) SettingItem *ITEM_ASR_SERVICE;
@property (nonatomic, retain) SettingItem *ITEM_ASR_TAP;
@property (nonatomic, retain) SettingItem *ITEM_TTS_SERVICE;
@property (nonatomic, retain) SettingItem *ITEM_TTS_VOLUME;
@property (nonatomic, retain) SettingItem *ITEM_TTS_SPEED;
@property (nonatomic, retain) SettingItem *ITEM_TTS_PITCH;
@property (nonatomic, retain) SettingItem *ITEM_LAYOUT_SERVICE;
+ (IQSetting *)sharedInstance;
- (NSString *)convertUserNameBySettingWithStr:(NSString *)str;
@end
