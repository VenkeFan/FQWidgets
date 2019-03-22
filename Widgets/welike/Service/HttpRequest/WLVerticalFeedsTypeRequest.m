//
//  WLVerticalFeedsTypeRequest.m
//  welike
//
//  Created by gyb on 2018/7/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLVerticalFeedsTypeRequest.h"
#import "WLPostBase.h"


@implementation WLVerticalFeedsTypeRequest

- (instancetype)init
{
    if ([[[AppContext getInstance] accountManager] isLogin]) {
        return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"leaderboard/interest/24h"] method:AFHttpOperationMethodGET];
    } else {
        return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"leaderboard/skip/interest/24h"] method:AFHttpOperationMethodGET];
    }
}

- (void)requestVerticalFeedsWithCursor:(NSString *)cursor interestId:(NSString *)interestId successed:(VerticalFeedsTypeRequestSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    [self.params setObject:[NSNumber numberWithInteger:5] forKey:@"count"];
    [self.params setObject:interestId forKey:@"interestId"];
    [self.params setObject:[LuuUtils deviceId] forKey:@"gid"];
    
    if (cursor.length > 0)
    {
        [self.params setObject:cursor forKey:@"cursor"];
    }
    else
    {
        [self.params setObject:@"" forKey:@"cursor"];
    }
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            
            NSArray *itemsJSON = [resDic objectForKey:@"list"];
            NSString *newCursor = [resDic stringForKey:@"cursor"];
            
            NSMutableArray *feeds = nil;
            
            if ([itemsJSON count] > 0)
            {
                feeds = [NSMutableArray arrayWithCapacity:[itemsJSON count]];
                for (NSInteger i = 0; i < [itemsJSON count]; i++)
                {
                    WLPostBase *info = [WLPostBase parseFromNetworkJSON:[itemsJSON objectAtIndex:i]];
                    info.trackerSource = [AppContext getInstance].accountManager.isLogin ? WLTrackerFeedSource_Discover_Hot : WLTrackerFeedSource_UnLogin;
                    info.trackerSubType = interestId;
                    if (info != nil)
                    {
                        [feeds addObject:info];
                    }
                }
            }
            else
            {
                [WLTrackerFeed setEmptyDataTrackerSource:[AppContext getInstance].accountManager.isLogin ? WLTrackerFeedSource_Discover_Hot : WLTrackerFeedSource_UnLogin];
                [WLTrackerFeed setEmptyDataTrackerSubType:interestId];
            }
            
            if (successed)
            {
                successed(feeds, newCursor);
            }
        }
        else
        {
            [WLTrackerFeed setEmptyDataTrackerSource:[AppContext getInstance].accountManager.isLogin ? WLTrackerFeedSource_Discover_Hot : WLTrackerFeedSource_UnLogin];
            [WLTrackerFeed setEmptyDataTrackerSubType:interestId];
            
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
