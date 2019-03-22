//
//  WLSearchSugRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchSugRequest.h"
#import "WLUser.h"
#import "WLSugResult.h"
#import "NSDictionary+JSON.h"

@implementation WLSearchSugRequest

- (id)initSearchSugRequest
{
    return [super initWithType:AFHttpOperationTypeNormal api:@"search/skip/query/user_all" method:AFHttpOperationMethodGET];
}

- (void)sugKeyword:(NSString *)keyword successed:(searchSugSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    [self.params setObject:keyword forKey:@"query"];
    [self.params setObject:[NSNumber numberWithInteger:0] forKey:@"pageNumber"];
    [self.params setObject:[NSNumber numberWithInteger:SUG_SEARCH_ONE_PAGE_NUM] forKey:@"count"];
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            NSArray *usersJSON = [resDic objectForKey:@"user"];
            NSArray *sugsJSON = [resDic objectForKey:@"queries"];
            NSMutableArray *list = [NSMutableArray array];
            if ([usersJSON count] > 0)
            {
                for (NSInteger i = 0; i < [usersJSON count]; i++)
                {
                    WLUser *user = [WLUser parseFromNetworkJSON:[usersJSON objectAtIndex:i]];
                    if (user != nil)
                    {
                        WLSugResult *sugRes = [[WLSugResult alloc] init];
                        sugRes.type = WELIKE_SUG_RESULT_TYPE_SUG;
                        sugRes.category = WELIKE_SUG_RESULT_CATEGORY_USER;
                        sugRes.object = user;
                        [list addObject:sugRes];
                    }
                    
                }
            }
            if ([sugsJSON count] > 0)
            {
                for (NSInteger i = 0; i < [sugsJSON count]; i++)
                {
                    NSDictionary *sugDic = [sugsJSON objectAtIndex:i];
                    NSString *suggestion = [sugDic stringForKey:@"text"];
                    WLSugResult *sugRes = [[WLSugResult alloc] init];
                    sugRes.type = WELIKE_SUG_RESULT_TYPE_SUG;
                    sugRes.category = WELIKE_SUG_RESULT_CATEGORY_KEYWORD;
                    sugRes.object = suggestion;
                    [list addObject:sugRes];
                }
            }
            if (successed)
            {
                successed(list);
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
