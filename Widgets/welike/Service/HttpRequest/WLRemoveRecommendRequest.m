//
//  WLRemoveRecommendRequest.m
//  welike
//
//  Created by fan qi on 2018/12/4.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLRemoveRecommendRequest.h"

@implementation WLRemoveRecommendRequest

- (instancetype)init {
    return [super initWithType:AFHttpOperationTypeNormal api:@"tag/recommended/close" method:AFHttpOperationMethodPOST];
}

- (void)removeRecommendWithUserID:(NSString *)userID
                          succeed:(void(^)(void))succeed
                           failed:(failedBlock)failed {
    if (userID.length == 0) {
        return;
    }
    
    [self.params removeAllObjects];
    [self setBody:[userID dataUsingEncoding:NSUTF8StringEncoding]];
    
    self.onSuccessed = ^(id result) {
        
    };
    
    self.onFailed = failed;
    [self sendQuery];
}

@end
