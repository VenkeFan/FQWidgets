//
//  WLLikeCommentRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@interface WLLikeCommentRequest : RDBaseRequest

- (id)initLikeCommentRequestWithUid:(NSString *)uid cid:(NSString *)cid;
- (void)like;

@end
