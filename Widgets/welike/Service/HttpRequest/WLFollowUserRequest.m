//
//  WLFollowUserRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFollowUserRequest.h"

@interface WLFollowUserRequest ()

@property (nonatomic, copy) NSString *uid;

@end

@implementation WLFollowUserRequest

- (id)initFollowUserRequestWithMyUid:(NSString *)myUid toUid:(NSString *)toUid
{
    self = [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/%@/follow/%@", myUid, toUid] method:AFHttpOperationMethodPUT];
    if (self)
    {
        self.uid = toUid;
    }
    return self;
}

- (void)followSuccessed:(followUserSuccessed)successed error:(failedBlock)error
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
