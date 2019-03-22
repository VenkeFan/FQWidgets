//
//  WLSearchUserProvider.h
//  welike
//
//  Created by 刘斌 on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLSearchUserProvider;

@protocol WLSearchUserProviderDelegate <NSObject>

- (void)onNewSearch:(WLSearchUserProvider *)provider users:(NSArray *)users last:(BOOL)last errCode:(NSInteger)errCode;
- (void)onMoreSearch:(WLSearchUserProvider *)provider users:(NSArray *)users last:(BOOL)last errCode:(NSInteger)errCode;

@end

@interface WLSearchUserProvider : NSObject

@property (nonatomic, weak) id<WLSearchUserProviderDelegate> delegate;

- (void)tryNewSearchUsers:(NSString *)keyword;
- (void)tryMoreSearchUsers;
- (void)stop;

@end
