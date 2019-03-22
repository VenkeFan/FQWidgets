//
//  WLUserDetailRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUserDetailRequest.h"
#import "WLUser.h"

@implementation WLUserDetailRequest

- (id)initUserDetailRequestWithUid:(NSString *)uid
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"user/detail/id/%@", uid] method:AFHttpOperationMethodGET];
}

- (void)detailSuccessed:(userDetailSuccessed)successed error:(failedBlock)error
{
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            WLUser *user = [WLUser parseFromNetworkJSON:result];
            
            NSMutableArray *interests = [result objectForKey:@"interests"];
            if (interests.count > 0)
            {
                user.interests = interests;
            }
            
            
            
            if (user != nil)
            {
                if (successed)
                {
                    successed(user);
                }
            }
            else
            {
                if (error)
                {
                    error(ERROR_NETWORK_RESP_INVALID);
                }
            }
        }
        else
        {
            if (error)
            {
                error(ERROR_NETWORK_RESP_INVALID);
            }
        }
    };
    self.onFailed = error;
    [self sendQuery];
}

@end
