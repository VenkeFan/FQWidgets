//
//  WLTopicHotRequest.m
//  welike
//
//  Created by fan qi on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTopicHotRequest.h"
#import "WLPostBase.h"
#import "NSDictionary+JSON.h"
#import "WLAccountManager.h"

@implementation WLTopicHotRequest {
    NSString *_topicID;
}

- (instancetype)initWithTopicID:(NSString *)topicID {
    _topicID = [topicID copy];
    
    
    if ([[[AppContext getInstance] accountManager] isLogin])
    {
         return [super initWithType:AFHttpOperationTypeNormal api:@"leaderboard/topic/24h" method:AFHttpOperationMethodGET];
    }
    else
    {
         return [super initWithType:AFHttpOperationTypeNormal api:@"leaderboard/topic/h5/24h" method:AFHttpOperationMethodGET];
    }
  
}

- (void)tryTopicHotWithCursor:(NSString *)cursor successed:(topicHotSuccessed)successed error:(failedBlock)error {
    [self.params removeAllObjects];
    
    [self.params setObject:[NSNumber numberWithInteger:POSTS_NUM_ONE_PAGE] forKey:@"count"];
    [self.params setObject:@"created" forKey:@"order"];
    if ([cursor length] > 0)
    {
        [self.params setObject:cursor forKey:@"cursor"];
    }
    if (_topicID.length > 0) {
        [self.params setObject:_topicID forKey:@"topicId"];
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
                    post.trackerSource = WLTrackerFeedSource_Topic_Hot;
                    [posts addObject:post];
                }
            }
            else
            {
                [WLTrackerFeed setEmptyDataTrackerSource:WLTrackerFeedSource_Topic_Hot];
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
            [WLTrackerFeed setEmptyDataTrackerSource:WLTrackerFeedSource_Topic_Hot];
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
