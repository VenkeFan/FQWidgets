//
//  WLTopicHotProvider.m
//  welike
//
//  Created by fan qi on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTopicHotProvider.h"
#import "WLTopicHotRequest.h"
#import "WLFeedsProviderDelegate.h"

@interface WLTopicHotProvider ()

@property (nonatomic, copy) NSString *topicID;
@property (nonatomic, strong) WLTopicHotRequest *feedsRequest;
@property (nonatomic, copy) NSString *cursor;
@property (nonatomic, weak) id<WLFeedsProviderDelegate> delegate;

@end

@implementation WLTopicHotProvider

- (void)loadTopicID:(NSString *)topicID {
    self.topicID = topicID;
}

- (void)tryRefreshFeeds {
    if (self.feedsRequest != nil) return;
    self.cursor = nil;
    [self.cacheList removeAllObjects];
    
    __weak typeof(self) weakSelf = self;
    self.feedsRequest = [[WLTopicHotRequest alloc] initWithTopicID:self.topicID];
    [self.feedsRequest tryTopicHotWithCursor:nil successed:^(NSArray *feeds, NSString *cursor) {
        weakSelf.feedsRequest = nil;
        NSInteger newCount = [weakSelf refreshNewCount:feeds];
        [weakSelf cacheFirstPage:feeds];
        self.cursor = cursor;
        BOOL last = [weakSelf.cursor length] == 0;
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

- (void)tryHisFeeds {
    if (self.feedsRequest != nil) return;
    
    if ([self.cursor length] != 0)
    {
        __weak typeof(self) weakSelf = self;
        self.feedsRequest = [[WLTopicHotRequest alloc] initWithTopicID:self.topicID];
        [self.feedsRequest tryTopicHotWithCursor:self.cursor successed:^(NSArray *feeds, NSString *cursor) {
            weakSelf.feedsRequest = nil;
            self.cursor = cursor;
            BOOL last = [weakSelf.cursor length] == 0;
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

- (void)setListener:(id<WLFeedsProviderDelegate>)delegate {
    self.delegate = delegate;
}

- (void)stop {
    if (self.feedsRequest != nil)
    {
        [self.feedsRequest cancel];
        self.feedsRequest = nil;
    }
}

@end
