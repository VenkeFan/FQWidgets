//
//  WLPushSettingPostRequest.h
//  welike
//
//  Created by chiemy on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^deletePushSuccessed)(void);

@interface WLPushSettingPostRequest : RDBaseRequest

- (id)initPushSettingPostRequest;

- (void)syncPushSetting:(NSDictionary *)setting successed:(deletePushSuccessed)successed error:(failedBlock)error;

@end
