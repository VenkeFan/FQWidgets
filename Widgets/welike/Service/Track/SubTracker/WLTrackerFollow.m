//
//  WLTrackerFollow.m
//  welike
//
//  Created by fan qi on 2018/11/7.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTrackerFollow.h"
#import "WLPostBase.h"

#define kWLTrackerFollowEventIDKey                  @"5001001"

static WLTrackerFeedSource _feedSource;

@implementation WLTrackerFollow

+ (void)appendTrackerWithFollowAction:(WLTrackerFollowAction)action
                                 post:(nullable WLPostBase *)post
                               userID:(NSString *)userID {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(action) forKey:@"action"];
    
    if ([AppContext getInstance].accountManager.myAccount.uid) {
        [eventInfo setObject:[AppContext getInstance].accountManager.myAccount.uid forKey:@"from_user_id"];
    }
    
    if (userID) {
        [eventInfo setObject:userID forKey:@"to_user_id"];
    }
    
    if (post) {
        NSString *source = trackerFeedSource(post.trackerSource, post.trackerSubType);
        if (source) {
            [eventInfo setObject:source forKey:@"button_from"];
        }
        
        if (post.pid) {
            [eventInfo setObject:post.pid forKey:@"post_id"];
        }
    } else {
        WLTrackerFeedSource feedSource = [self feedSource];
        NSString *source = trackerFeedSource(feedSource, nil);
        if (source) {
            [eventInfo setObject:source forKey:@"button_from"];
        }
    }
    
    [[WLTracker getInstance] appendEventId:kWLTrackerFollowEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)setFeedSource:(WLTrackerFeedSource)feedSource {
    _feedSource = feedSource;
}

+ (WLTrackerFeedSource)feedSource {
    return _feedSource;
}

@end
