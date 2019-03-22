//
//  WLTrackerSearch.m
//  welike
//
//  Created by fan qi on 2018/12/11.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLTrackerSearch.h"
#import "WLPostBase.h"

#define kWLTrackerSearchEventIDKey                  @"5001012"

typedef NS_ENUM(NSInteger, WLTrackerSearchActionType) {
    WLTrackerSearchActionType_Recommend     = 1,
    WLTrackerSearchActionType_Result        = 2,
    WLTrackerSearchActionType_Detail        = 3
};

@implementation WLTrackerSearch

+ (void)appendTrackerSearchRecommend {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerSearchActionType_Recommend) forKey:@"action"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackerSearchEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendTrackerSearchResult:(NSString *)searchKey {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerSearchActionType_Result) forKey:@"action"];
    
    if (searchKey.length > 0) {
        [eventInfo setObject:searchKey forKey:@"search_key"];
    }
    
    [[WLTracker getInstance] appendEventId:kWLTrackerSearchEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendTrackerSearchDetail:(NSString *)searchKey userID:(NSString *)userID index:(NSInteger)index {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerSearchActionType_Detail) forKey:@"action"];
    
    if (searchKey.length > 0) {
        [eventInfo setObject:searchKey forKey:@"search_key"];
    }
    
    if (userID.length > 0) {
        [eventInfo setObject:userID forKey:@"user_uid"];
    }
    
    [eventInfo setObject:@(index) forKey:@"rank"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackerSearchEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendTrackerSearchDetail:(NSString *)searchKey post:(WLPostBase *)post index:(NSInteger)index {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerSearchActionType_Detail) forKey:@"action"];
    
    if (searchKey.length > 0) {
        [eventInfo setObject:searchKey forKey:@"search_key"];
    }
    
    if (post.pid.length > 0) {
        [eventInfo setObject:post.pid forKey:@"postid"];
    }
    
    if (post.language.length > 0) {
        [eventInfo setObject:post.language forKey:@"post_la"];
    }
    
    if (post.tags) {
        [eventInfo setObject:post.tags forKey:@"post_tags"];
    }
    
    [eventInfo setObject:@(index) forKey:@"rank"];
    
    [[WLTracker getInstance] appendEventId:kWLTrackerSearchEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

@end
