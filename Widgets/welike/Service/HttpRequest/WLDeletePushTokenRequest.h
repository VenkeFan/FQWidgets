//
//  WLDeletePushTokenRequest.h
//  welike
//
//  Created by chiemy on 2018/5/31.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^deletePushSuccessed)(void);

@interface WLDeletePushTokenRequest : RDBaseRequest

- (id)initDeletePushTokenRequest;

- (void)deletePushTokenSuccessed:(deletePushSuccessed)successed error:(failedBlock)error;

@end
