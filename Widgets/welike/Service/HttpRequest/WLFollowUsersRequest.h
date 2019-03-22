//
//  WLFollowUsersRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@class WLAccount;

typedef void(^followUsersSuccessed)(void);

@interface WLFollowUsersRequest : RDBaseRequest

- (id)initFollowUsersRequestWithAccount:(WLAccount *)account;
- (void)followUsers:(NSArray *)uids successed:(followUsersSuccessed)successed error:(failedBlock)error;

@end
