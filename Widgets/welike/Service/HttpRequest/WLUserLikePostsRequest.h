//
//  WLUserLikePostsRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^userLikePostsSuccessed)(NSArray *posts, NSString *cursor);

@interface WLUserLikePostsRequest : RDBaseRequest

- (id)initUserLikePostsRequestWithUid:(NSString *)uid;
- (void)listWithCursor:(NSString *)cursor successed:(userLikePostsSuccessed)successed error:(failedBlock)error;

@end
