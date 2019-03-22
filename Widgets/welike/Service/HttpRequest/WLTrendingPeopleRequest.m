//
//  WLTrendingPeopleRequest.m
//  welike
//
//  Created by gyb on 2018/8/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTrendingPeopleRequest.h"

@implementation WLTrendingPeopleRequest

- (instancetype)init
{
    if ([AppContext getInstance].accountManager.isLogin) {
        return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"discovery/user/top"] method:AFHttpOperationMethodGET];
    } else {
        return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"discovery/skip/user/top"] method:AFHttpOperationMethodGET];
    }
}

- (void)requestTrendingUsers:(TrendingPeopleRequestSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    [self.params setObject:[NSNumber numberWithInteger:10] forKey:@"pageSize"];//最多显示10个
    [self.params setObject:[NSNumber numberWithInteger:0] forKey:@"page"];
    
    self.onSuccessed = ^(id result) {
        
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            
            
            WLTrendingUserModel *model = [WLTrendingUserModel parseTrendingUserInfo:resDic];
            NSString *forwardUrl = [resDic stringForKey:@"forwardUrl"];
            
            if (successed)
            {
                successed(model, forwardUrl);
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
