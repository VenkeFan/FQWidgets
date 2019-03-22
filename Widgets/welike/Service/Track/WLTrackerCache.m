//
//  WLTrackerCache.m
//  welike
//
//  Created by 刘斌 on 2018/6/5.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTrackerCache.h"
#import "WLAccountManager.h"
#import "AFNetworkManager.h"
#import "WLStorageDBManager.h"
#import "FMDB.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "RDLocalizationManager.h"
#import "WLRecordLog.h"

#define CREATE_TRACKER_TABLE_SQL @"CREATE TABLE IF NOT EXISTS tracker (trackid INTEGER PRIMARY KEY AUTOINCREMENT, track TEXT)"
#define INSERT_TRACKER_SQL @"INSERT INTO tracker (track) VALUES (?)"

#define kWLTrackerCacheTriggerCount            10

@implementation WLTrackerList

@end

@interface WLTrackerCache ()
{
//    dispatch_queue_t serialQueue;
}

@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@property (nonatomic, copy) NSString *dbFileName;
@property (nonatomic, strong) NSMutableArray<NSDictionary*> *memcache;

- (NSDictionary *)buildPublicDic;
//- (void)writeToDB:(NSArray<NSDictionary*> *)logs;

@end

@implementation WLTrackerCache

- (id)init
{
    self = [super init];
    if (self)
    {
        self.sessionId = [LuuUtils uuid];
        self.memcache = [NSMutableArray arrayWithCapacity:0];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:kDatabasePath];
        [LuuUtils createDirectory:databasePath];
        self.dbFileName = [documentsDirectory stringByAppendingPathComponent:@"welike_tracker.db"];
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.dbFileName];
        
//        serialQueue = dispatch_queue_create("TrackerQueue", DISPATCH_QUEUE_SERIAL);
        
        
        [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            [db beginTransaction];
            
            [db executeUpdate:CREATE_TRACKER_TABLE_SQL];
            
            [db commit];
        }];
    }
    return self;
}

- (void)dealloc
{
    self.dbFileName = nil;
    
    [_dbQueue close];
    _dbQueue = nil;
}

- (void)appendEventId:(NSString *)eventId eventInfo:(NSDictionary *)eventInfo
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:[self buildPublicDic]];
    [d setObject:eventId forKey:@"event_id"];
    [d setObject:eventInfo forKey:@"event_info"];
    
#ifdef __WELIKE_TEST_
//    NSLog(@"*** dotting: %@ ***", d);
   // [WLRecordLog writeNo:@"dot" text:[d objectForKey:@"ctime"]];
    //NSLog(@"dot==========%@",[d objectForKey:@"ctime"]);
#endif
    
    [self.memcache addObject:d];
    if ([_memcache count] > 0)
    {
        [self writeToDB:_memcache finish:^(BOOL result) {
            
            if (result)
            {
                [self->_memcache removeAllObjects];
            }
        }];
    }
}

- (void)synchronize
{
    if ([self.delegate respondsToSelector:@selector(trackerCacheSynchronize)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate trackerCacheSynchronize];
        });
    }
}

- (void)listTrackLogs:(void(^)(WLTrackerList *list))block {
    NSMutableArray<NSDictionary*> *logs = [NSMutableArray array];
    NSMutableArray<NSNumber*> *ids = [NSMutableArray array];
    
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM tracker"];
        
        while ([result next])
        {
            NSNumber *tid = [NSNumber numberWithInteger:[result intForColumn:@"trackid"]];
            NSString *t = [result stringForColumn:@"track"];
            NSData *a = [t dataUsingEncoding:NSUTF8StringEncoding];
            if ([a length] > 0)
            {
                NSDictionary *d = [NSJSONSerialization JSONObjectWithData:a options:NSJSONReadingMutableLeaves error:nil];
                [logs addObject:d];
                [ids addObject:tid];
            }
        }
        
        WLTrackerList *list = [[WLTrackerList alloc] init];
        list.logs = logs;
        list.trackIds = ids;
        
        if (block) {
            block(list);
        }
    }];
}

- (void)remove:(NSArray<NSNumber*> *)ids finish:(void (^)(void))callback
{
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [db beginTransaction];
        for (NSInteger i = 0; i < [ids count]; i++)
        {
            NSNumber *tid = [ids objectAtIndex:i];
            [db executeUpdate:@"DELETE FROM tracker WHERE trackid = ?", tid];
        }
         [db commit];
        
        if(callback)
        {
            callback();
        }
    }];
}

- (void)writeToDB:(NSArray<NSDictionary*> *)logs finish:(void (^)(BOOL result))callback
{
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [db beginTransaction];
        
        for (NSInteger i = 0; i < [logs count]; i++)
        {
            NSDictionary *dic = [logs objectAtIndex:i];
            NSData *a = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            NSString *t = [[NSString alloc] initWithData:a encoding:NSUTF8StringEncoding];
            [db executeUpdate:INSERT_TRACKER_SQL, t];
        }
        
          BOOL result = [db commit];
        if(callback)
        {
            callback(result);
        }
        
    }];
}

- (NSDictionary *)buildPublicDic
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setObject:[LuuUtils deviceId] forKey:@"deviceId"];
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    if (account != nil && [account.uid length] > 0)
    {
        [dic setObject:account.uid forKey:@"uid"];
    }
    [dic setObject:@"ios" forKey:@"os"];
    [dic setObject:[[UIDevice currentDevice] systemVersion] forKey:@"os_ver"];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    [dic setObject:zone.name forKey:@"tz"];
    NSString *sysLang = [LuuUtils preferredLanguage];
    if ([sysLang length] > 0)
    {
        [dic setObject:sysLang forKey:@"locale"];
    }
    
    NSString *language = [[RDLocalizationManager getInstance] getCurrentLanguage];
    if ([language length] > 0)
    {
        [dic setObject:language forKey:@"la"];
    }
    
    NSString *country = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    if ([country length] > 0)
    {
        [dic setObject:country forKey:@"country"];
    }
    long long ctime = [[NSDate date] timeIntervalSince1970] * 1000;
    [dic setObject:[NSString stringWithFormat:@"%lld", ctime] forKey:@"ctime"];
  
    [dic setObject:[[AFNetworkManager getInstance] getNetType] forKey:@"net"];
   
  
    [dic setObject:[NSString stringWithFormat:@"%ld", (long)self.entrance] forKey:@"open_source"];
    [dic setObject:self.sessionId forKey:@"session_id"];
    [dic setObject:self.ispName forKey:@"isp"];
    
    [dic setObject:[LuuUtils appVersion] forKey:@"versionName"];
    [dic setObject:@"apple" forKey:@"vendor"];
    [dic setObject:[NSNumber numberWithBool:[AppContext getInstance].accountManager.isLogin] forKey:@"isLogin"];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenRect.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat screenX = screenSize.width * scale;
    CGFloat screenY = screenSize.height * scale;
    [dic setObject:[NSString stringWithFormat:@"%ld*%ld",(long)screenY,(long)screenX] forKey:@"resolution"];
    [dic setObject:[LuuUtils deviceModel] forKey:@"model"];
    
    return dic;
}

-(NSString *)ispName
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    
    CTCarrier *carrier = [info subscriberCellularProvider];
    
    NSString *mobile;
    
    if (!carrier.isoCountryCode)
    {
        mobile = @"";
    }
    else
    {
        mobile = [carrier carrierName];
    }
    return mobile;
}

@end
