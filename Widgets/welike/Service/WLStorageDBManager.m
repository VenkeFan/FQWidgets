//
//  WLStorageDBManager.m
//  welike
//
//  Created by 刘斌 on 2018/4/20.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLStorageDBManager.h"
#import "LuuUtils.h"

#define kStorageDBVersion         1
#define kStorageDBVersionKey      @"StorageDBVersion"

static WLStorageDBManager *_gStorageDBMgr = nil;

@interface WLStorageDBManager ()
{
    dispatch_queue_t _workQueue;
}

@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, copy) NSString *dbFileName;
@property (nonatomic, strong) RDGCDBlockPool *blockPool;

- (void)databaseAllUpgrade:(NSString *)databasePath;
- (void)databaseUpgrade:(FMDatabase *)db newVersion:(NSInteger)newVersion oldVersion:(NSInteger)oldVersion;

@end

@implementation WLStorageDBManager

- (id)init
{
    self = [super init];
    if (self)
    {
        self.blockPool = [[RDGCDBlockPool alloc] initWithQueue:dispatch_queue_create("welike.storage.db.queue", DISPATCH_QUEUE_SERIAL)];
    }
    return self;
}

- (void)dealloc
{
    [self logout];
}

#pragma mark WLStorageDBManager singleton methods
+ (WLStorageDBManager *)getInstance
{
    if (!_gStorageDBMgr)
    {
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            _gStorageDBMgr = [[WLStorageDBManager alloc] init];
        });
    }
    
    return _gStorageDBMgr;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (!_gStorageDBMgr)
        {
            _gStorageDBMgr = [super allocWithZone:zone];
            return _gStorageDBMgr;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _gStorageDBMgr;
}

#pragma mark WLStorageDBManager public methods
- (void)loginWithUid:(NSString *)uid
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:kDatabasePath];
    [LuuUtils createDirectory:databasePath];
    [self databaseAllUpgrade:databasePath];
    NSString *dbName = [NSString stringWithFormat:@"welike_storage_%@.db", uid];
    self.dbFileName = [documentsDirectory stringByAppendingPathComponent:dbName];
    self.db = [[FMDatabase alloc] initWithPath:self.dbFileName];
    [self.db open];
    [self.db setShouldCacheStatements:YES];
}

- (void)logout
{
    [self.blockPool cancelAll];
    self.dbFileName = nil;
    [self.db close];
    self.db = nil;
}

- (void)asyncBlock:(queueBlock)block
{
    [self.blockPool asyncBlock:block];
}

- (void)syncBlock:(queueBlock)block
{
    [self.blockPool syncBlock:block];
}

#pragma mark WLStorageDBManager private methods
- (void)databaseAllUpgrade:(NSString *)databasePath
{
    NSInteger oldVersion = 1;
    id old = [[NSUserDefaults standardUserDefaults] objectForKey:kStorageDBVersionKey];
    if (old != nil)
    {
        oldVersion = [[[NSUserDefaults standardUserDefaults] objectForKey:kStorageDBVersionKey] integerValue];
    }
    if (oldVersion < kStorageDBVersion)
    {
        NSArray *dbList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:databasePath error:nil];
        for (NSString *dbFile in dbList)
        {
            if ([dbFile containsString:@"welike_storage"] == YES)
            {
                NSString *dbName = [databasePath stringByAppendingPathComponent:dbFile];
                FMDatabase *db = [[FMDatabase alloc] initWithPath:dbName];
                [db open];
                [db setShouldCacheStatements:YES];
                [self databaseUpgrade:db newVersion:kStorageDBVersion oldVersion:oldVersion];
                [db close];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:kStorageDBVersion] forKey:kStorageDBVersionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)databaseUpgrade:(FMDatabase *)db newVersion:(NSInteger)newVersion oldVersion:(NSInteger)oldVersion
{
    // TODO
}

@end
