//
//  WLAddPushTokenRequest.m
//  welike
//
//  Created by chiemy on 2018/5/31.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLAddPushTokenRequest.h"

@implementation WLAddPushTokenRequest

- (id)initAddPushTokenRequest
{
    return [super initWithType:AFHttpOperationTypeNormal api:@"push/token/add" method:AFHttpOperationMethodPOST];
}

- (void)addPushToken:(NSString *)token successed:(addPushSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    if (token != nil)
    {
        [self.params setObject:token forKey:@"pushToken"];
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
