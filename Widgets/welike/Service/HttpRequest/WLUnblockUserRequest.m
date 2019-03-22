//
//  WLUnblockUserRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUnblockUserRequest.h"

@interface WLUnblockUserRequest ()

@property (nonatomic, copy) NSString *uid;

@end

@implementation WLUnblockUserRequest

- (id)initUnblockUserRequestWithMyUid:(NSString *)myUid unblockUid:(NSString *)uid
{
    self = [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"relationship/user/%@/unblock/%@", myUid, uid] method:AFHttpOperationMethodDELETE];
    if (self)
    {
        self.uid = uid;
    }
    return self;
}

- (void)unblockAndSuccessed:(unblockSuccessed)successed error:(failedBlock)error
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
