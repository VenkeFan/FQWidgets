//
//  WLTrendingBannerRequest.m
//  welike
//
//  Created by gyb on 2018/8/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTrendingBannerRequest.h"
#import "WLTopicInfoModel.h"

@implementation WLTrendingBannerRequest

- (instancetype)init
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"conplay/topic/resident/skip/topics/2/30"]  method:AFHttpOperationMethodGET];
}

- (void)trendingBannerList:(TrendingBannerRequestSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    self.onSuccessed = ^(id result) {
        
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            NSArray *itemsJSON = [resDic objectForKey:@"list"];
            
            NSMutableArray *keys;
            
            if ([itemsJSON count] > 0)
            {
                keys = [NSMutableArray arrayWithCapacity:[itemsJSON count]];
                for (NSInteger i = 0; i < [itemsJSON count]; i++)
                {
                    WLTopicInfoModel *model = [WLTopicInfoModel parseFromNetworkJSON:itemsJSON[i]];
                    if (model != nil)
                    {
                        [keys addObject:model];
                    }
                }
            }
            if (successed)
            {
                successed(keys);
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
