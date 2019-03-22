//
//  WLDeletePushTokenRequest.m
//  welike
//
//  Created by chiemy on 2018/5/31.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLDeletePushTokenRequest.h"

@implementation WLDeletePushTokenRequest

- (id)initDeletePushTokenRequest
{
    return [super initWithType:AFHttpOperationTypeNormal api:@"push/token/del" method:AFHttpOperationMethodPOST];
}

- (void)deletePushTokenSuccessed:(deletePushSuccessed)successed error:(failedBlock)error;
{
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
