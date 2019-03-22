//
//  WLSearchPostProvider.m
//  welike
//
//  Created by 刘斌 on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchPostProvider.h"
#import "WLSearchPostRequest.h"

@interface WLSearchPostProvider ()

@property (nonatomic, strong) WLSearchPostRequest *searchPostRequest;
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, assign) NSInteger pageNum;

@end

@implementation WLSearchPostProvider

- (void)tryNewSearchPosts:(NSString *)keyword
{
    if (self.searchPostRequest != nil)
    {
        [self.searchPostRequest cancel];
        self.searchPostRequest = nil;
    }
    
    self.pageNum = 0;
    self.keyword = keyword;
    if ([self.keyword length] > 0)
    {
        __weak typeof(self) weakSelf = self;
        self.searchPostRequest = [[WLSearchPostRequest alloc] initSearchPostRequest];
        [self.searchPostRequest searchWithKeyword:self.keyword pageNum:self.pageNum successed:^(NSArray *posts, BOOL last, NSInteger pageNum) {
            weakSelf.searchPostRequest = nil;
            if ([weakSelf.delegate respondsToSelector:@selector(onNewSearch:posts:last:errCode:)])
            {
                [weakSelf.delegate onNewSearch:weakSelf posts:posts last:last errCode:ERROR_SUCCESS];
            }
        } error:^(NSInteger errorCode) {
            weakSelf.searchPostRequest = nil;
            if ([weakSelf.delegate respondsToSelector:@selector(onNewSearch:posts:last:errCode:)])
            {
                [weakSelf.delegate onNewSearch:weakSelf posts:nil last:NO errCode:errorCode];
            }
        }];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(onNewSearch:posts:last:errCode:)])
        {
            [self.delegate onNewSearch:self posts:nil last:YES errCode:ERROR_SUCCESS];
        }
    }
}

- (void)tryMoreSearchPosts
{
    if (self.searchPostRequest != nil) return;
    
    self.pageNum++;
    __weak typeof(self) weakSelf = self;
    self.searchPostRequest = [[WLSearchPostRequest alloc] initSearchPostRequest];
    [self.searchPostRequest searchWithKeyword:self.keyword pageNum:self.pageNum successed:^(NSArray *posts, BOOL last, NSInteger pageNum) {
        weakSelf.searchPostRequest = nil;
        if ([weakSelf.delegate respondsToSelector:@selector(onMoreSearch:posts:last:errCode:)])
        {
            [weakSelf.delegate onMoreSearch:weakSelf posts:posts last:last errCode:ERROR_SUCCESS];
        }
    } error:^(NSInteger errorCode) {
        weakSelf.searchPostRequest = nil;
        if ([weakSelf.delegate respondsToSelector:@selector(onMoreSearch:posts:last:errCode:)])
        {
            [weakSelf.delegate onMoreSearch:weakSelf posts:nil last:NO errCode:errorCode];
        }
    }];
}

- (void)stop
{
    if (self.searchPostRequest != nil)
    {
        [self.searchPostRequest cancel];
        self.searchPostRequest = nil;
    }
}

@end
