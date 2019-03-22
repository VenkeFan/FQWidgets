//
//  WLMessageCountObserver.m
//  welike
//
//  Created by 刘斌 on 2018/5/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLMessageCountObserver.h"
#import "WLMessageManager.h"
#import "WLIMConnectionManager.h"
#import "WLMessageBoxCountRequest.h"
#import "WLAccountManager.h"

@interface WLMessageCountObserver () <WLMessageManagerReceivedDelegate, WLIMConnectionManagerDelegate>

@property (nonatomic, assign) BOOL refreshing;
@property (nonatomic, strong) NSPointerArray *delegates;

- (void)broadcastmessagesCountChanged:(BOOL)has;

@end

@implementation WLMessageCountObserver

- (id)init
{
    self = [super init];
    if (self)
    {
        self.refreshing = NO;
        self.delegates = [NSPointerArray weakObjectsPointerArray];
        [[WLMessageManager instance] registerDelegate:self];
        [[WLIMConnectionManager instance] registerDelegate:self];
    }
    return self;
}

- (void)registerDelegate:(id<WLMessageCountObserverDelegate>)delegate
{
    @synchronized (self.delegates)
    {
        if ([self.delegates containsObject:delegate] == NO)
        {
            [self.delegates addObject:delegate];
        }
    }
}

- (void)unregister:(id<WLMessageCountObserverDelegate>)delegate
{
    @synchronized (self.delegates)
    {
        [self.delegates removeObject:delegate];
    }
}

- (void)refresh
{
    if (self.refreshing == NO)
    {
        [self updateCount];
    }
}

- (void)loadFromLocal
{
    __weak typeof(self) weakSelf = self;
    WLAccountSetting *setting = [[AppContext getInstance].accountManager mySetting];
    if (setting.mentionCount > 0 || setting.commentCount > 0 || setting.likeCount > 0)
    {
        [self broadcastmessagesCountChanged:YES];
    }
    else
    {
        [[WLMessageManager instance] hasUnreadMessagesAndCompleted:^(BOOL has) {
            [weakSelf broadcastmessagesCountChanged:has];
        }];
    }
}

#pragma mark - WLIMConnectionManagerDelegate
- (void)imConnectionManagerReceiveNotifications
{
    if (self.refreshing == NO)
    {
        [self updateCount];
    }
}

#pragma mark - WLMessageManagerReceivedDelegate
- (void)onIMNewMessagesCountChanged
{
    [self loadFromLocal];
}

#pragma mark - private
- (void)broadcastmessagesCountChanged:(BOOL)has
{
    @synchronized (self.delegates)
    {
        for (NSInteger i = 0; i < self.delegates.count; i++)
        {
            id<WLMessageCountObserverDelegate> delegate = [self.delegates pointerAtIndex:i];
            if (delegate && [delegate respondsToSelector:@selector(messagesCountChanged:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate messagesCountChanged:has];
                });
            }
        }
    }
}

- (void)updateCount
{
    __weak typeof(self) weakSelf = self;
    self.refreshing = YES;
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    WLMessageBoxCountRequest *request = [[WLMessageBoxCountRequest alloc] initMessageBoxCountRequestWithUid:account.uid];
    [request countWithSuccessed:^(NSInteger mention, NSInteger comment, NSInteger like) {
        WLAccountSetting *newSetting = [[AppContext getInstance].accountManager mySetting];
        newSetting.mentionCount = mention;
        newSetting.commentCount = comment;
        newSetting.likeCount = like;
        [[AppContext getInstance].accountManager updateSetting:newSetting];
        NSInteger count = mention + comment + like;
        weakSelf.refreshing = NO;
        [[WLMessageManager instance] hasUnreadMessagesAndCompleted:^(BOOL has) {
            if (has == YES)
            {
                [weakSelf broadcastmessagesCountChanged:YES];
            }
            else if (count > 0)
            {
                [weakSelf broadcastmessagesCountChanged:YES];
            }
            else
            {
                [weakSelf broadcastmessagesCountChanged:NO];
            }
        }];
    } error:^(NSInteger errCode) {
        weakSelf.refreshing = NO;
        WLAccountSetting *newSetting = [[AppContext getInstance].accountManager mySetting];
        NSInteger count = newSetting.mentionCount + newSetting.commentCount + newSetting.likeCount;
        if (count > 0)
        {
            [weakSelf broadcastmessagesCountChanged:YES];
        }
        else
        {
            [[WLMessageManager instance] hasUnreadMessagesAndCompleted:^(BOOL has) {
                [weakSelf broadcastmessagesCountChanged:has];
            }];
        }
    }];
}

@end
