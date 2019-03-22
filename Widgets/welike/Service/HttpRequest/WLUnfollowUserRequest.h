//
//  WLUnfollowUserRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^unfollowUserSuccessed)(NSString *uid);

@interface WLUnfollowUserRequest : RDBaseRequest

@property (nonatomic, readonly) NSString *uid;

- (id)initUnfollowUserRequestWithMyUid:(NSString *)myUid toUid:(NSString *)toUid;
- (void)unfollowSuccessed:(unfollowUserSuccessed)successed error:(failedBlock)error;

@end
