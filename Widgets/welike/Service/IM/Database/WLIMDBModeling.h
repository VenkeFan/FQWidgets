//
//  WLIMDBModeling.h
//  welike
//
//  Created by luxing on 2018/5/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMResultSet;

@protocol WLIMDBModeling <NSObject>

+ (id<WLIMDBModeling>)decodeFromDBSet:(FMResultSet *)resultSet;
- (NSMutableDictionary *)encodeToDBModel;

@end
