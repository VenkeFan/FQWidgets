//
//  WLTrackerPostDisplay.m
//  welike
//
//  Created by fan qi on 2018/11/1.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTrackerPostDisplay.h"
#import "WLPostBase.h"
#import "WLForwardPost.h"

#define kWLTrackerPostDisplayEventIDKey                  @"5001013"

static NSMutableDictionary *displayedDic;

@implementation WLTrackerPostDisplay

+ (void)appendTrackerWithDisplayAction:(WLTrackerPostDisplayAction)action {
    [[WLTracker getInstance] synchronize];
    
    if (displayedDic.count == 0) {
        return;
    }
    
    [displayedDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[WLPostBase class]]) {
            WLPostBase *postModel = (WLPostBase *)obj;
            NSMutableDictionary *eventInfo = [self eventInfoWithPost:postModel];
            [eventInfo setObject:@(action) forKey:kWLTrackerPostDisplayActionKey];
            
            if (action != WLTrackerPostDisplayAction_Detail) {
                NSString *source = trackerFeedSource(postModel.trackerSource, postModel.trackerSubType);
                if (source) {
                    [eventInfo setObject:source forKey:kWLTrackerPostDisplaySourceKey];
                }
            }
            
            [[WLTracker getInstance] appendEventId:kWLTrackerPostDisplayEventIDKey
                                         eventInfo:eventInfo];
        }
    }];
    
    [displayedDic removeAllObjects];
}

+ (void)addDisplayedPost:(WLPostBase *)post {
    if (!displayedDic) {
        displayedDic = [NSMutableDictionary dictionary];
    }
    
    if (post) {
        [displayedDic setObject:post forKey:post.pid];
    }
}

+ (NSMutableDictionary *)eventInfoWithPost:(WLPostBase *)postModel {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    if (!postModel) {
        return eventInfo;
    }
    
    WLPostBase *rootPost = nil;
    if (postModel.type == WELIKE_POST_TYPE_FORWARD) {
        rootPost = [(WLForwardPost *)postModel rootPost];
    }
    
    if ([AppContext getInstance].accountManager.myAccount.uid.length > 0) {
        [eventInfo setObject:[AppContext getInstance].accountManager.myAccount.uid forKey:kWLTrackerPostDisplayViewerIDKey];
    }
    
    if (postModel.uid.length > 0) {
        [eventInfo setObject:postModel.uid forKey:kWLTrackerPostDisplayPostUIDKey];
    }
    
    if (postModel.pid.length > 0) {
        [eventInfo setObject:postModel.pid forKey:kWLTrackerPostDisplayPostIDKey];
    }
    
    if (rootPost.uid.length > 0) {
        [eventInfo setObject:rootPost.uid forKey:kWLTrackerPostDisplayRootPostUIDKey];
    }
    
    if (rootPost.pid.length > 0) {
        [eventInfo setObject:rootPost.pid forKey:kWLTrackerPostDisplayRootPostIDKey];
    }
    
    WLTrackerRepostType postType = trackerPostType(postModel);
    [eventInfo setObject:@(postType) forKey:kWLTrackerPostDisplayTypeKey];
    
    return eventInfo;
}

@end
