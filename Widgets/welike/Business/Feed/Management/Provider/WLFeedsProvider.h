//
//  WLFeedsProvider.h
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WLFeedsProviderDelegate;

@protocol WLFeedsProvider <NSObject>

- (void)tryRefreshFeeds;
- (void)tryHisFeeds;
- (void)setListener:(id<WLFeedsProviderDelegate>)delegate;
- (void)stop;

@optional
- (void)loadUid:(NSString *)uid;
- (void)loadPid:(NSString *)pid;
- (void)loadTopicID:(NSString *)topicID;

@end
