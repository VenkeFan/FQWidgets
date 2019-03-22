//
//  WLStorageDBManager.h
//  welike
//
//  Created by 刘斌 on 2018/4/20.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "RDGCDBlockPool.h"

@interface WLStorageDBManager : NSObject

@property (nonatomic, readonly) FMDatabase *db;

+ (WLStorageDBManager *)getInstance;

- (void)loginWithUid:(NSString *)uid;
- (void)logout;

- (void)asyncBlock:(queueBlock)block;
- (void)syncBlock:(queueBlock)block;

@end
