//
//  WLLocationPersonsRequest.m
//  welike
//
//  Created by gyb on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLocationPersonsRequest.h"
#import "WLUser.h"

@implementation WLLocationPersonsRequest

- (id)initLocationPersons:(NSString *)placeId
{
    _placeId = placeId;
    return [super initWithType:AFHttpOperationTypeNormal api:@"lbs/place/users" method:AFHttpOperationMethodGET];
}

- (void)locationPersons:(NSInteger)pageNum successed:(requestSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    [self.params setObject:_placeId forKey:@"placeId"];
    [self.params setObject:[NSNumber numberWithInteger:pageNum] forKey:@"page"];
    [self.params setObject:[NSNumber numberWithInteger:USERS_NUM_ONE_PAGE] forKey:@"pageSize"];
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            NSMutableArray *users = nil;
            NSArray *usersJSON = [resDic objectForKey:@"users"];
            if ([usersJSON count] > 0)
            {
                users = [NSMutableArray arrayWithCapacity:[usersJSON count]];
                for (NSInteger i = 0; i < [usersJSON count]; i++)
                {
                    WLUser *user = [WLUser parseFromNetworkJSON:[[usersJSON objectAtIndex:i] objectForKey:@"user"]];
                    user.recentPostTime = [[usersJSON objectAtIndex:i] longLongForKey:@"passTime" def:0];
                    if (user != nil)
                    {
                        [users addObject:user];
                    }
                }
            }
            BOOL last = NO;
            if ([[resDic objectForKey:@"hasMore"] boolValue])
            {
                last = NO;
            }
            else
            {
                 last = YES;
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
