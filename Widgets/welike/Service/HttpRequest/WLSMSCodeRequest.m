//
//  WLSMSCodeRequest.m
//  welike
//
//  Created by 刘斌 on 2018/4/13.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSMSCodeRequest.h"

@implementation WLSMSCodeRequest

- (id)initSMSCodeRequest
{
    return [super initWithType:AFHttpOperationTypeNormal api:@"user/login/sms" method:AFHttpOperationMethodPOST];
}

- (void)reqSMSCodeWithMobile:(NSString *)mobile nationCode:(NSString *)nationCode successed:(smsCodeSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    if ([mobile length] > 0 && [nationCode length] > 0)
    {
        [self.params setObject:mobile forKey:@"phoneNumber"];
        [self.params setObject:nationCode forKey:@"nationCode"];
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
