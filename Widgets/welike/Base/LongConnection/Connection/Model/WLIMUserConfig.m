//
//  WLIMUserConfig.m
//  IMTest
//
//  Created by luxing on 2018/5/2.
//  Copyright © 2018年 chiemy. All rights reserved.
//  登录用户的信息

#import "WLIMUserConfig.h"
#import "AppContext.h"
#import "WLAccountManager.h"
#import "LuuUtils.h"
#import "RDLocalizationManager.h"

@implementation WLIMUserConfig

+ (instancetype)defaultUserConfig
{
    WLIMUserConfig *config = [[self alloc] init];
    WLAccount *account = [[[AppContext getInstance] accountManager] myAccount];
    config.uid = account.uid;
    config.token = account.accessToken;
    config.version = [[LuuUtils appVersion] intValue];
    config.deviceInfo = [LuuUtils deviceModel];
    config.la = [[RDLocalizationManager getInstance] getCurrentLanguage];
    return config;
}

@end
