//
//  WLPostLikeUsersRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^postLikeUsersSuccessed)(NSArray *users, NSString *cursor);

@interface WLPostLikeUsersRequest : RDBaseRequest

- (id)initPostLikeUsersRequestWithPostId:(NSString *)pid;
- (void)listWithCursor:(NSString *)cursor successed:(postLikeUsersSuccessed)successed error:(failedBlock)error;

@end
