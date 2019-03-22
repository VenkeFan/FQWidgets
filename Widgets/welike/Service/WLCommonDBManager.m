//
//  WLCommonDBManager.m
//  welike
//
//  Created by 刘斌 on 2018/4/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLCommonDBManager.h"
#import "LuuUtils.h"

#define kCommonDBVersion         1
#define kCommonDBVersionKey      @"CommonDBVersion"

static WLCommonDBManager *_gCommonDBMgr = nil;

@interface WLCommonDBManager ()

@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, copy) NSString *dbFileName;
@property (nonatomic, strong) RDGCDBlockPool *blockPool;

- (void)databaseAllUpgrade:(NSString *)databasePath;
- (void)databaseUpgrade:(FMDatabase *)db newVersion:(NSInteger)newVersion oldVersion:(NSInteger)oldVersion;

@end

@implementation WLCommonDBManager

- (id)init
{
    self = [super init];
    if (self)
    {
        self.blockPool = [[RDGCDBlockPool alloc] initWithQueue:dispatch_queue_create("welike.common.db.queue", DISPATCH_QUEUE_SERIAL)];
    }
    return self;
}

- (void)dealloc
{
    [self logout];
}

#pragma mark WLCommonDBManager singleton methods
+ (WLCommonDBManager *)getInstance
{
    if (!_gCommonDBMgr)
    {
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            _gCommonDBMgr = [[WLCommonDBManager alloc] init];
        });
    }
    
    return _gCommonDBMgr;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (!_gCommonDBMgr)
        {
            _gCommonDBMgr = [super allocWithZone:zone];
            return _gCommonDBMgr;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _gCommonDBMgr;
}

#pragma mark WLCommonDBManager public methods
- (void)loginWithUid:(NSString *)uid
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:kDatabasePath];
    [LuuUtils createDirectory:databasePath];
    [self databaseAllUpgrade:databasePath];
    NSString *dbName = [NSString stringWithFormat:@"welike_common_%@.db", uid];
    self.dbFileName = [databasePath stringByAppendingPathComponent:dbName];
    self.db = [[FMDatabase alloc] initWithPath:self.dbFileName];
    [self.db open];
    [self.db setShouldCacheStatements:YES];
}

- (void)logout
{
    [self.blockPool cancelAll];
    self.dbFileName = nil;
    if (self.db != nil)
    {
        [self.db close];
        self.db = nil;
    }
}

- (void)asyncBlock:(queueBlock)block
{
    [self.blockPool asyncBlock:block];
}

- (void)syncBlock:(queueBlock)block
{
    [self.blockPool syncBlock:block];
}

#pragma mark WLCommonDBManager private methods
- (void)databaseAllUpgrade:(NSString *)databasePath
{
    NSInteger oldVersion = 1;
    id old = [[NSUserDefaults standardUserDefaults] objectForKey:kCommonDBVersionKey];
    if (old != nil)
    {
        oldVersion = [[[NSUserDefaults standardUserDefaults] objectForKey:kCommonDBVersionKey] integerValue];
    }
    if (oldVersion < kCommonDBVersion)
    {
        NSArray *dbList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:databasePath error:nil];
        for (NSString *dbFile in dbList)
        {
            if ([dbFile containsString:@"welike_common"] == YES)
            {
                NSString *dbName = [databasePath stringByAppendingPathComponent:dbFile];
                FMDatabase *db = [[FMDatabase alloc] initWithPath:dbName];
                [db open];
                [db setShouldCacheStatements:YES];
                [self databaseUpgrade:db newVersion:kCommonDBVersion oldVersion:oldVersion];
                [db close];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:kCommonDBVersion] forKey:kCommonDBVersionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)databaseUpgrade:(FMDatabase *)db newVersion:(NSInteger)newVersion oldVersion:(NSInteger)oldVersion
{
    // TODO
}

@end
