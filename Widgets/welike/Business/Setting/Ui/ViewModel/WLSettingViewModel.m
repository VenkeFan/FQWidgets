//
//  WLSettingViewModel.m
//  welike
//
//  Created by 刘斌 on 2018/5/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSettingViewModel.h"
#import "WLSettingDataSourceItem.h"
#import "WLSwitchCell.h"
#import "WLAccountManager.h"

@implementation WLSettingViewModel

- (instancetype)init
{
    if (self = [super init])
    {
        WLSettingDataSourceItem *languageItem = [[WLSettingDataSourceItem alloc] init];
        languageItem.title = [AppContext getStringForKey:@"mine_setting_language_text" fileName:@"user"];
        languageItem.isTail = YES;
        languageItem.settingTag = kSettingLanguageTag;
        
        WLAccountSetting *setting = [[AppContext getInstance].accountManager mySetting];
        WLSwitchCellDataSourceItem *mobileModelItem = [[WLSwitchCellDataSourceItem alloc] init];
        mobileModelItem.title = [AppContext getStringForKey:@"setting_hide_mobile_model_text" fileName:@"user"];
        mobileModelItem.tag = kSettingHideMobileModelTag;
        mobileModelItem.switchVal = !setting.mobileModel;
        mobileModelItem.isTail = NO;
        
        WLSettingDataSourceItem *notificationItem = [[WLSettingDataSourceItem alloc] init];
        notificationItem.title = [AppContext getStringForKey:@"notification_setting" fileName:@"user"];
        notificationItem.isTail = NO;
        notificationItem.settingTag = kSettingNotificationTag;
        
        WLSettingDataSourceItem *blockItem = [[WLSettingDataSourceItem alloc] init];
        blockItem.title = [AppContext getStringForKey:@"block" fileName:@"common"];
        blockItem.settingTag = kSettingBlockTag;
        blockItem.isTail = NO;
        
        _dataArray = @[languageItem, notificationItem, mobileModelItem, blockItem];
    }
    return self;
}

@end
