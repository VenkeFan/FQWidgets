//
//  WLMessageGroup.h
//  welike
//
//  Created by luxing on 2018/5/20.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLIMMessage.h"
#import "WLUser.h"

@interface WLMessageGroup : NSObject

@property (nonatomic, assign) int64_t startTime;

@property (nonatomic, assign) int64_t endTime;

//+ (NSArray<WLMessageGroup*> *)groupsWithMessages:(NSArray *)messages;
//
//+ (NSArray<WLMessageGroup *> *)groups:(NSArray<WLMessageGroup *> *)messageGroups mergeMessages:(NSArray<WLIMMessage *> *)messages;
- (void)refreshUser:(WLUser *)user;

- (void)refreshAllSendingMessages;

- (void)refreshMessage:(WLIMMessage *)message;

- (NSUInteger)messagesCount;

- (NSUInteger)indexOfMessage:(WLIMMessage *)message;

- (WLIMMessage *)messageAtIndex:(NSUInteger)index;

- (void)appendLastMessage:(WLIMMessage *)message;

- (void)appendMessages:(NSArray<WLIMMessage *> *)messages;

- (NSArray<WLMessageGroup *> *)allMessageGroups;

@end
