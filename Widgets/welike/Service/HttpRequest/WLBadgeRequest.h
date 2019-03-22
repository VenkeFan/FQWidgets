//
//  WLBadgeRequest.h
//  welike
//
//  Created by fan qi on 2019/2/20.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

typedef void(^userBadgesSuccessed)(NSArray *dataArray);

NS_ASSUME_NONNULL_BEGIN

@interface WLBadgeRequest : RDBaseRequest

- (instancetype)initWithUserID:(NSString *)userID;
- (void)requestAllBadgesWithSucceed:(userBadgesSuccessed)succeed
                             failed:(failedBlock)failed;

@end

NS_ASSUME_NONNULL_END
