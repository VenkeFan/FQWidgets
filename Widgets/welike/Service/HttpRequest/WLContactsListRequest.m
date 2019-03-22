 //
//  WLContactsListRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLContactsListRequest.h"
#import "WLUser.h"

@implementation WLContactsListRequest

- (id)initContactsListRequestWithUid:(NSString *)uid
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"feed/user/%@/follow-users", uid] method:AFHttpOperationMethodGET];
}

//- (void)listContactsSuccessed:(contactsSuccessed)successed error:(failedBlock)error
//{
//    [self.params removeAllObjects];
//    [self.params setObject:[NSNumber numberWithInteger:Contacts_ONE_PAGE] forKey:@"count"];
//    
//    self.onSuccessed = ^(id result) {
//        if ([result isKindOfClass:[NSDictionary class]] == YES)
//        {
//            NSMutableArray *users = nil;
//            NSDictionary *resDic = (NSDictionary *)result;
//            NSString *cursor;
//        
//            if ([resDic.allKeys containsObject:@"cursor"])
//            {
//                cursor = [resDic objectForKey:@"cursor"];
//            }
//            
//            id usersObj = [resDic objectForKey:@"list"];
//            if ([usersObj isKindOfClass:[NSArray class]] == YES)
//            {
//                NSArray *usersJSON = (NSArray *)usersObj;
//                users = [NSMutableArray arrayWithCapacity:[usersJSON count]];
//                for (NSInteger i = 0; i < [usersJSON count]; i++)
//                {
//                    WLUser *user = [WLUser parseFromNetworkJSON:[usersJSON objectAtIndex:i]];
//                    [users addObject:user];
//                }
//            }
//            
//            
//            
//            
//            if (successed)
//            {
//                successed(users,cursor);
//            }
//        }
//        else
//        {
//            if (error)
//            {
//                error(ERROR_NETWORK_RESP_INVALID);
//            }
//        }
//    };
//    self.onFailed = error;
//    [self sendQuery];
//}

- (void)listContactsSuccessedWithPage:(NSString *)cursor success:(contactsSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    [self.params setObject:[NSNumber numberWithInteger:Contacts_ONE_PAGE] forKey:@"count"];
    [self.params setObject:cursor forKey:@"cursor"];
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSMutableArray *users = nil;
            NSDictionary *resDic = (NSDictionary *)result;
            id usersObj = [resDic objectForKey:@"list"];
            NSString *cursor;
            
            if ([resDic.allKeys containsObject:@"cursor"])
            {
                cursor = [resDic objectForKey:@"cursor"];
            }
            
            if ([usersObj isKindOfClass:[NSArray class]] == YES)
            {
                NSArray *usersJSON = (NSArray *)usersObj;
                users = [NSMutableArray arrayWithCapacity:[usersJSON count]];
                for (NSInteger i = 0; i < [usersJSON count]; i++)
                {
                    WLUser *user = [WLUser parseFromNetworkJSON:[usersJSON objectAtIndex:i]];
                    [users addObject:user];
                }
            }
            
            if ([cursor isEqual:[NSNull null]] || cursor.length == 0)
            {
                if (successed)
                {
                    successed(users,cursor,YES);
                }
            }
            else
            {
                if (successed)
                {
                    successed(users,cursor,NO);
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
