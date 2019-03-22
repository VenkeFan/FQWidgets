//
//  WLAppinfoRequest.m
//  welike
//
//  Created by gyb on 2018/10/9.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLAppinfoRequest.h"

@implementation WLAppinfoRequest

- (instancetype)init
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"auth/version"]  method:AFHttpOperationMethodPOST];
}

- (void)requestAppinfoSuccess:(AppInfoRequestSuccessed)successed error:(failedBlock)error
{
     [self.params removeAllObjects];
    
        self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;

//            NSArray *itemsJSON = [resDic objectForKey:@"list"];
//            NSString *cursor = [resDic stringForKey:@"cursor"];
//
//            NSMutableArray *topics = nil;
//
//            if ([itemsJSON count] > 0)
//            {
//                topics = [NSMutableArray arrayWithCapacity:[itemsJSON count]];
//                for (NSInteger i = 0; i < [itemsJSON count]; i++)
//                {
//                    WLTopicInfoModel *info = [WLTopicInfoModel parseFromNetworkJSON:[itemsJSON objectAtIndex:i]];
//                    if (info != nil)
//                    {
//                        [topics addObject:info];
//                    }
//                }
//            }
//
            if (successed)
            {
                successed(resDic);
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
