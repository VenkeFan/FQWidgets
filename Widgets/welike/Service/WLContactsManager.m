//
//  WLContactsManager.m
//  welike
//
//  Created by 刘斌 on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLContactsManager.h"
#import "WLContactsListRequest.h"
#import "WLAccountManager.h"
#import "WLCommonDBManager.h"
#import "WLSearchUserRequest.h"

#define CONTACT_COL_UID                                 @"uid"
#define CONTACT_COL_NICKNAME                            @"nickname"
#define CONTACT_COL_GENDER                              @"gender"
#define CONTACT_COL_CREATE                              @"created"
#define CONTACT_COL_HEAD                                @"head"
#define CONTACT_COL_AT_TIME                             @"at_time"
#define CONTACT_COL_VIP                                 @"vip"

#define CREATE_CONTACTS_TABLE_SQL @"CREATE TABLE IF NOT EXISTS contacts (%@ TEXT, %@ TEXT, %@ INTEGER, %@ INTEGER, %@ TEXT, %@ INTEGER, %@ INTEGER, PRIMARY KEY(%@))"
#define INSERT_CONTACTS_SQL @"INSERT INTO contacts (%@, %@, %@, %@, %@, %@, %@) VALUES (?, ?, ?, ?, ?, ?, ?)"
#define INSERT_OR_REPLACE_CONTACTS_SQL @"INSERT OR REPLACE INTO contacts (%@, %@, %@, %@, %@, %@, %@) VALUES (?, ?, ?, ?, ?, ?, ?)"
//#define UPDATE_CONTACTS_SQL @"UPDATE contacts (%@, %@, %@, %@, %@, %@) VALUES (?, ?, ?, ?, ?, ?) WHERE %@ > 0"

@implementation WLContact

@end

@interface WLContactsOnlineSearcher ()

@property (nonatomic, strong) WLSearchUserRequest *searchUserRequest;
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, assign) NSInteger pageNum;

@end

@implementation WLContactsOnlineSearcher

- (void)searchWithKeyword:(NSString *)keyword completed:(listMoreContactsCompleted)completed
{
    if (self.searchUserRequest != nil)
    {
        [self.searchUserRequest cancel];
        self.searchUserRequest = nil;
    }
    
    self.pageNum = 0;
    self.keyword = keyword;
    if ([self.keyword length] > 0)
    {
        __weak typeof(self) weakSelf = self;
        self.searchUserRequest = [[WLSearchUserRequest alloc] initSearchUserRequest];
        [self.searchUserRequest searchWithKeyword:self.keyword pageNum:self.pageNum successed:^(NSArray *users, BOOL last, NSInteger pageNum) {
            weakSelf.searchUserRequest = nil;
            if ([users count] > 0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completed)
                    {
                         completed(users, last, ERROR_SUCCESS);
                      
                    }
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completed)
                    {
                         completed(nil, last, ERROR_SUCCESS);
                    }
                });
            }
        } error:^(NSInteger errorCode) {
            weakSelf.searchUserRequest = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed)
                {
                     completed(nil, NO, errorCode);
                }
            });
        }];
    }
    else
    {
        if (completed)
        {
             completed(nil, NO, ERROR_SUCCESS);
        }
    }
}

- (void)moreCompleted:(listMoreContactsCompleted)completed
{
    if (self.searchUserRequest != nil) return;
    
    self.pageNum++;
    __weak typeof(self) weakSelf = self;
    self.searchUserRequest = [[WLSearchUserRequest alloc] initSearchUserRequest];
    [self.searchUserRequest searchWithKeyword:self.keyword pageNum:self.pageNum successed:^(NSArray *users, BOOL last, NSInteger pageNum) {
        weakSelf.searchUserRequest = nil;
        if ([users count] > 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed)
                {
                    completed(users, last, ERROR_SUCCESS);
                }
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed)
                {
                    completed(nil, last, ERROR_SUCCESS);
                }
            });
        }
    } error:^(NSInteger errorCode) {
        weakSelf.searchUserRequest = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed)
            {
                completed(nil, NO, errorCode);
            }
        });
    }];
}

@end

@interface WLContactsManager ()

@property (nonatomic, strong) WLContactsOnlineSearcher *searcher;
@property (nonatomic, strong) NSString *cursor;
@property (nonatomic, strong) WLContactsListRequest *contactsListReq;


- (void)updateContactsList:(NSArray *)users;

@end

@implementation WLContactsManager

- (void)prepare
{
    NSString *sql = [NSString stringWithFormat:CREATE_CONTACTS_TABLE_SQL, CONTACT_COL_UID, CONTACT_COL_NICKNAME, CONTACT_COL_GENDER, CONTACT_COL_CREATE, CONTACT_COL_HEAD, CONTACT_COL_AT_TIME, CONTACT_COL_VIP, CONTACT_COL_UID];
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [db executeUpdate:sql];
    
    [[WLCommonDBManager getInstance] syncBlock:^{
        [db beginTransaction];
        [db executeUpdate:@"DELETE FROM contacts WHERE nickname = ' ' OR nickname = '' OR nickname is NULL"];
        [db commit];
    }];
}

//分页下载,每页100条
- (void)refreshAll
{
    [self requestContact:@""];
}


- (void)refreshFromCursor:(NSString *)cursorStr
{
    [self requestContact:cursorStr];
}

-(void)requestContact:(NSString *)cursor
{
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    WLContactsListRequest  *contactsReq = [[WLContactsListRequest alloc] initContactsListRequestWithUid:account.uid];
       __weak typeof(self) weakSelf = self;
    [contactsReq listContactsSuccessedWithPage:cursor success:^(NSArray *users, NSString *nextCursor,BOOL isLast) {
        //NSLog(@"===========================contact:%lu",(unsigned long)users.count);
        [weakSelf updateContactsList:users];
        
        if (!isLast)
        {
            //从第二页请求时,请求前记录
            [[NSUserDefaults standardUserDefaults] setObject:nextCursor forKey:kContactCurrentCursor];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [weakSelf requestContact:nextCursor];
        }
        else
        {
//            NSLog(@"结束");
        }
    } error:^(NSInteger errorCode) {
        
        if (cursor.length == 0 || !cursor)
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:-1] forKey:@"ContactRequestTime"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}



- (void)updateContactsList:(NSArray *)users
{
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] asyncBlock:^{
        [db beginTransaction];
        
        //移除id和name为空的
        [db executeUpdate:@"DELETE FROM contacts WHERE nickname = ' ' OR nickname = '' OR nickname is NULL"];
        
        if ([users count] > 0)
        {
            //在对需要更新的数据进行更新
            for (NSInteger i = 0; i < users.count; i++)
            {
                WLUser *user = [users objectAtIndex:i];
                
                NSString *sql_update = [NSString stringWithFormat:@"UPDATE contacts SET nickname='%@', gender='%ld', head='%@', created='%lld', vip='%ld' where  uid = '%@' AND at_time > 0", user.nickName, (long)user.gender,user.headUrl, user.createdTime, (long)user.vip, user.uid];
                
                if (user.nickName.length > 0 && user.uid.length > 0)
                {
                    [db executeUpdate:sql_update];
                }
            }
            
            //然后对没有的数据插入
            NSString *sql_insert = [NSString stringWithFormat:INSERT_OR_REPLACE_CONTACTS_SQL, CONTACT_COL_UID, CONTACT_COL_NICKNAME, CONTACT_COL_GENDER, CONTACT_COL_CREATE, CONTACT_COL_HEAD, CONTACT_COL_AT_TIME, CONTACT_COL_VIP];
            for (NSInteger i = 0; i < users.count; i++)
            {
                WLUser *user = [users objectAtIndex:i];
                if (user.nickName.length > 0 && user.uid.length > 0)
                {
                    [db executeUpdate:sql_insert, user.uid, user.nickName, [NSNumber numberWithInteger:user.gender], [NSNumber numberWithLongLong:user.createdTime], user.headUrl, [NSNumber numberWithLongLong:0], [NSNumber numberWithInteger:user.vip]];
                }
            }
            
    
        }
        
        [db commit];
    }];
}

- (void)listAllContacts:(listAllContactsCompleted)completed
{
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] asyncBlock:^{
        [db beginTransaction];
        
        NSString *recentSql = [NSString stringWithFormat:@"SELECT * FROM contacts ORDER BY %@ DESC LIMIT %d", CONTACT_COL_AT_TIME, CONTACTS_RECENT_NUM];
        NSMutableArray *recentSection = [NSMutableArray arrayWithCapacity:CONTACTS_RECENT_NUM];
        FMResultSet *recentRs = [db executeQuery:recentSql];
        while ([recentRs next])
        {
            WLContact *contact = [[WLContact alloc] init];
            contact.uid = [recentRs stringForColumn:CONTACT_COL_UID];
            contact.nickName = [recentRs stringForColumn:CONTACT_COL_NICKNAME];
            contact.head = [recentRs stringForColumn:CONTACT_COL_HEAD];
            contact.gender = [recentRs intForColumn:CONTACT_COL_GENDER];
            contact.create = [recentRs longLongIntForColumn:CONTACT_COL_CREATE];
            contact.atTime = [recentRs longLongIntForColumn:CONTACT_COL_AT_TIME];
            contact.vip = [recentRs intForColumn:CONTACT_COL_VIP];
            if (contact.atTime > 0)
            {
                [recentSection addObject:contact];
            }
        }
        [recentRs close];
        
        NSMutableArray *allSection = [NSMutableArray array];
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM contacts"];
        while ([rs next])
        {
            WLContact *contact = [[WLContact alloc] init];
            contact.uid = [rs stringForColumn:CONTACT_COL_UID];
            contact.nickName = [rs stringForColumn:CONTACT_COL_NICKNAME];
            contact.head = [rs stringForColumn:CONTACT_COL_HEAD];
            contact.gender = [rs intForColumn:CONTACT_COL_GENDER];
            contact.create = [rs longLongIntForColumn:CONTACT_COL_CREATE];
            contact.atTime = [rs longLongIntForColumn:CONTACT_COL_AT_TIME];
            contact.vip = [rs intForColumn:CONTACT_COL_VIP];
            [allSection addObject:contact];
        }
        [rs close];
        
        NSMutableArray *contacts = nil;
        if ([recentSection count] > 0)
        {
            contacts = [NSMutableArray array];
            [contacts addObject:recentSection];
        }
        if ([allSection count] > 0)
        {
            if (contacts == nil)
            {
                contacts = [NSMutableArray array];
            }
            [contacts addObject:allSection];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed)
            {
                completed(contacts);
            }
        });
        
        [db commit];
    }];
}

- (void)atContact:(WLContact *)contact //此处是最近@过的,更新其时间
{
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] asyncBlock:^{
        [db beginTransaction];
        
        NSString *query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM contacts WHERE %@ = ?", CONTACT_COL_UID];
        FMResultSet *rs = [db executeQuery:query, contact.uid];
        BOOL has = NO;
        if ([rs next])
        {
            NSInteger count = [rs intForColumnIndex:0];
            if (count > 0)
            {
                
                has = YES;
            }
        }
        [rs close];
        
        long long now = [[NSDate date] timeIntervalSince1970] * 1000;
        if (has == YES)
        {
            NSString *update = [NSString stringWithFormat:@"UPDATE contacts SET %@ = ? WHERE uid = ?", CONTACT_COL_AT_TIME];
            [db executeUpdate:update, [NSNumber numberWithLongLong:now], contact.uid];
        }
        else
        {
            NSString *insert = [NSString stringWithFormat:INSERT_CONTACTS_SQL, CONTACT_COL_UID, CONTACT_COL_NICKNAME, CONTACT_COL_GENDER, CONTACT_COL_CREATE, CONTACT_COL_HEAD, CONTACT_COL_AT_TIME, CONTACT_COL_VIP];
            [db executeUpdate:insert, contact.uid, contact.nickName, [NSNumber numberWithInteger:contact.gender], [NSNumber numberWithLongLong:contact.create], contact.head, [NSNumber numberWithLongLong:now], [NSNumber numberWithInteger:contact.vip]];
        }
        
        [db commit];
    }];
}

- (void)addContact:(WLContact *)contact
{
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] asyncBlock:^{
        [db beginTransaction];
        
        NSString *insert = [NSString stringWithFormat:INSERT_CONTACTS_SQL, CONTACT_COL_UID, CONTACT_COL_NICKNAME, CONTACT_COL_GENDER, CONTACT_COL_CREATE, CONTACT_COL_HEAD, CONTACT_COL_AT_TIME, CONTACT_COL_VIP];
        [db executeUpdate:insert, contact.uid, contact.nickName, [NSNumber numberWithInteger:contact.gender], [NSNumber numberWithLongLong:contact.create], contact.head, [NSNumber numberWithLongLong:0], [NSNumber numberWithInteger:contact.vip]];
        
        [db commit];
    }];
}

- (void)removeContactWithUid:(NSString *)uid
{
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] asyncBlock:^{
        [db beginTransaction];
        
        NSString *delSql = [NSString stringWithFormat:@"DELETE FROM contacts WHERE %@ = ?", CONTACT_COL_UID];
        [db executeUpdate:delSql, uid];
        
        [db commit];
    }];
}

- (WLContactsOnlineSearcher *)provideOnlineSearcher
{
    if (self.searcher == nil)
    {
        self.searcher = [[WLContactsOnlineSearcher alloc] init];
    }
    return self.searcher;
}

- (NSInteger)contactsCount
{
    __block NSInteger count = 0;
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] syncBlock:^{
        FMResultSet *rs = [db executeQuery:@"SELECT COUNT(*) FROM contacts"];
        if ([rs next])
        {
            count = [rs intForColumnIndex:0];
        }
        [rs close];
    }];
    return count;
}

@end
