//
//  WLFollowUsersRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFollowUsersRequest.h"
#import "WLAccountManager.h"

@implementation WLFollowUsersRequest

- (id)initFollowUsersRequestWithAccount:(WLAccount *)account
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/%@/batchFollow", account.uid] method:AFHttpOperationMethodPUT];
}

- (void)followUsers:(NSArray *)uids successed:(followUsersSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:[uids count]];
    for (NSInteger i = 0; i < [uids count]; i++)
    {
        NSString *uid = [uids objectAtIndex:i];
        NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:uid, @"id", nil];
        [ids addObject:item];
    }
    NSData *body = [NSJSONSerialization dataWithJSONObject:ids options:NSJSONWritingPrettyPrinted error:nil];
    [self setBody:body];
    
    self.onSuccessed = ^(id result) {
        if (successed)
        {
            successed();
        }
    };
    self.onFailed = error;
    [self sendQuery];
}

@end
