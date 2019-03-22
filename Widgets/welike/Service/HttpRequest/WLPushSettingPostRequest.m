//
//  WLPushSettingPostRequest.m
//  welike
//
//  Created by chiemy on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPushSettingPostRequest.h"
#import "WLAccountManager.h"

@implementation WLPushSettingPostRequest

- (id)initPushSettingPostRequest
{
    return [super initWithType:AFHttpOperationTypeNormal api:@"push/switch/add" method:AFHttpOperationMethodPOST];
}

- (void)syncPushSetting:(NSDictionary *)setting successed:(deletePushSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    if (setting != nil)
    {
        [self.params setDictionary:setting];
    }
    
    self.onSuccessed = ^(id result) {
        if (successed)
        {
            successed();
        }
    };
    self.onFailed = error;
    [self sendQuery];
}

@end
