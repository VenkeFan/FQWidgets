//
//  WLInterestsRequest.h
//  welike
//
//  Created by 刘斌 on 2018/4/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@class WLReferrerInfo;

typedef void(^interestsSuccessed)(NSArray *interests, WLReferrerInfo *referrerInfo);

@interface WLInterestsRequest : RDBaseRequest

- (id)initInterestsRequest;
- (void)listInterestsWithPageNum:(NSInteger)pageNum referrerId:(NSString *)referrerId successed:(interestsSuccessed)successed error:(failedBlock)error;

@end
