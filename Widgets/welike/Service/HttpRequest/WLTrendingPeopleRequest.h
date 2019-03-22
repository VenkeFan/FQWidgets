//
//  WLTrendingPeopleRequest.h
//  welike
//
//  Created by gyb on 2018/8/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"
#import "WLTrendingUserModel.h"

typedef void(^TrendingPeopleRequestSuccessed)(WLTrendingUserModel *model, NSString *forwardUrl);


@interface WLTrendingPeopleRequest : RDBaseRequest

- (instancetype)init;

- (void)requestTrendingUsers:(TrendingPeopleRequestSuccessed)successed error:(failedBlock)error;

@end
