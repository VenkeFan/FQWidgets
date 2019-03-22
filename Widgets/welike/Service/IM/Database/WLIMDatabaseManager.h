//
//  WLIMDatabaseManager.h
//  welike
//
//  Created by luxing on 2018/5/9.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLIMDBDefines.h"
#import "WLIMMessageAccess.h"

@class WLIMMessage;
@class WLIMSession;

typedef void(^imDBReceivedMessagesInserted) (NSArray<WLIMMessage*> *messages, NSSet<NSString *> *sids, BOOL last);
typedef void(^imDBSendMessageInserted) (WLIMMessage *message, NSString *sid);
typedef void(^imDBMessagesInSession) (NSArray<WLIMMessage*> *messages);
typedef void(^imDBClearSessionUnreadCount) (NSInteger count);
typedef void(^imDBGetSingleSession) (WLIMSession *session);
typedef void(^imDBListSessions) (NSArray<WLIMSession*> *sessions);
typedef void(^imDBSessionsCount) (NSInteger count);
typedef void(^imDBHasUnread) (BOOL has);

@interface WLIMDatabaseManager : NSObject

- (void)openDatabase:(NSString *)path;
- (void)closeDatabase;

- (void)insertReceivedMessages:(NSArray<WLIMMessage*> *)messages last:(BOOL)last completed:(imDBReceivedMessagesInserted)completed;
- (void)sendMessage:(WLIMMessage *)message session:(WLIMSession *)session completed:(imDBSendMessageInserted)completed;
- (void)refreshSendMessageResult:(NSString *)mid sessionId:(NSString *)sid sessionType:(WLIMSessionType)sessionType messageTime:(long long)messageTime isGreet:(BOOL)isGreet status:(WLIMMessageStatus)status urls:(NSDictionary *)urls;
- (void)listNewMessagesInSession:(NSString *)sid sessionType:(WLIMSessionType)sessionType countOfOnePage:(NSInteger)countOfOnePage completed:(imDBMessagesInSession)completed;
- (void)listHisMessagesInSession:(NSString *)sid sessionType:(WLIMSessionType)sessionType cursorMid:(NSString *)cursorMid countOfOnePage:(NSInteger)countOfOnePage completed:(imDBMessagesInSession)completed;
- (void)deleteSession:(WLIMSession *)session;
- (void)clearSessionUnreadCount:(NSString *)sid completed:(imDBClearSessionUnreadCount)completed;
- (void)getSingleChatSessionWithUid:(NSString *)uid completed:(imDBGetSingleSession)completed;
- (void)listAllSessionsByGreet:(BOOL)greet completed:(imDBListSessions)completed;
- (void)countAllSessionsByGreet:(BOOL)greet completed:(imDBSessionsCount)completed;
- (void)hasUnreadMessagesAndCompleted:(imDBHasUnread)completed;
- (void)getSessions:(NSSet<NSString*> *)sids completed:(imDBListSessions)completed;
- (void)refreshUser:(WLUser *)user completed:(imCacheRefreshUser)completed;

@end
