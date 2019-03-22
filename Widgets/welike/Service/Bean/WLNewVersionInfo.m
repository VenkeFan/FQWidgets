//
//  WLNewVersionInfo.m
//  welike
//
//  Created by gyb on 2018/10/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNewVersionInfo.h"
#import "NSDictionary+JSON.h"

@implementation WLNewVersionInfo

+ (WLNewVersionInfo *)parseVersionInfo:(NSDictionary *)info
{
    if (info == nil) return nil;
    
    WLNewVersionInfo *trendingUserModel = [[WLNewVersionInfo alloc] init];
    
    trendingUserModel.versionId = [info stringForKey:@"id"];
    trendingUserModel.version = [info stringForKey:@"version"];
    trendingUserModel.operationSystem =  [info stringForKey:@"operationSystem"];
    trendingUserModel.updateType = [info  integerForKey:@"updateType" def:0];
    trendingUserModel.url = [info stringForKey:@"url"];
    trendingUserModel.language = [info stringForKey:@"language"];
    trendingUserModel.updateTitle = [info stringForKey:@"updateTitle"];
    trendingUserModel.updateContent = [info stringForKey:@"updateContent"];
    
    return trendingUserModel;
}




@end
