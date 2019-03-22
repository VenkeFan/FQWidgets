//
//  WLIMDatabaseManager.m
//  welike
//
//  Created by luxing on 2018/5/9.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLIMDatabaseManager.h"
#import "WLIMDBConnection.h"
#import "RDGCDBlockPool.h"

@interface WLIMDatabaseManager ()
{
    dispatch_queue_t _dbWorkQueue;
}

@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) WLIMDBConnection *connection;
@property (nonatomic, strong) WLIMMessageAccess *messageAccess;
@property (nonatomic, strong) RDGCDBlockPool *blockPool;

@end

@implementation WLIMDatabaseManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.blockPool = [[RDGCDBlockPool alloc] initWithQueue:dispatch_queue_create("welike.im.db.queue", DISPATCH_QUEUE_SERIAL)];
        _connection = [[WLIMDBConnection alloc] init];
        _messageAccess = [[WLIMMessageAccess alloc] init];
    }
    return self;
}

- (void)openDatabase:(NSString *)path
{
    if (self.db == nil)
    {
        [self createDatabase:path];
    }
}

- (void)closeDatabase
{
    [self.blockPool cancelAll];
    if (self.db != nil)
    {
        [self.db close];
        self.db = nil;
    }
}

- (void)insertReceivedMessages:(NSArray<WLIMMessage*> *)messages last:(BOOL)last completed:(imDBReceivedMessagesInserted)completed
{
    if (self.db != nil)
    {
        [self.messageAccess insertReceivedMessages:messages last:last db:self.db blockPool:self.blockPool completed:^(NSArray<WLIMMessage *> *messages, NSSet<NSString *> *sids, BOOL last) {
            if (completed)
            {
                completed(messages, sids, last);
            }
        }];
    }
}

- (void)sendMessage:(WLIMMessage *)message session:(WLIMSession *)session completed:(imDBSendMessageInserted)completed
{
    if (self.db != nil)
    {
        [self.messageAccess sendMessage:message session:session db:self.db blockPool:self.blockPool completed:^(WLIMMessage *message, NSString *sid) {
            if (completed)
            {
                completed(message, sid);
            }
        }];
    }
}

- (void)refreshSendMessageResult:(NSString *)mid sessionId:(NSString *)sid sessionType:(WLIMSessionType)sessionType messageTime:(long long)messageTime isGreet:(BOOL)isGreet status:(WLIMMessageStatus)status urls:(NSDictionary *)urls
{
    if (self.db != nil)
    {
        [self.messageAccess refreshSendMessageResult:mid sessionId:sid sessionType:sessionType messageTime:messageTime isGreet:isGreet status:status urls:urls db:self.db blockPool:self.blockPool];
    }
}

- (void)listNewMessagesInSession:(NSString *)sid sessionType:(WLIMSessionType)sessionType countOfOnePage:(NSInteger)countOfOnePage completed:(imDBMessagesInSession)completed
{
    if (self.db != nil)
    {
        [self.messageAccess listNewMessagesInSession:sid sessionType:sessionType countOfOnePage:countOfOnePage db:self.db blockPool:self.blockPool completed:^(NSArray<WLIMMessage *> *messages) {
            if (completed)
            {
                completed(messages);
            }
        }];
    }
}

- (void)listHisMessagesInSession:(NSString *)sid sessionType:(WLIMSessionType)sessionType cursorMid:(NSString *)cursorMid countOfOnePage:(NSInteger)countOfOnePage completed:(imDBMessagesInSession)completed
{
    if (self.db != nil)
    {
        [self.messageAccess listHisMessagesInSession:sid sessionType:sessionType cursorMid:cursorMid countOfOnePage:countOfOnePage db:self.db blockPool:self.blockPool completed:^(NSArray<WLIMMessage *> *messages) {
            if (completed)
            {
                completed(messages);
            }
        }];
    }
}

- (void)deleteSession:(WLIMSession *)session
{
    if (self.db != nil)
    {
        [self.messageAccess deleteSession:session db:self.db blockPool:self.blockPool];
    }
}

- (void)clearSessionUnreadCount:(NSString *)sid completed:(imDBClearSessionUnreadCount)completed
{
    if (self.db != nil)
    {
        [self.messageAccess clearSessionUnreadCount:sid db:self.db blockPool:self.blockPool completed:^(NSInteger count) {
            if (completed)
            {
                completed(count);
            }
        }];
    }
}

- (void)getSingleChatSessionWithUid:(NSString *)uid completed:(imDBGetSingleSession)completed
{
    if (self.db != nil)
    {
        [self.messageAccess getSingleChatSessionWithUid:uid db:self.db blockPool:self.blockPool completed:^(WLIMSession *session) {
            if (completed)
            {
                completed(session);
            }
        }];
    }
}

- (void)listAllSessionsByGreet:(BOOL)greet completed:(imDBListSessions)completed
{
    if (self.db != nil)
    {
        [self.messageAccess listAllSessionsByGreet:greet db:self.db blockPool:self.blockPool completed:^(NSArray<WLIMSession *> *sessions) {
            if (completed)
            {
                completed(sessions);
            }
        }];
    }
}

- (void)countAllSessionsByGreet:(BOOL)greet completed:(imDBSessionsCount)completed
{
    if (self.db != nil)
    {
        [self.messageAccess countAllSessionsByGreet:greet db:self.db blockPool:self.blockPool completed:^(NSInteger count) {
            if (completed)
            {
                completed(count);
            }
        }];
    }
}

- (void)hasUnreadMessagesAndCompleted:(imDBHasUnread)completed
{
    if (self.db != nil)
    {
        [self.messageAccess hasUnreadMessagesByDb:self.db blockPool:self.blockPool completed:^(BOOL has) {
            if (completed)
            {
                completed(has);
            }
        }];
    }
}

- (void)getSessions:(NSSet<NSString*> *)sids completed:(imDBListSessions)completed
{
    if (self.db != nil)
    {
        [self.messageAccess getSessions:sids db:self.db blockPool:self.blockPool completed:^(NSArray<WLIMSession *> *sessions) {
            if (completed)
            {
                completed(sessions);
            }
        }];
    }
}

#pragma mark - private
- (void)createDatabase:(NSString *)path
{
    [self closeDatabase];
    self.db = [[FMDatabase alloc] initWithPath:path];
    [self.db open];
    [self.db setShouldCacheStatements:YES];
    [self.connection dbUpgradeVersion:self.db blockPool:self.blockPool];
}

- (void)refreshUser:(WLUser *)user completed:(imCacheRefreshUser)completed
{
    if (self.db != nil && user.uid.length > 0)
    {
        [self.messageAccess refreshUser:user db:self.db blockPool:self.blockPool completed:completed];
    }
}

@end
