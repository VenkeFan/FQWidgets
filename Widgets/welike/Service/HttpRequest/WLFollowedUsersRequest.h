//
//  WLFollowedUsersRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^followedUsersSuccessed)(NSArray *users, NSString *cursor);

@interface WLFollowedUsersRequest : RDBaseRequest

- (id)initFollowedUsersRequestWithUid:(NSString *)uid;
- (void)listWithCursor:(NSString *)cursor index:(NSNumber *)index successed:(followedUsersSuccessed)successed error:(failedBlock)error;

@end
