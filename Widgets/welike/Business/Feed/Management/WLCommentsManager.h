//
//  WLCommentsManager.h
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLCommentsProvider.h"
#import "WLCommentsProviderDelegate.h"

@class WLCommentsManager;

@protocol WLCommentsManagerDelegate <NSObject>

- (void)onRefreshManager:(WLCommentsManager *)manager comments:(NSArray *)comments last:(BOOL)last errCode:(NSInteger)errCode;
- (void)onReceiveHisManager:(WLCommentsManager *)manager comments:(NSArray *)comments last:(BOOL)last errCode:(NSInteger)errCode;

@end

@interface WLCommentsManager : NSObject

@property (nonatomic, weak) id<WLCommentsManagerDelegate> delegate;

- (void)setDataSourceProvider:(id<WLCommentsProvider>)provider;
- (void)tryRefreshCommentsForPid:(NSString *)pid;
- (void)tryHisCommentsForPid:(NSString *)pid;

@end
