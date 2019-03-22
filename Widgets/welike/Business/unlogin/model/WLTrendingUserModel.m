//
//  WLTrendingUserModel.m
//  welike
//
//  Created by gyb on 2018/8/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTrendingUserModel.h"
#import "WLUser.h"

@implementation WLTrendingUserModel

+ (WLTrendingUserModel *)parseTrendingUserInfo:(NSDictionary *)info
{
    if (info == nil) return nil;
    
    WLTrendingUserModel *trendingUserModel = [[WLTrendingUserModel alloc] init];
    
    trendingUserModel.titleStr = [info stringForKey:@"title"];
    trendingUserModel.forwardUrl = [info stringForKey:@"forwardUrl"];
    trendingUserModel.users = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray *userArray = [info objectForKey:@"users"];
    
    for (int i = 0; i < userArray.count; i++)
    {
        WLUser *user = [WLUser parseTrendingUsersFromNetworkJSON:userArray[i]];
        [trendingUserModel.users addObject:user];
    }
    
    return trendingUserModel;
}



@end
