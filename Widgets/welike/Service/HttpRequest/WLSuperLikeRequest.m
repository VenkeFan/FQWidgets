//
//  WLSuperLikeRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/18.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSuperLikeRequest.h"

@implementation WLSuperLikeRequest

- (id)initSuperLikeRequestWithUid:(NSString *)uid pid:(NSString *)pid exp:(long long)exp
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/%@/superlike/post/%@/with/%lld", uid, pid, exp] method:AFHttpOperationMethodPOST];
}

- (void)like
{
    [self sendQuery];
}

@end
