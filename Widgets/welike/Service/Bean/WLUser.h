//
//  WLUser.h
//  welike
//
//  Created by 刘斌 on 2018/4/25.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUserBase.h"

typedef NS_ENUM(NSInteger, WELIKE_USER_TYPE)
{
    WELIKE_USER_TYPE_GENERAL = 0,
    WELIKE_USER_TYPE_OFFICIAL = 1,
    WELIKE_USER_TYPE_OPERATION = 2,
    WELIKE_USER_TYPE_CUSTOMER = 3
};

@interface WLUser : WLUserBase

@property (nonatomic, assign) long long superLikeExp;
@property (nonatomic, assign) BOOL following;
@property (nonatomic, assign) BOOL follower;
@property (nonatomic, assign) long long createdTime;
@property (nonatomic, assign) long long recentPostTime;
@property (nonatomic, assign) WELIKE_USER_TYPE type;

+ (WLUser *)parseFromNetworkJSON:(NSDictionary *)json;

+ (WLUser *)parseTrendingUsersFromNetworkJSON:(NSDictionary *)json;


@end
