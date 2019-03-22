//
//  WLCreateReplyToReplyRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@class WLRichContent;

typedef void(^createReplyToReplySuccessed)(NSDictionary *dic);

@interface WLCreateReplyToReplyRequest : RDBaseRequest

- (id)initCreateReplyToReplyRequestWithUid:(NSString *)uid;
- (void)createReplyToReplyWithComment:(WLRichContent *)comment replyId:(NSString *)replyId cid:(NSString *)cid forwardPostContent:(WLRichContent *)post forwardPid:(NSString *)forwardPid successed:(createReplyToReplySuccessed)successed error:(failedBlock)error;

@end
