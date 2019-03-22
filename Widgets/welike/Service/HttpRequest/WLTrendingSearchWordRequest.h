//
//  WLTrendingSearchWordRequest.h
//  welike
//
//  Created by gyb on 2018/8/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^TrendingSearchWordRequestSuccessed)(NSArray *items);

@interface WLTrendingSearchWordRequest : RDBaseRequest

- (instancetype)init;

- (void)trendingSearchKeyWordList:(TrendingSearchWordRequestSuccessed)successed error:(failedBlock)error;

@end
