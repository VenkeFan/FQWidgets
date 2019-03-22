//
//  WLLikeCommentRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLikeCommentRequest.h"

@implementation WLLikeCommentRequest

- (id)initLikeCommentRequestWithUid:(NSString *)uid cid:(NSString *)cid
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/%@/like/comment/%@", uid, cid] method:AFHttpOperationMethodPUT];
}

- (void)like
{
    [self sendQuery];
}

@end
