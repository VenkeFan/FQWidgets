//
//  WLDislikeCommentRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLDislikeCommentRequest.h"

@implementation WLDislikeCommentRequest

- (id)initDislikeCommentRequestWithUid:(NSString *)uid cid:(NSString *)cid
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/%@/dislike/comment/%@", uid, cid] method:AFHttpOperationMethodDELETE];
}

- (void)dislike
{
    [self sendQuery];
}

@end
