//
//  WLIMMessage.h
//  IMTest
//
//  Created by luxing on 2018/5/5.
//  Copyright © 2018年 chiemy. All rights reserved.
//  具体显示的的消息数据

#import <Foundation/Foundation.h>
#import "WLIMPacking.h"
#import "WLIMDBModeling.h"
#import "WLIMDBDefines.h"

@class MessageHeader;

@interface WLIMMessage : NSObject <WLIMPacking, WLIMDBModeling>

@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *sessionName;
@property (nonatomic, copy) NSString *sessionHead;
@property (nonatomic, assign) WLIMSessionType sessionType;
@property (nonatomic, assign) BOOL sessionEnableChat;
@property (nonatomic, assign) BOOL sessionVisableChat;
@property (nonatomic, copy) NSString *senderUid;
@property (nonatomic, copy) NSString *senderNickName;
@property (nonatomic, copy) NSString *senderHead;
@property (nonatomic, copy) NSString *remoteUid;
@property (nonatomic, assign) BOOL isGreet;
@property (nonatomic, assign) WLIMMessageStatus status;
@property (nonatomic, assign) long long time;
@property (nonatomic, assign) WLIMMessageType type;
@property (nonatomic, copy) NSString *from;
@property (nonatomic, strong) NSMutableDictionary *userInfo;

- (WLIMMessage *)copy;
- (MessageHeader *)messageHeader;
- (void)parseMessageHeader:(MessageHeader *)messageHeader;

@end
