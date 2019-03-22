//
//  WLLocationFeedsHotRequest.m
//  welike
//
//  Created by gyb on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLocationFeedsHotRequest.h"
#import "WLPostBase.h"

@implementation WLLocationFeedsHotRequest

- (id)initLocationHotFeeds:(NSString *)placeId
{
    _placeId = placeId;
    return [super initWithType:AFHttpOperationTypeNormal api:@"leaderboard/location/24h" method:AFHttpOperationMethodGET];
}

- (void)locationOfHotFeeds:(NSString *)cursor successed:(locationHotFeedsRequestSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];

    [self.params setObject:_placeId forKey:@"locationId"];

    [self.params setObject:[NSNumber numberWithInteger:POSTS_NUM_ONE_PAGE] forKey:@"count"];
    
    if ([cursor length] > 0)
    {
        [self.params setObject:cursor forKey:@"cursor"];
    }
    

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
                    feed.trackerSource = WLTrackerFeedSource_Location_Hot;
                    if (feed != nil)
                    {
                        [feeds addObject:feed];
                    }
                }
            }
            else
            {
                [WLTrackerFeed setEmptyDataTrackerSource:WLTrackerFeedSource_Location_Hot];
                [WLTrackerFeed setEmptyDataTrackerSubType:nil];
            }
            
            NSString *cursor = [resDic stringForKey:@"cursor"];
          
            if (successed)
            {
                successed(feeds, cursor);
            }
        }
        else
        {
            [WLTrackerFeed setEmptyDataTrackerSource:WLTrackerFeedSource_Location_Hot];
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
