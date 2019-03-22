//
//  WLTrackerDayLive.m
//  welike
//
//  Created by fan qi on 2018/10/25.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTrackerDayLive.h"
#import "WLTracker.h"

#define WLTrackDayLiveEventID                       @"5001020"
#define kWLTrackerDayLiveDateKey                    @"kWLTrackerDayLiveDateKey"

@implementation WLTrackerDayLive

+ (void)appendTrackWithOpenType:(WLTrackerDayLiveOpenType)openType {
    if (![self isToday]) {
        [[WLTracker getInstance] appendEventId:WLTrackDayLiveEventID
                                     eventInfo:@{@"open_type": @(openType)}];
        [[WLTracker getInstance] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kWLTrackerDayLiveDateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (BOOL)isToday {
    NSDate *date = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:kWLTrackerDayLiveDateKey];
    if (!date) {
        return NO;
    }
    
    return [[NSCalendar currentCalendar] isDateInToday:date];
}

@end
