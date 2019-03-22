//
//  WLSugManager.h
//  welike
//
//  Created by 刘斌 on 2018/5/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLSugResult;

typedef void(^searchSugResultsSuccessed)(NSString *keyword, NSArray *results);
typedef void(^searchSugRecentResultsCompleted)(NSArray *results, BOOL hasMore);
typedef void(^searchSugAllResultsCompleted)(NSArray *results);
typedef void(^searchSugCount)(NSInteger count);

@interface WLSugManager : NSObject

- (void)inputKeyword:(NSString *)keyword successed:(searchSugResultsSuccessed)successed;
- (void)deleteHistory:(NSString *)keyword;
- (void)listAllHistory:(searchSugAllResultsCompleted)successed;
- (void)listRecentKeywords:(searchSugRecentResultsCompleted)successed;
- (void)countAllHistory:(searchSugCount)completed;
- (void)insert:(NSString *)keyword;
- (void)cleanAllHistory;

@end
