//
//  WLFollowingUsersRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^followingUsersSuccessed)(NSArray *users, NSString *cursor);

@interface WLFollowingUsersRequest : RDBaseRequest

- (id)initFollowingUsersRequestWithUid:(NSString *)uid;
- (void)listWithCursor:(NSString *)cursor index:(NSNumber *)index successed:(followingUsersSuccessed)successed error:(failedBlock)error;

@end
