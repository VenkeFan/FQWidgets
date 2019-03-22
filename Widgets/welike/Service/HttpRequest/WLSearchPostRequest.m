//
//  WLSearchPostRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchPostRequest.h"
#import "WLPostBase.h"

@implementation WLSearchPostRequest

- (id)initSearchPostRequest
{
    return [super initWithType:AFHttpOperationTypeNormal api:@"/search/skip/post/content" method:AFHttpOperationMethodGET];
}

- (void)searchWithKeyword:(NSString *)keyword pageNum:(NSInteger)pageNum successed:(searchPostsSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    [self.params setObject:keyword forKey:@"content"];
    [self.params setObject:[NSNumber numberWithInteger:pageNum] forKey:@"pageNumber"];
    [self.params setObject:[NSNumber numberWithInteger:SEARCH_POSTS_NUMBER_ONE_PAGE] forKey:@"count"];
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            NSMutableArray *posts = nil;
            NSArray *postsJSON = [resDic objectForKey:@"list"];
            if ([postsJSON count] > 0)
            {
                posts = [NSMutableArray arrayWithCapacity:[postsJSON count]];
                for (NSInteger i = 0; i < [postsJSON count]; i++)
                {
                    WLPostBase *post = [WLPostBase parseFromNetworkJSON:[postsJSON objectAtIndex:i]];
                    post.trackerSource = WLTrackerFeedSource_Search_Posts;
                    if (post != nil)
                    {
                        [posts addObject:post];
                    }
                }
            }
            else
            {
                [WLTrackerFeed setEmptyDataTrackerSource:WLTrackerFeedSource_Search_Posts];
                [WLTrackerFeed setEmptyDataTrackerSubType:nil];
            }
            
            BOOL last = NO;
            if ([posts count] < SEARCH_POSTS_NUMBER_ONE_PAGE)
            {
                last = YES;
            }
            if (successed)
            {
                successed(posts, last, pageNum);
            }
        }
        else
        {
            [WLTrackerFeed setEmptyDataTrackerSource:WLTrackerFeedSource_Search_Posts];
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
