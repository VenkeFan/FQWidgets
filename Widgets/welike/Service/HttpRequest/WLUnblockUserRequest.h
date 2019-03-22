//
//  WLUnblockUserRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^unblockSuccessed)(NSString *uid);

@interface WLUnblockUserRequest : RDBaseRequest

- (id)initUnblockUserRequestWithMyUid:(NSString *)myUid unblockUid:(NSString *)uid;
- (void)unblockAndSuccessed:(unblockSuccessed)successed error:(failedBlock)error;

@end
