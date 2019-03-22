//
//  RDLocalizationManager.m
//  welike
//
//  Created by 刘斌 on 2018/4/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDLocalizationManager.h"
#import "LuuUtils.h"

#define LOCALIZATION_LANGUAGE_SETTING      @"localization_language_setting"

static RDLocalizationManager *_gLocalizationManager = nil;

@interface RDLocalizationManager ()

@property (nonatomic, copy) NSString *currentLanguage;
@property (nonatomic, strong) NSPointerArray *delegates;

@end

@implementation RDLocalizationManager

- (id)init
{
    self = [super init];
    if (self)
    {
        self.delegates = [NSPointerArray weakObjectsPointerArray];
        self.currentLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:LOCALIZATION_LANGUAGE_SETTING];
    }
    return self;
}

#pragma mark RDLocalizationManager singleton methods
+ (RDLocalizationManager *)getInstance
{
    if (!_gLocalizationManager)
    {
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            _gLocalizationManager = [[RDLocalizationManager alloc] init];
        });
    }
    
    return _gLocalizationManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (!_gLocalizationManager)
        {
            _gLocalizationManager = [super allocWithZone:zone];
            return _gLocalizationManager;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _gLocalizationManager;
}

#pragma mark RDLocalizationManager public methods
- (void)registerDelegate:(id<RDLocalizationManagerDelegate>)delegate
{
    @synchronized (_delegates)
    {
        if ([_delegates containsObject:delegate] == NO)
        {
            [_delegates addObject:delegate];
        }
    }
}

- (void)unregisterDelegate:(id<RDLocalizationManagerDelegate>)delegate
{
    @synchronized (_delegates)
    {
        [_delegates removeObject:delegate];
    }
}

- (NSString *)getCurrentLanguage
{
    return self.currentLanguage;
}

- (NSString *)getCurrentSystemLanguage
{
    NSString *currentSystemLanguage = [LuuUtils preferredLanguage];
    if ([currentSystemLanguage containsString:LANGUAGE_TYPE_HINDI])
    {
        return LANGUAGE_TYPE_HINDI;
    }
    else
    {
        return LANGUAGE_TYPE_ENG;
    }
}

- (void)switchLanguage:(NSString *)language
{
    if ([language length] > 0 && [language isEqualToString:self.currentLanguage] == NO)
    {
        self.currentLanguage = language;
        [[NSUserDefaults standardUserDefaults] setObject:self.currentLanguage forKey:LOCALIZATION_LANGUAGE_SETTING];
        [[NSUserDefaults standardUserDefaults] synchronize];

        @synchronized (_delegates)
        {
            for (int i = 0; i < [_delegates count]; i++)
            {
                id<RDLocalizationManagerDelegate> delegate = [_delegates pointerAtIndex:i];
                if ([delegate respondsToSelector:@selector(didChangedLanguage:)])
                {
                   [delegate didChangedLanguage:self.currentLanguage];
                }
            }
        }
    }
}

@end
