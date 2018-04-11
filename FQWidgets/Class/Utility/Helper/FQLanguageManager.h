//
//  FQLanguageManager.h
//  Pook
//
//  Created by fanqi on 17/6/16.
//  Copyright © 2017年 haidai. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kLocalizedString(string)               [[FQLanguageManager manager] getStringForKey:string]

typedef NS_ENUM(NSInteger, FQLanguageType) {
    FQLanguageType_CN,
    FQLanguageType_EN
};

@interface FQLanguageManager : NSObject

+ (instancetype)manager;
- (NSString *)getStringForKey:(NSString *)key;

@property (nonatomic, assign) FQLanguageType userLanguage;
@property (nonatomic, copy) NSString *logogram;

@end
