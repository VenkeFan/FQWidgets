//
//  WLPostLikeUsersRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPostLikeUsersRequest.h"
#import "WLUser.h"
#import "NSDictionary+JSON.h"

@implementation WLPostLikeUsersRequest

- (id)initPostLikeUsersRequestWithPostId:(NSString *)pid
{
    if ([[[AppContext getInstance] accountManager] isLogin]) {
        return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/post/%@/liked-users", pid] method:AFHttpOperationMethodGET];
    } else {
        return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/post/h5/%@/liked-users", pid] method:AFHttpOperationMethodGET];
    }
}

- (void)listWithCursor:(NSString *)cursor successed:(postLikeUsersSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    [self.params setObject:[NSNumber numberWithInteger:USERS_NUM_ONE_PAGE] forKey:@"count"];
    if ([cursor length] > 0)
    {
        [self.params setObject:cursor forKey:@"cursor"];
    }
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            NSArray *list = [resDic objectForKey:@"list"];
            NSString *cursor = [resDic stringForKey:@"cursor"];
            if ([list count] > 0)
            {
                NSMutableArray *users = [NSMutableArray arrayWithCapacity:[list count]];
                for (NSInteger i = 0; i < [list count]; i++)
                {
                    WLUser *user = [WLUser parseFromNetworkJSON:[list objectAtIndex:i]];
                    if (user != nil)
                    {
                        [users addObject:user];
                    }
                }
                if (successed)
                {
                    successed(users, cursor);
                }
            }
            else
            {
                if (successed)
                {
                    successed(nil, cursor);
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
