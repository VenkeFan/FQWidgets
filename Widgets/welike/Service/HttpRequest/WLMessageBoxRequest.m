//
//  WLMessageBoxRequest.m
//  welike
//
//  Created by 刘斌 on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLMessageBoxRequest.h"
#import "WLMsgBoxNotificationBase.h"
#import "NSDictionary+JSON.h"

@implementation WLMessageBoxRequest

- (id)initMessageBoxRequestWithUid:(NSString *)uid
{
    return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"im/user/%@/notifications", uid] method:AFHttpOperationMethodGET];
}

- (void)listWithType:(NSString *)messageBoxType cursor:(NSString *)cursor successed:(messageBoxSuccessed)successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    [self.params setObject:messageBoxType forKey:@"type"];
    if ([cursor length] > 0)
    {
        [self.params setObject:cursor forKey:@"cursor"];
    }
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSDictionary *resDic = (NSDictionary *)result;
            NSArray *listJSON = [resDic objectForKey:@"list"];
            NSString *cursor = [resDic stringForKey:@"cursor"];
            if ([listJSON count] > 0)
            {
                NSMutableArray *messages = [NSMutableArray arrayWithCapacity:[listJSON count]];
                for (NSInteger i = 0; i < [listJSON count]; i++)
                {
                    WLMsgBoxNotificationBase *notification = [WLMsgBoxNotificationBase parseFromNetworkJSON:[listJSON objectAtIndex:i]];
                    if (notification != nil)
                    {
                        [messages addObject:notification];
                    }
                }
                if (successed)
                {
                    successed(messages, cursor);
                }
            }
            else
            {
                if (successed)
                {
                    successed(nil, cursor);
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
