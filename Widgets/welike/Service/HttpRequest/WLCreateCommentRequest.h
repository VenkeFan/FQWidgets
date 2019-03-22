//
//  WLCreateCommentRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^createCommentSuccessed)(NSDictionary *dic);

@class WLRichContent;

@interface WLCreateCommentRequest : RDBaseRequest

- (id)initCreateCommentRequestWithUid:(NSString *)uid;
- (void)createCommentWithPid:(NSString *)pid commentContent:(WLRichContent *)commentContent postContent:(WLRichContent *)postContent successed:(createCommentSuccessed)successed error:(failedBlock)error;

@end
