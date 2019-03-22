//
//  WLSearchLatestProvider.m
//  welike
//
//  Created by 刘斌 on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchLatestProvider.h"
#import "WLSearchLatestRequest.h"

@interface WLSearchLatestProvider ()

@property (nonatomic, strong) WLSearchLatestRequest *searchLatestRequest;
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, assign) NSInteger pageNum;

@end

@implementation WLSearchLatestProvider

- (void)tryNewSearchLatest:(NSString *)keyword
{
    if (self.searchLatestRequest != nil)
    {
        [self.searchLatestRequest cancel];
        self.searchLatestRequest = nil;
    }
    
    self.pageNum = 0;
    self.keyword = keyword;
    if ([self.keyword length] > 0)
    {
        __weak typeof(self) weakSelf = self;
        self.searchLatestRequest = [[WLSearchLatestRequest alloc] initSearchLatestRequest];
        [self.searchLatestRequest searchWithKeyword:self.keyword pageNum:self.pageNum successed:^(NSArray *posts, NSArray *users, BOOL last, NSInteger pageNum) {
            weakSelf.searchLatestRequest = nil;
            if ([weakSelf.delegate respondsToSelector:@selector(onNewSearchLatest:posts:users:last:errCode:)])
            {
                [weakSelf.delegate onNewSearchLatest:weakSelf posts:posts users:users last:last errCode:ERROR_SUCCESS];
            }
        } error:^(NSInteger errorCode) {
            weakSelf.searchLatestRequest = nil;
            if ([weakSelf.delegate respondsToSelector:@selector(onNewSearchLatest:posts:users:last:errCode:)])
            {
                [weakSelf.delegate onNewSearchLatest:weakSelf posts:nil users:nil last:NO errCode:errorCode];
            }
        }];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(onNewSearchLatest:posts:users:last:errCode:)])
        {
            [self.delegate onNewSearchLatest:self posts:nil users:nil last:YES errCode:ERROR_SUCCESS];
        }
    }
}

- (void)tryMoreSearchLatest
{
    if (self.searchLatestRequest != nil) return;
    
    self.pageNum++;
    __weak typeof(self) weakSelf = self;
    self.searchLatestRequest = [[WLSearchLatestRequest alloc] initSearchLatestRequest];
    [self.searchLatestRequest searchWithKeyword:self.keyword pageNum:self.pageNum successed:^(NSArray *posts, NSArray *users, BOOL last, NSInteger pageNum) {
        weakSelf.searchLatestRequest = nil;
        if ([self.delegate respondsToSelector:@selector(onMoreSearchLatest:posts:last:errCode:)])
        {
            [self.delegate onMoreSearchLatest:weakSelf posts:posts last:last errCode:ERROR_SUCCESS];
        }
    } error:^(NSInteger errorCode) {
        weakSelf.searchLatestRequest = nil;
        if ([weakSelf.delegate respondsToSelector:@selector(onMoreSearchLatest:posts:last:errCode:)])
        {
            [weakSelf.delegate onMoreSearchLatest:weakSelf posts:nil last:NO errCode:errorCode];
        }
    }];
}

- (void)stop
{
    if (self.searchLatestRequest != nil)
    {
        [self.searchLatestRequest cancel];
        self.searchLatestRequest = nil;
    }
}

@end
