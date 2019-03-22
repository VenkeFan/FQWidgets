//
//  WLDislikeCommentRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@interface WLDislikeCommentRequest : RDBaseRequest

- (id)initDislikeCommentRequestWithUid:(NSString *)uid cid:(NSString *)cid;
- (void)dislike;

@end
