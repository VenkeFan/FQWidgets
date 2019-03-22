//
//  WLMessageBoxManager.h
//  welike
//
//  Created by 刘斌 on 2018/5/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MSG_BOX_TYPE_MENTION                @"MENTION"
#define MSG_BOX_TYPE_COMMENT                @"COMMENT"
#define MSG_BOX_TYPE_LIKE                   @"LIKE"

@protocol WLMessageBoxManagerDelegate <NSObject>

- (void)onRefreshMessageBoxNotifications:(NSArray *)notifications last:(BOOL)last errCode:(NSInteger)errCode;
- (void)onReceiveHisMessageBoxNotifications:(NSArray *)notifications last:(BOOL)last errCode:(NSInteger)errCode;

@end

@interface WLMessageBoxManager : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, weak) id<WLMessageBoxManagerDelegate> delegate;

- (void)tryRefresh;
- (void)tryHis;

@end
