//
//  WLInterestsRequest.m
//  welike
//
//  Created by 刘斌 on 2018/4/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLInterestsRequest.h"
#import "WLReferrerInfo.h"
#import "NSDictionary+JSON.h"
#import "WLInterestLabelMenuModel.h"

@implementation WLInterestsRequest

- (id)initInterestsRequest
{
    return [super initWithType:AFHttpOperationTypeNormal api:@"user/interest/list" method:AFHttpOperationMethodGET];
}

- (void)listInterestsWithPageNum:(NSInteger)pageNum referrerId:(NSString *)referrerId successed:(interestsSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    [self.params setObject:[NSNumber numberWithInteger:pageNum] forKey:@"pageNumber"];
    [self.params setObject:[NSNumber numberWithInteger:INTERESTS_NUM_ONE_PAGE] forKey:@"pageSize"];
    if ([referrerId length] > 0)
    {
        [self.params setObject:referrerId forKey:@"referrerId"];
    }
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            WLReferrerInfo *referrerInfo = nil;
            NSArray *interests = nil;
            NSDictionary *resDic = (NSDictionary *)result;
            id referrerObj = [resDic stringForKey:@"referrer"];
            if ([referrerObj isKindOfClass:[NSDictionary class]] == YES)
            {
                referrerInfo = [WLReferrerInfo parseReferrerInfo:(NSDictionary *)referrerObj];
            }
            id list = [result objectForKey:@"list"];
            if ([list isKindOfClass:[NSArray class]] == YES)
            {
                interests = [WLInterestLabelMenuModel modelsWithItems:list];//wlx test
            }
            if (successed != nil)
            {
                successed(interests, referrerInfo);
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

@end
