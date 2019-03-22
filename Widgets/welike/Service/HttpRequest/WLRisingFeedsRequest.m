//
//  WLRisingFeedsRequest.m
//  welike
//
//  Created by fan qi on 2018/12/20.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLRisingFeedsRequest.h"
#import "WLPostBase.h"
#import "NSDictionary+JSON.h"

@implementation WLRisingFeedsRequest

- (instancetype)init {
    if ([AppContext getInstance].accountManager.isLogin) {
        return [super initWithType:AFHttpOperationTypeNormal api:@"leaderboard/rising" method:AFHttpOperationMethodGET];
    } else {
        return [super initWithType:AFHttpOperationTypeNormal api:@"leaderboard/skip/rising" method:AFHttpOperationMethodGET];
    }
}

- (void)tryRisingFeedsWithCursor:(NSString *)cursor
                       interests:(NSArray *)interests
                       successed:(void(^)(NSArray *feeds, NSString *cursor))successed
                           error:(failedBlock)error {
    [self.params removeAllObjects];
    
    [self.params setObject:[NSNumber numberWithInteger:POSTS_NUM_ONE_PAGE] forKey:@"count"];
    if ([cursor length] > 0) {
        [self.params setObject:cursor forKey:@"cursor"];
    }
    
    if ([[LuuUtils deviceId] length] > 0) {
        [self.params setObject:[LuuUtils deviceId] forKey:@"gid"];
    }
    if (interests) {
        NSMutableString *strM = [[NSMutableString alloc] init];
        [strM appendString:@"["];

        for (int i = 0; i < interests.count; i++) {
            if (i == 0) {
                [strM appendString:interests[i]];
            } else {
                [strM appendString:@","];
                [strM appendString:interests[i]];
            }
        }
        [strM appendString:@"]"];
        
        [self.params setObject:strM ?: @"" forKey:@"interests"];
    }
    
    [self.params setObject:@"vidmate" forKey:@"userType"];
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES) {
            NSMutableArray *posts = nil;
            NSDictionary *resDic = (NSDictionary *)result;
            NSArray *postsObj = [resDic objectForKey:@"list"];
            if ([postsObj isKindOfClass:[NSArray class]] == YES && [postsObj count] > 0) {
                NSArray *postsJSON = (NSArray *)postsObj;
                posts = [NSMutableArray arrayWithCapacity:[postsJSON count]];
                for (NSInteger i = 0; i < [postsJSON count]; i++) {
                    WLPostBase *post = [WLPostBase parseFromNetworkJSON:[postsJSON objectAtIndex:i]];
                    post.trackerSource = WLTrackerFeedSource_Discover_Latest;
                    [posts addObject:post];
                }
            } else {
                [WLTrackerFeed setEmptyDataTrackerSource:WLTrackerFeedSource_Discover_Latest];
                [WLTrackerFeed setEmptyDataTrackerSubType:nil];
            }
            
            NSString *cursor = [resDic stringForKey:@"cursor"];
            if (successed) {
                successed(posts, cursor);
            }
        } else {
            [WLTrackerFeed setEmptyDataTrackerSource:WLTrackerFeedSource_Discover_Latest];
            [WLTrackerFeed setEmptyDataTrackerSubType:nil];
            
            if (error) {
                error(ERROR_NETWORK_RESP_INVALID);
            }
        }
    };
    self.onFailed = error;
    [self sendQuery];
}

@end
