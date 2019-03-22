//
//  WLSugUsersRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@class WLReferrerInfo;

typedef void(^sugUsersSuccessed)(NSArray *groups, WLReferrerInfo *referrerInfo);

@interface WLSugUsersRequest : RDBaseRequest

- (id)initSugUsersRequest;
- (void)listSugUsersWithReferrerId:(NSString *)referrerId successed:(sugUsersSuccessed)successed error:(failedBlock)error;

@end
