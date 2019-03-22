//
//  WLSettingViewModel.h
//  welike
//
//  Created by 刘斌 on 2018/5/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSettingHideMobileModelTag       @"SettingHideMobileModel"
#define kSettingLanguageTag              @"SettingLanguage"
#define kSettingNotificationTag          @"SettingNotification"
#define kSettingBlockTag                 @"SettingBlock"

@interface WLSettingViewModel : NSObject

@property (nonatomic, copy, readonly) NSArray *dataArray;

@end
