//
//  WLCreateReplyRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@class WLRichContent;

typedef void(^createReplySuccessed)(NSDictionary *dic);

@interface WLCreateReplyRequest : RDBaseRequest

- (id)initCreateReplyRequestWithUid:(NSString *)uid;
- (void)createReplyWithComment:(WLRichContent *)comment cid:(NSString *)cid forwardPostContent:(WLRichContent *)post forwardPid:(NSString *)forwardPid successed:(createReplySuccessed)successed error:(failedBlock)error;

@end
