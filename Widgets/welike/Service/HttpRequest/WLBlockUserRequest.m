//
//  WLBlockUserRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLBlockUserRequest.h"

@interface WLBlockUserRequest ()

@property (nonatomic, copy) NSString *uid;

@end

@implementation WLBlockUserRequest

- (id)initBlockUserRequestWithMyUid:(NSString *)myUid blockUid:(NSString *)uid
{
    self = [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"relationship/user/%@/block/%@", myUid, uid] method:AFHttpOperationMethodPUT];
    if (self)
    {
        self.uid = uid;
    }
    return self;
}

- (void)blockAndSuccessed:(blockSuccessed)successed error:(failedBlock)error
{
    __weak typeof(self) weakSelf = self;
    self.onSuccessed = ^(id result) {
        if (successed)
        {
            successed(weakSelf.uid);
        }
    };
    self.onFailed = error;
    [self sendQuery];
}

@end
