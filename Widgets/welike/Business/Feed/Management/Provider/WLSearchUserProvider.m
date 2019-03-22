//
//  WLSearchUserProvider.m
//  welike
//
//  Created by 刘斌 on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchUserProvider.h"
#import "WLSearchUserRequest.h"

@interface WLSearchUserProvider ()

@property (nonatomic, strong) WLSearchUserRequest *searchUserRequest;
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, assign) NSInteger pageNum;

@end

@implementation WLSearchUserProvider

- (void)tryNewSearchUsers:(NSString *)keyword
{
    if (self.searchUserRequest != nil)
    {
        [self.searchUserRequest cancel];
        self.searchUserRequest = nil;
    }
    
    self.pageNum = 0;
    self.keyword = keyword;
    if ([self.keyword length] > 0)
    {
        __weak typeof(self) weakSelf = self;
        self.searchUserRequest = [[WLSearchUserRequest alloc] initSearchUserRequest];
        [self.searchUserRequest searchWithKeyword:self.keyword pageNum:self.pageNum successed:^(NSArray *users, BOOL last, NSInteger pageNum) {
            weakSelf.searchUserRequest = nil;
            if ([weakSelf.delegate respondsToSelector:@selector(onNewSearch:users:last:errCode:)])
            {
                [weakSelf.delegate onNewSearch:weakSelf users:users last:last errCode:ERROR_SUCCESS];
            }
        } error:^(NSInteger errorCode) {
            weakSelf.searchUserRequest = nil;
            if ([weakSelf.delegate respondsToSelector:@selector(onNewSearch:users:last:errCode:)])
            {
                [weakSelf.delegate onNewSearch:weakSelf users:nil last:NO errCode:errorCode];
            }
        }];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(onNewSearch:users:last:errCode:)])
        {
            [self.delegate onNewSearch:self users:nil last:YES errCode:ERROR_SUCCESS];
        }
    }
}

- (void)tryMoreSearchUsers
{
    if (self.searchUserRequest != nil) return;
    
    self.pageNum++;
    __weak typeof(self) weakSelf = self;
    self.searchUserRequest = [[WLSearchUserRequest alloc] initSearchUserRequest];
    [self.searchUserRequest searchWithKeyword:self.keyword pageNum:self.pageNum successed:^(NSArray *users, BOOL last, NSInteger pageNum) {
        weakSelf.searchUserRequest = nil;
        if ([weakSelf.delegate respondsToSelector:@selector(onMoreSearch:users:last:errCode:)])
        {
            [weakSelf.delegate onMoreSearch:weakSelf users:users last:last errCode:ERROR_SUCCESS];
        }
    } error:^(NSInteger errorCode) {
        weakSelf.searchUserRequest = nil;
        if ([weakSelf.delegate respondsToSelector:@selector(onMoreSearch:users:last:errCode:)])
        {
            [weakSelf.delegate onMoreSearch:weakSelf users:nil last:NO errCode:errorCode];
        }
    }];
}

- (void)stop
{
    if (self.searchUserRequest != nil)
    {
        [self.searchUserRequest cancel];
        self.searchUserRequest = nil;
    }
}

@end
