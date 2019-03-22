//
//  WLBlockUserRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^blockSuccessed)(NSString *uid);

@interface WLBlockUserRequest : RDBaseRequest

- (id)initBlockUserRequestWithMyUid:(NSString *)myUid blockUid:(NSString *)uid;
- (void)blockAndSuccessed:(blockSuccessed)successed error:(failedBlock)error;

@end
