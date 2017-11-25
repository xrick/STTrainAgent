//
//  IQSound.m
//  IQAgent
//
//  Created by IanFan on 2016/10/4.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "IQSound.h"
#import <AudioToolbox/AudioToolbox.h>
#import "SoundManager.h"

#define NSUSER_DEFAULTS_SOUND_DICTIONARY  @"userDefaults_soundDictionary"

#define NSUSER_DEFAULTS_SOUND_ID  @"userDefaults_soundID"

#define DEFAULT_SOUND_ID @"0015"

@interface SoundCell : NSObject
@property NSString *soundName;
@end

@implementation SoundCell
- (instancetype)initWithFileName:(NSString *)fileName {
    self = [super init];
    if (self) {
        _soundName = fileName;
    }
    return self;
}
@end


#pragma mark -
#pragma mark - SoundSingleton

@interface IQSound()
@property (retain, nonatomic) NSMutableDictionary *soundDic;
@end

@implementation IQSound

#pragma mark - LifeCycle

+ (IQSound*)sharedInstance {
    static IQSound *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[IQSound alloc] init];
    });
    return shared;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _soundDic = [self loadSoundDic];
        
        [SoundManager sharedManager].allowsBackgroundMusic = YES;
    }
    return self;
}

#pragma mark - Vibration

- (void)playVibration {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

#pragma mark - Sound

#pragma mark Sound Dictionary

- (NSMutableDictionary *)loadSoundDic {
    NSMutableDictionary *dict = [SoundInfo getDefaultSoundDic];
    return dict;
}

- (void)reloadSoundkDic {
    self.soundDic = [self loadSoundDic];
}

#pragma mark Play Sound

- (BOOL)shouldPlayKeySound {
    return YES;
}

- (void)playKeySound {
    if (![self shouldPlayKeySound]) {
        return;
    }
    
    [self playKeySoundBySoundID];
}

- (void)playKeySoundBySoundID {
    NSString *soundID = [[NSUserDefaults standardUserDefaults] objectForKey:NSUSER_DEFAULTS_SOUND_ID];
    if (soundID.length == 0) {
        soundID = DEFAULT_SOUND_ID;
    }
    
    [self playKeySoundWithSoundID:soundID];
}

- (void)playKeySoundWithSoundID:(NSString *)soundID {
//    if (![IQQISetting sharedInstance].ITEM_KEYSOUND.bDEFAULT) {
//        return;
//    }
    
    SoundItem *item = [self getSoundItemWithsoundID:soundID];
    if (item == nil) {
        item = [self.soundDic objectForKey:DEFAULT_SOUND_ID];
        NSLog(@"error playKeySoundWithSoundID = %@",soundID);
    }
    
    NSString *fileName = item.FILE_NAME;
    [self playKeySoundWithFileName:fileName];
}

- (void)playKeySoundWithFileName:(NSString *)fileName {
    if (fileName.length > 0) {
        [SoundManager sharedManager].soundVolume = 100.0;
        [[SoundManager sharedManager] playSound:fileName looping:NO];
    }
    else {
        NSLog(@"error playKeySoundWithFileName: %@",fileName);
    }
}

#pragma mark Select Sound

- (void)selectKeySoundWithSoundID:(NSString *)soundID {
    if (![self isSoundItemExistWithSoundID:soundID]) {
        soundID = DEFAULT_SOUND_ID;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:soundID forKey:NSUSER_DEFAULTS_SOUND_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[IQLog sharedInstance] logSoundPickSound:[self getSoundNameWithSoundID:soundID]];
}

#pragma mark Info

- (SoundItem *)getSoundItemWithsoundID:(NSString *)soundID {
    SoundItem *item = [self.soundDic objectForKey:soundID];
    return item;
}

- (NSString *)getSoundNameWithSoundID:(NSString *)soundID {
    SoundItem *item = [self getSoundItemWithsoundID:soundID];
    
    if (item != nil) {
        NSString *soundName = item.NAME;
        if (soundName.length > 0) {
            return soundName;
        }
        else {
            return item.ID;
        }
    }
    
    NSLog(@"error getSoundNameWithSoundID = %@",soundID);
    return nil;
}

- (NSInteger)getSoundsCount {
    return self.soundDic.count;
}

- (BOOL)isSelectedKeySoundWithSoundID:(NSString *)soundID {
    NSString *savedSoundID = [[NSUserDefaults standardUserDefaults] objectForKey:NSUSER_DEFAULTS_SOUND_ID];
    if ([soundID isEqualToString: savedSoundID]) {
        return YES;
    }
    return NO;
}

- (BOOL)isSoundItemExistWithSoundID:(NSString *)soundID {
    SoundItem *item = [self.soundDic objectForKey:soundID];
    if (item) {
        return YES;
    }
    return NO;
}

@end
