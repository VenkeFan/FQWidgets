//
//  WLInterestRequest.m
//  welike
//
//  Created by gyb on 2018/7/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLInterestRequest.h"
#import "WLVerticalItem.h"

@implementation WLInterestRequest

- (instancetype)init
{
    if ([[[AppContext getInstance] accountManager] isLogin]) {
        return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"user/interest/list"] method:AFHttpOperationMethodGET];
    } else {
        return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"user/interest/skip/list"] method:AFHttpOperationMethodGET];
    }
}

- (void)requestInterest:(InterestsRequestSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    [self.params setObject:@"" forKey:@"referrerId"];
    
    self.onSuccessed = ^(id result) {
        
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            
            NSArray *itemsJSON = [resDic objectForKey:@"list"];
            //NSString *cursor = [resDic objectForKey:@"cursor"];
            
            NSMutableArray *verticals;
            
            if ([itemsJSON count] > 0)
            {
                verticals = [NSMutableArray arrayWithCapacity:[itemsJSON count]];
                for (NSInteger i = 0; i < [itemsJSON count]; i++)
                {
                    WLVerticalItem *verticalItem = [WLVerticalItem parseFromNetworkJSON:[itemsJSON objectAtIndex:i]];
                    if (verticalItem != nil)
                    {
                        [verticals addObject:verticalItem];
                    }
                }
            }
            
            if (successed)
            {
                successed(verticals);
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
