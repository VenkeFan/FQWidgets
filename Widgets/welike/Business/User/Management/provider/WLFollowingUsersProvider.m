//
//  WLFollowingUsersProvider.m
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFollowingUsersProvider.h"
#import "WLFollowingUsersRequest.h"
#import "WLUsersProviderDelegate.h"

@interface WLFollowingUsersProvider ()

@property (nonatomic, strong) WLFollowingUsersRequest *usersRequest;
@property (nonatomic, copy) NSString *cursor;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, weak) id<WLUsersProviderDelegate> delegate;

@end

@implementation WLFollowingUsersProvider

- (void)tryRefreshUsersWithKeyId:(NSString *)kid
{
    if (self.usersRequest != nil) return;
    
    __weak typeof(self) weakSelf = self;
    self.cursor = nil;
    self.index = 0;
    [self.cacheList removeAllObjects];
    self.usersRequest = [[WLFollowingUsersRequest alloc] initFollowingUsersRequestWithUid:kid];
    [self.usersRequest listWithCursor:nil index:nil successed:^(NSArray *users, NSString *cursor) {
        weakSelf.usersRequest = nil;
        NSArray *list = [weakSelf filterUsers:users];
        self.cursor = cursor;
        BOOL last = [weakSelf.cursor length] == 0;
        NSInteger newCount = [weakSelf refreshNewCount:list];
        [weakSelf cacheFirstPage:list];
        if ([weakSelf.delegate respondsToSelector:@selector(onRefreshUsersProvider:users:kid:newCount:last:errCode:)])
        {
            [weakSelf.delegate onRefreshUsersProvider:weakSelf users:list kid:kid newCount:newCount last:last errCode:ERROR_SUCCESS];
        }
    } error:^(NSInteger errorCode) {
        weakSelf.usersRequest = nil;
        if ([weakSelf.delegate respondsToSelector:@selector(onRefreshUsersProvider:users:kid:newCount:last:errCode:)])
        {
            [weakSelf.delegate onRefreshUsersProvider:weakSelf users:nil kid:kid newCount:0 last:NO errCode:errorCode];
        }
    }];
}

- (void)tryHisUsersWithKeyId:(NSString *)kid
{
    if (self.usersRequest != nil) return;
    
    if ([self.cursor length] != 0)
    {
        __weak typeof(self) weakSelf = self;
        self.usersRequest = [[WLFollowingUsersRequest alloc] initFollowingUsersRequestWithUid:kid];
        [self.usersRequest listWithCursor:self.cursor index:[NSNumber numberWithInteger:self.index] successed:^(NSArray *users, NSString *cursor) {
            weakSelf.usersRequest = nil;
            NSArray *list = [weakSelf filterUsers:users];
            weakSelf.cursor = cursor;
            BOOL last = [weakSelf.cursor length] == 0;
            if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisUsersProvider:users:kid:last:errCode:)])
            {
                [weakSelf.delegate onReceiveHisUsersProvider:weakSelf users:list kid:kid last:last errCode:ERROR_SUCCESS];
            }
        } error:^(NSInteger errorCode) {
            weakSelf.usersRequest = nil;
            if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisUsersProvider:users:kid:last:errCode:)])
            {
                [weakSelf.delegate onReceiveHisUsersProvider:weakSelf users:nil kid:kid last:NO errCode:errorCode];
            }
        }];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(onReceiveHisUsersProvider:users:kid:last:errCode:)])
        {
            [self.delegate onReceiveHisUsersProvider:self users:nil kid:kid last:YES errCode:ERROR_SUCCESS];
        }
    }
}

- (void)setListener:(id<WLUsersProviderDelegate>)delegate
{
    self.delegate = delegate;
}

- (void)stop
{
    if (self.usersRequest != nil)
    {
        [self.usersRequest cancel];
        self.usersRequest = nil;
    }
}

@end
