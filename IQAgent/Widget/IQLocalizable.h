//
//  IQLocalizable.h
//  IQAgent
//
//  Created by IanFan on 2016/10/4.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import <Foundation/Foundation.h>

#undef NSLocalizedString
#define NSLocalizedString(key, comment) \
[[IQLocalizable sharedInstance] localizedStringForKey:(key)]

#undef NSLocalizedStringFromTable
#define NSLocalizedStringFromTable(key, tbl, comment) \
[[IQLocalizable sharedInstance] localizedStringForKey:(key) fromTable:(tbl)]

#undef NSLocalizedStringFromTableInBundle
#define NSLocalizedStringFromTableInBundle(key, tbl, bundle, comment) \
[[[IQLocalizable sharedInstance] manualLanguageBundle:(bundle)] localizedStringForKey:(key) value:@"" table:(tbl)]

#undef NSLocalizedStringWithDefaultValue
#define NSLocalizedStringWithDefaultValue(key, tbl, bundle, val, comment) \
[[[IQLocalizable sharedInstance] manualLanguageBundle:(bundle)] localizedStringForKey:(key) value:(val) table:(tbl)]

#define IQLocalizedString(key, comment) \
[[IQLocalizable sharedInstance] localizedStringForKey:(key) fromTable:@"IQLocalizable"]

//#warning Mark before release
//#define LOCALIZABLE_TEST_MODE_EN //強制英文翻譯

//#warning Mark before release
#define LOCALIZABLE_TEST_MODE_ZH_HANT //強制繁中翻譯

//#warning Mark before release
//#define LOCALIZABLE_TEST_MODE_AR //強制阿拉伯文翻譯

typedef NS_ENUM(NSInteger, LocalizableLanguage) {
    LocalizableLanguage_en             = 0,//英文
    LocalizableLanguage_zh_Hant           ,//繁中
    LocalizableLanguage_zh_Hans           ,//簡中
    LocalizableLanguage_ko                ,//韓文
    LocalizableLanguage_ja                ,//日文
    LocalizableLanguage_ar                ,//阿拉伯文
    LocalizableLanguage_he                ,//希伯來語
    LocalizableLanguage_ur                ,//烏爾都語
    LocalizableLanguage_fa                ,//波斯語
    LocalizableLanguage_fr                ,//法語
};

@interface IQLocalizable : NSObject

@property (nonatomic, retain) NSString *currentLanguage;
@property (nonatomic, assign) NSInteger currentSupportLanguage;


+ (IQLocalizable *)sharedInstance;

- (void)setTempLanguage:(NSInteger)language;
- (void)setManualLanguageEnum:(NSInteger)languageEnum;

#pragma mark - Info

- (NSInteger)getCurreuntLanguageEnum;

- (NSInteger)getFirstLanguageEnum;
- (NSInteger)getSecondLanguageEnum;

#pragma mark - For Macros

- (NSString *)localizedStringForKey:(NSString *)key;
- (NSString *)localizedStringForKey:(NSString *)key fromTable:(NSString *)table;

@end
