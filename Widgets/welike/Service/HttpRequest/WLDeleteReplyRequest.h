//
//  WLDeleteReplyRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^deleteReplySuccessed)(NSString *rid);

@interface WLDeleteReplyRequest : RDBaseRequest

- (id)initDeleteReplyRequestWithUid:(NSString *)uid rid:(NSString *)rid;
- (void)deleteReplyForSuccessed:(deleteReplySuccessed)successed error:(failedBlock)error;

@end
