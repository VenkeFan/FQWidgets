//
//  WLSearchLatestRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchLatestRequest.h"
#import "WLUser.h"
#import "WLPostBase.h"

@implementation WLSearchLatestRequest

- (id)initSearchLatestRequest
{
    return [super initWithType:AFHttpOperationTypeNormal api:@"/search/skip/top/content" method:AFHttpOperationMethodGET];
}

- (void)searchWithKeyword:(NSString *)keyword pageNum:(NSInteger)pageNum successed:(searchLatestSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    [self.params setObject:keyword forKey:@"query"];
    [self.params setObject:[NSNumber numberWithInteger:pageNum] forKey:@"pageNumber"];
    [self.params setObject:[NSNumber numberWithInteger:SEARCH_POSTS_NUMBER_ONE_PAGE] forKey:@"count"];
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            NSMutableArray *users = nil;
            NSMutableArray *posts = nil;
            NSArray *usersJSON = [resDic objectForKey:@"users"];
            NSArray *postsJSON = [resDic objectForKey:@"posts"];
            if ([usersJSON count] > 0)
            {
                users = [NSMutableArray arrayWithCapacity:[usersJSON count]];
                for (NSInteger i = 0; i < [usersJSON count]; i++)
                {
                    WLUser *user = [WLUser parseFromNetworkJSON:[usersJSON objectAtIndex:i]];
                    if (user != nil)
                    {
                        [users addObject:user];
                    }
                    
                }
            }
            if ([postsJSON count] > 0)
            {
                posts = [NSMutableArray arrayWithCapacity:[postsJSON count]];
                for (NSInteger i = 0; i < [postsJSON count]; i++)
                {
                    WLPostBase *post = [WLPostBase parseFromNetworkJSON:[postsJSON objectAtIndex:i]];
                    post.trackerSource = WLTrackerFeedSource_Search_Latest;
                    if (post != nil)
                    {
                        [posts addObject:post];
                    }
                }
            }
            else
            {
                [WLTrackerFeed setEmptyDataTrackerSource:WLTrackerFeedSource_Search_Latest];
                [WLTrackerFeed setEmptyDataTrackerSubType:nil];
            }
            
            BOOL last = NO;
            if ([posts count] < SEARCH_POSTS_NUMBER_ONE_PAGE)
            {
                last = YES;
            }
            if (successed)
            {
                successed(posts, users, last, pageNum);
            }
        }
        else
        {
            [WLTrackerFeed setEmptyDataTrackerSource:WLTrackerFeedSource_Search_Latest];
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
