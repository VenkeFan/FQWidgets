//
//  WLTrackerRepostAndComment.m
//  welike
//
//  Created by fan qi on 2018/11/5.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTrackerRepostAndComment.h"
#import "WLDraft.h"

#define kWLTrackerRepostAndCommentEventIDKey                    @"5001002"

static WLTrackerFeedSource _feedSource;

typedef NS_ENUM(NSInteger, WLTrackerRepostBtnType) {
    WLTrackerRepostBtnType_Cell     = 1,
    WLTrackerRepostBtnType_Detail   = 2
};

@implementation WLTrackerRepostAndComment

+ (void)appendTrackerWithDraft:(WLDraftBase *)draft
                        status:(WLTrackerReAndComStatus)status {
    if (!draft) {
        return;
    }
    
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    
    WLTrackerReAndComAction action = WLTrackerReAndComAction_Repost;
    WLTrackerRepostType postType = WLTrackerRepostType_Text;
    WLTrackerFeedSource feedSource = [self feedSource];
    NSString *source = nil;
    WLTrackerRepostBtnType btnFrom = WLTrackerRepostBtnType_Cell;
    NSString *pid = nil;
    
    if ([draft isKindOfClass:[WLForwardDraft class]]
        || [draft isKindOfClass:[WLCommentDraft class]]) {
        action = WLTrackerReAndComAction_Repost;
        
        WLForwardDraft *forward = (WLForwardDraft *)draft;
        
        postType = trackerPostType(forward.parentPost);
        
        if (feedSource == WLTrackerFeedSource_Unknown) {
            feedSource = forward.parentPost.trackerSource;
        }
        source = trackerFeedSource(feedSource, forward.parentPost.trackerSubType);
        
        btnFrom = (feedSource == WLTrackerFeedSource_FeedDetail_Bottom
                   || feedSource == WLTrackerFeedSource_CommentDetail_Bottom)
        ? WLTrackerRepostBtnType_Detail
        : WLTrackerRepostBtnType_Cell;
        
        pid = forward.parentPost.pid;
        
    } else if ([draft isKindOfClass:[WLReplyDraft class]]
               || [draft isKindOfClass:[WLReplyOfReplyDraft class]]) {
        action = WLTrackerReAndComAction_Comment;
        postType = WLTrackerRepostType_Comment;
        
        if (feedSource == WLTrackerFeedSource_Unknown) {
            feedSource = draft.parentPost.trackerSource;
        }
        source = trackerFeedSource(feedSource, draft.parentPost.trackerSubType);

        btnFrom = (feedSource == WLTrackerFeedSource_FeedDetail_Bottom
                   || feedSource == WLTrackerFeedSource_CommentDetail_Bottom)
        ? WLTrackerRepostBtnType_Detail
        : WLTrackerRepostBtnType_Cell;
        
        pid = draft.pid;
        
        [eventInfo setObject:@(draft.asRepost) forKey:@"if_repost"];
    }
    
    [eventInfo setObject:@(action) forKey:@"action"];
    [eventInfo setObject:@(status) forKey:@"send_status"];
    [eventInfo setObject:@(postType) forKey:@"post_type"];
    [eventInfo setObject:@(btnFrom) forKey:@"button_from"];
    
    if (source) {
        [eventInfo setObject:source forKey:@"source"];
    }
    if (pid) {
        [eventInfo setObject:pid forKey:@"post_id"];
    }
    if ([AppContext getInstance].accountManager.myAccount.uid) {
        [eventInfo setObject:[AppContext getInstance].accountManager.myAccount.uid forKey:@"user_id"];
    }
    
    [[WLTracker getInstance] appendEventId:kWLTrackerRepostAndCommentEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
    
    [WLTrackerRepostAndComment setFeedSource:WLTrackerFeedSource_Unknown];
}

+ (void)setFeedSource:(WLTrackerFeedSource)feedSource {
    _feedSource = feedSource;
}

+ (WLTrackerFeedSource)feedSource {
    return _feedSource;
}

@end
