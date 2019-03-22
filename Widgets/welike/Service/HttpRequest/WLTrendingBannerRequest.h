//
//  WLTrendingBannerRequest.h
//  welike
//
//  Created by gyb on 2018/8/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^TrendingBannerRequestSuccessed)(NSArray *items);


@interface WLTrendingBannerRequest : RDBaseRequest

- (instancetype)init;

- (void)trendingBannerList:(TrendingBannerRequestSuccessed)successed error:(failedBlock)error;


@end
