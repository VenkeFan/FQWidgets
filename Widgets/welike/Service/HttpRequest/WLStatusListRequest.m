//
//  WLStatusListRequest.m
//  welike
//
//  Created by gyb on 2018/11/14.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLStatusListRequest.h"
#import "WLStatusInfo.h"

@implementation WLStatusListRequest

- (instancetype)init
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"conplay/post/status/all"]  method:AFHttpOperationMethodGET];
}

- (void)requestStatusListSuccess:(StatusListRequestSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            
            NSArray *itemsJSON = [resDic objectForKey:@"list"];
            
             NSMutableArray *statusArray = nil;
            
            if ([itemsJSON count] > 0)
            {
                statusArray = [NSMutableArray arrayWithCapacity:[itemsJSON count]];
                for (NSInteger i = 0; i < [itemsJSON count]; i++)
                {
                    WLStatusInfo *info = [WLStatusInfo parseFromNetworkJSON:[itemsJSON objectAtIndex:i]];
                    if (info != nil && info.picUrlList.count > 0 && info.contentList.count > 0)
                    {
                        [statusArray addObject:info];
                    }
                }
            }
            
            if (successed)
            {
                successed(statusArray);
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

- (void)requestStatusJsonSuccess:(StatusListRequestSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            
            NSMutableArray *itemsJSON = [resDic objectForKey:@"list"];
            
            NSMutableArray *statusArray = nil;
            
            if ([itemsJSON count] > 0)
            {
                statusArray = [NSMutableArray arrayWithCapacity:0];
                for (NSInteger i = 0; i < [itemsJSON count]; i++)
                {
                    WLStatusInfo *info = [WLStatusInfo parseFromNetworkJSON:[itemsJSON objectAtIndex:i]];
                    if (info != nil && info.picUrlList.count > 0 && info.contentList.count > 0)
                    {
                        [statusArray addObject:[itemsJSON objectAtIndex:i]];
                    }
                }
            }
            
            successed(statusArray);
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
