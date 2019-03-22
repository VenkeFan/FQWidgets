//
//  WLSyncAccountRequest.m
//  welike
//
//  Created by 刘斌 on 2018/4/27.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSyncAccountRequest.h"
#import "WLAccountManager.h"

@implementation WLSyncAccountRequest

- (id)initSyncAccountRequest
{
    return [super initWithType:AFHttpOperationTypeNormal api:@"user/update" method:AFHttpOperationMethodPOST];
}

- (void)syncAccount:(NSString *)uid info:(NSDictionary *)userInfo successed:(syncAccountSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    if (userInfo != nil)
    {
        [self.params setDictionary:userInfo];
    }
    if ([uid length] > 0)
    {
        [self.params setObject:uid forKey:@"id"];
    }
    self.onSuccessed = ^(id result) {
        if (result != nil && [result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *userInfoDic = (NSDictionary *)result;
            WLAccount *account = [WLAccount parseFromNetworkJSON:userInfoDic];
            if (successed)
            {
                successed(account);
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

- (void)syncAccount:(NSString *)uid interests:(NSArray *)interests successed:(syncAccountSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    if ([uid length] > 0)
    {
        [self.params setObject:uid forKey:@"id"];
    }
    if (interests != nil)
    {
        [self.params setObject:interests forKey:@"interests"];
    }
    self.onSuccessed = ^(id result) {
        if (result != nil && [result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *userInfoDic = (NSDictionary *)result;
            WLAccount *account = [WLAccount parseFromNetworkJSON:userInfoDic];
            if (successed)
            {
                successed(account);
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

- (void)syncAccount:(NSString *)uid setting:(WLAccountSetting *)setting successed:(syncAccountSettingSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    if ([uid length] > 0)
    {
        [self.params setObject:uid forKey:@"id"];
    }
    if (setting != nil)
    {
        [self.params setObject:[setting toNetworkJSON] forKey:@"settings"];
    }
    else
    {
        setting = [[WLAccountSetting alloc] init];
        [self.params setObject:[setting toNetworkJSON] forKey:@"settings"];
    }
    self.onSuccessed = ^(id result) {
        if (result != nil && [result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *userInfoDic = (NSDictionary *)result;
            WLAccountSetting *setting = [WLAccountSetting parseFromNetworkJSON:userInfoDic];
            if (successed)
            {
                successed(setting);
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
