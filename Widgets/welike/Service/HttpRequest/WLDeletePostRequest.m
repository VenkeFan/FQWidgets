//
//  WLDeletePostRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLDeletePostRequest.h"

@interface WLDeletePostRequest ()

@property (nonatomic, copy) NSString *pid;

@end

@implementation WLDeletePostRequest

- (id)initDeletePostRequestWithUid:(NSString *)uid pid:(NSString *)pid
{
    self = [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/%@/delete/post/%@", uid, pid] method:AFHttpOperationMethodDELETE];
    if (self)
    {
        self.pid = pid;
    }
    return self;
}

- (void)deletePostForSuccessed:(deletePostSuccessed)successed error:(failedBlock)error;
{
    __weak typeof(self) weakSelf = self;
    self.onSuccessed = ^(id result) {
        if (successed)
        {
            successed(weakSelf.pid);
        }
    };
    self.onFailed = error;
    [self sendQuery];
}

@end
