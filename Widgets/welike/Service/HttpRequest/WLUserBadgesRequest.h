//
//  WLUserBadgesRequest.h
//  welike
//
//  Created by fan qi on 2019/2/22.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLBadgeRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface WLUserBadgesRequest : WLBadgeRequest

- (void)requestUserBadgesWithSucceed:(userBadgesSuccessed)succeed
                              failed:(failedBlock)failed;

@end

NS_ASSUME_NONNULL_END
