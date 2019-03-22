//
//  WLSugUsersRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSugUsersRequest.h"
#import "WLRegisterSugUserDataSourceItem.h"
#import "WLRegisterSugUserSectionDataSourceItem.h"
#import "WLReferrerInfo.h"
#import "WLUser.h"
#import "NSDictionary+JSON.h"

@interface WLSugUsersRequest ()

- (NSArray *)parseSugUsersGroup:(NSArray *)list;

@end

@implementation WLSugUsersRequest

- (id)initSugUsersRequest
{
    return [super initWithType:AFHttpOperationTypeNormal api:@"user/hot" method:AFHttpOperationMethodGET];
}

- (void)listSugUsersWithReferrerId:(NSString *)referrerId successed:(sugUsersSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    [self.params setObject:[NSNumber numberWithInteger:SUG_USERS_NUM_ONE_PAGE] forKey:@"count"];
    if ([referrerId length] > 0)
    {
        [self.params setObject:referrerId forKey:@"referrerId"];
    }
    __weak typeof(self) weakSelf = self;
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            WLReferrerInfo *referrerInfo = nil;
            NSArray *groups = nil;
            NSDictionary *resDic = (NSDictionary *)result;
            id referrerObj = [resDic stringForKey:@"referrer"];
            if ([referrerObj isKindOfClass:[NSDictionary class]] == YES)
            {
                referrerInfo = [WLReferrerInfo parseReferrerInfo:(NSDictionary *)referrerObj];
            }
            id list = [result objectForKey:@"list"];
            if ([list isKindOfClass:[NSArray class]] == YES)
            {
                groups = [weakSelf parseSugUsersGroup:(NSArray *)list];
            }
            if (successed != nil)
            {
                successed(groups, referrerInfo);
            }
        }
        else
        {
            if (error != nil)
            {
                error(ERROR_NETWORK_RESP_INVALID);
            }
        }
    };
    self.onFailed = error;
    [self sendQuery];
}

- (NSArray *)parseSugUsersGroup:(NSArray *)list
{
    NSMutableArray *arr = [NSMutableArray array];
    if ([list count] > 0)
    {
        for (NSInteger i = 0; i < [list count]; i++)
        {
            id oo = [list objectAtIndex:i];
            if ([oo isKindOfClass:[NSDictionary class]] == YES)
            {
                WLRegisterSugUserSectionDataSourceItem *section = [[WLRegisterSugUserSectionDataSourceItem alloc] init];
                [arr addObject:section];
                NSMutableArray *sugUsers = [NSMutableArray array];
                section.users = sugUsers;
                NSDictionary *groupDic = (NSDictionary *)oo;
                id tagObj = [groupDic objectForKey:@"tag"];
                if ([tagObj isKindOfClass:[NSDictionary class]] == YES)
                {
                    section.title = [((NSDictionary *)tagObj) stringForKey:@"value"];
                }
                id usersObj = [groupDic objectForKey:@"users"];
                if ([usersObj isKindOfClass:[NSArray class]] == YES)
                {
                    NSArray *usersArr = (NSArray *)usersObj;
                    if ([usersArr count] > 0)
                    {
                        for (NSInteger j = 0; j < [usersArr count]; j++)
                        {
                            id userObj = [usersArr objectAtIndex:j];
                            if ([userObj isKindOfClass:[NSDictionary class]] == YES)
                            {
                                WLUser *user = [WLUser parseFromNetworkJSON:(NSDictionary *)userObj];
                                if (user != nil)
                                {
                                    WLRegisterSugUserDataSourceItem *userItem = [[WLRegisterSugUserDataSourceItem alloc] init];
                                    userItem.uid = user.uid;
                                    userItem.head = user.headUrl;
                                    userItem.name = user.nickName;
                                    userItem.intro = user.introduction;
                                    userItem.isSelected = YES;
                                    [sugUsers addObject:userItem];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return arr;
}

@end
