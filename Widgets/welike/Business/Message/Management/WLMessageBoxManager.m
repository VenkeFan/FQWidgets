//
//  WLMessageBoxManager.m
//  welike
//
//  Created by 刘斌 on 2018/5/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLMessageBoxManager.h"
#import "WLMessageBoxRequest.h"
#import "WLAccountManager.h"
#import "WLMsgBoxCell.h"
#import "UIImage+LuuBase.h"

@interface WLMessageBoxManager ()

@property (nonatomic, copy) NSString *cursor;
@property (nonatomic, strong) WLMessageBoxRequest *notificationsRequest;
@property (nonatomic, strong) UIImage *placeHolder;

@end

@implementation WLMessageBoxManager

- (id)init
{
    self = [super init];
    if (self)
    {
        self.placeHolder = [UIImage placeholder:[AppContext getImageForKey:@"img_thumb_default_small"] backgroundColor:kLightBackgroundViewColor size:CGSizeMake(kMsgBoxCellThumbSize, kMsgBoxCellThumbSize)];
    }
    return self;
}

- (void)tryRefresh
{
    if (self.notificationsRequest != nil) return;
    
    WLAccount *myAccount = [[AppContext getInstance].accountManager myAccount];
    self.cursor = nil;
    __weak typeof(self) weakSelf = self;
    self.notificationsRequest = [[WLMessageBoxRequest alloc] initMessageBoxRequestWithUid:myAccount.uid];
    [self.notificationsRequest listWithType:self.type cursor:nil successed:^(NSArray *messages, NSString *cursor) {
        weakSelf.notificationsRequest = nil;
        weakSelf.cursor = cursor;
        BOOL last = [weakSelf.cursor length] == 0;
        if ([messages count] > 0)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSMutableArray *notifications = [NSMutableArray arrayWithCapacity:[messages count]];
                for (NSInteger i = 0; i < [messages count]; i++)
                {
                    WLMsgBoxDataSourceItem *item = [[WLMsgBoxDataSourceItem alloc] init];
                    item.notification = [messages objectAtIndex:i];
                    item.placeholder = weakSelf.placeHolder;
                    if (i == ([messages count] - 1))
                    {
                        item.end = YES;
                    }
                    [item calcCellHeigth];
                    [notifications addObject:item];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([weakSelf.delegate respondsToSelector:@selector(onRefreshMessageBoxNotifications:last:errCode:)])
                    {
                        [weakSelf.delegate onRefreshMessageBoxNotifications:notifications last:last errCode:ERROR_SUCCESS];
                    }
                });
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.delegate respondsToSelector:@selector(onRefreshMessageBoxNotifications:last:errCode:)])
                {
                    [weakSelf.delegate onRefreshMessageBoxNotifications:nil last:(BOOL)last errCode:ERROR_SUCCESS];
                }
            });
        }
    } error:^(NSInteger errorCode) {
        weakSelf.notificationsRequest = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(onRefreshMessageBoxNotifications:last:errCode:)])
            {
                [weakSelf.delegate onRefreshMessageBoxNotifications:nil last:NO errCode:errorCode];
            }
        });
    }];
}

- (void)tryHis
{
    if (self.notificationsRequest != nil) return;
    
    __weak typeof(self) weakSelf = self;
    if ([self.cursor length] != 0)
    {
        WLAccount *myAccount = [[AppContext getInstance].accountManager myAccount];
        self.notificationsRequest = [[WLMessageBoxRequest alloc] initMessageBoxRequestWithUid:myAccount.uid];
        [self.notificationsRequest listWithType:self.type cursor:self.cursor successed:^(NSArray *messages, NSString *cursor) {
            weakSelf.notificationsRequest = nil;
            weakSelf.cursor = cursor;
            BOOL last = [weakSelf.cursor length] == 0;
            if ([messages count] > 0)
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSMutableArray *notifications = [NSMutableArray arrayWithCapacity:[messages count]];
                    for (NSInteger i = 0; i < [messages count]; i++)
                    {
                        WLMsgBoxDataSourceItem *item = [[WLMsgBoxDataSourceItem alloc] init];
                        item.notification = [messages objectAtIndex:i];
                        item.placeholder = weakSelf.placeHolder;
                        if (i == ([messages count] - 1))
                        {
                            item.end = YES;
                        }
                        [item calcCellHeigth];
                        [notifications addObject:item];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisMessageBoxNotifications:last:errCode:)])
                        {
                            [weakSelf.delegate onReceiveHisMessageBoxNotifications:notifications last:last errCode:ERROR_SUCCESS];
                        }
                    });
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisMessageBoxNotifications:last:errCode:)])
                    {
                        [weakSelf.delegate onReceiveHisMessageBoxNotifications:nil last:last errCode:ERROR_SUCCESS];
                    }
                });
            }
        } error:^(NSInteger errorCode) {
            weakSelf.notificationsRequest = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisMessageBoxNotifications:last:errCode:)])
                {
                    [weakSelf.delegate onReceiveHisMessageBoxNotifications:nil last:NO errCode:errorCode];
                }
            });
        }];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisMessageBoxNotifications:last:errCode:)])
            {
                [weakSelf.delegate onReceiveHisMessageBoxNotifications:nil last:YES errCode:ERROR_SUCCESS];
            }
        });
    }
}

@end
