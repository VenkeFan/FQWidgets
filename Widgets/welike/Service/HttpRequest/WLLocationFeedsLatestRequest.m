//
//  WLLocationFeedsLatestRequest.m
//  welike
//
//  Created by gyb on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLocationFeedsLatestRequest.h"
#import "WLPostBase.h"

@implementation WLLocationFeedsLatestRequest

- (id)initLocationFeedsLatest:(NSString *)placeId
{
    _placeId = placeId;
    return [super initWithType:AFHttpOperationTypeNormal api:@"lbs/place/feeds" method:AFHttpOperationMethodGET];
}


- (void)locationOfLatestFeeds:(NSInteger)pageNum successed:(requestSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    [self.params setObject:_placeId forKey:@"placeId"];
    [self.params setObject:[NSNumber numberWithInteger:pageNum] forKey:@"page"];
    [self.params setObject:[NSNumber numberWithInteger:POSTS_NUM_ONE_PAGE] forKey:@"pageSize"];
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            NSMutableArray *feeds = nil;
            NSArray *feedsJSON = [resDic objectForKey:@"list"];
            if ([feedsJSON count] > 0)
            {
                feeds = [NSMutableArray arrayWithCapacity:[feedsJSON count]];
                for (NSInteger i = 0; i < [feedsJSON count]; i++)
                {
                    WLPostBase *feed = [WLPostBase parseFromNetworkJSON:[feedsJSON objectAtIndex:i]];
                    feed.trackerSource = WLTrackerFeedSource_Location_Latest;
                    if (feed != nil)
                    {
                        [feeds addObject:feed];
                    }
                }
            }
            else
            {
                [WLTrackerFeed setEmptyDataTrackerSource:WLTrackerFeedSource_Location_Latest];
                [WLTrackerFeed setEmptyDataTrackerSubType:nil];
            }
            
            BOOL last = NO;
            if ([[resDic objectForKey:@"hasMore"] boolValue])
            {
                last = NO;
            }
            else
            {
                last = YES;
            }
            
            if (successed)
            {
                successed(feeds, last, pageNum);
            }
        }
        else
        {
            [WLTrackerFeed setEmptyDataTrackerSource:WLTrackerFeedSource_Location_Latest];
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
