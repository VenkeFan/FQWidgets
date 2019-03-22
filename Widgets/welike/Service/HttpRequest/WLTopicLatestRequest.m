//
//  WLTopicLatestRequest.m
//  welike
//
//  Created by fan qi on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTopicLatestRequest.h"
#import "WLPostBase.h"
#import "NSDictionary+JSON.h"
#import "WLAccountManager.h"

@implementation WLTopicLatestRequest

- (instancetype)initWithTopicID:(NSString *)topicID {
    
    if ([[[AppContext getInstance] accountManager] isLogin])
    {
        return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/topic/%@/posts", [topicID urlEncode:NSUTF8StringEncoding]] method:AFHttpOperationMethodGET];
    }
    else
    {
        
        return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/topic/h5/%@/posts", [topicID urlEncode:NSUTF8StringEncoding]] method:AFHttpOperationMethodGET];
    }
}

- (void)tryTopicLatestWithCursor:(NSString *)cursor successed:(topicLatestSuccessed)successed error:(failedBlock)error {
    [self.params removeAllObjects];
    
    [self.params setObject:[NSNumber numberWithInteger:POSTS_NUM_ONE_PAGE] forKey:@"count"];
    [self.params setObject:@"created" forKey:@"order"];
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
                    post.trackerSource = WLTrackerFeedSource_Topic_Latest;
                    [posts addObject:post];
                }
            }
            else
            {
                [WLTrackerFeed setEmptyDataTrackerSource:WLTrackerFeedSource_Topic_Latest];
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
            [WLTrackerFeed setEmptyDataTrackerSource:WLTrackerFeedSource_Topic_Latest];
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
