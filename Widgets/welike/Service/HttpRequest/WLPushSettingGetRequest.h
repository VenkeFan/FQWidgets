//
//  WLPushSettingGetRequest.h
//  welike
//
//  Created by chiemy on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@class WLPushSetting;

typedef void(^getPushSuccessed)(WLPushSetting *setting);

@interface WLPushSettingGetRequest : RDBaseRequest

- (id)initPushSettingGetRequest;

- (void)getPushSettingSuccessed:(getPushSuccessed)successed error:(failedBlock)error;

@end
