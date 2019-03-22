//
//  WLPushSetting.m
//  welike
//
//  Created by luxing on 2018/5/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPushSetting.h"
#import "NSDictionary+JSON.h"

#define kPushSettingType @"type"
#define kPushSettingValue @"value"
#define kPushSettingSwitch @"switchs"
#define kPushSettingTimeLimit  @"timeLimit"

@implementation WLPushSetting

+ (WLPushSetting *)defaultPushSetting
{
    WLPushSetting *setting = [[WLPushSetting alloc] init];
    setting.repostSwitch = YES;
    setting.commentSwitch = YES;
    setting.likeSwitch = YES;
    setting.friendSwitch = YES;
    setting.followingSwitch = YES;
    setting.disturbSwitch = NO;
    setting.fromHours = 22;
    setting.fromMinute = 0;
    setting.toHours = 7;
    setting.toMinute = 0;
    return setting;
}

- (NSMutableDictionary *)toNetworkJSON
{
    NSMutableDictionary *repostDic = [NSMutableDictionary dictionaryWithCapacity:2];
    [repostDic setObject:@(WLPushSettingTypePost) forKey:kPushSettingType];
    [repostDic setObject:self.repostSwitch?@"1":@"2" forKey:kPushSettingValue];
    
    NSMutableDictionary *commentDic = [NSMutableDictionary dictionaryWithCapacity:2];
    [commentDic setObject:@(WLPushSettingTypeComment) forKey:kPushSettingType];
    [commentDic setObject:self.commentSwitch?@"1":@"2" forKey:kPushSettingValue];
    
    NSMutableDictionary *likeDic = [NSMutableDictionary dictionaryWithCapacity:2];
    [likeDic setObject:@(WLPushSettingTypeLike) forKey:kPushSettingType];
    [likeDic setObject:self.likeSwitch?@"1":@"2" forKey:kPushSettingValue];
    
    NSMutableDictionary *friendDic = [NSMutableDictionary dictionaryWithCapacity:2];
    [friendDic setObject:@(WLPushSettingTypeFriend) forKey:kPushSettingType];
    [friendDic setObject:self.friendSwitch?@"1":@"2" forKey:kPushSettingValue];
    
    NSMutableDictionary *followingDic = [NSMutableDictionary dictionaryWithCapacity:2];
    [followingDic setObject:@(WLPushSettingTypeFollowing) forKey:kPushSettingType];
    [followingDic setObject:self.followingSwitch?@"1":@"2" forKey:kPushSettingValue];
    
    NSMutableDictionary *disturbDic = [NSMutableDictionary dictionaryWithCapacity:2];
    [disturbDic setObject:@(WLPushSettingTypeDisturb) forKey:kPushSettingType];
    [disturbDic setObject:self.disturbSwitch?@"1":@"2" forKey:kPushSettingValue];
    
    NSArray *switchs = [NSArray arrayWithObjects:repostDic,commentDic,likeDic,friendDic,followingDic,disturbDic, nil];
    NSMutableDictionary *settingDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:switchs,kPushSettingSwitch, nil];
    [settingDic setObject:[NSString stringWithFormat:@"%02ld:%02ld-%02ld:%02ld",(long)self.fromHours,(long)self.fromMinute,(long)self.toHours,(long)self.toMinute] forKey:kPushSettingTimeLimit];
    return settingDic;
}

+ (WLPushSetting *)parseFromNetworkJSON:(NSDictionary *)result
{
    WLPushSetting *setting = [[WLPushSetting alloc] init];
    NSDictionary *settingDic = result;
    if ([settingDic containForKey:kPushSettingSwitch] == YES) {
        NSArray *switchs = [settingDic objectForKey:kPushSettingSwitch];
        for (NSInteger i = 0; i < switchs.count; i++) {
            NSDictionary *dic = switchs[i];
            NSInteger type = [dic integerForKey:kPushSettingType def:0];
            NSString *valueStr = [dic stringForKey:kPushSettingValue];
            BOOL value = YES;
            if ([valueStr isEqualToString:@"2"]) {
                value = NO;
            }
            switch (type) {
                case WLPushSettingTypePost:
                {
                    setting.repostSwitch = value;
                }
                    break;
                case WLPushSettingTypeComment:
                {
                    setting.commentSwitch = value;
                }
                    break;
                case WLPushSettingTypeLike:
                {
                    setting.likeSwitch = value;
                }
                    break;
                case WLPushSettingTypeFriend:
                {
                    setting.friendSwitch = value;
                }
                    break;
                case WLPushSettingTypeFollowing:
                {
                    setting.followingSwitch = value;
                }
                    break;
                case WLPushSettingTypeDisturb:
                {
                    setting.disturbSwitch = value;
                }
                    break;
                default:
                    break;
            }
        }
    }
    NSString *timeLimit = [settingDic stringForKey:kPushSettingTimeLimit];
    if ([timeLimit length] > 0) {
        NSArray *times = [timeLimit componentsSeparatedByString:@"-"];
        if (times.count == 2) {
            NSString *fromTime = times[0];
            NSString *toTime = times[1];
            NSArray *fromTimes = [fromTime componentsSeparatedByString:@":"];
            if (fromTime != nil && fromTimes.count == 2) {
                setting.fromHours = [fromTimes[0] intValue];
                setting.fromMinute = [fromTimes[1] intValue];
            } else {
                setting.fromHours = 22;
                setting.fromMinute = 0;
            }
            NSArray *toTimes = [toTime componentsSeparatedByString:@":"];
            if (toTime != nil && toTimes.count == 2) {
                setting.toHours = [toTimes[0] intValue];
                setting.toMinute = [toTimes[1] intValue];
            } else {
                setting.toHours = 7;
                setting.toMinute = 0;
            }
        } else {
            setting.fromHours = 22;
            setting.fromMinute = 0;
            setting.toHours = 7;
            setting.toMinute = 0;
        }
    } else {
        setting.fromHours = 22;
        setting.fromMinute = 0;
        setting.toHours = 7;
        setting.toMinute = 0;
    }
    return setting;
}

-(BOOL)isEqual:(id)object
{
    WLPushSetting *setting = object;
    if(self.repostSwitch == setting.repostSwitch
       && self.commentSwitch == setting.commentSwitch
       && self.likeSwitch == setting.likeSwitch
       && self.friendSwitch == setting.friendSwitch
       && self.followingSwitch == setting.followingSwitch
       && self.disturbSwitch == setting.disturbSwitch
       && self.fromHours == setting.fromHours
       && self.fromMinute == setting.fromMinute
       && self.toHours == setting.toHours
       && self.toMinute == setting.toMinute) {
        return YES;
    }
    return NO;
}

@end
