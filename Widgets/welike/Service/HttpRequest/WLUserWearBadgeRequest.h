//
//  WLUserWearBadgeRequest.h
//  welike
//
//  Created by fan qi on 2019/2/22.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface WLUserWearBadgeRequest : RDBaseRequest

- (void)wearBadgeWithUserID:(NSString *)userID
                 newBadgeID:(NSString *)newBadgeID
                 oldBadgeID:(NSString *)oldBadgeID
                      index:(NSInteger)index
                    succeed:(void(^)(NSDictionary *dic))succeed
                     failed:(failedBlock)failed;

@end

NS_ASSUME_NONNULL_END
