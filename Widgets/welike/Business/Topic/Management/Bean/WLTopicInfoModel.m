//
//  WLTopicInfoModel.m
//  welike
//
//  Created by fan qi on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTopicInfoModel.h"
#import "WLPostBase.h"
#import "NSDictionary+JSON.h"

@implementation WLTopicInfoModel

+ (WLTopicInfoModel *)parseFromNetworkJSON:(NSDictionary *)json
{
    if (json == nil) return nil;
    
    WLTopicInfoModel *topic = [[WLTopicInfoModel alloc] init];
    topic.bannerUrl = [[json stringForKey:@"bannerUrl"] convertToHttps];
    topic.desc = [json stringForKey:@"description"];
    topic.topicID = [json stringForKey:@"id"];
    topic.topicName = [json stringForKey:@"topicName"];
    topic.created = [json longLongForKey:@"created" def:0];
    topic.postsCount = [json integerForKey:@"postsCount" def:0];
    topic.usersCount = [json integerForKey:@"usersCount" def:0];
    topic.icon =  [json stringForKey:@"icon"];
    topic.viewsCount = [json integerForKey:@"viewNum" def:0];
    
    if ([json.allKeys containsObject:@"topPosts"])
    {
        NSArray *postsJson = [json objectForKey:@"topPosts"];
        
        topic.postArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (int i = 0; i < postsJson.count; i++)
        {
            WLPostBase *post = [WLPostBase parseFromNetworkJSON:[postsJson objectAtIndex:i]];
            post.trackerSource = WLTrackerFeedSource_Topic_Top;
            [topic.postArray addObject:post];
        }
    }
    
    return topic;
}

@end
