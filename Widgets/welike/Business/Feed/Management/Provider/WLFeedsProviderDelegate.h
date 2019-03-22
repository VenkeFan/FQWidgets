//
//  WLFeedsProviderDelegate.h
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WLFeedsProvider;

@protocol WLFeedsProviderDelegate <NSObject>

- (void)onRefreshFeedsProvider:(id<WLFeedsProvider>)provider feeds:(NSArray *)feeds newCount:(NSInteger)newCount last:(BOOL)last error:(NSInteger)error;
- (void)onReceiveHisFeedsProvider:(id<WLFeedsProvider>)provider feeds:(NSArray *)feeds last:(BOOL)last error:(NSInteger)error;

@end
