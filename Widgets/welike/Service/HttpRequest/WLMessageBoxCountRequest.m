//
//  WLMessageBoxCountRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLMessageBoxCountRequest.h"
#import "NSDictionary+JSON.h"

@implementation WLMessageBoxCountRequest

- (id)initMessageBoxCountRequestWithUid:(NSString *)uid
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"im/user/%@/notifications/count", uid] method:AFHttpOperationMethodGET];
}

- (void)countWithSuccessed:(messageBoxCountSuccessed)successed error:(failedBlock)error
{
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            NSInteger mention = [resDic integerForKey:@"MENTION" def:0];
            NSInteger comment = [resDic integerForKey:@"COMMENT" def:0];
            NSInteger like = [resDic integerForKey:@"LIKE" def:0];
            if (successed)
            {
                successed(mention, comment, like);
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
