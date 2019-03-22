//
//  WLPostDetailRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPostDetailRequest.h"
#import "WLAccountManager.h"

@implementation WLPostDetailRequest

- (id)initPostDetailRequestWithPid:(NSString *)pid
{
    if ([[[AppContext getInstance] accountManager] isLogin])
    {
         return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/post/%@", pid] method:AFHttpOperationMethodGET];
    }
    else
    {
         return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/post/h5/%@", pid] method:AFHttpOperationMethodGET];
    }
}

- (void)detailForSuccessed:(detailPostSuccessed)successed error:(failedBlock)error
{
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            WLPostBase *post = [WLPostBase parseFromNetworkJSON:result];
            post.trackerSource = WLTrackerFeedSource_FeedDetail;
            if (successed)
            {
                successed(post);
            }
        }
        else
        {
            [WLTrackerFeed setEmptyDataTrackerSource:WLTrackerFeedSource_FeedDetail];
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
