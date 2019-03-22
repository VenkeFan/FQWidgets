//
//  WLInterestRequest.h
//  welike
//
//  Created by gyb on 2018/7/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^InterestsRequestSuccessed)(NSArray *feeds);

@interface WLInterestRequest : RDBaseRequest

- (instancetype)init;

- (void)requestInterest:(InterestsRequestSuccessed)successed error:(failedBlock)error;

@end
