//
//  WLDislikePostRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/18.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLDislikePostRequest.h"

@implementation WLDislikePostRequest

- (id)initDislikeRequestWithUid:(NSString *)uid pid:(NSString *)pid
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/%@/dislike/post/%@", uid, pid] method:AFHttpOperationMethodDELETE];
}

- (void)dislike
{
    [self sendQuery];
}

@end
