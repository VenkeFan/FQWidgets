//
//  WLTopicInfoRequest.m
//  welike
//
//  Created by fan qi on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTopicInfoRequest.h"
#import "WLPostBase.h"
#import "WLTopicInfoModel.h"
#import "WLAccountManager.h"

@implementation WLTopicInfoRequest

- (instancetype)initWithTopicID:(NSString *)topicID {
    
    if ([[[AppContext getInstance] accountManager] isLogin])
    {
         return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"conplay/topic/%@/detail", [topicID urlEncode:NSUTF8StringEncoding]] method:AFHttpOperationMethodGET];
    }
    else
    {
        
       return [super initWithType:AFHttpOperationTypeNormal api:[NSString stringWithFormat:@"conplay/topic/h5/%@/detail", [topicID urlEncode:NSUTF8StringEncoding]] method:AFHttpOperationMethodGET];
    }
}

- (void)fetchTopicInfoWithSucceed:(requsetSuccessed)succeed failed:(failedBlock)failed {
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]]) {
            WLTopicInfoModel *topic = nil;
            WLPostBase *topPost = nil;
            
            id topicJson = result[@"topicRes"];
            if ([topicJson isKindOfClass:[NSDictionary class]]) {
                topic = [WLTopicInfoModel parseFromNetworkJSON:topicJson];
            }
            
            id postJson = result[@"postRes"];
            if ([postJson isKindOfClass:[NSDictionary class]]) {
                topPost = [WLPostBase parseFromNetworkJSON:result[@"postRes"]];
                topPost.trackerSource = WLTrackerFeedSource_Topic_Top;
            }
            
            if (topic) {
                if (succeed) {
                    succeed(topic, topPost);
                }
            } else {
                if (failed) {
                    failed(ERROR_NETWORK_RESP_INVALID);
                }
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
