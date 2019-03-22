//
//  WLIMDBConnection.m
//  welike
//
//  Created by luxing on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLIMDBConnection.h"
#import "WLIMDBDefines.h"

static const uint32_t IMDatabaseVersion        = 0;

#define CREATE_S_MESSAGE_TABLE_SQL @"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT, %@ TEXT, %@ TEXT, %@ TEXT, %@ TEXT, %@ TEXT, %@ TEXT, %@ INTEGER, %@ INTEGER, %@ INTEGER, %@ INTEGER, %@ TEXT, %@ TEXT, %@ TEXT, %@ TEXT, %@ TEXT, %@ TEXT, %@ TEXT, PRIMARY KEY(%@))"
#define CREATE_SESSION_TABLE_SQL @"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT, %@ TEXT, %@ TEXT, %@ INTEGER, %@ INTEGER, %@ INTEGER, %@ INTEGER, %@ INTEGER, %@ INTEGER, %@ INTEGER, %@ TEXT, %@ TEXT, PRIMARY KEY(%@))"

@interface WLIMDBConnection ()

@end

@implementation WLIMDBConnection

#pragma mark - public
- (void)dbUpgradeVersion:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool
{
    __weak typeof(self) weakSelf = self;
    [blockPool syncBlock:^{
        [db beginTransaction];
        
        uint32_t oldVersion = db.userVersion;
        if (IMDatabaseVersion > oldVersion)
        {
            [weakSelf onUpgrade:db fromVersion:oldVersion toVersion:IMDatabaseVersion];
        }
        else
        {
            [weakSelf onCreate:db];
        }
        db.userVersion = IMDatabaseVersion;
        
        [db commit];
    }];
}

#pragma mark - private
+ (void)db:(FMDatabase *)db createSingleMessageTable:(NSString *)tableName
{

}

+ (void)db:(FMDatabase *)db createChatTable:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:CREATE_SESSION_TABLE_SQL,
                    tableName,
                    IM_SESSION_COL_SID,
                    IM_SESSION_COL_SESSION_NAME,
                    IM_SESSION_COL_SESSION_HEAD,
                    IM_SESSION_COL_MSG_TYPE,
                    IM_SESSION_COL_ENABLE_CHAT,
                    IM_SESSION_COL_VISABLE_CHAT,
                    IM_SESSION_COL_GREET,
                    IM_SESSION_COL_TYPE,
                    IM_SESSION_COL_TIME,
                    IM_SESSION_COL_UNREAD_COUNT,
                    IM_SESSION_COL_CONTENT,
                    IM_SESSION_COL_EXTRA,
                    IM_SESSION_COL_SID];
    [db executeUpdate:sql];
}

- (void)onCreate:(FMDatabase *)db
{
    NSString *sql1 = [NSString stringWithFormat:CREATE_S_MESSAGE_TABLE_SQL,
                     WLPrivateMessageTableName,
                     IM_MESSAGE_COL_MID,
                     IM_MESSAGE_COL_SID,
                     IM_MESSAGE_COL_SESSION_NAME,
                     IM_MESSAGE_COL_SESSION_HEAD,
                     IM_MESSAGE_COL_SENDER_UID,
                     IM_MESSAGE_COL_SENDER_NAME,
                     IM_MESSAGE_COL_SENDER_HEAD,
                     IM_MESSAGE_COL_SESSION_TYPE,
                     IM_MESSAGE_COL_STATUS,
                     IM_MESSAGE_COL_TIME,
                     IM_MESSAGE_COL_TYPE,
                     IM_MESSAGE_COL_TEXT,
                     IM_MESSAGE_COL_PIC,
                     IM_MESSAGE_COL_AUDIO,
                     IM_MESSAGE_COL_THUMB,
                     IM_MESSAGE_COL_VIDEO,
                     IM_MESSAGE_COL_FILE_NAME,
                     IM_MESSAGE_COL_EXTRA,
                     IM_MESSAGE_COL_MID];
    [db executeUpdate:sql1];
    
    NSString *sql2 = [NSString stringWithFormat:CREATE_SESSION_TABLE_SQL,
                     WLSessionTableName,
                     IM_SESSION_COL_SID,
                     IM_SESSION_COL_SESSION_NAME,
                     IM_SESSION_COL_SESSION_HEAD,
                     IM_SESSION_COL_MSG_TYPE,
                     IM_SESSION_COL_ENABLE_CHAT,
                     IM_SESSION_COL_VISABLE_CHAT,
                     IM_SESSION_COL_GREET,
                     IM_SESSION_COL_TYPE,
                     IM_SESSION_COL_TIME,
                     IM_SESSION_COL_UNREAD_COUNT,
                     IM_SESSION_COL_CONTENT,
                     IM_SESSION_COL_EXTRA,
                     IM_SESSION_COL_SID];
    [db executeUpdate:sql2];
}

- (void)onUpgrade:(FMDatabase *)db fromVersion:(uint32_t)oldVersion toVersion:(uint32_t)newVersion
{
    for (uint32_t i = (oldVersion + 1); i <= newVersion; i++)
    {
        SEL sel = NSSelectorFromString([@"dbAlterTableVersion" stringByAppendingFormat:@"%d:", i]);
        if ([self respondsToSelector:sel])
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:sel withObject:db];
#pragma clang diagnostic pop
        }
    }
    
    NSMutableArray *tableNames = [NSMutableArray arrayWithCapacity:20];
    FMResultSet *rs = [db executeQuery:@"select name from sqlite_master where type='table' AND name LIKE '_message' escape '/'"];
    while ([rs next])
    {
        NSString *name = [rs stringForColumnIndex:0];
        [tableNames addObject:name];
    }
    [rs close];
    for (NSString *name in tableNames)
    {
        for (uint32_t i = (oldVersion + 1); i <= newVersion; i++)
        {
            SEL sel = NSSelectorFromString([@"db:alterGroupTableVesion" stringByAppendingFormat:@"%d:", i]);
            if ([self respondsToSelector:sel])
            {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self performSelector:sel withObject:db withObject:name];
#pragma clang diagnostic pop
            }
        }
    }
}

- (void)onDowngrade:(FMDatabase *)db fromVersion:(uint32_t)oldVersion toVersion:(uint32_t)newVersion
{
}

#pragma mark - alter table
- (void)dbAlterTableVersion1:(FMDatabase *)db
{
}

#pragma mark - alter group table
- (void)db:(FMDatabase *)db alterGroupTableVesion1:(NSString *)tableName
{
}

@end
