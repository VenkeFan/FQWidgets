//
//  WLUploadStatusStorage.m
//  welike
//
//  Created by 刘斌 on 2018/4/20.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUploadStatusStorage.h"
#import "WLStorageDBManager.h"

#define CREATE_STORAGE_TABLE_SQL @"CREATE TABLE IF NOT EXISTS upload (sign TEXT, uploadid TEXT, PRIMARY KEY(sign))"

@interface WLUploadStatusStorage ()

@end

@implementation WLUploadStatusStorage

- (void)prepare
{
    FMDatabase *db = [WLStorageDBManager getInstance].db;
    [db executeUpdate:CREATE_STORAGE_TABLE_SQL];
}

#pragma mark WLUploadStatusStorage public methods
- (NSString *)getMultiPartStatus:(NSString *)sign
{
    __block NSString *uploadId = nil;
    if ([sign length] > 0)
    {
        FMDatabase *db = [WLStorageDBManager getInstance].db;
        [[WLStorageDBManager getInstance] syncBlock:^{
            FMResultSet *rs = [db executeQuery:@"SELECT * FROM upload WHERE sign = ?", sign];
            if ([rs next])
            {
                uploadId = [[rs stringForColumn:@"uploadid"] copy];
            }
            [rs close];
        }];
    }
    return uploadId;
}

- (void)putMultiPartStatus:(NSString *)uploadId forSign:(NSString *)sign
{
    if ([uploadId length] > 0 && [sign length] > 0)
    {
        FMDatabase *db = [WLStorageDBManager getInstance].db;
        [[WLStorageDBManager getInstance] asyncBlock:^{
            [db executeUpdate:@"INSERT OR REPLACE INTO upload (sign, uploadid) VALUES (?, ?)", sign, uploadId];
        }];
    }
}

- (void)removeMultiPartStatusForSign:(NSString *)sign
{
    if ([sign length] > 0)
    {
        FMDatabase *db = [WLStorageDBManager getInstance].db;
        [[WLStorageDBManager getInstance] asyncBlock:^{
            [db executeUpdate:@"DELETE FROM upload WHERE sign = ?", sign];
        }];
    }
}

@end
