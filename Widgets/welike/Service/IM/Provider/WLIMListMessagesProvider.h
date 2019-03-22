//
//  WLIMListMessagesProvider.h
//  welike
//
//  Created by 刘斌 on 2018/5/20.
//  Copyright © 2018年 redefine. All rights reserved.
// 数库取消息

#import <Foundation/Foundation.h>
#import "WLIMCommon.h"

@class WLIMDatabaseManager;

typedef void(^imListMessagesRefreshMessages) (NSArray<WLIMMessage*> *messages);

@interface WLIMListMessagesProvider : NSObject

- (id)initWithCache:(WLIMDatabaseManager *)cache;

- (void)refreshMessagesWithSession:(WLIMSession *)session completed:(imListMessagesRefreshMessages)completed;
- (void)hisMessagesWithSession:(WLIMSession *)session completed:(imListMessagesRefreshMessages)completed;

@end
