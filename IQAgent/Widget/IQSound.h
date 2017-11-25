//
//  IQSound.h
//  IQAgent
//
//  Created by IanFan on 2016/10/4.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoundInfo.h"

@interface IQSound : NSObject

+ (IQSound *)sharedInstance;

//playVibration
- (void)playVibration;

//playSound
- (void)playKeySound;
- (void)playKeySoundWithSoundID:(NSString *)soundID;

//change
- (void)selectKeySoundWithSoundID:(NSString *)soundID;

//info
- (SoundItem *)getSoundItemWithsoundID:(NSString *)soundID;
- (NSString *)getSoundNameWithSoundID:(NSString *)soundID;
- (BOOL)isSelectedKeySoundWithSoundID:(NSString *)soundID;
- (NSInteger)getSoundsCount;

@end
