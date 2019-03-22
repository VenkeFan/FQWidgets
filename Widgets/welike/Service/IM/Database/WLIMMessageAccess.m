//
//  WLIMMessageAccess.m
//  welike
//
//  Created by luxing on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLIMMessageAccess.h"
#import "WLAccountManager.h"
#import "NSDictionary+JSON.h"
#import "LuuLogger.h"
#import "WLIMDBDefines.h"
#import "WLIMCommon.h"

@interface WLIMMessageAccess ()

- (BOOL)insertMessageDBModel:(NSDictionary *)model db:(FMDatabase *)db;
- (BOOL)insertOrUpdateMessageDBModel:(NSDictionary *)model db:(FMDatabase *)db;
- (BOOL)insertOrUpdateSessionDBModel:(NSDictionary *)model db:(FMDatabase *)db;
- (NSString *)messageTableNameWithSessionId:(NSString *)sid sessionType:(WLIMSessionType)type;
+ (void)removeMessage:(NSString *)mid inList:(NSArray<WLIMMessage*> *)messages;
+ (WLIMSession *)findSession:(NSString *)sid inList:(NSArray<WLIMSession*> *)sessions;

@end

@implementation WLIMMessageAccess

- (void)insertReceivedMessages:(NSArray<WLIMMessage*> *)messages last:(BOOL)last db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheReceivedMessagesInserted)completed
{
    [blockPool asyncBlock:^{
        [db beginTransaction];
        
        NSMutableDictionary<NSString*, WLIMMessage*> *sessionsMap = [NSMutableDictionary dictionary];
        NSMutableDictionary<NSString*, NSNumber*> *sessionsUnreadCount = [NSMutableDictionary dictionary];
        NSMutableSet<NSString*> *sids = [NSMutableSet set];
        NSMutableArray<WLIMMessage*> *filterMessages = [NSMutableArray arrayWithArray:messages];
        for (NSInteger i = 0; i < messages.count; i++)
        {
            WLIMMessage *message = [messages objectAtIndex:i];
            if (message.sessionType == WLIMSessionTypeP2P)
            {
                NSDictionary *dbModel = [message encodeToDBModel];
                BOOL res = [self insertMessageDBModel:dbModel db:db];
                if (res == YES)
                {
                    if (message.type == WLIMMessageTypeSystem) continue;
                    
                    [sids addObject:message.sessionId];
                    WLIMMessage *preMsg = [sessionsMap objectForKey:message.sessionId];
                    if (preMsg != nil)
                    {
                        if (preMsg.time < message.time)
                        {
                            [sessionsMap setObject:message forKey:message.sessionId];
                        }
                    }
                    else
                    {
                        [sessionsMap setObject:message forKey:message.sessionId];
                    }
                    
                    NSNumber *unreadCountObj = [sessionsUnreadCount objectForKey:message.sessionId];
                    NSInteger unreadCount = 0;
                    if (unreadCountObj != nil)
                    {
                        unreadCount = [unreadCountObj integerValue];
                        unreadCount += 1;
                    }
                    else
                    {
                        unreadCount = 1;
                    }
                    [sessionsUnreadCount setObject:[NSNumber numberWithInteger:unreadCount] forKey:message.sessionId];
                }
                else
                {
                    [WLIMMessageAccess removeMessage:message.messageId inList:filterMessages];
                }
            }
            else
            {
                [WLIMMessageAccess removeMessage:message.messageId inList:filterMessages];
            }
        }
        
        NSMutableArray<WLIMSession*> *existedSessionList = [NSMutableArray array];
        NSString *sidsDelimitedString = [[sids allObjects] componentsJoinedByString:@"','"];
        NSString *sidsQuerySql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ IN ('%@')", WLSessionTableName, IM_SESSION_COL_SID, sidsDelimitedString];
        FMResultSet *rs = [db executeQuery:sidsQuerySql];
        while ([rs next])
        {
            WLIMSession *session = [WLIMSession decodeFromDBSet:rs];
            [existedSessionList addObject:session];
        }
        [rs close];
        NSArray *skeys = [sessionsMap allKeys];
        if ([skeys count] > 0)
        {
            for (NSInteger i = 0; i < [skeys count]; i++)
            {
                NSString *sid = [skeys objectAtIndex:i];
                WLIMMessage *message = [sessionsMap objectForKey:sid];
                WLIMSession *session = [WLIMMessageAccess findSession:sid inList:existedSessionList];
                if (session == nil)
                {
                    session = [[WLIMSession alloc] init];
                    session.sessionId = sid;
                }
                session.enableChat = message.sessionEnableChat;
                session.visableChat = message.sessionVisableChat;
                session.greet = message.isGreet;
                session.nickName = message.sessionName;
                session.head = message.sessionHead;
                if (message.sessionType == WLIMSessionTypeP2P)
                {
                    session.sessionType = WLIMSessionTypeP2P;
                }
                long long pretime = session.time;
                if (pretime < message.time)
                {
                    session.msgType = message.type;
                    session.time = message.time;
                    if (message.type == WLIMMessageTypeTxt)
                    {
                        session.content = ((WLIMTextMessage *)message).text;
                    }
                    else
                    {
                        session.content = @"";
                    }
                }
                NSNumber *nCountObj = [sessionsUnreadCount objectForKey:sid];
                NSInteger newUnreadCount = 0;
                if (nCountObj != nil)
                {
                    newUnreadCount = [nCountObj integerValue];
                }
                session.unreadCount += newUnreadCount;
                [self insertOrUpdateSessionDBModel:[session encodeToDBModel] db:db];
            }
        }
        [db commit];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed)
            {
                completed(filterMessages, sids, last);
            }
        });
    }];
}

- (void)sendMessage:(WLIMMessage *)message session:(WLIMSession *)session db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheSendMessageInserted)completed
{
    [blockPool asyncBlock:^{
        [db beginTransaction];
        
        WLIMSession *tmpSession = [session copy];
        [self insertMessageDBModel:[message encodeToDBModel] db:db];
        if (tmpSession.time < message.time)
        {
            tmpSession.msgType = message.type;
            if (message.type == WLIMMessageTypeTxt)
            {
                tmpSession.content = ((WLIMTextMessage *)message).text;
            }
            else
            {
                tmpSession.content = @"";
            }
            tmpSession.time = message.time;
            [self insertOrUpdateSessionDBModel:[tmpSession encodeToDBModel] db:db];
        }
        [db commit];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed)
            {
                completed(message, session.sessionId);
            }
        });
    }];
}

- (void)refreshSendMessageResult:(NSString *)mid sessionId:(NSString *)sid sessionType:(WLIMSessionType)sessionType messageTime:(long long)messageTime isGreet:(BOOL)isGreet status:(WLIMMessageStatus)status urls:(NSDictionary *)urls db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool
{
    [blockPool asyncBlock:^{
        [db beginTransaction];
        
        NSString *tableName = [self messageTableNameWithSessionId:sid sessionType:sessionType];
        NSString *oldMsgQuerySql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?", tableName, IM_MESSAGE_COL_MID];
        FMResultSet *rs = [db executeQuery:oldMsgQuerySql, mid];
        if ([rs next])
        {
            WLIMMessage *message = (WLIMMessage *)[WLIMMessage decodeFromDBSet:rs];
            if (message != nil)
            {
                message.status = status;
                message.time = messageTime;
                if ([message isKindOfClass:[WLIMPicMessage class]])
                {
                    WLIMPicMessage *picMessage = (WLIMPicMessage *)message;
                    picMessage.picUri = [urls stringForKey:IM_MESSAGE_COL_PIC];
                }
                [self insertOrUpdateMessageDBModel:[message encodeToDBModel] db:db];
            }
        }
        [rs close];
        
        NSString *sessionQuerySql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?", WLSessionTableName, IM_MESSAGE_COL_SID];
        FMResultSet *rs2 = [db executeQuery:sessionQuerySql, sid];
        BOOL needUpdateSessionGreet = NO;
        if ([rs2 next])
        {
            needUpdateSessionGreet = YES;
        }
        [rs2 close];
        if (needUpdateSessionGreet == YES)
        {
            NSString *updateGreetSql = [NSString stringWithFormat:@"UPDATE %@ SET %@ = ? WHERE %@ = ?", WLSessionTableName, IM_SESSION_COL_GREET, IM_SESSION_COL_SID];
            [db executeUpdate:updateGreetSql, [NSNumber numberWithBool:isGreet], sid];
        }
        
        [db commit];
    }];
}

- (void)listNewMessagesInSession:(NSString *)sid sessionType:(WLIMSessionType)sessionType countOfOnePage:(NSInteger)countOfOnePage db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheMessagesInSession)completed
{
    [blockPool asyncBlock:^{
        NSMutableArray<WLIMMessage*> *messages = [NSMutableArray arrayWithCapacity:countOfOnePage];
        
        NSString *tableName = [self messageTableNameWithSessionId:sid sessionType:sessionType];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ? ORDER BY %@ DESC LIMIT %ld", tableName, IM_MESSAGE_COL_SID, IM_MESSAGE_COL_TIME, (long)countOfOnePage];
        FMResultSet *rs = [db executeQuery:sql, sid];
        while ([rs next])
        {
            WLIMMessage *message = (WLIMMessage *)[WLIMMessage decodeFromDBSet:rs];
            [messages addObject:message];
        }
        [rs close];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed)
            {
                completed(messages);
            }
        });
    }];
}

- (void)listHisMessagesInSession:(NSString *)sid sessionType:(WLIMSessionType)sessionType cursorMid:(NSString *)cursorMid countOfOnePage:(NSInteger)countOfOnePage db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheMessagesInSession)completed
{
    [blockPool asyncBlock:^{
        NSMutableArray<WLIMMessage*> *messages = [NSMutableArray arrayWithCapacity:countOfOnePage];
        
        NSString *tableName = [self messageTableNameWithSessionId:sid sessionType:sessionType];
        
        NSString *cursorSql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?", tableName, IM_MESSAGE_COL_MID];
        WLIMMessage *cursorMessage = nil;
        FMResultSet *rs1 = [db executeQuery:cursorSql, cursorMid];
        if ([rs1 next])
        {
            cursorMessage = (WLIMMessage *)[WLIMMessage decodeFromDBSet:rs1];
        }
        [rs1 close];
        
        if (cursorMessage != nil)
        {
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ <= ? AND %@ = ? ORDER BY %@ DESC LIMIT %ld", tableName, IM_MESSAGE_COL_TIME, IM_MESSAGE_COL_SID, IM_MESSAGE_COL_TIME, (long)(countOfOnePage + 1)];
            FMResultSet *rs2 = [db executeQuery:sql, [NSNumber numberWithLongLong:cursorMessage.time], sid];
            BOOL begin = NO;
            while ([rs2 next])
            {
                WLIMMessage *message = (WLIMMessage *)[WLIMMessage decodeFromDBSet:rs2];
                if (begin == YES)
                {
                    if (message != nil)
                    {
                        [messages addObject:message];
                    }
                }
                else if ([message.messageId isEqualToString:cursorMessage.messageId] == YES)
                {
                    begin = YES;
                }
            }
            [rs2 close];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed)
            {
                completed(messages);
            }
        });
    }];
}

- (void)deleteSession:(WLIMSession *)session db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool
{
    [blockPool asyncBlock:^{
        [db beginTransaction];
        
        NSString *deleteSessionSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?", WLSessionTableName, IM_SESSION_COL_SID];
        [db executeUpdate:deleteSessionSql, session.sessionId];
        
        if (session.sessionType == WLIMSessionTypeP2P)
        {
            NSString *tableName = [self messageTableNameWithSessionId:session.sessionId sessionType:session.sessionType];
            NSString *deleteMessagesSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?", tableName, IM_MESSAGE_COL_SID];
            [db executeUpdate:deleteMessagesSql, session.sessionId];
        }
        
        [db commit];
    }];
}

- (void)clearSessionUnreadCount:(NSString *)sid db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheClearSessionUnreadCount)completed
{
    [blockPool asyncBlock:^{
        [db beginTransaction];
        
        NSInteger unreadCount = 0;
        NSString *sql1 = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?", WLSessionTableName, IM_SESSION_COL_SID];
        FMResultSet *rs = [db executeQuery:sql1, sid];
        if ([rs next])
        {
            WLIMSession *session = [WLIMSession decodeFromDBSet:rs];
            unreadCount = -session.unreadCount;
        }
        [rs close];
        
        NSString *sql2 = [NSString stringWithFormat:@"UPDATE %@ SET %@ = ? WHERE %@ = ?", WLSessionTableName, IM_SESSION_COL_UNREAD_COUNT, IM_SESSION_COL_SID];
        [db executeUpdate:sql2, [NSNumber numberWithInteger:0], sid];
        
        [db commit];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed)
            {
                completed(unreadCount);
            }
        });
    }];
}

- (void)getSingleChatSessionWithUid:(NSString *)uid db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheGetSingleSession)completed
{
    [blockPool asyncBlock:^{
        WLIMSession *session = nil;
        
        WLAccount *account = [[AppContext getInstance].accountManager myAccount];
        NSString *sid = [WLIMSession buildSessionIdWithUid1:account.uid uid2:uid];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?", WLSessionTableName, IM_SESSION_COL_SID];
        FMResultSet *rs = [db executeQuery:sql, sid];
        if ([rs next])
        {
            session = [WLIMSession decodeFromDBSet:rs];
        }
        [rs close];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed)
            {
                completed(session);
            }
        });
    }];
}

- (void)listAllSessionsByGreet:(BOOL)greet db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheListSessions)completed
{
    [blockPool asyncBlock:^{
        NSMutableArray <WLIMSession*> *sessions = [NSMutableArray array];
        WLIMSession *stranger = nil;
        if (greet == NO)
        {
            WLIMSession *ss = nil;
            NSString *strangerHasSql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ? ORDER BY %@ DESC LIMIT %d", WLSessionTableName, IM_SESSION_COL_GREET, IM_SESSION_COL_TIME, 1];
            FMResultSet *rs1 = [db executeQuery:strangerHasSql, [NSNumber numberWithBool:YES]];
            if ([rs1 next])
            {
                ss = [WLIMSession decodeFromDBSet:rs1];
            }
            [rs1 close];
            
            if (ss != nil)
            {
                NSString *strangerUnreadCountSql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@ = ? AND %@ > ?", WLSessionTableName, IM_SESSION_COL_GREET, IM_SESSION_COL_UNREAD_COUNT];
                BOOL hasUnreadInStranger = NO;
                FMResultSet *rs2 = [db executeQuery:strangerUnreadCountSql, [NSNumber numberWithBool:YES], [NSNumber numberWithInteger:0]];
                if ([rs2 next])
                {
                    NSInteger count = [rs2 intForColumnIndex:0];
                    if (count > 0)
                    {
                        hasUnreadInStranger = YES;
                    }
                }
                [rs2 close];
                
                stranger = [[WLIMSession alloc] init];
                stranger.sessionId = STRANGER_SESSION_SID;
                stranger.sessionType = WLIMSessionTypeStranger;
                stranger.time = ss.time;
                if (hasUnreadInStranger == YES)
                {
                    stranger.unreadCount = 1;
                }
                else
                {
                    stranger.unreadCount = 0;
                }
            }
        }
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ? ORDER BY %@ DESC", WLSessionTableName, IM_SESSION_COL_GREET, IM_SESSION_COL_TIME];
        FMResultSet *rs2 = [db executeQuery:sql, [NSNumber numberWithBool:greet]];
        while ([rs2 next])
        {
            WLIMSession *session = [WLIMSession decodeFromDBSet:rs2];
            if (stranger != nil)
            {
                if (session.time < stranger.time)
                {
                    [sessions addObject:stranger];
                    stranger = nil;
                }
            }
            [sessions addObject:session];
        }
        [rs2 close];
        if (stranger != nil)
        {
            [sessions addObject:stranger];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed)
            {
                completed(sessions);
            }
        });
    }];
}

- (void)countAllSessionsByGreet:(BOOL)greet db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheSessionsCount)completed
{
    [blockPool asyncBlock:^{
        NSInteger count = 0;
        NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@ = ?", WLSessionTableName, IM_SESSION_COL_GREET];
        FMResultSet *rs = [db executeQuery:sql, [NSNumber numberWithBool:greet]];
        if ([rs next])
        {
            count = [rs intForColumnIndex:0];
        }
        [rs close];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed)
            {
                completed(count);
            }
        });
    }];
}

- (void)hasUnreadMessagesByDb:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheHasUnread)completed
{
    [blockPool asyncBlock:^{
        BOOL has = NO;
        NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@ > ?", WLSessionTableName, IM_SESSION_COL_UNREAD_COUNT];
        FMResultSet *rs = [db executeQuery:sql, [NSNumber numberWithInteger:0]];
        if ([rs next])
        {
            NSInteger count = [rs intForColumnIndex:0];
            if (count > 0)
            {
                has = YES;
            }
        }
        [rs close];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed)
            {
                completed(has);
            }
        });
    }];
}

- (void)getSessions:(NSSet<NSString*> *)sids db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheListSessions)completed
{
    [blockPool asyncBlock:^{
        NSMutableArray <WLIMSession*> *sessions = [NSMutableArray array];
        
        NSString *sidsDelimitedString = [[sids allObjects] componentsJoinedByString:@"','"];
        NSString *sidsQuerySql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ IN ('%@')", WLSessionTableName, IM_SESSION_COL_SID, sidsDelimitedString];
        FMResultSet *rs = [db executeQuery:sidsQuerySql];
        while ([rs next])
        {
            WLIMSession *session = [WLIMSession decodeFromDBSet:rs];
            [sessions addObject:session];
        }
        [rs close];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed)
            {
                completed(sessions);
            }
        });
    }];
}

- (void)refreshUser:(WLUser *)user db:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool completed:(imCacheRefreshUser)completed
{
    [blockPool asyncBlock:^{
        [db beginTransaction];
        NSMutableArray<WLIMMessage*> *messages = [NSMutableArray arrayWithCapacity:50];
        NSString *tableName = [self messageTableNameWithSessionId:nil sessionType:WLIMSessionTypeUnknown];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?", tableName, IM_MESSAGE_COL_SENDER_UID];
        FMResultSet *rs = [db executeQuery:sql, user.uid];
        while ([rs next])
        {
            BOOL update = NO;
            WLIMMessage *message = (WLIMMessage *)[WLIMMessage decodeFromDBSet:rs];
            if (![message.senderNickName isEqualToString:user.nickName]) {
                message.senderNickName = user.nickName;
                update = YES;
            }
            if (![message.senderHead isEqualToString:user.headUrl]) {
                message.senderHead = user.headUrl;
                update = YES;
            }
            if (update) {
                [messages addObject:message];
            }
        }
        [rs close];
        for (NSInteger i = 0;i < messages.count;i++) {
            WLIMMessage *message =  messages[i];
            [self insertOrUpdateMessageDBModel:[message encodeToDBModel] db:db];
        }
        [db commit];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed)
            {
                completed(user);
            }
        });
    }];
}

#pragma mark - private
- (BOOL)insertMessageDBModel:(NSDictionary *)model db:(FMDatabase *)db
{
    NSArray *keys = [model allKeys];
    NSMutableArray *keyValues = [NSMutableArray arrayWithCapacity:18];
    for (NSInteger i = 0; i < keys.count; i++)
    {
        [keyValues addObject:[NSString stringWithFormat:@":%@",keys[i]]];
    }
    NSString *keyStr = [keys componentsJoinedByString:@","];
    NSString *keyValueStr = [keyValues componentsJoinedByString:@","];
    if (keyStr != nil)
    {
        NSString *sid = [model stringForKey:IM_MESSAGE_COL_SID];
        NSInteger type = [model integerForKey:IM_MESSAGE_COL_SESSION_TYPE def:WLIMSessionTypeUnknown];
        NSString *tableName = [self messageTableNameWithSessionId:sid sessionType:type];
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES(%@)", tableName, keyStr, keyValueStr];
        return [db executeUpdate:sql withParameterDictionary:model];
    }
    return NO;
}

- (BOOL)insertOrUpdateMessageDBModel:(NSDictionary *)model db:(FMDatabase *)db
{
    NSArray *keys = [model allKeys];
    NSMutableArray *keyValues = [NSMutableArray arrayWithCapacity:18];
    for (NSInteger i = 0; i < keys.count; i++)
    {
        [keyValues addObject:[NSString stringWithFormat:@":%@",keys[i]]];
    }
    NSString *keyStr = [keys componentsJoinedByString:@","];
    NSString *keyValueStr = [keyValues componentsJoinedByString:@","];
    if (keyStr != nil)
    {
        NSString *sid = [model stringForKey:IM_MESSAGE_COL_SID];
        NSInteger type = [model integerForKey:IM_MESSAGE_COL_SESSION_TYPE def:WLIMSessionTypeUnknown];
        NSString *tableName = [self messageTableNameWithSessionId:sid sessionType:type];
        NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@) VALUES(%@)", tableName, keyStr, keyValueStr];
        return [db executeUpdate:sql withParameterDictionary:model];
    }
    return NO;
}

- (BOOL)insertOrUpdateSessionDBModel:(NSDictionary *)model db:(FMDatabase *)db
{
    NSArray *keys = [model allKeys];
    NSMutableArray *keyValues = [NSMutableArray arrayWithCapacity:18];
    for (NSInteger i = 0; i < keys.count; i++)
    {
        [keyValues addObject:[NSString stringWithFormat:@":%@",keys[i]]];
    }
    NSString *keyStr = [keys componentsJoinedByString:@","];
    NSString *keyValueStr = [keyValues componentsJoinedByString:@","];
    if (keyStr != nil)
    {
        NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@) VALUES(%@)", WLSessionTableName, keyStr, keyValueStr];
        return [db executeUpdate:sql withParameterDictionary:model];
    }
    return NO;
}

- (NSString *)messageTableNameWithSessionId:(NSString *)sid sessionType:(WLIMSessionType)type
{
    return WLPrivateMessageTableName;
}

+ (void)removeMessage:(NSString *)mid inList:(NSMutableArray<WLIMMessage*> *)messages
{
    NSInteger idx = -1;
    for (WLIMMessage *message in messages)
    {
        idx++;
        if ([message.messageId isEqualToString:mid] == YES) break;
    }
    if (idx != -1)
    {
        [messages removeObjectAtIndex:idx];
    }
}

+ (WLIMSession *)findSession:(NSString *)sid inList:(NSArray<WLIMSession*> *)sessions
{
    if ([sessions count] > 0)
    {
        for (WLIMSession *session in sessions)
        {
            if ([session.sessionId isEqualToString:sid] == YES)
            {
                return session;
            }
        }
    }
    return nil;
}

@end
