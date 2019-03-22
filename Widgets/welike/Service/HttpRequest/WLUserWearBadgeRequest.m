//
//  WLUserWearBadgeRequest.m
//  welike
//
//  Created by fan qi on 2019/2/22.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLUserWearBadgeRequest.h"

@implementation WLUserWearBadgeRequest

- (instancetype)init {
    return [super initWithType:AFHttpOperationTypeNormal api:@"discovery/user/badge/wear" method:AFHttpOperationMethodGET];
}

- (void)wearBadgeWithUserID:(NSString *)userID
                 newBadgeID:(NSString *)newBadgeID
                 oldBadgeID:(NSString *)oldBadgeID
                      index:(NSInteger)index
                    succeed:(void(^)(NSDictionary *dic))succeed
                     failed:(failedBlock)failed {
    if (userID.length <= 0 || newBadgeID.length <= 0 || oldBadgeID.length <= 0) {
        return;
    }
    
    [self.params removeAllObjects];
    
    [self.params setObject:userID forKey:@"userId"];
    [self.params setObject:newBadgeID forKey:@"badgeId"];
    [self.params setObject:oldBadgeID forKey:@"oldBadgeId"];
    [self.params setObject:@(index) forKey:@"index"];
    
    self.onSuccessed = succeed;
    self.onFailed = failed;
    [self sendQuery];
}

@end
