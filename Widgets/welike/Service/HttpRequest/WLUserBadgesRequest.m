//
//  WLUserBadgesRequest.m
//  welike
//
//  Created by fan qi on 2019/2/22.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLUserBadgesRequest.h"
#import "WLBadgeModel.h"

@interface WLUserBadgesRequest ()

@property (nonatomic, copy) NSString *userID;

@end

@implementation WLUserBadgesRequest

- (instancetype)initWithUserID:(NSString *)userID {
    _userID = [userID copy];
    
    return [super initWithType:AFHttpOperationTypeNormal api:@"discovery/user/badges" method:AFHttpOperationMethodGET];
}

- (void)requestUserBadgesWithSucceed:(userBadgesSuccessed)succeed failed:(failedBlock)failed {
    if (self.userID.length <= 0) {
        return;
    }
    
    [self.params removeAllObjects];
    
    [self.params setObject:self.userID forKey:@"userId"];
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *arrayM = nil;
            NSDictionary *resDic = (NSDictionary *)result;
            NSArray *jsonArray = [resDic objectForKey:@"badges"];
            
            if (jsonArray.count > 0) {
                arrayM = [NSMutableArray arrayWithCapacity:jsonArray.count];
                
                for (int i = 0; i < jsonArray.count; i++) {
                    WLBadgeModel *model = [WLBadgeModel parseWithNetworkJson:jsonArray[i]];
                    model.have = YES;
                    if (model) {
                        [arrayM addObject:model];
                    }
                }
            }
            
            if (succeed) {
                succeed(arrayM);
            }
        } else {
            if (failed) {
                failed(ERROR_NETWORK_RESP_INVALID);
            }
        }
    };
    self.onFailed = failed;
    [self sendQuery];
}

@end
