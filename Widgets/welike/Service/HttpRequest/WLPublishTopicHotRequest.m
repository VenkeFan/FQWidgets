//
//  WLPublishTopicHotRequest.m
//  welike
//
//  Created by gyb on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPublishTopicHotRequest.h"
#import "WLTopicInfoModel.h"

@implementation WLPublishTopicHotRequest

- (instancetype)init
{
     return [super initWithType:AFHttpOperationTypeNormal api:@"conplay/topic/rank/topics" method:AFHttpOperationMethodGET];
}



- (void)tryPublishTopicHot:(void (^)(NSArray * topics))successed error:(failedBlock)error
{
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSMutableArray *posts = nil;
            NSDictionary *resDic = (NSDictionary *)result;
            id postsObj = [resDic objectForKey:@"list"];
            if ([postsObj isKindOfClass:[NSArray class]] == YES)
            {
                NSArray *postsJSON = (NSArray *)postsObj;
                posts = [NSMutableArray arrayWithCapacity:[postsJSON count]];
                for (NSInteger i = 0; i < [postsJSON count]; i++)
                {
                    WLTopicInfoModel *topicInfoModel = [WLTopicInfoModel parseFromNetworkJSON:[postsJSON objectAtIndex:i]];
                    
                    if (topicInfoModel.topicName.length != 0)
                    {
                        if ([topicInfoModel.topicName containsString:@"#"])
                        {
                            topicInfoModel.topicName = [topicInfoModel.topicName substringFromIndex:1];
                        }
                        
                        [posts addObject:topicInfoModel];
                    }
                }
            }
            if (successed)
            {
                successed(posts);
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
