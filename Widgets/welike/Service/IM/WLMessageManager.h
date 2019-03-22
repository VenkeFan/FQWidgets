//
//  WLMessageManager.h
//  IMTest
//
//  Created by luxing on 2018/5/6.
//  Copyright © 2018年 chiemy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLIMCommon.h"

@class WLUser;

typedef void(^imChatRefreshMessages) (NSArray<WLIMMessage*> *messages, NSString *sid);

typedef void(^imSessionGoInSession) (WLIMSession *session);
typedef void(^imSessionListAllSessions) (NSArray<WLIMSession*> *sessions, BOOL greet);

typedef void(^imHasUnread) (BOOL has);

@protocol WLMessageManagerReceivedDelegate <NSObject>//收回调

@optional
- (void)onIMReceivedMessages:(NSArray<WLIMMessage*> *)messages sid:(NSString *)sid;
- (void)onIMSessionsUpdated:(NSArray<WLIMSession*> *)sessions;
- (void)onIMNewMessagesCountChanged;
- (void)onUserChanged:(WLUser *)user;

@end

@protocol WLMessageManagerSendDelegate <NSObject>//发回调

- (void)onIMOneSendResult:(WLIMMessage *)message errCode:(NSInteger)errCode;
- (void)onIAllMSendMessagesError:(NSInteger)errCode;
@optional
- (void)onIMSendProcess:(NSString *)mid process:(CGFloat)process;

@end

@interface WLMessageManager : NSObject

+ (WLMessageManager *)instance;

- (void)registerDelegate:(id<WLMessageManagerReceivedDelegate>)delegate;
- (void)unregister:(id<WLMessageManagerReceivedDelegate>)delegate;

- (void)openWithUid:(NSString *)uid;//自己的uid数据库
- (void)close;//观数据库
- (void)restart; //重新连接
- (void)stop;//停止链接

- (void)hasUnreadMessagesAndCompleted:(imHasUnread)completed;//未读数处理

// session methods
- (void)goInSingleSessionWithUser:(WLUser *)user sendDelegate:(id<WLMessageManagerSendDelegate>)sendDelegate completed:(imSessionGoInSession)completed;
- (void)goInSingleSessionWithSid:(NSString *)sid sendDelegate:(id<WLMessageManagerSendDelegate>)sendDelegate completed:(imSessionGoInSession)completed;
- (void)exitSingleSession:(WLIMSession *)session;
- (void)listAllSessionsWithGreet:(BOOL)greet completed:(imSessionListAllSessions)completed;//返回未关注人还是关注人的信息
- (void)removeSession:(WLIMSession *)session;//删除对话

// chat methods
- (void)refreshMessagesAndCompleted:(imChatRefreshMessages)completed;//进对话时,刷新消息
- (void)hisMessagesAndCompleted:(imChatRefreshMessages)completed;//取历史消息的
- (void)sendMessage:(WLIMMessage *)message;
- (void)cancelAllSendingMessages;
- (void)refreshUser:(WLUser *)user;//用户图像手动刷新

@end
