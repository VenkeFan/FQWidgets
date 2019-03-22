//
//  WLFollowUserRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^followUserSuccessed)(NSString *uid);

@interface WLFollowUserRequest : RDBaseRequest

@property (nonatomic, readonly) NSString *uid;

- (id)initFollowUserRequestWithMyUid:(NSString *)myUid toUid:(NSString *)toUid;
- (void)followSuccessed:(followUserSuccessed)successed error:(failedBlock)error;

@end
