//
//  WLVideoSimilarRequest.m
//  welike
//
//  Created by fan qi on 2018/8/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLVideoSimilarRequest.h"
#import "WLPostBase.h"
#import "WLVideoPost.h"

@implementation WLVideoSimilarRequest {
    NSString *_postID;
}

- (instancetype)initWithPostID:(NSString *)postID {
    _postID = [postID copy];
    
    if ([[[AppContext getInstance] accountManager] isLogin]) {
        return [super initWithType:AFHttpOperationTypeNormal api:@"leaderboard/post/video/similar" method:AFHttpOperationMethodGET];
    } else {
        return [super initWithType:AFHttpOperationTypeNormal api:@"leaderboard/skip/post/video/similar" method:AFHttpOperationMethodGET];
    }
}

- (void)tryVideoSimilarWithCursor:(NSString *)cursor successed:(videoSimilarSuccessed)successed error:(failedBlock)error {
    [self.params removeAllObjects];
    
    [self.params setObject:[NSNumber numberWithInteger:POSTS_NUM_ONE_PAGE] forKey:@"count"];
    [self.params setObject:[self selectedInterests] forKey:@"interests"];
    if ([cursor length] > 0) {
        [self.params setObject:cursor forKey:@"cursor"];
    }
    if (_postID.length > 0) {
        [self.params setObject:_postID forKey:@"post"];
    }
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSMutableArray *videos = nil;
            NSDictionary *resDic = (NSDictionary *)result;
            NSArray *videosObj = [resDic objectForKey:@"list"];
            if ([videosObj isKindOfClass:[NSArray class]] == YES && [videosObj count] > 0)
            {
                NSArray *videosJSON = (NSArray *)videosObj;
                videos = [NSMutableArray arrayWithCapacity:[videosJSON count]];
                for (NSInteger i = 0; i < [videosJSON count]; i++)
                {
                    WLPostBase *post = [WLPostBase parseFromNetworkJSON:[videosJSON objectAtIndex:i]];
                    post.trackerSource = [AppContext getInstance].accountManager.isLogin ? WLTrackerFeedSource_Discover_Hot : WLTrackerFeedSource_UnLogin;
                    post.trackerSubType = kWLTrackerFeedSubType_VideoSimilar;
                    WLVideoPost *video = (WLVideoPost *)post;
                    [videos addObject:video];
                }
            }
            else
            {
                [WLTrackerFeed setEmptyDataTrackerSource:[AppContext getInstance].accountManager.isLogin ? WLTrackerFeedSource_Discover_Hot : WLTrackerFeedSource_UnLogin];
                [WLTrackerFeed setEmptyDataTrackerSubType:kWLTrackerFeedSubType_VideoSimilar];
            }
            
            NSString *cursor = [resDic stringForKey:@"cursor"];
            if (successed)
            {
                successed(videos, cursor);
            }
        }
        else
        {
            [WLTrackerFeed setEmptyDataTrackerSource:[AppContext getInstance].accountManager.isLogin ? WLTrackerFeedSource_Discover_Hot : WLTrackerFeedSource_UnLogin];
            [WLTrackerFeed setEmptyDataTrackerSubType:kWLTrackerFeedSubType_VideoSimilar];
            
            if (error)
            {
                error(ERROR_NETWORK_RESP_INVALID);
            }
        }
    };
    self.onFailed = error;
    [self sendQuery];
}

- (NSString *)selectedInterests {
    NSString *defaultInterestID = @"59";
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:defaultInterestID];
    
    NSArray *selectedItems = (NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:kSelectionInterestsKey];
    if (selectedItems.count > 0) {
        [array addObjectsFromArray:selectedItems];
    }
    
    NSMutableString *mutStr = [[NSMutableString alloc] init];
    for (int i = 0; i < array.count; i++) {
        if (i == 0) {
            [mutStr appendString:@"["];
            [mutStr appendString:array[i]];
        } else {
            [mutStr appendString:@","];
            [mutStr appendString:array[i]];
            
            if (i == array.count - 1) {
                [mutStr appendString:@"]"];
            }
        }
    }
    
    return mutStr;
}

@end
