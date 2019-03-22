//
//  WLDeleteCommentRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^deleteCommentSuccessed)(NSString *cid);

@interface WLDeleteCommentRequest : RDBaseRequest

- (id)initDeleteCommentRequestWithUid:(NSString *)uid cid:(NSString *)cid;
- (void)deleteCommentForSuccessed:(deleteCommentSuccessed)successed error:(failedBlock)error;

@end
