//
//  WLThirdLoginRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/31.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLThirdLoginRequest.h"
#import "NSDictionary+JSON.h"

@implementation WLThirdLoginRequest

- (id)initThirdLoginRequest
{
    return [super initWithType:AFHttpOperationTypeNormal api:@"user/login/third" method:AFHttpOperationMethodPOST];
}

- (void)loginWithType:(NSInteger)type token:(NSString *)token successed:(loginSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    [self.urlExtParams removeAllObjects];
    
    [self.urlExtParams setObject:[NSString stringWithFormat:@"%ld", (long)type] forKey:@"loginType"];
    [self.params setObject:token forKey:@"token"];
    
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
