//
//  WLLocationFeedsProvider.m
//  welike
//
//  Created by gyb on 2018/6/1.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLocationHotFeedsProvider.h"
#import "WLLocationFeedsLatestRequest.h"
#import "WLLocationFeedsHotRequest.h"
#import "WLLocationHotFeedsProvider.m"
#import "WLAccountManager.h"
#import "WLFeedsProviderDelegate.h"

@interface WLLocationHotFeedsProvider ()

@property (nonatomic, strong) WLLocationFeedsHotRequest *feedsRequest;
@property (nonatomic, strong) NSString *cursor;
@property (nonatomic, weak) id<WLFeedsProviderDelegate> delegate;
@property (nonatomic, assign) BOOL isEnd;

@end

@implementation WLLocationHotFeedsProvider

- (void)tryRefreshFeeds
{
    if (self.feedsRequest != nil) return;
    
    [self.cacheList removeAllObjects];
    
    __weak typeof(self) weakSelf = self;
    self.feedsRequest = [[WLLocationFeedsHotRequest alloc] initLocationHotFeeds:_placeId];
    [self.feedsRequest locationOfHotFeeds:nil successed:^(NSArray *feeds, NSString *cursor) {
        weakSelf.feedsRequest = nil;
        
        if (cursor.length > 0)
        {
            weakSelf.cursor = cursor;
            weakSelf.isEnd = NO;
        }
        else
        {
            weakSelf.isEnd = YES;
        }
    
        NSInteger newCount = [weakSelf refreshNewCount:feeds];
        [weakSelf cacheFirstPage:feeds];

        if ([weakSelf.delegate respondsToSelector:@selector(onRefreshFeedsProvider:feeds:newCount:last:error:)])
        {
            [weakSelf.delegate onRefreshFeedsProvider:weakSelf feeds:feeds newCount:newCount last:weakSelf.isEnd error:ERROR_SUCCESS];
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
        self.feedsRequest = [[WLLocationFeedsHotRequest alloc] initLocationHotFeeds:_placeId];
        [self.feedsRequest locationOfHotFeeds:_cursor successed:^(NSArray *feeds, NSString *cursor) {
            weakSelf.feedsRequest = nil;
            
            if (cursor.length > 0)
            {
                weakSelf.cursor = cursor;
                weakSelf.isEnd = NO;
            }
            else
            {
                weakSelf.isEnd = YES;
            }
            
            if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisFeedsProvider:feeds:last:error:)])
            {
                [weakSelf.delegate onReceiveHisFeedsProvider:weakSelf feeds:feeds last:weakSelf.isEnd error:ERROR_SUCCESS];
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
