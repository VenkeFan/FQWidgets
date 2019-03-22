//
//  WLVerticalVideoRequest.m
//  welike
//
//  Created by gyb on 2018/8/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLVerticalVideoRequest.h"
#import "WLPostBase.h"


@implementation WLVerticalVideoRequest

- (instancetype)init
{
    if ([[[AppContext getInstance] accountManager] isLogin]) {
        return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"/leaderboard/post/video/24h"] method:AFHttpOperationMethodGET];
    } else {
        return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"/leaderboard/skip/post/video/24h"] method:AFHttpOperationMethodGET];
    }
}

- (void)requestVerticalVideoFeedsWithCursor:(NSString *)cursor  interests:(NSArray *)interests successed:(VerticalVideoFeedsRequestSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    [self.params setObject:[NSNumber numberWithInteger:VerticalPageCount] forKey:@"count"];
    
    NSMutableString *intrestStr = [[NSMutableString alloc] initWithString:@""];
    for (int i = 0; i < interests.count; i++)
    {
        [intrestStr appendString:[NSString stringWithFormat:@"%@,",interests[i]]];
    }
    
    if (intrestStr.length > 0)
    {
        [intrestStr insertString:@"[" atIndex:0];
        [intrestStr deleteCharactersInRange:NSMakeRange(intrestStr.length - 1, 1)];
        [intrestStr appendString:@"]"];
    }
    
    [self.params setObject:intrestStr forKey:@"interests"];
    [self.params setObject:@"vidmate" forKey:@"userType"];
    [self.params setObject:[LuuUtils deviceId] forKey:@"gid"];
    [self.params setObject:@"video" forKey:@"postType"];
    
    
    if (cursor.length > 0)
    {
        [self.params setObject:cursor forKey:@"cursor"];
    }
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            
            NSArray *itemsJSON = [resDic objectForKey:@"list"];
            NSString *cursor = [resDic stringForKey:@"cursor"];
            
            NSMutableArray *feeds = nil;
            
            if ([itemsJSON count] > 0)
            {
                feeds = [NSMutableArray arrayWithCapacity:[itemsJSON count]];
                for (NSInteger i = 0; i < [itemsJSON count]; i++)
                {
                    WLPostBase *info = [WLPostBase parseFromNetworkJSON:[itemsJSON objectAtIndex:i]];
                    info.trackerSource = [AppContext getInstance].accountManager.isLogin ? WLTrackerFeedSource_Discover_Hot : WLTrackerFeedSource_UnLogin;
                    info.trackerSubType = kWLTrackerFeedSubType_InterestVideo;
                    if (info != nil)
                    {
                        [feeds addObject:info];
                    }
                }
            }
            else
            {
                [WLTrackerFeed setEmptyDataTrackerSource:[AppContext getInstance].accountManager.isLogin ? WLTrackerFeedSource_Discover_Hot : WLTrackerFeedSource_UnLogin];
                [WLTrackerFeed setEmptyDataTrackerSubType:kWLTrackerFeedSubType_InterestVideo];
            }
            
            if (successed)
            {
                successed(feeds, cursor);
            }
        }
        else
        {
            [WLTrackerFeed setEmptyDataTrackerSource:[AppContext getInstance].accountManager.isLogin ? WLTrackerFeedSource_Discover_Hot : WLTrackerFeedSource_UnLogin];
            [WLTrackerFeed setEmptyDataTrackerSubType:kWLTrackerFeedSubType_InterestVideo];
            
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
