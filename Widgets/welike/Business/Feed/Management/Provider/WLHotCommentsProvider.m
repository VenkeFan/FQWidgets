//
//  WLHotCommentsProvider.m
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLHotCommentsProvider.h"
#import "WLCommentsRequest.h"
#import "WLCommentsProviderDelegate.h"

@interface WLHotCommentsProvider ()

@property (nonatomic, strong) WLCommentsRequest *commentsRequest;
@property (nonatomic, copy) NSString *cursor;
@property (nonatomic, weak) id<WLCommentsProviderDelegate> delegate;

@end

@implementation WLHotCommentsProvider

- (void)tryRefreshCommentsForPid:(NSString *)pid
{
    if (self.commentsRequest != nil) return;
    self.cursor = nil;
    
    __weak typeof(self) weakSelf = self;
    self.commentsRequest = [[WLCommentsRequest alloc] initCommentsRequestWithPid:pid];
    [self.commentsRequest listCommentsWithSort:WELIKE_COMMENTS_SORT_HOT cursor:nil successed:^(NSArray *comments, NSString *cursor) {
        weakSelf.commentsRequest = nil;
        weakSelf.cursor = cursor;
        BOOL last = [weakSelf.cursor length] == 0;
        if ([weakSelf.delegate respondsToSelector:@selector(onRefreshCommentsProvider:comments:last:error:)])
        {
            [weakSelf.delegate onRefreshCommentsProvider:weakSelf comments:comments last:last error:ERROR_SUCCESS];
        }
    } error:^(NSInteger errorCode) {
        weakSelf.commentsRequest = nil;
        if ([weakSelf.delegate respondsToSelector:@selector(onRefreshCommentsProvider:comments:last:error:)])
        {
            [weakSelf.delegate onRefreshCommentsProvider:weakSelf comments:nil last:NO error:errorCode];
        }
    }];
}

- (void)tryHisCommentsForPid:(NSString *)pid
{
    if (self.commentsRequest != nil) return;
    
    if ([self.cursor length] != 0)
    {
        __weak typeof(self) weakSelf = self;
        self.commentsRequest = [[WLCommentsRequest alloc] initCommentsRequestWithPid:pid];
        [self.commentsRequest listCommentsWithSort:WELIKE_COMMENTS_SORT_HOT cursor:self.cursor successed:^(NSArray *comments, NSString *cursor) {
            weakSelf.commentsRequest = nil;
            weakSelf.cursor = cursor;
            BOOL last = [weakSelf.cursor length] == 0;
            if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisCommentsProvider:comments:last:error:)])
            {
                [weakSelf.delegate onReceiveHisCommentsProvider:weakSelf comments:comments last:last error:ERROR_SUCCESS];
            }
        } error:^(NSInteger errorCode) {
            weakSelf.commentsRequest = nil;
            if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisCommentsProvider:comments:last:error:)])
            {
                [weakSelf.delegate onReceiveHisCommentsProvider:weakSelf comments:nil last:NO error:errorCode];
            }
        }];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(onReceiveHisCommentsProvider:comments:last:error:)])
        {
            [self.delegate onReceiveHisCommentsProvider:self comments:nil last:YES error:ERROR_SUCCESS];
        }
    }
}

- (void)setListener:(id<WLCommentsProviderDelegate>)delegate
{
    self.delegate = delegate;
}

- (void)stop
{
    if (self.commentsRequest != nil)
    {
        [self.commentsRequest cancel];
        self.commentsRequest = nil;
    }
}

@end
