//
//  WLDeleteCommentRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLDeleteCommentRequest.h"

@interface WLDeleteCommentRequest ()

@property (nonatomic, copy) NSString *cid;

@end

@implementation WLDeleteCommentRequest

- (id)initDeleteCommentRequestWithUid:(NSString *)uid cid:(NSString *)cid
{
    self = [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/%@/delete/comment/%@", uid, cid] method:AFHttpOperationMethodDELETE];
    if (self)
    {
        self.cid = cid;
    }
    return self;
}

- (void)deleteCommentForSuccessed:(deleteCommentSuccessed)successed error:(failedBlock)error
{
    __weak typeof(self) weakSelf = self;
    self.onSuccessed = ^(id result) {
        if (successed)
        {
            successed(weakSelf.cid);
        }
    };
    self.onFailed = error;
    [self sendQuery];
}

@end
