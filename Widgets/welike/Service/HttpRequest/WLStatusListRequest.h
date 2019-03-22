//
//  WLStatusListRequest.h
//  welike
//
//  Created by gyb on 2018/11/14.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^StatusListRequestSuccessed)(NSMutableArray *items);

@interface WLStatusListRequest : RDBaseRequest

- (instancetype)init;

- (void)requestStatusListSuccess:(StatusListRequestSuccessed)successed error:(failedBlock)error;
- (void)requestStatusJsonSuccess:(StatusListRequestSuccessed)successed error:(failedBlock)error;


@end

NS_ASSUME_NONNULL_END
