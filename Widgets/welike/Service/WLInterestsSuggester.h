//
//  WLInterestsSuggester.h
//  welike
//
//  Created by 刘斌 on 2018/5/1.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLReferrerInfo;

@protocol WLInterestsSuggesterDelegate <NSObject>

@optional
- (void)onRefreshInetrestSuggestions:(NSArray *)interests referrerInfo:(WLReferrerInfo *)referrerInfo errCode:(NSInteger)errCode;
- (void)onHisInterestSuggestions:(NSArray *)interests last:(BOOL)last errCode:(NSInteger)errCode;

@end

@interface WLInterestsSuggester : NSObject

@property (nonatomic, weak) id<WLInterestsSuggesterDelegate> delegate;

- (void)refresh;
- (void)his;

@end
