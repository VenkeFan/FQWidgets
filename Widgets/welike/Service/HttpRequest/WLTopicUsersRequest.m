//
//  WLTopicUsersRequest.m
//  welike
//
//  Created by fan qi on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTopicUsersRequest.h"
#import "NSDictionary+JSON.h"
#import "WLUser.h"
#import "WLAccountManager.h"

@implementation WLTopicUsersRequest

- (instancetype)initWithTopicID:(NSString *)topicID {
    
    
    if ([[[AppContext getInstance] accountManager] isLogin])
    {
         return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/topic/%@/users", [topicID urlEncode:NSUTF8StringEncoding]] method:AFHttpOperationMethodGET];
    }
    else
    {
        
         return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/topic/h5/%@/users", [topicID urlEncode:NSUTF8StringEncoding]] method:AFHttpOperationMethodGET];
    }
}

- (void)listWithCursor:(NSString *)cursor index:(NSNumber *)index successed:(topicUsersSuccessed)successed error:(failedBlock)error {
    [self.params removeAllObjects];
    
    [self.params setObject:[NSNumber numberWithInteger:USERS_NUM_ONE_PAGE] forKey:@"count"];
    [self.params setObject:@"created" forKey:@"order"];
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
