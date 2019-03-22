//
//  WLIMSession.m
//  welike
//
//  Created by luxing on 2018/5/8.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLIMSession.h"
#import "WLAccountManager.h"
#import "FMDB.h"
#import "WLIMDBDefines.h"

@implementation WLIMSession

- (WLIMSession *)copy
{
    WLIMSession *session = [[WLIMSession alloc] init];
    session.sessionId = self.sessionId;
    session.nickName = self.nickName;
    session.head = self.head;
    session.msgType = self.msgType;
    session.sessionType = self.sessionType;
    session.time = self.time;
    session.enableChat = self.enableChat;
    session.visableChat = self.visableChat;
    session.content = self.content;
    session.unreadCount = self.unreadCount;
    session.greet = self.greet;
    return session;
}

- (NSString *)remoteUid
{
    NSArray *uids = [self.sessionId componentsSeparatedByString:@"AAA"];
    if ([uids count] == 2)
    {
        WLAccount *account = [[AppContext getInstance].accountManager myAccount];
        if ([account.uid isEqualToString:uids[0]] == YES)
        {
            return uids[1];
        }
        else
        {
            return uids[0];
        }
    }
    return nil;
}

+ (NSString *)buildSessionIdWithUid1:(NSString *)uid1 uid2:(NSString *)uid2
{
    NSInteger uid1Int = [uid1 integerValue];
    NSInteger uid2Int = [uid2 integerValue];
    if (uid1Int < uid2Int)
    {
        return [NSString stringWithFormat:@"%@AAA%@", uid1, uid2];
    }
    else
    {
        return [NSString stringWithFormat:@"%@AAA%@", uid2, uid1];
    }
}

#pragma mark - WLIMDBModeling
+ (WLIMSession *)decodeFromDBSet:(FMResultSet *)resultSet
{
    WLIMSession *session = [[WLIMSession alloc] init];
    session.sessionId = [resultSet stringForColumn:IM_SESSION_COL_SID];
    session.nickName = [resultSet stringForColumn:IM_SESSION_COL_SESSION_NAME];
    session.head = [resultSet stringForColumn:IM_SESSION_COL_SESSION_HEAD];
    session.msgType = [resultSet intForColumn:IM_SESSION_COL_MSG_TYPE];
    session.sessionType = [resultSet intForColumn:IM_SESSION_COL_TYPE];
    session.time = [resultSet longLongIntForColumn:IM_SESSION_COL_TIME];
    session.enableChat = [resultSet boolForColumn:IM_SESSION_COL_ENABLE_CHAT];
    session.visableChat = [resultSet boolForColumn:IM_SESSION_COL_VISABLE_CHAT];
    session.content = [resultSet stringForColumn:IM_SESSION_COL_CONTENT];
    session.unreadCount = [resultSet intForColumn:IM_SESSION_COL_UNREAD_COUNT];
    session.greet = [resultSet boolForColumn:IM_SESSION_COL_GREET];
    return session;
}

- (NSMutableDictionary *)encodeToDBModel
{
    NSMutableDictionary *model = [NSMutableDictionary dictionaryWithCapacity:11];
    [model setObject:self.sessionId forKey:IM_SESSION_COL_SID];
    if ([self.nickName length] > 0)
    {
        [model setObject:self.nickName forKey:IM_SESSION_COL_SESSION_NAME];
    }
    else
    {
        [model setObject:@"" forKey:IM_SESSION_COL_SESSION_NAME];
    }
    if ([self.head length] > 0)
    {
        [model setObject:self.head forKey:IM_SESSION_COL_SESSION_HEAD];
    }
    [model setObject:[NSNumber numberWithInteger:self.msgType] forKey:IM_SESSION_COL_MSG_TYPE];
    [model setObject:[NSNumber numberWithInteger:self.sessionType] forKey:IM_SESSION_COL_TYPE];
    [model setObject:[NSNumber numberWithLongLong:self.time] forKey:IM_SESSION_COL_TIME];
    [model setObject:[NSNumber numberWithBool:self.enableChat] forKey:IM_SESSION_COL_ENABLE_CHAT];
    [model setObject:[NSNumber numberWithBool:self.visableChat] forKey:IM_SESSION_COL_VISABLE_CHAT];
    if ([self.content length] > 0)
    {
        [model setObject:self.content forKey:IM_SESSION_COL_CONTENT];
    }
    [model setObject:[NSNumber numberWithInteger:self.unreadCount] forKey:IM_SESSION_COL_UNREAD_COUNT];
    [model setObject:[NSNumber numberWithBool:self.greet] forKey:IM_SESSION_COL_GREET];
    return model;
}

@end
