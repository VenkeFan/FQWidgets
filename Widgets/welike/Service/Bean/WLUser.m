//
//  WLUser.m
//  welike
//
//  Created by 刘斌 on 2018/4/25.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUser.h"
#import "NSDictionary+JSON.h"

@implementation WLUser

+ (WLUser *)parseFromNetworkJSON:(NSDictionary *)json
{
    if (json == nil) return nil;
    
    WLUser *user = [[WLUser alloc] init];
    user.uid = [json stringForKey:@"id"];
    user.nickName = [json stringForKey:@"nickName"];
    user.followUsersCount = [json integerForKey:@"followUsersCount" def:0];
    user.followedUsersCount = [json integerForKey:@"followedUsersCount" def:0];
    user.likedMyPostsCount = [json integerForKey:@"likedCount" def:0];
    user.myLikedPostsCount = [json integerForKey:@"likePostsCount" def:0];
    user.postsCount = [json integerForKey:@"postsCount" def:0];
    user.gender = (WELIKE_USER_GENDER)[json integerForKey:@"sex" def:-1];
    user.headUrl = [[json stringForKey:@"avatarUrl"] convertToHttps];
    user.following = [json boolForKey:@"follow" def:NO];
    user.follower = [json boolForKey:@"followed" def:NO];
    user.introduction = [json stringForKey:@"introduction"];
    user.superLikeExp = [json longLongForKey:@"exp" def:0];
    user.createdTime = [json longLongForKey:@"created" def:0];
    user.vip = [json integerForKey:@"vip" def:0];
    user.recentPostTime = [json longLongForKey:@"recentPostTime" def:0];
    user.type = [json integerForKey:@"type" def:WELIKE_USER_TYPE_GENERAL];
    user.links = [self linksFromNetworkJSON:[json objectForKey:USER_JSON_KEY_LINKS]];
    user.curLevel = (WLUserLevel)[json integerForKey:USER_JSON_KEY_LEVEL def:0];
    user.cover = [json stringForKey:@"coverPage"];
    user.canChangeCover = [json boolForKey:@"canChangeCoverPage" def:NO];
    user.honors = [WLUserHonorModel honorsFromNetworkJSON:[json objectForKey:@"userhonors"]];
    
    return user;
}

//兼容trending 列表中userid解析key值是id
+ (WLUser *)parseTrendingUsersFromNetworkJSON:(NSDictionary *)json
{
    if (json == nil) return nil;
    
    WLUser *user = [[WLUser alloc] init];
    user.uid = [json stringForKey:@"userId"];
    user.nickName = [json stringForKey:@"nickName"];
    user.followUsersCount = [json integerForKey:@"followUsersCount" def:0];
    user.followedUsersCount = [json integerForKey:@"followedUsersCount" def:0];
    user.likedMyPostsCount = [json integerForKey:@"likedCount" def:0];
    user.myLikedPostsCount = [json integerForKey:@"likePostsCount" def:0];
    user.postsCount = [json integerForKey:@"postsCount" def:0];
    user.gender = (WELIKE_USER_GENDER)[json integerForKey:@"sex" def:-1];
    user.headUrl = [[json stringForKey:@"avatarUrl"] convertToHttps];
    user.following = [json boolForKey:@"follow" def:NO];
    user.follower = [json boolForKey:@"followed" def:NO];
    user.introduction = [json stringForKey:@"introduction"];
    user.superLikeExp = [json longLongForKey:@"exp" def:0];
    user.createdTime = [json longLongForKey:@"created" def:0];
    user.vip = [json integerForKey:@"vip" def:0];
    user.recentPostTime = [json longLongForKey:@"recentPostTime" def:0];
    user.type = [json integerForKey:@"type" def:WELIKE_USER_TYPE_GENERAL];
    user.links = [self linksFromNetworkJSON:[json objectForKey:USER_JSON_KEY_LINKS]];
    user.curLevel = (WLUserLevel)[json integerForKey:USER_JSON_KEY_LEVEL def:0];
    user.cover = [json stringForKey:@"coverPage"];
    user.canChangeCover = [json boolForKey:@"canChangeCoverPage" def:NO];
    user.honors = [WLUserHonorModel honorsFromNetworkJSON:[json objectForKey:@"userhonors"]];
    
    return user;
}

+ (NSArray *)linksFromNetworkJSON:(NSArray *)linkJsons {
    if (linkJsons.count > 0) {
        NSMutableArray *linkArray = [NSMutableArray array];
        for (int i = 0; i < linkJsons.count; i++) {
            WLUserLinkModel *linkModel = [WLUserLinkModel parseWithNetworkJson:linkJsons[i]];
            if (linkModel) {
                [linkArray addObject:linkModel];
            }
        }
        
        return linkArray;
    }
    return nil;
}

@end
