//
//  WLUnfollowUserRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUnfollowUserRequest.h"

@interface WLUnfollowUserRequest ()

@property (nonatomic, copy) NSString *uid;

@end

@implementation WLUnfollowUserRequest

- (id)initUnfollowUserRequestWithMyUid:(NSString *)myUid toUid:(NSString *)toUid
{
    self = [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/%@/unfollow/%@", myUid, toUid] method:AFHttpOperationMethodDELETE];
    if (self)
    {
        self.uid = toUid;
    }
    return self;
}

- (void)unfollowSuccessed:(unfollowUserSuccessed)successed error:(failedBlock)error
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
