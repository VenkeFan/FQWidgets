//
//  WLPushSettingGetRequest.m
//  welike
//
//  Created by chiemy on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPushSettingGetRequest.h"
#import "WLPushSetting.h"

@implementation WLPushSettingGetRequest

- (id)initPushSettingGetRequest
{
    return [super initWithType:AFHttpOperationTypeNormal api:@"push/switch" method:AFHttpOperationMethodGET];
}

- (void)getPushSettingSuccessed:(getPushSuccessed)successed error:(failedBlock)error
{
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]])
        {
            WLPushSetting *setting = [WLPushSetting parseFromNetworkJSON:result];
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
