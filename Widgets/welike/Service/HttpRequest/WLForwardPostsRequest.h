//
//  WLForwardPostsRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^forwardPostsSuccessed)(NSArray *posts, NSString *cursor);

@interface WLForwardPostsRequest : RDBaseRequest

- (id)initForwardPostsRequestWithPid:(NSString *)pid;
- (void)listWithCursor:(NSString *)cursor successed:(forwardPostsSuccessed)successed error:(failedBlock)error;

@end
