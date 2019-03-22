//
//  WLLocationFeedsProvider.m
//  welike
//
//  Created by gyb on 2018/6/1.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLocationFeedsProvider.h"
#import "WLLocationFeedsLatestRequest.h"
#import "WLAccountManager.h"
#import "WLFeedsProviderDelegate.h"

@interface WLLocationFeedsProvider ()

@property (nonatomic, strong) WLLocationFeedsLatestRequest *feedsRequest;
@property (nonatomic, assign) NSInteger pageNo;
@property (nonatomic, weak) id<WLFeedsProviderDelegate> delegate;
@property (nonatomic, assign) BOOL isEnd;

@end

@implementation WLLocationFeedsProvider

- (void)tryRefreshFeeds
{
    if (self.feedsRequest != nil) return;

    self.pageNo = 0;
    
    [self.cacheList removeAllObjects];
    
    __weak typeof(self) weakSelf = self;
    self.feedsRequest = [[WLLocationFeedsLatestRequest alloc] initLocationFeedsLatest:_placeId];
    [self.feedsRequest locationOfLatestFeeds:_pageNo successed:^(NSArray *feeds, BOOL last, NSInteger pageNum) {
        weakSelf.feedsRequest = nil;
        if (last == NO)
        {
            weakSelf.pageNo++;
        }
        
        weakSelf.isEnd = last;
        
        NSInteger newCount = [weakSelf refreshNewCount:feeds];
        [weakSelf cacheFirstPage:feeds];

        if ([weakSelf.delegate respondsToSelector:@selector(onRefreshFeedsProvider:feeds:newCount:last:error:)])
        {
            [weakSelf.delegate onRefreshFeedsProvider:weakSelf feeds:feeds newCount:newCount last:last error:ERROR_SUCCESS];
        }
    } error:^(NSInteger errorCode) {
        
        weakSelf.feedsRequest = nil;
        if ([weakSelf.delegate respondsToSelector:@selector(onRefreshFeedsProvider:feeds:newCount:last:error:)])
        {
            [weakSelf.delegate onRefreshFeedsProvider:weakSelf feeds:nil newCount:0 last:NO error:errorCode];
        }
        
    }];
}

- (void)tryHisFeeds
{
    if (self.feedsRequest != nil) return;

    if (self.isEnd == NO)
    {
        __weak typeof(self) weakSelf = self;
        self.feedsRequest = [[WLLocationFeedsLatestRequest alloc] initLocationFeedsLatest:_placeId];
        [self.feedsRequest locationOfLatestFeeds:_pageNo successed:^(NSArray *feeds, BOOL last, NSInteger pageNum)
        {
            weakSelf.feedsRequest = nil;
            if (last == NO)
            {
                weakSelf.pageNo++;
            }
            
              weakSelf.isEnd = last;
            if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisFeedsProvider:feeds:last:error:)])
            {
                [weakSelf.delegate onReceiveHisFeedsProvider:weakSelf feeds:feeds last:last error:ERROR_SUCCESS];
            }
        } error:^(NSInteger errorCode) {
            weakSelf.feedsRequest = nil;
            if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisFeedsProvider:feeds:last:error:)])
            {
                [weakSelf.delegate onReceiveHisFeedsProvider:weakSelf feeds:nil last:NO error:errorCode];
            }
      }];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(onReceiveHisFeedsProvider:feeds:last:error:)])
        {
            [self.delegate onReceiveHisFeedsProvider:self feeds:nil last:YES error:ERROR_SUCCESS];
        }
    }
}

- (void)setListener:(id<WLFeedsProviderDelegate>)delegate
{
    self.delegate = delegate;
}

- (void)stop
{
    if (self.feedsRequest != nil)
    {
        [self.feedsRequest cancel];
        self.feedsRequest = nil;
    }
}

@end
