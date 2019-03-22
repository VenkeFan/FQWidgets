//
//  WLAuthRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLAuthRequest.h"
#import "NSDictionary+JSON.h"

@implementation WLAuthRequest

- (id)initAuthRequest
{
    return [super initWithType:AFHttpOperationTypeNormal api:@"auth/token/refresh" method:AFHttpOperationMethodPOST];
}

- (void)authWithRefreshToken:(NSString *)refreshToken successed:(authSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    [self.params setObject:refreshToken forKey:@"refresh_token"];
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            NSString *accessToken = [resDic stringForKey:@"access_token"];
            NSString *refreshToken = [resDic stringForKey:@"refresh_token"];
            long long expired = [resDic longLongForKey:@"expires_in" def:0];
            if ([accessToken length] > 0 && [refreshToken length] > 0 && expired > 0)
            {
                WLAccount *account = [[AppContext getInstance].accountManager myAccount];
                if (account != nil)
                {
                    account.accessToken = accessToken;
                    account.expired = [[NSDate date] timeIntervalSince1970] * 1000 + expired * 1000;
                    account.refreshToken = refreshToken;
                    if (successed)
                    {
                        successed(account);
                    }
                    return;
                }
            }
            if (error)
            {
                error(ERROR_NETWORK_RESP_INVALID);
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
