//
//  WLSugManager.m
//  welike
//
//  Created by 刘斌 on 2018/5/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSugManager.h"
#import "WLSearchSugRequest.h"
#import "WLSugResult.h"
#import "WLHistoryCache.h"

@interface WLSugManager ()

@property (nonatomic, strong) WLSearchSugRequest *searchSugRequest;

+ (NSArray *)dbHistoryListToSugResults:(NSArray *)dbList;

@end

@implementation WLSugManager

- (void)inputKeyword:(NSString *)keyword successed:(searchSugResultsSuccessed)successed
{
    if ([keyword length] > 0)
    {
        if (self.searchSugRequest != nil)
        {
            [self.searchSugRequest cancel];
        }
        self.searchSugRequest = [[WLSearchSugRequest alloc] initSearchSugRequest];
        __weak typeof(self) weakSelf = self;
        [self.searchSugRequest sugKeyword:keyword successed:^(NSArray *sugs) {
            weakSelf.searchSugRequest = nil;
            [WLHistoryCache resultType:WELIKE_SEARCH_HISTORY_TYPE_MAIN listRecentResults:^(NSArray *results, BOOL hasMore) {
                NSArray *hisResults = [WLSugManager dbHistoryListToSugResults:results];
                NSInteger allCount = [hisResults count] + [sugs count];
                if (allCount > 0)
                {
                    NSMutableArray *allSugs = [NSMutableArray arrayWithCapacity:allCount];
                    if ([hisResults count] > 0)
                    {
                        [allSugs addObjectsFromArray:hisResults];
                    }
                    if ([sugs count] > 0)
                    {
                        [allSugs addObjectsFromArray:sugs];
                    }
                    if (successed)
                    {
                        successed(keyword, allSugs);
                    }
                }
                else
                {
                    if (successed)
                    {
                        successed(keyword, nil);
                    }
                }
            }];
        } error:^(NSInteger errorCode) {
            weakSelf.searchSugRequest = nil;
            [WLHistoryCache resultType:WELIKE_SEARCH_HISTORY_TYPE_MAIN listRecentResults:^(NSArray *results, BOOL hasMore) {
                NSArray *hisResults = [WLSugManager dbHistoryListToSugResults:results];
                if ([hisResults count] > 0)
                {
                    if (successed)
                    {
                        successed(keyword, hisResults);
                    }
                }
                else
                {
                    if (successed)
                    {
                        successed(keyword, nil);
                    }
                }
            }];
        }];
    }
    else
    {
        [WLHistoryCache resultType:WELIKE_SEARCH_HISTORY_TYPE_MAIN listRecentResults:^(NSArray *results, BOOL hasMore) {
            if ([results count] > 0)
            {
                NSArray *sugResults = [WLSugManager dbHistoryListToSugResults:results];
                if (successed)
                {
                    successed(keyword, sugResults);
                }
            }
            else
            {
                if (successed)
                {
                    successed(keyword, nil);
                }
            }
        }];
    }
}

- (void)deleteHistory:(NSString *)keyword
{
    [WLHistoryCache deleteOne:keyword withResultType:WELIKE_SEARCH_HISTORY_TYPE_MAIN];
}

- (void)listAllHistory:(searchSugAllResultsCompleted)completed
{
    [WLHistoryCache resultType:WELIKE_SEARCH_HISTORY_TYPE_MAIN listAllResults:^(NSArray *results) {
        NSArray *sugResults = [WLSugManager dbHistoryListToSugResults:results];
        if (completed)
        {
            completed(sugResults);
        }
    }];
}

- (void)listRecentKeywords:(searchSugRecentResultsCompleted)completed
{
    [WLHistoryCache resultType:WELIKE_SEARCH_HISTORY_TYPE_MAIN listRecentResults:^(NSArray *results, BOOL hasMore) {
        NSArray *sugResults = [WLSugManager dbHistoryListToSugResults:results];
        if (completed)
        {
            completed(sugResults, hasMore);
        }
    }];
}

- (void)countAllHistory:(searchSugCount)completed
{
    [WLHistoryCache resultType:WELIKE_SEARCH_HISTORY_TYPE_MAIN AllCount:^(NSInteger count) {
        if (completed)
        {
            completed(count);
        }
    }];
}

- (void)insert:(NSString *)keyword
{
    WLSearchHistory *histroy = [[WLSearchHistory alloc] init];
    histroy.keyword = keyword;
    histroy.time = [[NSDate date] timeIntervalSince1970] * 1000;
    [WLHistoryCache insert:histroy withResultType:WELIKE_SEARCH_HISTORY_TYPE_MAIN];
}

- (void)cleanAllHistory
{
    [WLHistoryCache cleanAllWithResultType:WELIKE_SEARCH_HISTORY_TYPE_MAIN];
}

+ (NSArray *)dbHistoryListToSugResults:(NSArray *)dbList
{
     NSMutableArray *sugResults = [NSMutableArray arrayWithCapacity:[dbList count]];
    for (NSInteger i = 0; i < [dbList count]; i++)
    {
        WLSearchHistory *hisItem = [dbList objectAtIndex:i];
        WLSugResult *sugResult = [[WLSugResult alloc] init];
        sugResult.type = WELIKE_SUG_RESULT_TYPE_HIS;
        sugResult.category = WELIKE_SUG_RESULT_CATEGORY_KEYWORD;
        sugResult.object = hisItem.keyword;
        [sugResults addObject:sugResult];
    }
    return [NSArray arrayWithArray:sugResults];
}

@end
