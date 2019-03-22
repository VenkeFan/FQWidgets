//
//  WLCommentsProviderDelegate.h
//  welike
//
//  Created by 刘斌 on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WLCommentsProvider;

@protocol WLCommentsProviderDelegate <NSObject>

- (void)onRefreshCommentsProvider:(id<WLCommentsProvider>)provider comments:(NSArray *)comments last:(BOOL)last error:(NSInteger)error;
- (void)onReceiveHisCommentsProvider:(id<WLCommentsProvider>)provider comments:(NSArray *)comments last:(BOOL)last error:(NSInteger)error;

@end
