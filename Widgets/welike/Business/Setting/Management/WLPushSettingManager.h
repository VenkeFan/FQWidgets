//
//  WLPushSettingManager.h
//  welike
//
//  Created by luxing on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPushSetting.h"
#import "WLAccountManager.h"
#import "WLTimeSelectViewModel.h"

@interface WLPushSettingManager : NSObject

- (void)loginWithUid:(NSString *)uid;

- (void)logout;

- (WLPushSetting *)currentPushSetting;

- (void)syncPushSetting:(NSString *)key value:(BOOL)value;

- (void)syncPushSettingLimitTime:(WLTimeSelectViewModel *)time;

- (void)bindPushToken:(NSString*)token;

- (void)refreshPushSetting;

@end
