//
//  WLTrackerBlock.m
//  welike
//
//  Created by fan qi on 2018/12/11.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLTrackerBlock.h"
#import "WLPostBase.h"

#define kWLTrackerBlockEventIDKey                  @"5001088"

@implementation WLTrackerBlock

+ (void)appendTrackerWithBlockType:(WLTrackerBlockType)type
                              post:(WLPostBase *)post {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(type) forKey:@"action"];
    
    if (post.uid.length > 0) {
        [eventInfo setObject:post.uid forKey:@"blocked_uid"];
    }
    
    if (post.pid.length > 0) {
        [eventInfo setObject:post.pid forKey:@"post_id"];
    }
    
    if (post.language.length > 0) {
        [eventInfo setObject:post.language forKey:@"post_la"];
    }
    
    if (post.tags) {
        [eventInfo setObject:post.tags forKey:@"post_tags"];
    }
    
    NSString *trackerSource = trackerFeedSource(post.trackerSource, post.trackerSubType);
    if (trackerSource.length > 0) {
        [eventInfo setObject:trackerSource forKey:@"button_from"];
    }
    
    [[WLTracker getInstance] appendEventId:kWLTrackerBlockEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendTrackerWithBlockType:(WLTrackerBlockType)type
                            userID:(NSString *)userID
                            source:(WLTrackerFeedSource)source {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(type) forKey:@"action"];
    [eventInfo setObject:@(source) forKey:@"button_from"];
    if (userID > 0) {
        [eventInfo setObject:userID forKey:@"blocked_uid"];
    }
    
    [[WLTracker getInstance] appendEventId:kWLTrackerBlockEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

@end
