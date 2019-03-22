//
//  WLIMDBConnection.h
//  welike
//
//  Created by luxing on 2018/5/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "RDGCDBlockPool.h"

@interface WLIMDBConnection : NSObject

- (void)dbUpgradeVersion:(FMDatabase *)db blockPool:(RDGCDBlockPool *)blockPool;

@end
