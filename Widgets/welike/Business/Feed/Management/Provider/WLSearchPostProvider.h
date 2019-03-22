//
//  WLSearchPostProvider.h
//  welike
//
//  Created by 刘斌 on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLSearchPostProvider;

@protocol WLSearchPostProviderDelegate <NSObject>

- (void)onNewSearch:(WLSearchPostProvider *)provider posts:(NSArray *)posts last:(BOOL)last errCode:(NSInteger)errCode;
- (void)onMoreSearch:(WLSearchPostProvider *)provider posts:(NSArray *)posts last:(BOOL)last errCode:(NSInteger)errCode;

@end

@interface WLSearchPostProvider : NSObject

@property (nonatomic, weak) id<WLSearchPostProviderDelegate> delegate;

- (void)tryNewSearchPosts:(NSString *)keyword;
- (void)tryMoreSearchPosts;
- (void)stop;

@end
