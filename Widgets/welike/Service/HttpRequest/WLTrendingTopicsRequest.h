//
//  WLTrendingTopicsRequest.h
//  welike
//
//  Created by gyb on 2018/8/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^TrendingTopicsRequestSuccessed)(NSArray *items,NSString *cursor);

@interface WLTrendingTopicsRequest : RDBaseRequest

- (instancetype)init;

- (void)trendingTopicListWithCursor:(NSString *)cursor success:(TrendingTopicsRequestSuccessed)successed error:(failedBlock)error;



@end
