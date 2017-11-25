//
//  IQLocalizable.m
//  IQAgent
//
//  Created by IanFan on 2016/10/4.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "IQLocalizable.h"

#define USERDEFAULTS_LOCALIZABLE_LANGUAGE_IDENTIFIER_MANUAL @"nsuserDefaults_localizableLanguageIdentifierManual"

@implementation IQLocalizable

#pragma mark - Singleton

+ (IQLocalizable *)sharedInstance {
    static IQLocalizable *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[IQLocalizable alloc] init];
    });
    return shared;
}

#pragma mark - Init

- (id)init {
    self = [super init];
    if (self) {
        NSString *currentLanguageString = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_LOCALIZABLE_LANGUAGE_IDENTIFIER_MANUAL];
        
        if (currentLanguageString.length > 0) {
            self.currentLanguage = currentLanguageString;
        }
        else {
            // first init
            NSInteger languageEnum = [self getFirstLanguageEnum];
            
            [self setTempLanguage:languageEnum];
        }
    }
    return self;
}

#pragma mark - Public

- (void)setTempLanguage:(NSInteger)languageEnum {
    //如果public使用，還需要先做檢查有無支援的動作
    
    self.currentLanguage = [self convertToSupportLanguage:languageEnum];
    
#ifdef LOCALIZABLE_TEST_MODE_ZH_HANT
    self.currentLanguage = [self convertToLanguageFromLanguageEnum:LocalizableLanguage_zh_Hant];
#endif
    
#ifdef LOCALIZABLE_TEST_MODE_AR
    self.currentLanguage = [self convertToLanguageFromLanguageEnum:LocalizableLanguage_ar];
#endif
    
#ifdef LOCALIZABLE_TEST_MODE_EN
    self.currentLanguage = [self convertToLanguageFromLanguageEnum:LocalizableLanguage_en];
#endif
    
#ifdef LOCALIZABLE_TEST_MODE_AR
    self.currentLanguage = [self convertToLanguageFromLanguageEnum:LocalizableLanguage_ar];
#endif
}

- (void)setManualLanguageEnum:(NSInteger)languageEnum {
    NSString *language = [self convertToSupportLanguage:languageEnum];
    self.currentLanguage = language;
    
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:USERDEFAULTS_LOCALIZABLE_LANGUAGE_IDENTIFIER_MANUAL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Info

- (NSInteger)getFirstLanguageEnum {
    return [self getLanguageEnumWithIndex:0];
}

- (NSInteger)getSecondLanguageEnum {
    return [self getLanguageEnumWithIndex:1];
}

- (NSInteger)getLanguageEnumWithIndex:(NSInteger)index {
    //1.處理languageCode，看是否有支援
    //2.如果有同languageCode但不同地區（例如zh有分TW,HK,CN等等，但沒出現Hant或Hans資訊），用關鍵字做進一步判斷
    
    NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    if (languages.count == 0) {
        return LocalizableLanguage_en;
    }
    index = MIN(index, languages.count-1);
    NSString *firstLanguage = languages[index];
    
    NSArray *array = [firstLanguage componentsSeparatedByString:@"-"];
    NSString *languageCode = [array firstObject];//例如 @"zh-Hant-TW" 會被分開成Array的內容 @[@"zh",@"Hant",@"TW"]
    
    if ([languageCode isEqualToString:@"zh"]) {
        if ([self isArray:array containKeyWord:@"Hant"] ||
            [self isArray:array containKeyWord:@"TW"] ||
            [self isArray:array containKeyWord:@"HK"]) {
            return LocalizableLanguage_zh_Hant;
        }
        else {
            return LocalizableLanguage_zh_Hans;
        }
    }
    else if ([languageCode isEqualToString:@"ko"]) {
        return LocalizableLanguage_ko;
    }
    else if ([languageCode isEqualToString:@"ja"]) {
        return LocalizableLanguage_ja;
    }
    else if ([languageCode isEqualToString:@"ar"]) {
        return LocalizableLanguage_ar;
    }
    else if ([languageCode isEqualToString:@"he"]) {
        return LocalizableLanguage_he;
    }
    else if ([languageCode isEqualToString:@"ur"]) {
        return LocalizableLanguage_ur;
    }
    else if ([languageCode isEqualToString:@"fa"]) {
        return LocalizableLanguage_fa;
    }
    else if ([languageCode isEqualToString:@"fr"]) {
        return LocalizableLanguage_fr;
    }
    
    return LocalizableLanguage_en;
}

- (NSString *)convertToSupportLanguage:(NSInteger)languageEnum {
    switch (languageEnum) {
        case LocalizableLanguage_zh_Hant:
            return @"zh-Hant";
        case LocalizableLanguage_zh_Hans:
            return @"zh-Hans";
        case LocalizableLanguage_ar:
            return @"ar";
            
        default:
            break;
    }
    
    //當不支援時，皆用英文支援
    return @"en";
}

- (NSString *)convertToLanguageFromLanguageEnum:(NSInteger)languageEnum {
    switch (languageEnum) {
        case LocalizableLanguage_zh_Hant: return @"zh-Hant";
        case LocalizableLanguage_zh_Hans: return @"zh-Hans";
        case LocalizableLanguage_ko:      return @"ko";
        case LocalizableLanguage_ja:      return @"ja";
        case LocalizableLanguage_ar:      return @"ar";
        case LocalizableLanguage_he:      return @"he";
        case LocalizableLanguage_ur:      return @"ur";
        case LocalizableLanguage_fa:      return @"fa";
        case LocalizableLanguage_fr:      return @"fr";
        case LocalizableLanguage_en:
        default: return @"en";
    }
}

- (NSInteger)convertToLanguageEnumFromLanguage:(NSString *)language {
    if ([language isEqualToString:@"zh-Hant"]) {
        return LocalizableLanguage_zh_Hant;
    }
    else if ([language isEqualToString:@"zh-Hans"]) {
        return LocalizableLanguage_zh_Hans;
    }
    else if ([language isEqualToString:@"ko"]) {
        return LocalizableLanguage_ko;
    }
    else if ([language isEqualToString:@"ja"]) {
        return LocalizableLanguage_ja;
    }
    else if ([language isEqualToString:@"ar"]) {
        return LocalizableLanguage_ar;
    }
    else if ([language isEqualToString:@"he"]) {
        return LocalizableLanguage_he;
    }
    else if ([language isEqualToString:@"ur"]) {
        return LocalizableLanguage_ur;
    }
    else if ([language isEqualToString:@"fa"]) {
        return LocalizableLanguage_fa;
    }
    else if ([language isEqualToString:@"fr"]) {
        return LocalizableLanguage_fr;
    }
    return LocalizableLanguage_en;
}

- (NSInteger)getCurreuntLanguageEnum {
    return [self convertToLanguageEnumFromLanguage:self.currentLanguage];
}

#pragma mark - For Macros

- (NSString *)localizedStringForKey:(NSString *)key {
    return [[self languageBundle:[NSBundle mainBundle]] localizedStringForKey:(key) value:@"" table:nil];
}

- (NSString *)localizedStringForKey:(NSString *)key fromTable:(NSString *)table {
    return [[self languageBundle:[NSBundle mainBundle]] localizedStringForKey:(key) value:@"" table:table];
}

- (NSBundle *)languageBundle:(NSBundle *)bundle {
    NSBundle *newBundle = bundle;
    
    // path to this languages bundle
    NSString *path = [bundle pathForResource:self.currentLanguage ofType:@"lproj"];
    
    if (path) {
        newBundle = [NSBundle bundleWithPath:path];
    }
    return newBundle;
}

#pragma mark - Private

- (BOOL)isArray:(NSArray *)array containKeyWord:(NSString *)keyWord {
    for (NSString *str in array) {
        if ([keyWord isEqualToString:str]) {
            return YES;
        }
    }
    return NO;
}

@end
