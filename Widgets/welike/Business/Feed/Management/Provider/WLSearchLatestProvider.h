//
//  WLSearchLatestProvider.h
//  welike
//
//  Created by 刘斌 on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLSearchLatestProvider;

@protocol WLSearchLatestProviderDelegate <NSObject>

- (void)onNewSearchLatest:(WLSearchLatestProvider *)provider posts:(NSArray *)posts users:(NSArray *)users last:(BOOL)last errCode:(NSInteger)errCode;
- (void)onMoreSearchLatest:(WLSearchLatestProvider *)provider posts:(NSArray *)posts last:(BOOL)last errCode:(NSInteger)errCode;

@end

@interface WLSearchLatestProvider : NSObject

@property (nonatomic, weak) id<WLSearchLatestProviderDelegate> delegate;

- (void)tryNewSearchLatest:(NSString *)keyword;
- (void)tryMoreSearchLatest;
- (void)stop;

@end
