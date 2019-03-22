//
//  WLTrackerPlayer.m
//  welike
//
//  Created by fan qi on 2018/11/8.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLTrackerPlayer.h"
#import "WLVideoPost.h"
#import "WLForwardPost.h"

#define kWLTrackerPlayerEventIDKey                  @"5001007"

static WLPostBase *_forwardPost;
static WLTrackerPlayerOpenType _openType;

@implementation WLTrackerPlayer

+ (void)appendTrackerWithPlayerAction:(WLTrackerPlayerAction)action
                            videoPost:(WLVideoPost *)videoPost
                             playTime:(CGFloat)playTime
                             duration:(CGFloat)duration
                             muteType:(WLTrackerPlayerMuteType)muteType {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(action) forKey:@"action"];
    [eventInfo setObject:@(playTime * 1000) forKey:@"play_duration"];
    [eventInfo setObject:@(duration * 1000) forKey:@"duration_time"];
    [eventInfo setObject:@(muteType) forKey:@"mute_type"];
    
    if (action == WLTrackerPlayerAction_Screen) {
        [eventInfo setObject:@([self openType]) forKey:@"open_type"];
    }
    
    if ([AppContext getInstance].accountManager.myAccount.uid) {
        [eventInfo setObject:[AppContext getInstance].accountManager.myAccount.uid forKey:@"uid"];
    }
    
    NSString *source = nil;
    if ([self forwardPost]) {
        source = trackerFeedSource([self forwardPost].trackerSource, [self forwardPost].trackerSubType);
        
        if ([self forwardPost].pid) {
            [eventInfo setObject:[self forwardPost].pid forKey:@"post_id"];
        }
        if ([self forwardPost].uid) {
            [eventInfo setObject:[self forwardPost].uid forKey:@"post_uid"];
        }
        
        if (videoPost.pid) {
            [eventInfo setObject:videoPost.pid forKey:@"rootpost_id"];
        }
        if (videoPost.uid) {
            [eventInfo setObject:videoPost.uid forKey:@"rootpost_uid"];
        }
    } else {
        source = trackerFeedSource(videoPost.trackerSource, videoPost.trackerSubType);
        
        if (videoPost.pid) {
            [eventInfo setObject:videoPost.pid forKey:@"post_id"];
        }
        if (videoPost.uid) {
            [eventInfo setObject:videoPost.uid forKey:@"post_uid"];
        }
        
    }
    if (source) {
        [eventInfo setObject:source forKey:@"play_source"];
    }
    
    [[WLTracker getInstance] appendEventId:kWLTrackerPlayerEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendTrackerWithPlayerOperateType:(WLTrackerPlayerOperateType)operateType {
    [[WLTracker getInstance] appendEventId:kWLTrackerPlayerEventIDKey
                                 eventInfo:@{@"playclick": @(operateType)}];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendTrackerWithPlayerOperateType:(WLTrackerPlayerOperateType)operateType
                                  muteType:(WLTrackerPlayerMuteType)muteType {
    [[WLTracker getInstance] appendEventId:kWLTrackerPlayerEventIDKey
                                 eventInfo:@{@"playclick": @(operateType),
                                             @"mute_type": @(muteType)}];
    [[WLTracker getInstance] synchronize];
}

+ (void)setForwardPost:(WLPostBase *)forwardPost {
    if ([forwardPost isKindOfClass:[WLForwardPost class]]) {
        _forwardPost = forwardPost;
    } else {
        _forwardPost = nil;
    }
}

+ (WLPostBase *)forwardPost {
    return _forwardPost;
}

+ (void)setOpenType:(WLTrackerPlayerOpenType)openType {
    _openType = openType;
}

+ (WLTrackerPlayerOpenType)openType {
    return _openType;
}

@end
