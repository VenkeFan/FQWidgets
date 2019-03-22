//
//  WLTrackerFeed.m
//  welike
//
//  Created by fan qi on 2018/10/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTrackerFeed.h"
#import "WLPostBase.h"

#define WLTrackerFeedEventID                        @"5001021"
#define WLTrackerFeedActionKey                      @"action"
#define WLTrackerFeedTypeKey                        @"type"
#define WLTrackerFeedFetchCountKey                  @"list_total"

static WLTrackerFeedSource _emptyDataTrackerSource;
static WLTrackerFeedSubType _emptyDataTrackerSubType;

@implementation WLTrackerFeed

+ (void)appendTrackWithAction:(WLTrackerFeedAction)action
                         type:(WLTrackerFeedSource)type
                      subType:(nullable WLTrackerFeedSubType)subType
                   fetchCount:(NSUInteger)fetchCount {
    [[WLTracker getInstance] synchronize];
    
    NSString *strType = nil;
    
    if (fetchCount > 0) {
        strType = trackerFeedSource(type, subType);
    } else {
        strType = trackerFeedSource([self emptyDataTrackerSource], [self emptyDataTrackerSubType]);
    }
    
    [[WLTracker getInstance] appendEventId:WLTrackerFeedEventID
                                 eventInfo:@{WLTrackerFeedActionKey: @(action),
                                             WLTrackerFeedTypeKey: strType ?: @"",
                                             WLTrackerFeedFetchCountKey: @(fetchCount)}];
}

+ (void)setEmptyDataTrackerSource:(WLTrackerFeedSource)emptyDataTrackerSource {
    _emptyDataTrackerSource = emptyDataTrackerSource;
}

+ (WLTrackerFeedSource)emptyDataTrackerSource {
    return _emptyDataTrackerSource;
}

+ (void)setEmptyDataTrackerSubType:(nullable WLTrackerFeedSubType)emptyDataTrackerSubType {
    _emptyDataTrackerSubType = emptyDataTrackerSubType;
}

+ (nullable WLTrackerFeedSubType)emptyDataTrackerSubType {
    return _emptyDataTrackerSubType;
}

@end
