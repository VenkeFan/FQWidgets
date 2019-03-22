//
//  WLTrackerLanguage.m
//  welike
//
//  Created by fan qi on 2018/11/12.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLTrackerLanguage.h"
#import "WLTracker.h"

#define kWLTrackerLanguageEventIDKey                  @"5001008"
#define kWLTrackerLanguageDateKey                     @"kWLTrackerLanguageDateKey"

@implementation WLTrackerLanguage

+ (void)appendTrackerWithLang:(NSString *)lang
                       source:(WLTrackerLanguageSource)source {
    if (![self isToday]) {
        [[WLTracker getInstance] appendEventId:kWLTrackerLanguageEventIDKey
                                     eventInfo:@{@"action": @"1",
                                                 @"la": lang ?: @"",
                                                 @"button_from": @(source)}];
        [[WLTracker getInstance] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kWLTrackerLanguageDateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (BOOL)isToday {
    NSDate *date = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:kWLTrackerLanguageDateKey];
    if (!date) {
        return NO;
    }
    
    return [[NSCalendar currentCalendar] isDateInToday:date];
}

@end
