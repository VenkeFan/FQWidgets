//
//  WLFeedsManager.m
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFeedsManager.h"
#import "WLHomeFeedsProvider.h"
#import "WLLatestFeedsProvider.h"
#import "WLHotFeedsProvider.h"
#import "WLRisingFeedsProvider.h"
#import "WLUserPostsProvider.h"
#import "WLUserLikePostsProvider.h"
#import "WLTopicHotProvider.h"
#import "WLTopicLatestProvider.h"
#import "WLForwardPostsProvider.h"
#import "WLLocationFeedsProvider.h"
#import "WLLocationHotFeedsProvider.h"
#import "WLHandledFeedModel.h"
#import "WLForwardPost.h"

@interface WLFeedsManager () <WLFeedsProviderDelegate>

@property (nonatomic, strong) id<WLFeedsProvider> provider;
@property (nonatomic, assign, readwrite) WLFeedLayoutType layoutType;
@property (nonatomic, assign, readwrite) WLFeedSourceType sourceType;

- (NSArray *)convertPostListToLayoutModelList:(NSArray *)feeds;

@end

@implementation WLFeedsManager

- (void)setDataSourceProvider:(id<WLFeedsProvider>)provider uid:(NSString *)uid
{
    if (self.provider != nil)
    {
        [self.provider stop];
        [self.provider setListener:nil];
    }
    self.provider = provider;
    if ([self.provider respondsToSelector:@selector(loadUid:)])
    {
        [self.provider loadUid:uid];
    }
    [self.provider setListener:self];
    
    [self p_setLayoutAndSourceTypeWithProvider:provider];
}

- (void)tryRefreshFeeds
{
    if (self.provider != nil)
    {
        [self.provider tryRefreshFeeds];
    }
}

- (void)tryHisFeeds
{
    if (self.provider != nil)
    {
        [self.provider tryHisFeeds];
    }
}

#pragma mark WLFeedsProviderDelegate private methods
- (void)onRefreshFeedsProvider:(id<WLFeedsProvider>)provider feeds:(NSArray *)feeds newCount:(NSInteger)newCount last:(BOOL)last error:(NSInteger)error
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *feedModels = [weakSelf convertPostListToLayoutModelList:feeds];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(onRefreshManager:feeds:newCount:last:errCode:)])
            {
                [weakSelf.delegate onRefreshManager:weakSelf feeds:feedModels newCount:newCount last:last errCode:error];
            }
        });
    });
}

- (void)onReceiveHisFeedsProvider:(id<WLFeedsProvider>)provider feeds:(NSArray *)feeds last:(BOOL)last error:(NSInteger)error
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *feedModels = [weakSelf convertPostListToLayoutModelList:feeds];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(onReceiveHisManager:feeds:last:errCode:)])
            {
                [weakSelf.delegate onReceiveHisManager:weakSelf feeds:feedModels last:last errCode:error];
            }
        });
    });
}

#pragma mark - Private
- (NSArray *)convertPostListToLayoutModelList:(NSArray *)feeds
{
    NSMutableArray *feedModels = [NSMutableArray arrayWithCapacity:[feeds count]];
    for (NSInteger i = 0; i < [feeds count]; i++) {
        WLPostBase *feed = [feeds objectAtIndex:i];
        if (self.layoutType == WLFeedLayoutType_RepostInDetail) {
            WLFeedRepostLayout *layout = [WLFeedRepostLayout layoutWithFeedModel:feed];
            [feedModels addObject:layout];
        } else {
            WLFeedLayout *layout = [WLFeedLayout layoutWithFeedModel:feed layoutType:self.layoutType];
            [feedModels addObject:layout];
        }
    }
    return feedModels;
}

- (void)p_setLayoutAndSourceTypeWithProvider:(id<WLFeedsProvider>)provider {
    if ([provider isKindOfClass:[WLHomeFeedsProvider class]]) {
        self.layoutType = WLFeedLayoutType_TimeLine;
        self.sourceType = WLFeedSourceType_Home;
    } else if ([provider isKindOfClass:[WLHotFeedsProvider class]]) {
        self.layoutType = WLFeedLayoutType_TimeLine;
        self.sourceType = WLFeedSourceType_Discover_Hot;
    } else if ([provider isKindOfClass:[WLLatestFeedsProvider class]]
               || [provider isKindOfClass:[WLRisingFeedsProvider class]]) {
        self.layoutType = WLFeedLayoutType_TimeLine;
        self.sourceType = WLFeedSourceType_Discover_Latest;
    } else if ([provider isKindOfClass:[WLUserPostsProvider class]]) {
        self.layoutType = WLFeedLayoutType_UserDetail;
        self.sourceType = WLFeedSourceType_UserDetail_Posts;
    } else if ([provider isKindOfClass:[WLUserLikePostsProvider class]]) {
        self.layoutType = WLFeedLayoutType_UserDetail;
        self.sourceType = WLFeedSourceType_UserDetail_Likes;
    } else if ([provider isKindOfClass:[WLTopicHotProvider class]]) {
        self.layoutType = WLFeedLayoutType_TimeLine;
        self.sourceType = WLFeedSourceType_Topic_Hot;
    } else if ([provider isKindOfClass:[WLTopicLatestProvider class]]) {
        self.layoutType = WLFeedLayoutType_TimeLine;
        self.sourceType = WLFeedSourceType_Topic_Latest;
    } else if ([provider isKindOfClass:[WLForwardPostsProvider class]]) {
        self.layoutType = WLFeedLayoutType_RepostInDetail;
        self.sourceType = WLFeedSourceType_RepostInDetail;
    } else if ([provider isKindOfClass:[WLLocationFeedsProvider class]]) {
        self.layoutType = WLFeedLayoutType_TimeLine;
        self.sourceType = WLFeedSourceType_Location_Latest;
    } else if ([provider isKindOfClass:[WLLocationHotFeedsProvider class]]) {
        self.layoutType = WLFeedLayoutType_TimeLine;
        self.sourceType = WLFeedSourceType_Location_Hot;
    }
}

@end
