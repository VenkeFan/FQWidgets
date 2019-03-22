//
//  WLPushSettingManager.m
//  welike
//
//  Created by luxing on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPushSettingManager.h"
#import "WLPushSettingGetRequest.h"
#import "WLPushSettingPostRequest.h"
#import "WLAddPushTokenRequest.h"
#import "WLDeletePushTokenRequest.h"

#define kPushSettingKey @"PushSettingKey_"
#define kPushTokenKey   @"PushTokenKey"
#define kPushSettingTimeZone @"timeZone"

@interface WLPushSettingManager ()

@property (nonatomic, strong) WLPushSetting *setting;
@property (nonatomic, copy) NSString *pushToken;

@end

@implementation WLPushSettingManager

- (void)loginWithUid:(NSString *)uid
{
    self.pushToken = [[NSUserDefaults standardUserDefaults] objectForKey:kPushTokenKey];
    NSString *key = [kPushSettingKey stringByAppendingString:uid];
    NSDictionary *settingDic = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (settingDic != nil)
    {
        self.setting = [WLPushSetting parseFromNetworkJSON:settingDic];
    }
    else
    {
        self.setting = [WLPushSetting defaultPushSetting];
    }
    
    if ([self.pushToken length] > 0)
    {
        WLAddPushTokenRequest *request = [[WLAddPushTokenRequest alloc] initAddPushTokenRequest];
        [request addPushToken:self.pushToken successed:nil error:nil];
    }
    [self refreshPushSetting];
}

- (void)logout
{
    self.setting = nil;
    WLDeletePushTokenRequest *request = [[WLDeletePushTokenRequest alloc] initDeletePushTokenRequest];
    [request deletePushTokenSuccessed:nil error:nil];
}

- (WLPushSetting *)currentPushSetting
{
    return self.setting;
}

- (void)syncPushSetting:(NSString *)key value:(BOOL)value
{
    BOOL needUpdate = NO;
    if (self.setting != nil)
    {
        if ([key isEqualToString:kRepostNotificationKey])
        {
            self.setting.repostSwitch = value;
            needUpdate = YES;
        }
        else if ([key isEqualToString:kCommentNotificationKey])
        {
            self.setting.commentSwitch = value;
            needUpdate = YES;
        }
        else if ([key isEqualToString:kLikeNotificationKey])
        {
            self.setting.likeSwitch = value;
            needUpdate = YES;
        }
        else if ([key isEqualToString:kFriendNotificationKey])
        {
            self.setting.friendSwitch = value;
            needUpdate = YES;
        }
        else if ([key isEqualToString:kFollowingNotificationKey])
        {
            self.setting.followingSwitch = value;
            needUpdate = YES;
        }
        else if ([key isEqualToString:kDisturbNotificationKey])
        {
            self.setting.disturbSwitch = value;
            needUpdate = YES;
        }
        if (needUpdate == YES)
        {
            [self saveAndSyncPushSetting];
        }
    }
}

- (void)syncPushSettingLimitTime:(WLTimeSelectViewModel *)time
{
    if (self.setting != nil)
    {
        self.setting.fromHours = time.fromHours;
        self.setting.fromMinute = time.fromMinute;
        self.setting.toHours = time.toHours;
        self.setting.toMinute = time.toMinute;
        [self saveAndSyncPushSetting];
    }
}

- (void)bindPushToken:(NSString*)token
{
    if ([token length] > 0)
    {
        self.pushToken = token;
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:kPushTokenKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        WLAccount *account = [[AppContext getInstance].accountManager myAccount];
        if (account != nil && [self.pushToken length] > 0)
        {
            WLAddPushTokenRequest *request = [[WLAddPushTokenRequest alloc] initAddPushTokenRequest];
            [request addPushToken:token successed:nil error:nil];
        }
    }
}

- (void)refreshPushSetting
{
    WLPushSettingGetRequest *req = [[WLPushSettingGetRequest alloc] initPushSettingGetRequest];
    [req getPushSettingSuccessed:^(WLPushSetting *setting) {
        self.setting = setting;
        [self savePushSetting];
    } error:nil];
}

- (void)savePushSetting
{
    NSString *uid = [[AppContext getInstance].accountManager myAccount].uid;
    NSDictionary *jsonDic = [self.setting toNetworkJSON];
    NSString *key = [kPushSettingKey stringByAppendingString:uid ?: @""];
    [[NSUserDefaults standardUserDefaults] setObject:jsonDic forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveAndSyncPushSetting
{
    NSString *uid = [[AppContext getInstance].accountManager myAccount].uid;
    NSMutableDictionary *jsonDic = [self.setting toNetworkJSON];
    NSString *key = [kPushSettingKey stringByAppendingString:uid];
    [[NSUserDefaults standardUserDefaults] setObject:jsonDic forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    if (zone.name != nil) {
        [jsonDic setObject:zone.name forKey:kPushSettingTimeZone];
    }
    WLPushSettingPostRequest *request = [[WLPushSettingPostRequest alloc] initPushSettingPostRequest];
    [request syncPushSetting:jsonDic successed:nil error:nil];
}

@end
