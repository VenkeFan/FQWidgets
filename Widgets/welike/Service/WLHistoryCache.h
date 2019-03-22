//
//  WLHistoryCache.h
//  welike
//
//  Created by 刘斌 on 2018/5/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WELIKE_SEARCH_HISTORY_TYPE)
{
    WELIKE_SEARCH_HISTORY_TYPE_MAIN = 1,
    WELIKE_SEARCH_HISTORY_TYPE_TOPIC
};

typedef void(^historyRecentSugResultsCompleted)(NSArray *results, BOOL hasMore);
typedef void(^historyAllSugResultsCompleted)(NSArray *results);
typedef void(^historySugCount)(NSInteger count);

@interface WLSearchHistory : NSObject

@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, assign) long long time;

@end

@interface WLHistoryCache : NSObject

+ (void)prepare;
+ (void)keyword:(NSString *)keyword resultType:(WELIKE_SEARCH_HISTORY_TYPE)type listRecentResults:(historyAllSugResultsCompleted)completed;
+ (void)resultType:(WELIKE_SEARCH_HISTORY_TYPE)type listRecentResults:(historyRecentSugResultsCompleted)completed;
+ (void)resultType:(WELIKE_SEARCH_HISTORY_TYPE)type listAllResults:(historyAllSugResultsCompleted)completed;
+ (void)resultType:(WELIKE_SEARCH_HISTORY_TYPE)type AllCount:(historySugCount)completed;
+ (void)insert:(WLSearchHistory *)history withResultType:(WELIKE_SEARCH_HISTORY_TYPE)type;
+ (void)deleteOne:(NSString *)keyword withResultType:(WELIKE_SEARCH_HISTORY_TYPE)type;
+ (void)cleanAllWithResultType:(WELIKE_SEARCH_HISTORY_TYPE)type;

@end
