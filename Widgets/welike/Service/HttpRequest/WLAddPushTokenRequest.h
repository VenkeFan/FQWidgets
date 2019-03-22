//
//  WLAddPushTokenRequest.h
//  welike
//
//  Created by chiemy on 2018/5/31.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^addPushSuccessed)(void);

@interface WLAddPushTokenRequest : RDBaseRequest

- (id)initAddPushTokenRequest;
- (void)addPushToken:(NSString *)token successed:(addPushSuccessed)successed error:(failedBlock)error;

@end
