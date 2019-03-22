//
//  WLTrendingSearchKey.h
//  welike
//
//  Created by gyb on 2018/8/27.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLTrendingSearchKey : NSObject

@property (nonatomic, copy) NSString *words;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, assign) BOOL isDel;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString *wards;


+ (WLTrendingSearchKey *)parseTrendingKey:(NSDictionary *)info;


@end
