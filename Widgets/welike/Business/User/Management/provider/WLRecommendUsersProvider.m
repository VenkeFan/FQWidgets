//
//  WLRecommendUsersProvider.m
//  welike
//
//  Created by fan qi on 2018/12/13.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLRecommendUsersProvider.h"
#import "WLUserRecommendRequest.h"
#import "WLUsersProviderDelegate.h"

@interface WLRecommendUsersProvider ()

@property (nonatomic, strong) WLUserRecommendRequest *usersRequest;
@property (nonatomic, weak) id<WLUsersProviderDelegate> delegate;
@property (nonatomic, assign) NSInteger pageNum;

@end

@implementation WLRecommendUsersProvider

- (void)tryRefreshUsersWithKeyId:(NSString *)kid {
    if (self.usersRequest != nil) return;
    
    __weak typeof(self) weakSelf = self;
    self.pageNum = 0;
    [self.cacheList removeAllObjects];
    self.usersRequest = [[WLUserRecommendRequest alloc] init];
    [self.usersRequest requestRecommendUsersWithPageNum:self.pageNum succeed:^(NSArray *users) {
        weakSelf.usersRequest = nil;
        NSArray *list = [weakSelf filterUsers:users];
        BOOL last = users.count == 0;
        NSInteger newCount = [weakSelf refreshNewCount:list];
        [weakSelf cacheFirstPage:list];
        if ([weakSelf.delegate respondsToSelector:@selector(onRefreshUsersProvider:users:kid:newCount:last:errCode:)]) {
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

- (void)tryHisUsersWithKeyId:(NSString *)kid {
    if (self.usersRequest != nil) return;
    
    self.pageNum++;
    __weak typeof(self) weakSelf = self;
    self.usersRequest = [[WLUserRecommendRequest alloc] init];
    [self.usersRequest requestRecommendUsersWithPageNum:self.pageNum succeed:^(NSArray *users) {
        weakSelf.usersRequest = nil;
        NSArray *list = [weakSelf filterUsers:users];
        BOOL last = users.count == 0;
        if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisUsersProvider:users:kid:last:errCode:)]) {
            [weakSelf.delegate onReceiveHisUsersProvider:weakSelf users:list kid:kid last:last errCode:ERROR_SUCCESS];
        }
    } error:^(NSInteger errorCode) {
        weakSelf.usersRequest = nil;
        if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisUsersProvider:users:kid:last:errCode:)]) {
            [weakSelf.delegate onReceiveHisUsersProvider:weakSelf users:nil kid:kid last:NO errCode:errorCode];
        }
    }];
}

- (void)setListener:(id<WLUsersProviderDelegate>)delegate {
    self.delegate = delegate;
}

- (void)stop {
    if (self.usersRequest != nil) {
        [self.usersRequest cancel];
        self.usersRequest = nil;
    }
}

@end
