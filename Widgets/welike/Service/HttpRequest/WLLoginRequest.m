//
//  WLLoginRequest.m
//  welike
//
//  Created by 刘斌 on 2018/4/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLoginRequest.h"
#import "NSDictionary+JSON.h"

@implementation WLLoginRequest

- (id)initLoginRequest
{
    return [super initWithType:AFHttpOperationTypeNormal api:@"user/login" method:AFHttpOperationMethodPOST];
}

- (void)loginWithMobile:(NSString *)mobile smsCode:(NSString *)smsCode successed:(loginSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    if ([mobile length] > 0 && [smsCode length] > 0)
    {
        [self.params setObject:mobile forKey:@"userName"];
        [self.params setObject:smsCode forKey:@"valideCode"];
    }
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            NSString *accessToken = [resDic stringForKey:@"access_token"];
            NSString *refreshToken = [resDic stringForKey:@"refresh_token"];
            long long expired = [resDic longLongForKey:@"expires_in" def:0];
            NSString *uid = nil;
            id userInfo = [result objectForKey:@"userinfo"];
            if (userInfo != nil && [userInfo isKindOfClass:[NSDictionary class]] == YES)
            {
                NSDictionary *userInfoDic = (NSDictionary *)userInfo;
                uid = [userInfoDic stringForKey:USER_JSON_KEY_UID];
            }
            if ([accessToken length] > 0 && [refreshToken length] > 0 && expired > 0 && [uid length] > 0)
            {
                WLAccount *account = [WLAccount parseFromNetworkJSON:(NSDictionary *)userInfo];
                account.accessToken = accessToken;
                account.expired = [[NSDate date] timeIntervalSince1970] * 1000 + expired * 1000;
                account.refreshToken = refreshToken;
                
                NSMutableArray *interests = [userInfo objectForKey:@"interests"];
                NSMutableArray *interestStrs = [[NSMutableArray alloc] initWithCapacity:0];
                if (interests.count > 0)
                {
                    for (int i = 0; i < interests.count; i++)
                    {
                        NSDictionary *dic = interests[i];
                        [interestStrs addObject:[dic stringForKey:@"id"]];
                    }
                    
                    account.interests = interestStrs;
                }
                
                WLAccountSetting *setting = [WLAccountSetting parseFromNetworkJSON:(NSDictionary *)userInfo];
                if (successed)
                {
                    successed(account, setting);
                }
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
