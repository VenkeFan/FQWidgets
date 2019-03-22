//
//  WLDeleteReplyRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLDeleteReplyRequest.h"

@interface WLDeleteReplyRequest ()

@property (nonatomic, copy) NSString *rid;

@end

@implementation WLDeleteReplyRequest

- (id)initDeleteReplyRequestWithUid:(NSString *)uid rid:(NSString *)rid
{
    self = [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/%@/delete/reply/%@", uid, rid] method:AFHttpOperationMethodDELETE];
    if (self)
    {
        self.rid = rid;
    }
    return self;
}

- (void)deleteReplyForSuccessed:(deleteReplySuccessed)successed error:(failedBlock)error
{
    __weak typeof(self) weakSelf = self;
    self.onSuccessed = ^(id result) {
        if (successed)
        {
            successed(weakSelf.rid);
        }
    };
    self.onFailed = error;
    [self sendQuery];
}

@end
