//
//  WLTopicResidentRequest.m
//  welike
//
//  Created by fan qi on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTopicResidentRequest.h"
#import "WLTopicInfoModel.h"

@implementation WLTopicResidentRequest

- (instancetype)init {
    if ([AppContext getInstance].accountManager.isLogin) {
        return [super initWithType:AFHttpOperationTypeNormal api:@"conplay/topic/resident/topics/" method:AFHttpOperationMethodGET];
    } else {
        return [super initWithType:AFHttpOperationTypeNormal api:@"conplay/topic/resident/skip/topics/4" method:AFHttpOperationMethodGET];
    }
}

- (void)fetchResidentTopicWithSucceed:(topicResidentSuccessed)succeed failed:(failedBlock)failed {
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resDic = (NSDictionary *)result;
            id topicsObj = [resDic objectForKey:@"list"];
            NSMutableArray *topicArray = nil;
            
            if ([topicsObj isKindOfClass:[NSArray class]] == YES)
            {
                NSArray *topicsJSON = (NSArray *)topicsObj;
                topicArray = [NSMutableArray arrayWithCapacity:[topicsJSON count]];
                for (NSInteger i = 0; i < [topicsJSON count]; i++)
                {
                    WLTopicInfoModel *topic = [WLTopicInfoModel parseFromNetworkJSON:topicsJSON[i]];
                    [topicArray addObject:topic];
                }
            }
            
            if (succeed) {
                succeed(topicArray);
            }
            
        } else {
            if (failed) {
                failed(ERROR_NETWORK_RESP_INVALID);
            }
        }
    };
    self.onFailed = failed;
    [self sendQuery];
}

@end
