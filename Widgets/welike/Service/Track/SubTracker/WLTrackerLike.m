//
//  WLTrackerLike.m
//  welike
//
//  Created by fan qi on 2018/11/6.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTrackerLike.h"
#import "WLPostBase.h"

#define kWLTrackerLikeEventIDKey                    @"5001003"
#define kWLTrackerLikeActionKey                     @"action"
#define kWLTrackerLikePostTypeKey                   @"post_type"
#define kWLTrackerLikeSourceKey                     @"source"
#define kWLTrackerLikeFromKey                       @"likefrom"
#define kWLTrackerLikePostIDKey                     @"post_id"
#define kWLTrackerLikeUserIDKey                     @"user_id"

static WLTrackerFeedSource _feedSource;

typedef NS_ENUM(NSInteger, WLTrackerLikeBtnType) {
    WLTrackerLikeBtnType_Cell           = 1,
    WLTrackerLikeBtnType_Detail         = 2,
    WLTrackerLikeBtnType_VideoPlayer    = 3,
};

@implementation WLTrackerLike

+ (void)appendTrackerLikePost:(WLPostBase *)post {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@"1" forKey:kWLTrackerLikeActionKey];
    
    WLTrackerRepostType postType = trackerPostType(post);
    [eventInfo setObject:@(postType) forKey:kWLTrackerLikePostTypeKey];
    
    WLTrackerFeedSource feedSource = [self feedSource];
    if (feedSource == WLTrackerFeedSource_Unknown) {
        feedSource = post.trackerSource;
    }
    NSString *source = trackerFeedSource(feedSource, post.trackerSubType);
    if (source) {
        [eventInfo setObject:source forKey:kWLTrackerLikeSourceKey];
    }
    
    WLTrackerLikeBtnType likeFrom = WLTrackerLikeBtnType_Cell;
    
    if (feedSource == WLTrackerFeedSource_FeedDetail_Bottom
        || feedSource == WLTrackerFeedSource_CommentDetail_Bottom
        || feedSource == WLTrackerFeedSource_FeedDetail) {
        likeFrom = WLTrackerLikeBtnType_Detail;
    } else if (feedSource == WLTrackerFeedSource_VideoPlayer) {
        likeFrom = WLTrackerLikeBtnType_VideoPlayer;
    }
    
    [eventInfo setObject:@(likeFrom) forKey:kWLTrackerLikeFromKey];
    
    if (post.pid) {
        [eventInfo setObject:post.pid forKey:kWLTrackerLikePostIDKey];
    }
    if ([AppContext getInstance].accountManager.myAccount.uid) {
        [eventInfo setObject:[AppContext getInstance].accountManager.myAccount.uid forKey:kWLTrackerLikeUserIDKey];
    }
    
    [self p_appendTrackerWithEventInfo:eventInfo];
}

+ (void)appendTrackerLikeCommentOrReplay:(NSString *)comOrReplyID {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@"1" forKey:kWLTrackerLikeActionKey];
    
    [eventInfo setObject:@(WLTrackerRepostType_Comment) forKey:kWLTrackerLikePostTypeKey];
    
    WLTrackerFeedSource feedSource = [self feedSource];
    NSString *source = trackerFeedSource(feedSource, nil);
    if (source) {
        [eventInfo setObject:source forKey:kWLTrackerLikeSourceKey];
    }
    
    WLTrackerLikeBtnType likeFrom = WLTrackerLikeBtnType_Cell;
    likeFrom = (feedSource == WLTrackerFeedSource_FeedDetail_Bottom
                || feedSource == WLTrackerFeedSource_CommentDetail_Bottom)
    ? WLTrackerLikeBtnType_Detail
    : WLTrackerLikeBtnType_Cell;
    [eventInfo setObject:@(likeFrom) forKey:kWLTrackerLikeFromKey];
    
    if (comOrReplyID) {
        [eventInfo setObject:comOrReplyID forKey:kWLTrackerLikePostIDKey];
    }
    if ([AppContext getInstance].accountManager.myAccount.uid) {
        [eventInfo setObject:[AppContext getInstance].accountManager.myAccount.uid forKey:kWLTrackerLikeUserIDKey];
    }
    
    [self p_appendTrackerWithEventInfo:eventInfo];
}

+ (void)p_appendTrackerWithEventInfo:(NSDictionary *)eventInfo {
    [[WLTracker getInstance] appendEventId:kWLTrackerLikeEventIDKey eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
    
    [WLTrackerLike setFeedSource:WLTrackerFeedSource_Unknown];
}

+ (void)setFeedSource:(WLTrackerFeedSource)feedSource {
    _feedSource = feedSource;
}

+ (WLTrackerFeedSource)feedSource {
    return _feedSource;
}

@end
