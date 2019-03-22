//
//  WLDislikeReplyRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLDislikeReplyRequest.h"

@implementation WLDislikeReplyRequest

- (id)initDislikeReplyRequestWithUid:(NSString *)uid rid:(NSString *)rid
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/%@/dislike/reply/%@", uid, rid] method:AFHttpOperationMethodDELETE];
}

- (void)dislike
{
    [self sendQuery];
}

@end
