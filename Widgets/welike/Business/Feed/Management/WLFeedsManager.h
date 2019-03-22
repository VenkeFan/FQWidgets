//
//  WLFeedsManager.h
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLFeedsProvider.h"
#import "WLFeedsProviderDelegate.h"
#import "WLFeedLayout.h"
#import "WLFeedRepostLayout.h"

@class WLFeedsManager;

@protocol WLFeedsManagerDelegate <NSObject>

- (void)onRefreshManager:(WLFeedsManager *)manager feeds:(NSArray *)feeds newCount:(NSInteger)newCount last:(BOOL)last errCode:(NSInteger)errCode;
- (void)onReceiveHisManager:(WLFeedsManager *)manager feeds:(NSArray *)feeds last:(BOOL)last errCode:(NSInteger)errCode;

@end

@interface WLFeedsManager : NSObject

@property (nonatomic, weak) id<WLFeedsManagerDelegate> delegate;

@property (nonatomic, assign, readonly) WLFeedLayoutType layoutType;
@property (nonatomic, assign, readonly) WLFeedSourceType sourceType;

- (void)setDataSourceProvider:(id<WLFeedsProvider>)provider uid:(NSString *)uid;
- (void)tryRefreshFeeds;
- (void)tryHisFeeds;

@end
