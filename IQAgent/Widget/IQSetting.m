//
//  IQSetting.m
//  IQAgent
//
//  Created by IanFan on 2016/12/12.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "IQSetting.h"

#define KEY_ASR_SERVICE @"KEY_ASR_SERVICE"
#define KEY_ASR_TAP @"KEY_ASR_TAP"
#define KEY_TTS_SERVICE @"KEY_TTS_SERVICE"
#define KEY_TTS_VOLUME @"KEY_TTS_VOLUME"
#define KEY_TTS_SPEED @"KEY_TTS_SPEED"
#define KEY_TTS_PITCH @"KEY_TTS_PITCH"
#define KEY_LAYOUT_SERVICE @"KEY_LAYOUT_SERVICE"

static BOOL isSettingInit = true;

@implementation SettingItem
@synthesize bDefault = _bDefault;
@synthesize iDefault = _iDefault;

- (void)setIDefault:(NSInteger)iDefault {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    _iDefault = iDefault;
    
    if (!isSettingInit) {
        [userDefaults setInteger:iDefault forKey:_key];
    }
}

- (NSInteger)iDefault {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (!isSettingInit) {
        if ([userDefaults objectForKey:_key] != nil) {
            return [userDefaults integerForKey:_key];
        }
    }
    
    return _iDefault;
}

- (void)setBDEFAULT:(BOOL)bDEFAULT {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    _bDefault = bDEFAULT;
    
    if (!isSettingInit) {
        [userDefaults setBool:bDEFAULT forKey:_key];
    }
}

- (BOOL)bDEFAULT {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (!isSettingInit) {
        if ([userDefaults objectForKey:_key] != nil) {
            return [userDefaults boolForKey:_key];
        }
    }
    
    return _bDefault;
}

@end


@implementation IQSetting

+ (IQSetting *)sharedInstance {
    static id shared = nil;
    if (shared == nil) {
        shared = [[IQSetting alloc] init];
    }
    return shared;
}

- (instancetype)init {
    isSettingInit = true;
    
    self = [super init];
    if (self) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        //語音辨識:
        //服務
        _ITEM_ASR_SERVICE = [SettingItem new];
        _ITEM_ASR_SERVICE.key             = KEY_ASR_SERVICE;
        _ITEM_ASR_SERVICE.iDefault        = 0; //0:Apple,1:Google
        //發話（錄音）模式
        _ITEM_ASR_TAP = [SettingItem new];
        _ITEM_ASR_TAP.key                 = KEY_ASR_TAP;
        _ITEM_ASR_TAP.iDefault            = 0; //0:點擊說話,1:按住說話
        
        //TTS:
        //服務
        _ITEM_TTS_SERVICE = [SettingItem new];
        _ITEM_TTS_SERVICE.key             = KEY_TTS_SERVICE;
        _ITEM_TTS_SERVICE.iDefault        = 0; //0:Apple,1:Google
        //聲音大小
        _ITEM_TTS_VOLUME = [SettingItem new];
        _ITEM_TTS_VOLUME.key              = KEY_TTS_VOLUME;
        _ITEM_TTS_VOLUME.iDefault         = 100; //0~100
        //語速
        _ITEM_TTS_SPEED = [SettingItem new];
        _ITEM_TTS_SPEED.key               = KEY_TTS_SPEED;
        _ITEM_TTS_SPEED.iDefault          = 0; //-1:慢,0:一般,1:快
        //音調
        _ITEM_TTS_PITCH = [SettingItem new];
        _ITEM_TTS_PITCH.key               = KEY_TTS_PITCH;
        _ITEM_TTS_PITCH.iDefault          = 100; //20~200 (低~高)
        
        //版本:
        _ITEM_LAYOUT_SERVICE = [SettingItem new];
        _ITEM_LAYOUT_SERVICE.key         = KEY_LAYOUT_SERVICE;
        _ITEM_LAYOUT_SERVICE.iDefault    = 0; //0:火車來了沒,1:客服
        
        //註冊需要保存記錄的設定項目 (頻率優先暫時先不加入初始)
        NSDictionary *SettingsList = @{
                                       _ITEM_ASR_SERVICE.key: @(_ITEM_ASR_SERVICE.iDefault),
                                       _ITEM_ASR_TAP.key: @(_ITEM_ASR_TAP.iDefault),
                                       _ITEM_TTS_SERVICE.key: @(_ITEM_TTS_SERVICE.iDefault),
                                       _ITEM_TTS_VOLUME.key: @(_ITEM_TTS_VOLUME.iDefault),
                                       _ITEM_TTS_SPEED.key: @(_ITEM_TTS_SPEED.iDefault),
                                       _ITEM_TTS_PITCH.key: @(_ITEM_TTS_PITCH.iDefault),
                                       _ITEM_LAYOUT_SERVICE.key: @(_ITEM_LAYOUT_SERVICE.iDefault),
                                       };
        
        [userDefaults registerDefaults:SettingsList];
        
        isSettingInit = false;
    }
    return self;
}

- (NSString *)convertUserNameBySettingWithStr:(NSString *)str {
    switch ([IQSetting sharedInstance].ITEM_LAYOUT_SERVICE.iDefault) {
        case 0:
            str = [str stringByReplacingOccurrencesOfString:@"Vicky" withString:@"BoBo"];
            break;
        case 1:
            str = [str stringByReplacingOccurrencesOfString:@"BoBo" withString:@"Vicky"];
            break;
        default:
            break;
    }
    
#ifdef ACADEMIA_SINICA_DEMO
    str = [str stringByReplacingOccurrencesOfString:@"Vicky" withString:@"TINA"];
    str = [str stringByReplacingOccurrencesOfString:@"BoBo" withString:@"TINA"];
#endif
    
    return str;
}

@end
