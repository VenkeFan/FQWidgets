//
//  WLUserRecommendRequest.m
//  welike
//
//  Created by fan qi on 2018/12/3.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLUserRecommendRequest.h"
#import "WLUser.h"

@implementation WLUserRecommendRequest

- (instancetype)init {
    return [super initWithType:AFHttpOperationTypeNormal api:@"user/recommend" method:AFHttpOperationMethodGET];
}

- (void)requestRecommendUsersWithPageNum:(NSInteger)pageNum
                                 succeed:(void(^)(NSArray *users))succeed
                                   error:(failedBlock)error {
    [self.params removeAllObjects];
    
    [self.params setObject:@(pageNum) forKey:@"pageNum"];
    [self.params setObject:@(30) forKey:@"pageSize"];
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *userArray = [NSMutableArray array];
            NSDictionary *resDic = (NSDictionary *)result;
            NSArray *jsonArray = resDic[@"list"];
            if ([jsonArray isEqual:[NSNull null]])
            {
                if (succeed) {
                    succeed(userArray);
                };
            }
            else
            {
                for (int i = 0; i < jsonArray.count; i++) {
                    WLUser *user = [WLUser parseFromNetworkJSON:jsonArray[i]];
                    if (user) {
                        [userArray addObject:user];
                    }
                }
                
                if (succeed) {
                    succeed(userArray);
                }
            }
        } else {
            if (error) {
                error(ERROR_NETWORK_RESP_INVALID);
            }
        }
    };
    self.onFailed = error;
    [self sendQuery];
}

@end
