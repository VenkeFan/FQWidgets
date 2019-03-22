//
//  WLTrendingTopicsRequest.m
//  welike
//
//  Created by gyb on 2018/8/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTrendingTopicsRequest.h"
#import "WLTopicInfoModel.h"

@implementation WLTrendingTopicsRequest

- (instancetype)init
{
     return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"leaderboard/skip/topic/hot"]  method:AFHttpOperationMethodGET];
}

- (void)trendingTopicListWithCursor:(NSString *)cursor success:(TrendingTopicsRequestSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
      [self.params setObject:[NSNumber numberWithInteger:TrendingTopicsCount] forKey:@"count"];
      [self.params setObject:[NSNumber numberWithBool:YES] forKey:@"topPosts"]; //是否显示post
    
    
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
            
            NSMutableArray *topics = nil;

            if ([itemsJSON count] > 0)
            {
                topics = [NSMutableArray arrayWithCapacity:[itemsJSON count]];
                for (NSInteger i = 0; i < [itemsJSON count]; i++)
                {
                    WLTopicInfoModel *info = [WLTopicInfoModel parseFromNetworkJSON:[itemsJSON objectAtIndex:i]];
                    if (info != nil)
                    {
                        [topics addObject:info];
                    }
                }
            }

            if (successed)
            {
                successed(topics, cursor);
            }
        }
        else
        {
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
