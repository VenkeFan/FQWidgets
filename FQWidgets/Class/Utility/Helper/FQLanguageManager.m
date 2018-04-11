//
//  FQLanguageManager.m
//  Pook
//
//  Created by fanqi on 17/6/16.
//  Copyright © 2017年 haidai. All rights reserved.
//

#import "FQLanguageManager.h"

#define kUserLanguage @"UserLanguage"

NSString * const FQLanguageTypeMapping[] = {
    [FQLanguageType_CN] = @"zh-Hans",
    [FQLanguageType_EN] = @"en"
};

@implementation FQLanguageManager

+ (instancetype)manager {
    static dispatch_once_t one;
    static FQLanguageManager *_instance = nil;
    dispatch_once(&one, ^{
        _instance = [FQLanguageManager new];
    });
    return _instance;
}

- (void)setUserLanguage:(FQLanguageType)languageType {
    [[NSUserDefaults standardUserDefaults] setObject:FQLanguageTypeMapping[languageType] forKey:kUserLanguage];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (FQLanguageType)userLanguage {
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:kUserLanguage];
    
    if (kIsNullOrEmpty(language)) {
        NSArray *appleLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        if ([appleLang.firstObject containsString:FQLanguageTypeMapping[FQLanguageType_CN]]) {
            language = FQLanguageTypeMapping[FQLanguageType_CN];
        } else {
            language = FQLanguageTypeMapping[FQLanguageType_EN];
        }
    }
    
    if ([FQLanguageTypeMapping[FQLanguageType_EN] isEqualToString:language]) {
        return FQLanguageType_EN;
    } else {
        return FQLanguageType_CN;
    }
}

- (NSString *)logogram {
    NSString *str = @"";
    
    switch (self.userLanguage) {
        case FQLanguageType_CN:
            str = @"cn";
            break;
        case FQLanguageType_EN:
            str  = @"en";
            break;
    }
    
    return str;
}

- (NSString *)getStringForKey:(NSString *)key {
    NSString *str = @"";
    
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:kUserLanguage];
    if (kIsNullOrEmpty(language)) {
        str = NSLocalizedString(key, nil);
    } else {
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]];
        str = NSLocalizedStringFromTableInBundle(key, nil, bundle, nil);
    }
    
    return str;
}

@end
