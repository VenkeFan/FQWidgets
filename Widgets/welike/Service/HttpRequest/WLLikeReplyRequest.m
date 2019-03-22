//
//  WLLikeReplyRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLikeReplyRequest.h"

@implementation WLLikeReplyRequest

- (id)initLikeReplyRequestWithUid:(NSString *)uid rid:(NSString *)rid
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/%@/like/reply/%@", uid, rid] method:AFHttpOperationMethodPUT];
}

- (void)like
{
    [self sendQuery];
}

@end
