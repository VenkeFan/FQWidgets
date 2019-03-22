//
//  WLRisingFeedsProvider.m
//  welike
//
//  Created by fan qi on 2018/12/20.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLRisingFeedsProvider.h"
#import "WLRisingFeedsRequest.h"
#import "WLAccountManager.h"
#import "WLFeedsProviderDelegate.h"

@interface WLRisingFeedsProvider ()

@property (nonatomic, strong) WLRisingFeedsRequest *feedsRequest;
@property (nonatomic, copy) NSString *cursor;
@property (nonatomic, weak) id<WLFeedsProviderDelegate> delegate;

@end

@implementation WLRisingFeedsProvider

- (void)tryRefreshFeeds {
    if (self.feedsRequest != nil) {
        return;
    }
    self.cursor = nil;
    [self.cacheList removeAllObjects];
    
    NSArray *interests = [self selectedInterests];
    
    __weak typeof(self) weakSelf = self;
    self.feedsRequest = [[WLRisingFeedsRequest alloc] init];
    [self.feedsRequest tryRisingFeedsWithCursor:nil interests:interests successed:^(NSArray *feeds, NSString *cursor) {
        weakSelf.feedsRequest = nil;
        NSInteger newCount = [weakSelf refreshNewCount:feeds];
        [weakSelf cacheFirstPage:feeds];
        weakSelf.cursor = cursor;
        BOOL last = [weakSelf.cursor length] == 0;
        if ([weakSelf.delegate respondsToSelector:@selector(onRefreshFeedsProvider:feeds:newCount:last:error:)]) {
            [weakSelf.delegate onRefreshFeedsProvider:weakSelf feeds:feeds newCount:newCount last:last error:ERROR_SUCCESS];
        }
    } error:^(NSInteger errorCode) {
        weakSelf.feedsRequest = nil;
        if ([weakSelf.delegate respondsToSelector:@selector(onRefreshFeedsProvider:feeds:newCount:last:error:)]) {
            [weakSelf.delegate onRefreshFeedsProvider:weakSelf feeds:nil newCount:0 last:NO error:errorCode];
        }
    }];
}

- (void)tryHisFeeds {
    if (self.feedsRequest != nil) {
        return;
    }
    
    if ([self.cursor length] != 0) {
        NSArray *interests = [self selectedInterests];
        
        __weak typeof(self) weakSelf = self;
        self.feedsRequest = [[WLRisingFeedsRequest alloc] init];
        [self.feedsRequest tryRisingFeedsWithCursor:self.cursor interests:interests successed:^(NSArray *feeds, NSString *cursor) {
            weakSelf.feedsRequest = nil;
            weakSelf.cursor = cursor;
            BOOL last = [weakSelf.cursor length] == 0;
            if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisFeedsProvider:feeds:last:error:)]) {
                [weakSelf.delegate onReceiveHisFeedsProvider:weakSelf feeds:feeds last:last error:ERROR_SUCCESS];
            }
        } error:^(NSInteger errorCode) {
            weakSelf.feedsRequest = nil;
            if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisFeedsProvider:feeds:last:error:)]) {
                [weakSelf.delegate onReceiveHisFeedsProvider:weakSelf feeds:nil last:NO error:errorCode];
            }
        }];
    } else {
        if ([self.delegate respondsToSelector:@selector(onReceiveHisFeedsProvider:feeds:last:error:)]) {
            [self.delegate onReceiveHisFeedsProvider:self feeds:nil last:YES error:ERROR_SUCCESS];
        }
    }
}

- (void)setListener:(id<WLFeedsProviderDelegate>)delegate {
    self.delegate = delegate;
}

- (void)stop {
    if (self.feedsRequest != nil) {
        [self.feedsRequest cancel];
        self.feedsRequest = nil;
    }
}

- (NSArray *)selectedInterests {
    NSString *defaultInterestID = @"59";
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:defaultInterestID];
    
    NSArray *selectedItems = (NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:kSelectionInterestsKey];
    if (selectedItems.count > 0) {
        [array addObjectsFromArray:selectedItems];
    }
    return array;
}

@end
