//
//  WLHomeFeedsRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLHomeFeedsRequest.h"
#import "WLPostBase.h"
#import "NSDictionary+JSON.h"

@implementation WLHomeFeedsRequest

- (id)initHomeFeedsRequestWithUid:(NSString *)uid
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/%@/feeds", uid] method:AFHttpOperationMethodGET];
}

- (void)tryHomeFeedsWithCursor:(NSString *)cursor successed:(homeFeedsSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    [self.params setObject:[NSNumber numberWithInteger:POSTS_NUM_ONE_PAGE] forKey:@"count"];
    if ([cursor length] > 0)
    {
        [self.params setObject:cursor forKey:@"cursor"];
    }
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSMutableArray *posts = nil;
            NSDictionary *resDic = (NSDictionary *)result;
            NSArray *postsObj = [resDic objectForKey:@"list"];
            if ([postsObj isKindOfClass:[NSArray class]] == YES && [postsObj count] > 0)
            {
                NSArray *postsJSON = (NSArray *)postsObj;
                posts = [NSMutableArray arrayWithCapacity:[postsJSON count]];
                for (NSInteger i = 0; i < [postsJSON count]; i++)
                {
                    WLPostBase *post = [WLPostBase parseFromNetworkJSON:[postsJSON objectAtIndex:i]];
                    post.trackerSource = WLTrackerFeedSource_Home;
                    [posts addObject:post];
                }
            }
            else
            {
                [WLTrackerFeed setEmptyDataTrackerSource:WLTrackerFeedSource_Home];
                [WLTrackerFeed setEmptyDataTrackerSubType:nil];
            }
            
            NSString *cursor = [resDic stringForKey:@"cursor"];
            if (successed)
            {
                successed(posts, cursor);
            }
        }
        else
        {
            [WLTrackerFeed setEmptyDataTrackerSource:WLTrackerFeedSource_Home];
            [WLTrackerFeed setEmptyDataTrackerSubType:nil];
            
            if (error)
            {
                error(ERROR_NETWORK_RESP_INVALID);
            }
        }
    };
    self.onFailed = error;
    [self sendQuery];
}

@end
