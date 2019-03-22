//
//  WLRefreshVerticalFeedList.m
//  welike
//
//  Created by gyb on 2018/7/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRefreshVerticalFeedList.h"
#import "WLAccountManager.h"
//#import "WLUserBase.h"

@implementation WLRefreshVerticalFeedList


- (instancetype)init
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"leaderboard/interest/notifyupdate"] method:AFHttpOperationMethodGET];
}

- (void)RefreshVerticalFeedList:(RefreshVerticalSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    if ([LuuUtils deviceId].length > 0)
    {
         [self.params setObject:[LuuUtils deviceId] forKey:@"userId"];
    }
    
    self.onSuccessed = ^(id result) {
        
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
           // NSDictionary *resDic = (NSDictionary *)result;
            
          //  NSArray *itemsJSON = [resDic objectForKey:@"list"];
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
