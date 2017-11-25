//
//  SoundInfo.m
//  IQAgent
//
//  Created by IanFan on 2016/10/4.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "SoundInfo.h"
#import <AudioToolbox/AudioToolbox.h>

#pragma mark - SoundItem
#pragma mark -

@implementation  SoundItem
@synthesize ID;
@synthesize NAME;
@synthesize FILE_NAME;

+ (SoundItem *)copySoundItem:(SoundItem *)soundItem {
    SoundItem *item = [[SoundItem alloc] init];
    item.ID = soundItem.ID;
    item.NAME = soundItem.NAME;
    item.FILE_NAME = soundItem.FILE_NAME;
    return item;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:ID forKey:@"ITEM_NUM"];
    [aCoder encodeObject:NAME forKey:@"NAME"];
    [aCoder encodeObject:FILE_NAME forKey:@"FILE_NAME"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.ID = [aDecoder decodeObjectForKey:@"ITEM_NUM"];
        self.NAME = [aDecoder decodeObjectForKey:@"NAME"];
        self.FILE_NAME = [aDecoder decodeObjectForKey:@"FILE_NAME"];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

@end

@implementation SoundInfo

+ (NSMutableDictionary *)getDefaultSoundDic {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    {
        SoundItem *item = [[SoundItem alloc] init];
        item.ID = @"0001";
        item.NAME = IQLocalizedString(@"答答", nil);
        item.FILE_NAME = @"sound_tock.caf";
        NSString *key = item.ID;
        [dic setObject:item forKey:key];
    }
    
    {
        SoundItem *item = [[SoundItem alloc] init];
        item.ID = @"0002";
        item.NAME = IQLocalizedString(@"叮叮", nil);
        item.FILE_NAME = @"sound_tink.caf";
        NSString *key = item.ID;
        [dic setObject:item forKey:key];
    }
    
    {
        SoundItem *item = [[SoundItem alloc] init];
        item.ID = @"0003";
        item.NAME = IQLocalizedString(@"實體鍵盤1", nil);
        item.FILE_NAME = @"sound_physical1.mp3";
        NSString *key = item.ID;
        [dic setObject:item forKey:key];
    }
    
    {
        SoundItem *item = [[SoundItem alloc] init];
        item.ID = @"0004";
        item.NAME = IQLocalizedString(@"實體鍵盤2", nil);
        item.FILE_NAME = @"sound_physical2.mp3";
        NSString *key = item.ID;
        [dic setObject:item forKey:key];
    }
    
    {
        SoundItem *item = [[SoundItem alloc] init];
        item.ID = @"0005";
        item.NAME = IQLocalizedString(@"煙火", nil);
        item.FILE_NAME = @"sound_firework.mp3";
        NSString *key = item.ID;
        [dic setObject:item forKey:key];
    }
    
    {
        SoundItem *item = [[SoundItem alloc] init];
        item.ID = @"0006";
        item.NAME = IQLocalizedString(@"光劍", nil);
        item.FILE_NAME = @"sound_interstellar.mp3";
        NSString *key = item.ID;
        [dic setObject:item forKey:key];
    }
    
    {
        SoundItem *item = [[SoundItem alloc] init];
        item.ID = @"0007";
        item.NAME = IQLocalizedString(@"愛你喔", nil);
        item.FILE_NAME = @"sound_love.mp3";
        NSString *key = item.ID;
        [dic setObject:item forKey:key];
    }
    
    {
        SoundItem *item = [[SoundItem alloc] init];
        item.ID = @"0008";
        item.NAME = IQLocalizedString(@"金幣雨", nil);
        item.FILE_NAME = @"sound_coin.mp3";
        NSString *key = item.ID;
        [dic setObject:item forKey:key];
    }
    
    {
        SoundItem *item = [[SoundItem alloc] init];
        item.ID = @"0009";
        item.NAME = IQLocalizedString(@"釘書機", nil);
        item.FILE_NAME = @"sound_bubble.mp3";
        NSString *key = item.ID;
        [dic setObject:item forKey:key];
    }
    
    {
        SoundItem *item = [[SoundItem alloc] init];
        item.ID = @"0010";
        item.NAME = IQLocalizedString(@"水滴1", nil);
        item.FILE_NAME = @"sound_drop1.mp3";
        NSString *key = item.ID;
        [dic setObject:item forKey:key];
    }
    
    {
        SoundItem *item = [[SoundItem alloc] init];
        item.ID = @"0011";
        item.NAME = IQLocalizedString(@"水滴2", nil);
        item.FILE_NAME = @"sound_drop2.mp3";
        NSString *key = item.ID;
        [dic setObject:item forKey:key];
    }
    
    {
        SoundItem *item = [[SoundItem alloc] init];
        item.ID = @"0012";
        item.NAME = IQLocalizedString(@"跳跳跳", nil);
        item.FILE_NAME = @"sound_jump.mp3";
        NSString *key = item.ID;
        [dic setObject:item forKey:key];
    }
    
    {
        SoundItem *item = [[SoundItem alloc] init];
        item.ID = @"0013";
        item.NAME = IQLocalizedString(@"飛吻", nil);
        item.FILE_NAME = @"sound_kiss.mp3";
        NSString *key = item.ID;
        [dic setObject:item forKey:key];
    }
    
    {
        SoundItem *item = [[SoundItem alloc] init];
        item.ID = @"0014";
        item.NAME = IQLocalizedString(@"電報", nil);
        item.FILE_NAME = @"sound_telegraph.mp3";
        NSString *key = item.ID;
        [dic setObject:item forKey:key];
    }
    
    {
        SoundItem *item = [[SoundItem alloc] init];
        item.ID = @"0015";
        item.NAME = IQLocalizedString(@"傳統打字機", nil);
        item.FILE_NAME = @"sound_writer.mp3";
        NSString *key = item.ID;
        [dic setObject:item forKey:key];
    }
    
    {
        SoundItem *item = [[SoundItem alloc] init];
        item.ID = @"0016";
        item.NAME = IQLocalizedString(@"聆聽", nil);
        item.FILE_NAME = @"sound_record_on.m4a";
        NSString *key = item.ID;
        [dic setObject:item forKey:key];
    }
    
    {
        SoundItem *item = [[SoundItem alloc] init];
        item.ID = @"0017";
        item.NAME = IQLocalizedString(@"聽到", nil);
        item.FILE_NAME = @"sound_record_understand.m4a";
        NSString *key = item.ID;
        [dic setObject:item forKey:key];
    }
    
    {
        SoundItem *item = [[SoundItem alloc] init];
        item.ID = @"0018";
        item.NAME = IQLocalizedString(@"不懂", nil);
        item.FILE_NAME = @"sound_record_off.m4a";
        NSString *key = item.ID;
        [dic setObject:item forKey:key];
    }
    
    return dic;
}

@end
