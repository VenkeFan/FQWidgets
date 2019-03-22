//
//  WLSearchManager.m
//  welike
//
//  Created by 刘斌 on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchManager.h"
#import "WLSearchLatestProvider.h"
#import "WLSearchPostProvider.h"
#import "WLSearchUserProvider.h"
#import "WLFeedLayout.h"

@interface WLSearchManager () <WLSearchLatestProviderDelegate, WLSearchPostProviderDelegate, WLSearchUserProviderDelegate>

@property (nonatomic, strong) WLSearchLatestProvider *searchLatestProvider;
@property (nonatomic, strong) WLSearchPostProvider *searchPostProvider;
@property (nonatomic, strong) WLSearchUserProvider *searchUserProvider;
@property (nonatomic, assign) WELIKE_SEARCH_TYPE currentType;

- (NSArray *)convertPostListToLayoutModelList:(NSArray *)feeds;

@end

@implementation WLSearchManager

- (id)init
{
    self = [super init];
    if (self)
    {
        self.searchLatestProvider = [[WLSearchLatestProvider alloc] init];
        self.searchLatestProvider.delegate = self;
        self.searchPostProvider = [[WLSearchPostProvider alloc] init];
        self.searchPostProvider.delegate = self;
        self.searchUserProvider = [[WLSearchUserProvider alloc] init];
        self.searchUserProvider.delegate = self;
    }
    return self;
}

- (void)searchWithKeyword:(NSString *)keyword searchType:(WELIKE_SEARCH_TYPE)searchType
{
    self.currentType = searchType;
    if (self.currentType == WELIKE_SEARCH_TYPE_LATEST)
    {
        [self.searchPostProvider stop];
        [self.searchUserProvider stop];
        [self.searchLatestProvider tryNewSearchLatest:keyword];
    }
    else if (self.currentType == WELIKE_SEARCH_TYPE_POSTS)
    {
        [self.searchLatestProvider stop];
        [self.searchUserProvider stop];
        [self.searchPostProvider tryNewSearchPosts:keyword];
    }
    else if (self.currentType == WELIKE_SEARCH_TYPE_USERS)
    {
        [self.searchLatestProvider stop];
        [self.searchPostProvider stop];
        [self.searchUserProvider tryNewSearchUsers:keyword];
    }
}

- (void)loadMore
{
    if (self.currentType == WELIKE_SEARCH_TYPE_LATEST)
    {
        [self.searchLatestProvider tryMoreSearchLatest];
    }
    else if (self.currentType == WELIKE_SEARCH_TYPE_POSTS)
    {
        [self.searchPostProvider tryMoreSearchPosts];
    }
    else if (self.currentType == WELIKE_SEARCH_TYPE_USERS)
    {
        [self.searchUserProvider tryMoreSearchUsers];
    }
}

- (void)onNewSearchLatest:(WLSearchLatestProvider *)provider posts:(NSArray *)posts users:(NSArray *)users last:(BOOL)last errCode:(NSInteger)errCode
{
     if ([posts count] > 0 || [users count] > 0)
    {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSInteger count = [posts count] + [users count];
            NSMutableArray *list = [NSMutableArray arrayWithCapacity:count];
            if ([users count] > 0)
            {
                [list addObjectsFromArray:users];
            }
            if ([posts count] > 0)
            {
                NSArray *feedModels = [weakSelf convertPostListToLayoutModelList:posts];
                [list addObjectsFromArray:feedModels];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(onNewSearchResult:searchType:last:errCode:)])
                {
                    [self.delegate onNewSearchResult:list searchType:WELIKE_SEARCH_TYPE_LATEST last:last errCode:errCode];
                }
            });
        });
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(onNewSearchResult:searchType:last:errCode:)])
        {
            [self.delegate onNewSearchResult:nil searchType:WELIKE_SEARCH_TYPE_LATEST last:last errCode:errCode];
        }
    }
}

- (void)onMoreSearchLatest:(WLSearchLatestProvider *)provider posts:(NSArray *)posts last:(BOOL)last errCode:(NSInteger)errCode
{
    if ([posts count] > 0)
    {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *feedModels = nil;
            if ([posts count] > 0)
            {
                feedModels = [weakSelf convertPostListToLayoutModelList:posts];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(onMoreSearchResult:searchType:last:errCode:)])
                {
                    [self.delegate onMoreSearchResult:feedModels searchType:WELIKE_SEARCH_TYPE_LATEST last:last errCode:errCode];
                }
            });
        });
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(onMoreSearchResult:searchType:last:errCode:)])
        {
            [self.delegate onMoreSearchResult:nil searchType:WELIKE_SEARCH_TYPE_LATEST last:last errCode:errCode];
        }
    }
}

- (void)onNewSearch:(WLSearchPostProvider *)provider posts:(NSArray *)posts last:(BOOL)last errCode:(NSInteger)errCode
{
    if ([posts count] > 0)
    {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *feedModels = nil;
            if ([posts count] > 0)
            {
                feedModels = [weakSelf convertPostListToLayoutModelList:posts];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(onNewSearchResult:searchType:last:errCode:)])
                {
                    [self.delegate onNewSearchResult:feedModels searchType:WELIKE_SEARCH_TYPE_POSTS last:last errCode:errCode];
                }
            });
        });
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(onNewSearchResult:searchType:last:errCode:)])
        {
            [self.delegate onNewSearchResult:nil searchType:WELIKE_SEARCH_TYPE_POSTS last:last errCode:errCode];
        }
    }
}

- (void)onMoreSearch:(WLSearchPostProvider *)provider posts:(NSArray *)posts last:(BOOL)last errCode:(NSInteger)errCode
{
    if ([posts count] > 0)
    {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *feedModels = nil;
            if ([posts count] > 0)
            {
                feedModels = [weakSelf convertPostListToLayoutModelList:posts];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(onMoreSearchResult:searchType:last:errCode:)])
                {
                    [self.delegate onMoreSearchResult:feedModels searchType:WELIKE_SEARCH_TYPE_POSTS last:last errCode:errCode];
                }
            });
        });
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(onMoreSearchResult:searchType:last:errCode:)])
        {
            [self.delegate onMoreSearchResult:nil searchType:WELIKE_SEARCH_TYPE_POSTS last:last errCode:errCode];
        }
    }
}

- (void)onNewSearch:(WLSearchUserProvider *)provider users:(NSArray *)users last:(BOOL)last errCode:(NSInteger)errCode
{
    if ([users count] > 0)
    {
        if ([self.delegate respondsToSelector:@selector(onNewSearchResult:searchType:last:errCode:)])
        {
            [self.delegate onNewSearchResult:users searchType:WELIKE_SEARCH_TYPE_USERS last:last errCode:errCode];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(onNewSearchResult:searchType:last:errCode:)])
        {
            [self.delegate onNewSearchResult:nil searchType:WELIKE_SEARCH_TYPE_USERS last:last errCode:errCode];
        }
    }
}

- (void)onMoreSearch:(WLSearchUserProvider *)provider users:(NSArray *)users last:(BOOL)last errCode:(NSInteger)errCode
{
    if ([users count] > 0)
    {
        if ([self.delegate respondsToSelector:@selector(onMoreSearchResult:searchType:last:errCode:)])
        {
            [self.delegate onMoreSearchResult:users searchType:WELIKE_SEARCH_TYPE_USERS last:last errCode:errCode];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(onMoreSearchResult:searchType:last:errCode:)])
        {
            [self.delegate onMoreSearchResult:nil searchType:WELIKE_SEARCH_TYPE_USERS last:last errCode:errCode];
        }
    }
}

- (NSArray *)convertPostListToLayoutModelList:(NSArray *)feeds
{
    NSMutableArray *feedModels = [NSMutableArray arrayWithCapacity:[feeds count]];
    for (NSInteger i = 0; i < [feeds count]; i++) {
        WLPostBase *feed = [feeds objectAtIndex:i];
        WLFeedLayout *layout = [WLFeedLayout layoutWithFeedModel:feed];
        [feedModels addObject:layout];
    }
    return feedModels;
}

@end
