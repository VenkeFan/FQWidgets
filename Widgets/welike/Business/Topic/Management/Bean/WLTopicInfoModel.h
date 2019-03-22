//
//  WLTopicInfoModel.h
//  welike
//
//  Created by fan qi on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLPostBase;

@interface WLTopicInfoModel : NSObject

@property (nonatomic, copy) NSString *bannerUrl;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *topicID; //不带#
@property (nonatomic, copy) NSString *topicName; //带#
@property (nonatomic, copy) NSString *icon; //带#
@property (nonatomic, assign) long long created;
@property (nonatomic, assign) NSInteger postsCount;
@property (nonatomic, assign) NSInteger usersCount;
@property (nonatomic, strong) NSMutableArray *postArray;
@property (nonatomic, assign) NSInteger viewsCount;
//track
@property (nonatomic, assign) WLTopic_source topic_source;


+ (WLTopicInfoModel *)parseFromNetworkJSON:(NSDictionary *)json;

@end
