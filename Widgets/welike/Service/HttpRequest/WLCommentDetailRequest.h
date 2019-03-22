//
//  WLCommentDetailRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^listRepliesSuccessed)(NSArray *replies, NSString *cursor);

@interface WLCommentDetailRequest : RDBaseRequest

- (id)initCommentDetailRequestWithCid:(NSString *)cid;
- (void)listRepliesWithCursor:(NSString *)cursor successed:(listRepliesSuccessed)successed error:(failedBlock)error;

@end
