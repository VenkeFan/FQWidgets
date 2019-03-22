//
//  WLServiceRequest.m
//  welike
//
//  Created by gyb on 2019/3/9.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLServiceRequest.h"
#import "WLIMSession.h"
#import "WLUser.h"

@implementation WLServiceRequest

- (instancetype)init
{
    return [super initWithType:AFHttpOperationTypeNormal api:@"im/message/conversation/customer" method:AFHttpOperationMethodPOST];
}

-(void)getServiceUser:(ServiceUserRequestSuccessed)succeed failed:(failedBlock)failed
{
    [self.params removeAllObjects];
    
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:1];
   
    NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:[AppContext getInstance].accountManager.myAccount.uid, @"id", nil];
    [ids addObject:item];
    
    NSData *body = [NSJSONSerialization dataWithJSONObject:ids options:NSJSONWritingPrettyPrinted error:nil];
    
    if ([body length] > 0)
    {
        [self setBody:body];
    }
    
    self.onSuccessed = ^(id result) {
        
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            
            if ([resDic.allKeys containsObject:@"members"])
            {
                NSArray *users = resDic[@"members"];
                WLUser *user;
                
                for (NSDictionary *dic in users)
                {
                    if (![[dic stringForKey:@"id"] isEqualToString:[AppContext getInstance].accountManager.myAccount.uid])
                    {
                        user = [WLUser parseFromNetworkJSON:dic];
                        break;
                    }
                }
                
                if (succeed)
                {
                    succeed(user);
                }
            }
            else
            {
                if (failed)
                {
                    failed(ERROR_NETWORK_RESP_INVALID);
                }
            }
        }
        else
        {
            if (failed)
            {
                failed(ERROR_NETWORK_RESP_INVALID);
            }
        }
    };
    self.onFailed = failed;
    [self sendQuery];
}

@end
