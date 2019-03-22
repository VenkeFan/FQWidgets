//
//  WLIMMessageSender.h
//  welike
//
//  Created by 刘斌 on 2018/5/20.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLIMCommon.h"

@class WLIMDatabaseManager;

@protocol WLIMMessageSenderDelegate <NSObject>

- (void)willSendMessage:(WLIMMessage *)message;
- (void)onIMSenderOneMessage:(NSString *)mid process:(CGFloat)process;
- (void)onIMSenderOneMessageSentResult:(WLIMMessage *)message errCode:(NSInteger)errCode;

@end

@interface WLIMMessageSender : NSObject

@property (nonatomic, weak) id<WLIMMessageSenderDelegate> delegate;

- (id)initWithCache:(WLIMDatabaseManager *)cache;

- (void)sendMessage:(WLIMMessage *)message session:(WLIMSession *)session;
- (void)cancelAllSendingMessages;
- (void)handleOneMessageSentResult:(NSString *)mid errCode:(NSInteger)errCode;

@end
