//
//  WLHistoryCache.m
//  welike
//
//  Created by 刘斌 on 2018/5/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLHistoryCache.h"
#import "WLCommonDBManager.h"

#define HISTORY_COL_HID                                 @"hid"
#define HISTORY_COL_TYPE                                @"type"
#define HISTORY_COL_KEYWORD                             @"keyword"
#define HISTORY_COL_TIME                                @"time"

#define CREATE_HISTORY_TABLE_SQL @"CREATE TABLE IF NOT EXISTS history (%@ INTEGER PRIMARY KEY AUTOINCREMENT, %@ INTEGER, %@ TEXT, %@ INTEGER)"
#define INSERT_HISTORY_SQL @"INSERT INTO history (%@, %@, %@) VALUES (?, ? ,?)"

@implementation WLSearchHistory

@end

@implementation WLHistoryCache

+ (void)prepare
{
    NSString *sql = [NSString stringWithFormat:CREATE_HISTORY_TABLE_SQL, HISTORY_COL_HID, HISTORY_COL_TYPE, HISTORY_COL_KEYWORD, HISTORY_COL_TIME];
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [db executeUpdate:sql];
}

+ (void)keyword:(NSString *)keyword resultType:(WELIKE_SEARCH_HISTORY_TYPE)type listRecentResults:(historyAllSugResultsCompleted)completed
{
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] asyncBlock:^{
        NSMutableArray *results = [NSMutableArray array];
        NSString *likeParameter = [NSString stringWithFormat:@"%%%@%%", keyword];
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM history WHERE %@ = ? LIKE ? ORDER BY %@ DESC LIMIT %d", HISTORY_COL_TYPE, HISTORY_COL_TIME, SUG_EMPTY_HIS_SHOW_NUM], [NSNumber numberWithInteger:type], likeParameter];
        while ([rs next])
        {
            WLSearchHistory *history = [[WLSearchHistory alloc] init];
            history.keyword = [rs stringForColumn:HISTORY_COL_KEYWORD];
            history.time = [rs longLongIntForColumn:HISTORY_COL_TIME];
            [results addObject:history];
        }
        [rs close];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed)
            {
                completed(results);
            }
        });
    }];
}

+ (void)resultType:(WELIKE_SEARCH_HISTORY_TYPE)type listRecentResults:(historyRecentSugResultsCompleted)completed
{
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] asyncBlock:^{
        NSMutableArray *results = [NSMutableArray array];
        
        NSInteger totalCount = 0;
        FMResultSet *rsCount = [db executeQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM history WHERE %@ = ?", HISTORY_COL_TYPE], [NSNumber numberWithInteger:type]];
        if ([rsCount next])
        {
            totalCount = [rsCount intForColumnIndex:0];
        }
        [rsCount close];
        BOOL hasMore = NO;
        if (totalCount > 0)
        {
            FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM history WHERE %@ = ? ORDER BY %@ DESC LIMIT %d", HISTORY_COL_TYPE, HISTORY_COL_TIME, SUG_EMPTY_HIS_SHOW_NUM], [NSNumber numberWithInteger:type]];
            while ([rs next])
            {
                WLSearchHistory *history = [[WLSearchHistory alloc] init];
                history.keyword = [rs stringForColumn:HISTORY_COL_KEYWORD];
                history.time = [rs longLongIntForColumn:HISTORY_COL_TIME];
                [results addObject:history];
            }
            [rs close];
            if (totalCount > SUG_EMPTY_HIS_SHOW_NUM)
            {
                hasMore = YES;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed)
            {
                completed(results, hasMore);
            }
        });
    }];
}

+ (void)resultType:(WELIKE_SEARCH_HISTORY_TYPE)type listAllResults:(historyAllSugResultsCompleted)completed
{
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] asyncBlock:^{
        NSMutableArray *results = [NSMutableArray array];
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM history WHERE %@ = ? ORDER BY %@ DESC", HISTORY_COL_TYPE, HISTORY_COL_TIME], [NSNumber numberWithInteger:type]];
        while ([rs next])
        {
            WLSearchHistory *history = [[WLSearchHistory alloc] init];
            history.keyword = [rs stringForColumn:HISTORY_COL_KEYWORD];
            history.time = [rs longLongIntForColumn:HISTORY_COL_TIME];
            [results addObject:history];
        }
        [rs close];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed)
            {
                completed(results);
            }
        });
    }];
}

+ (void)resultType:(WELIKE_SEARCH_HISTORY_TYPE)type AllCount:(historySugCount)completed
{
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] asyncBlock:^{
        NSInteger totalCount = 0;
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM history WHERE %@ = ?", HISTORY_COL_TYPE]];
        if ([rs next])
        {
            totalCount = [rs intForColumnIndex:0];
        }
        [rs close];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed)
            {
                completed(totalCount);
            }
        });
    }];
}

+ (void)insert:(WLSearchHistory *)history withResultType:(WELIKE_SEARCH_HISTORY_TYPE)type
{
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] asyncBlock:^{
        [db beginTransaction];
        
        [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM history WHERE %@ = ? AND %@ = ?", HISTORY_COL_TYPE, HISTORY_COL_KEYWORD], [NSNumber numberWithInteger:type], history.keyword];
        BOOL res = [db executeUpdate:[NSString stringWithFormat:INSERT_HISTORY_SQL, HISTORY_COL_TYPE, HISTORY_COL_KEYWORD, HISTORY_COL_TIME], [NSNumber numberWithInteger:type], history.keyword, [NSNumber numberWithLongLong:history.time]];
        if (res == NO)
        {
            [db rollback];
            return;
        }
        
        [db commit];
    }];
}

+ (void)deleteOne:(NSString *)keyword withResultType:(WELIKE_SEARCH_HISTORY_TYPE)type
{
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] asyncBlock:^{
        [db beginTransaction];
        
        [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM history WHERE %@ = ? AND %@ = ?", HISTORY_COL_TYPE, HISTORY_COL_KEYWORD], [NSNumber numberWithInteger:type], keyword];
        
        [db commit];
    }];
}

+ (void)cleanAllWithResultType:(WELIKE_SEARCH_HISTORY_TYPE)type
{
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] asyncBlock:^{
        [db beginTransaction];
        
        [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM history WHERE %@ = ?", HISTORY_COL_TYPE], [NSNumber numberWithInteger:type]];
        
        [db commit];
    }];
}

@end
