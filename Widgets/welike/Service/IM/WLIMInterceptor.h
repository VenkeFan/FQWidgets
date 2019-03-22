//
//  WLIMInterceptor.h
//  welike
//
//  Created by 刘斌 on 2018/5/19.
//  Copyright © 2018年 redefine. All rights reserved.
//  长连接的管理

#import <Foundation/Foundation.h>
#import "WLIMCommon.h"

@protocol WLIMInterceptorDelegate <NSObject>

- (void)onIMAdapterReceivedMessages:(NSArray<WLIMMessage*> *)messages last:(BOOL)last;
- (void)onIMAdapterOneMessageSentResult:(NSString *)mid errCode:(NSInteger)errCode;
- (void)onIMAdapterAllMessagesSentResultsError:(NSInteger)errCode;

@end

@interface WLIMInterceptor : NSObject

@property (nonatomic, weak) id<WLIMInterceptorDelegate> delegate;

- (void)restart;
- (void)stop;

- (void)sendMessage:(WLIMMessage *)message;

@end
