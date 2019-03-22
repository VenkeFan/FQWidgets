//
//  WLSearchUserRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchUserRequest.h"
#import "WLUser.h"

@implementation WLSearchUserRequest

- (id)initSearchUserRequest
{
    return [super initWithType:AFHttpOperationTypeNormal api:@"search/skip/user/nickName" method:AFHttpOperationMethodGET];
}

- (void)searchWithKeyword:(NSString *)keyword pageNum:(NSInteger)pageNum successed:(searchUsersSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    [self.params setObject:keyword forKey:@"nickName"];
    [self.params setObject:[NSNumber numberWithInteger:pageNum] forKey:@"pageNumber"];
    [self.params setObject:[NSNumber numberWithInteger:SEARCH_USERS_NUMBER_ONE_PAGE] forKey:@"count"];
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            NSMutableArray *users = nil;
            NSArray *usersJSON = [resDic objectForKey:@"list"];
            if ([usersJSON count] > 0)
            {
                users = [NSMutableArray arrayWithCapacity:[usersJSON count]];
                for (NSInteger i = 0; i < [usersJSON count]; i++)
                {
                    WLUser *user = [WLUser parseFromNetworkJSON:[usersJSON objectAtIndex:i]];
                    if (user != nil)
                    {
                        [users addObject:user];
                    }
                }
            }
            BOOL last = YES;
            if ([users count] > 0)
            {
                last = NO;
            }
            
            if (successed)
            {
                successed(users, last, pageNum);
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
