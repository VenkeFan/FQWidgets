//
//  WLSearchTopicRequest.m
//  welike
//
//  Created by gyb on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchTopicRequest.h"
#import "WLTopicInfoModel.h"

@implementation WLSearchTopicRequest {
    NSString *topicKeyword;
}

- (instancetype)initWithTopicKeyWord:(NSString *)keyword
{
    topicKeyword = [keyword copy];
    return [super initWithType:AFHttpOperationTypeNormal api:@"search/topic/name" method:AFHttpOperationMethodGET];
}


- (void)searchRecommandTopics:(void (^)(NSArray * topics))successed error:(failedBlock)error
{
    [self.params removeAllObjects];
    
    [self.params setObject:[NSNumber numberWithInteger:0] forKey:@"pageNumber"];
    [self.params setObject:[NSNumber numberWithInteger:RECOMMAND_TOPIC_NUM] forKey:@"count"];
    [self.params setObject:topicKeyword forKey:@"query"];
    
    self.onSuccessed = ^(id result) {
        if ([result isKindOfClass:[NSDictionary class]] == YES)
        {
            NSMutableArray *posts = nil;
            NSDictionary *resDic = (NSDictionary *)result;
            id postsObj = [resDic objectForKey:@"topics"];
            if ([postsObj isKindOfClass:[NSArray class]] == YES)
            {
                NSArray *postsJSON = (NSArray *)postsObj;
                posts = [NSMutableArray arrayWithCapacity:[postsJSON count]];
                for (NSInteger i = 0; i < [postsJSON count]; i++)
                {
                    WLTopicInfoModel *topicInfoModel = [WLTopicInfoModel parseFromNetworkJSON:[postsJSON objectAtIndex:i]];
                    [posts addObject:topicInfoModel];
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
