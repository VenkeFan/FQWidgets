//
//  WLUserRecommendRequest.h
//  welike
//
//  Created by fan qi on 2018/12/3.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@interface WLUserRecommendRequest : RDBaseRequest

- (void)requestRecommendUsersWithPageNum:(NSInteger)pageNum
                                 succeed:(void(^)(NSArray *))succeed
                                   error:(failedBlock)error;

@end
