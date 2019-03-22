//
//  WLIMMessageAccess.h
//  welike
//
//  Created by luxing on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLIMMessage.h"
#import "WLIMSession.h"
#import "FMDB.h"
#import "WLUser.h"
#import "RDGCDBlockPool.h"

typedef void(^imCacheReceivedMessagesInserted) (NSArray<WLIMMessage*> *messages, NSSet<NSString *> *sids, BOOL last);
typedef void(^imCacheSendMessageInserted) (WLIMMessage *message, NSString *sid);
typedef void(^imCacheMessagesInSession) (NSArray<WLIMMessage*> *messages);
typedef void(^imCacheClearSessionUnreadCount) (NSInteger count);
typedef void(^imCacheGetSingleSession) (WLIMSession *session);
typedef void(^imCacheListSessions) (NSArray<WLIMSession*> *sessions);
typedef void(^imCacheSessionsCount) (NSInteger count);
typedef void(^imCacheHasUnread) (BOOL has);
typedef void(^imCacheRefreshUser) (WLUser *user);

@interface WLIMMessageAccess : NSObject

- (void)insertReceivedMessages:(NSArray<WLIMMessage*> *)messages last:(BOOL)last db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheReceivedMessagesInserted)completed;
- (void)sendMessage:(WLIMMessage *)message session:(WLIMSession *)session db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheSendMessageInserted)completed;
- (void)refreshSendMessageResult:(NSString *)mid sessionId:(NSString *)sid sessionType:(WLIMSessionType)sessionType messageTime:(long long)messageTime isGreet:(BOOL)isGreet status:(WLIMMessageStatus)status urls:(NSDictionary *)urls db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool;
- (void)listNewMessagesInSession:(NSString *)sid sessionType:(WLIMSessionType)sessionType countOfOnePage:(NSInteger)countOfOnePage db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheMessagesInSession)completed;
- (void)listHisMessagesInSession:(NSString *)sid sessionType:(WLIMSessionType)sessionType cursorMid:(NSString *)cursorMid countOfOnePage:(NSInteger)countOfOnePage db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheMessagesInSession)completed;
- (void)deleteSession:(WLIMSession *)session db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool;
- (void)clearSessionUnreadCount:(NSString *)sid db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheClearSessionUnreadCount)completed;
- (void)getSingleChatSessionWithUid:(NSString *)uid db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheGetSingleSession)completed;
- (void)listAllSessionsByGreet:(BOOL)greet db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheListSessions)completed;
- (void)countAllSessionsByGreet:(BOOL)greet db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheSessionsCount)completed;
- (void)hasUnreadMessagesByDb:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheHasUnread)completed;
- (void)getSessions:(NSSet<NSString*> *)sids db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheListSessions)completed;
- (void)refreshUser:(WLUser *)user db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheRefreshUser)completed;

@end
