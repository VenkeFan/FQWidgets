//
//  WLUserPostsRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^userPostsSuccessed)(NSArray *posts, NSString *cursor);

@interface WLUserPostsRequest : RDBaseRequest

- (id)initUserPostsRequestWithUid:(NSString *)uid;
- (void)listWithCursor:(NSString *)cursor successed:(userPostsSuccessed)successed error:(failedBlock)error;

@end
