//
//  WLIMSession.h
//  welike
//
//  Created by luxing on 2018/5/8.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLIMMessage.h"
#import "WLIMDBModeling.h"
#import "WLIMDBDefines.h"

@interface WLIMSession : NSObject <WLIMDBModeling>

@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *head;
@property (nonatomic, assign) WLIMMessageType msgType;
@property (nonatomic, assign) WLIMSessionType sessionType;
@property (nonatomic, assign) long long time;
@property (nonatomic, assign) BOOL enableChat;
@property (nonatomic, assign) BOOL visableChat;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) NSInteger unreadCount;
@property (nonatomic, assign) BOOL greet;

- (WLIMSession *)copy;
- (NSString *)remoteUid;
+ (NSString *)buildSessionIdWithUid1:(NSString *)uid1 uid2:(NSString *)uid2;

@end
