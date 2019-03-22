//
//  WLTrendingSearchKey.m
//  welike
//
//  Created by gyb on 2018/8/27.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTrendingSearchKey.h"

@implementation WLTrendingSearchKey

+ (WLTrendingSearchKey *)parseTrendingKey:(NSDictionary *)info
{
    if (info == nil) return nil;
    
    WLTrendingSearchKey *trendingSearchKey = [[WLTrendingSearchKey alloc] init];
    
    trendingSearchKey.words = [info stringForKey:@"words"];
    trendingSearchKey.language = [info stringForKey:@"language"];
    
    trendingSearchKey.isDel = [info boolForKey:@"isDel" def:NO];
    trendingSearchKey.createTime = [info stringForKey:@"createTime"];
    
    trendingSearchKey.status = [info integerForKey:@"status" def:1];
    trendingSearchKey.wards = [info stringForKey:@"wards"];
   
    return trendingSearchKey;
}


@end
