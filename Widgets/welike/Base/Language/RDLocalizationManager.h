//
//  RDLocalizationManager.h
//  welike
//
//  Created by 刘斌 on 2018/4/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LANGUAGE_TYPE_ENG                @"en"
#define LANGUAGE_TYPE_HINDI              @"hi"

@protocol RDLocalizationManagerDelegate <NSObject>

@optional
- (void)didChangedLanguage:(NSString *)language;

@end

@interface RDLocalizationManager : NSObject

+ (RDLocalizationManager *)getInstance;

- (void)registerDelegate:(id<RDLocalizationManagerDelegate>)delegate;
- (void)unregisterDelegate:(id<RDLocalizationManagerDelegate>)delegate;

- (NSString *)getCurrentLanguage;
- (NSString *)getCurrentSystemLanguage;
- (void)switchLanguage:(NSString *)language;

@end
