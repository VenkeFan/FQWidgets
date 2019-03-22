//
//  WLTrackerPostRead.m
//  welike
//
//  Created by fan qi on 2018/11/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTrackerPostRead.h"
#import "WLPostBase.h"

#define kWLTrackerPostReadEventIDKey                    @"5001005"
#define kWLTrackerPostReadDurationKey                   @"view_time"

@implementation WLTrackerPostRead

+ (void)appendTrackerWithReadAction:(WLTrackerPostReadAction)action
                               post:(WLPostBase *)postModel
                           duration:(CFTimeInterval)duration {
    NSMutableDictionary *eventInfo = [self eventInfoWithPost:postModel];
    
    [eventInfo setObject:@(duration) forKey:kWLTrackerPostReadDurationKey];
    [eventInfo setObject:@(action) forKey:kWLTrackerPostDisplayActionKey];
    
    if (action != WLTrackerPostReadAction_Detail && postModel.trackerSource != WLTrackerFeedSource_FeedDetail) {
        NSString *source = trackerFeedSource(postModel.trackerSource, postModel.trackerSubType);
        if (source) {
            [eventInfo setObject:source forKey:kWLTrackerPostDisplaySourceKey];
        }
    }
    
    [[WLTracker getInstance] appendEventId:kWLTrackerPostReadEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendTrackerWithClickedArea:(WLTrackerPostClickedArea)area
                                post:(WLPostBase *)postModel {
    NSMutableDictionary *eventInfo = [self eventInfoWithPost:postModel];
    [eventInfo setObject:@(WLTrackerPostReadAction_Clicked) forKey:kWLTrackerPostDisplayActionKey];
    [eventInfo setObject:@(area) forKey:kWLTrackerPostDisplayClickedAreaKey];
    
    if (postModel.trackerSource != WLTrackerFeedSource_FeedDetail) {
        NSString *source = trackerFeedSource(postModel.trackerSource, postModel.trackerSubType);
        if (source) {
            [eventInfo setObject:source forKey:kWLTrackerPostDisplaySourceKey];
        }
    }
    
    [[WLTracker getInstance] appendEventId:kWLTrackerPostReadEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

@end
