//
//  WLSearchManager.h
//  welike
//
//  Created by 刘斌 on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WELIKE_SEARCH_TYPE)
{
    WELIKE_SEARCH_TYPE_USERS = 1,
    WELIKE_SEARCH_TYPE_POSTS,
    WELIKE_SEARCH_TYPE_LATEST
};

@protocol WLSearchManagerDelegate <NSObject>

- (void)onNewSearchResult:(NSArray *)results searchType:(WELIKE_SEARCH_TYPE)searchType last:(BOOL)last errCode:(NSInteger)errCode;
- (void)onMoreSearchResult:(NSArray *)results searchType:(WELIKE_SEARCH_TYPE)searchType last:(BOOL)last errCode:(NSInteger)errCode;

@end

@interface WLSearchManager : NSObject

@property (nonatomic, weak) id<WLSearchManagerDelegate> delegate;

- (void)searchWithKeyword:(NSString *)keyword searchType:(WELIKE_SEARCH_TYPE)searchType;
- (void)loadMore;

@end
