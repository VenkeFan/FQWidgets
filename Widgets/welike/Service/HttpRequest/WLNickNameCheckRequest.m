//
//  WLNickNameCheckRequest.m
//  welike
//
//  Created by 刘斌 on 2018/4/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNickNameCheckRequest.h"

@implementation WLNickNameCheckRequest

- (id)initNickNameCheckRequest
{
    return [super initWithType:AFHttpOperationTypeNormal api:@"user/validate-nick-name" method:AFHttpOperationMethodGET];
}

- (void)checkForNickName:(NSString *)nickName successed:(nickNameSuccessed)successed error:(failedBlock)error
{
    _nickName = [nickName copy];
    [self.params removeAllObjects];
    [self.params setObject:_nickName forKey:@"nickName"];
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
