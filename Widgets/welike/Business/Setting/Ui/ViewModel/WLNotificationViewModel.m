//
//  WLNotificationViewModel.m
//  welike
//
//  Created by luxing on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNotificationViewModel.h"
#import "WLSwitchCell.h"
#import "WLTimeSelectViewModel.h"
#import "WLPushSettingManager.h"

@interface WLNotificationViewModel ()

@property (nonatomic, strong) NSMutableDictionary *dataDic;

@end

@implementation WLNotificationViewModel

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.dataDic = [NSMutableDictionary dictionaryWithCapacity:10];
        WLSwitchCellDataSourceItem *repostModelItem = [[WLSwitchCellDataSourceItem alloc] init];
        repostModelItem.title = [AppContext getStringForKey:@"mute_at" fileName:@"user"];
        repostModelItem.tag = kRepostNotificationKey;
        repostModelItem.switchVal = [[AppContext getInstance].pushSettingManager currentPushSetting].repostSwitch;
        repostModelItem.isTail = NO;
        [self.dataDic setObject:repostModelItem forKey:kRepostNotificationKey];
        
        WLSwitchCellDataSourceItem *commentModelItem = [[WLSwitchCellDataSourceItem alloc] init];
        commentModelItem.title = [AppContext getStringForKey:@"mute_comment" fileName:@"user"];
        commentModelItem.tag = kCommentNotificationKey;
        commentModelItem.switchVal = [[AppContext getInstance].pushSettingManager currentPushSetting].commentSwitch;
        commentModelItem.isTail = NO;
        [self.dataDic setObject:commentModelItem forKey:kCommentNotificationKey];
        
        WLSwitchCellDataSourceItem *likeModelItem = [[WLSwitchCellDataSourceItem alloc] init];
        likeModelItem.title = [AppContext getStringForKey:@"mute_like" fileName:@"user"];
        likeModelItem.tag = kLikeNotificationKey;
        likeModelItem.switchVal = [[AppContext getInstance].pushSettingManager currentPushSetting].likeSwitch;
        likeModelItem.isTail = YES;
        [self.dataDic setObject:likeModelItem forKey:kLikeNotificationKey];
        
        WLSwitchCellDataSourceItem *friendModelItem = [[WLSwitchCellDataSourceItem alloc] init];
        friendModelItem.title = [AppContext getStringForKey:@"mute_im_message" fileName:@"user"];
        friendModelItem.tag = kFriendNotificationKey;
        friendModelItem.switchVal = [[AppContext getInstance].pushSettingManager currentPushSetting].friendSwitch;
        friendModelItem.isTail = YES;
        [self.dataDic setObject:friendModelItem forKey:kFriendNotificationKey];
        
        WLSwitchCellDataSourceItem *followingModelItem = [[WLSwitchCellDataSourceItem alloc] init];
        followingModelItem.title = [AppContext getStringForKey:@"mute_new_post" fileName:@"user"];;
        followingModelItem.tag = kFollowingNotificationKey;
        followingModelItem.switchVal = [[AppContext getInstance].pushSettingManager currentPushSetting].followingSwitch;
        followingModelItem.isTail = YES;
        [self.dataDic setObject:followingModelItem forKey:kFollowingNotificationKey];
        
        WLSwitchCellDataSourceItem *disturbModelItem = [[WLSwitchCellDataSourceItem alloc] init];
        disturbModelItem.title = [AppContext getStringForKey:@"mut_scheduled" fileName:@"user"];
        disturbModelItem.tag = kDisturbNotificationKey;
        disturbModelItem.switchVal = [[AppContext getInstance].pushSettingManager currentPushSetting].disturbSwitch;
        disturbModelItem.isTail = NO;
        [self.dataDic setObject:disturbModelItem forKey:kDisturbNotificationKey];
        
        WLTimeSelectViewModel *timeSelectModelItem = [[WLTimeSelectViewModel alloc] init];
        timeSelectModelItem.fromTitle = [AppContext getStringForKey:@"mute_start" fileName:@"user"];
        timeSelectModelItem.toTitle = [AppContext getStringForKey:@"mute_end" fileName:@"user"];
        timeSelectModelItem.fromHours = [[AppContext getInstance].pushSettingManager currentPushSetting].fromHours;
        timeSelectModelItem.fromMinute = [[AppContext getInstance].pushSettingManager currentPushSetting].fromMinute;
        timeSelectModelItem.toHours = [[AppContext getInstance].pushSettingManager currentPushSetting].toHours;
        timeSelectModelItem.toMinute = [[AppContext getInstance].pushSettingManager currentPushSetting].toMinute;
        timeSelectModelItem.tag = kTimeNotificationKey;
        timeSelectModelItem.isTail = NO;
        [self.dataDic setObject:timeSelectModelItem forKey:kTimeNotificationKey];
    }
    return self;
}

- (NSInteger)sectionCount
{
    return 4;
}

- (NSInteger)rowCoutInSection:(NSUInteger)section
{
    NSInteger rowCount = 0;
    switch (section) {
        case 0:
        {
            rowCount = 3;
        }
            break;
        case 1:
        {
            rowCount = 1;
        }
            break;
        case 2:
        {
            rowCount = 1;
        }
            break;
        case 3:
        {
            WLSwitchCellDataSourceItem *item = [self.dataDic objectForKey:kDisturbNotificationKey];
            if (item.switchVal) {
                rowCount = 2;
            } else {
                rowCount = 1;
            }
        }
            break;
        default:
            break;
    }
    return rowCount;
}

- (id)itemDataAtRow:(NSUInteger)row inSection:(NSUInteger)section
{
    id item = nil;
    switch (section) {
        case 0:
        {
            if (row == 0) {
                item = [self.dataDic objectForKey:kRepostNotificationKey];
            } else if (row ==1) {
                item = [self.dataDic objectForKey:kCommentNotificationKey];
            } else {
                item = [self.dataDic objectForKey:kLikeNotificationKey];
            }
        }
            break;
        case 1:
        {
            item = [self.dataDic objectForKey:kFriendNotificationKey];
        }
            break;
        case 2:
        {
            item = [self.dataDic objectForKey:kFollowingNotificationKey];
        }
            break;
        case 3:
        {
            if (row == 0) {
                item = [self.dataDic objectForKey:kDisturbNotificationKey];
            } else {
                item = [self.dataDic objectForKey:kTimeNotificationKey];
            }
        }
            break;
        default:
            break;
    }
    return item;
}

- (NSString *)sectionTitle:(NSUInteger)section
{
    NSString *title = nil;
    switch (section) {
        case 0:
        {
            title = [AppContext getStringForKey:@"notification_reminder" fileName:@"user"];
        }
            break;
        case 1:
        {
            title = [AppContext getStringForKey:@"mute_im_message_tips" fileName:@"user"];
        }
            break;
        case 2:
        {
            title = [AppContext getStringForKey:@"mute_new_post_tips" fileName:@"user"];
        }
            break;
        case 3:
        {
            title = [AppContext getStringForKey:@"mute_scheduled_tips" fileName:@"user"];
        }
            break;
            
        default:
            break;
    }
    return title;
}

- (void)setSwitchVal:(BOOL)val forKey:(NSString*)key
{
    WLSwitchCellDataSourceItem *item = [self.dataDic objectForKey:key];
    if ([item isKindOfClass:[WLSwitchCellDataSourceItem class]]) {
        item.switchVal = val;
    }
}

- (void)setTail:(BOOL)tail forKey:(NSString*)key
{
    WLSwitchCellDataSourceItem *item = [self.dataDic objectForKey:key];
    if ([item isKindOfClass:[WLSwitchCellDataSourceItem class]]) {
        item.isTail = tail;
    }
}

- (void)refresh:(WLPushSetting *)setting
{
    WLSwitchCellDataSourceItem *repostModelItem = [self.dataDic objectForKey:kRepostNotificationKey];
    repostModelItem.switchVal = setting.repostSwitch;
    WLSwitchCellDataSourceItem *commentModelItem = [self.dataDic objectForKey:kCommentNotificationKey];
    commentModelItem.switchVal = setting.commentSwitch;
    WLSwitchCellDataSourceItem *likeModelItem = [self.dataDic objectForKey:kLikeNotificationKey];
    likeModelItem.switchVal = setting.likeSwitch;
    WLSwitchCellDataSourceItem *friendModelItem = [self.dataDic objectForKey:kFriendNotificationKey];
    friendModelItem.switchVal = setting.friendSwitch;
    WLSwitchCellDataSourceItem *followingModelItem = [self.dataDic objectForKey:kFollowingNotificationKey];
    followingModelItem.switchVal = setting.followingSwitch;
    WLSwitchCellDataSourceItem *disturbModelItem = [self.dataDic objectForKey:kDisturbNotificationKey];
    disturbModelItem.switchVal = setting.disturbSwitch;
    WLTimeSelectViewModel *timeModelItem = [self.dataDic objectForKey:kTimeNotificationKey];
    timeModelItem.fromHours = setting.fromHours;
    timeModelItem.fromMinute = setting.fromMinute;
    timeModelItem.toHours = setting.toHours;
    timeModelItem.toMinute = setting.toMinute;
}

@end
