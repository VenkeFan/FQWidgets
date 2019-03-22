//
//  WLRemoveRecommendRequest.h
//  welike
//
//  Created by fan qi on 2018/12/4.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface WLRemoveRecommendRequest : RDBaseRequest

- (void)removeRecommendWithUserID:(NSString *)userID
                          succeed:(void(^)(void))succeed
                           failed:(failedBlock)failed;

@end

NS_ASSUME_NONNULL_END
