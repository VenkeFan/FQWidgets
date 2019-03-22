//
//  WLLocationInfo.m
//  welike
//
//  Created by gyb on 2018/5/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLocationInfo.h"

@implementation WLLocationInfo


+ (WLLocationInfo *)parseFromNetworkJSON:(NSDictionary *)json
{
    if (json == nil) return nil;
    
    WLLocationInfo *info = [[WLLocationInfo alloc] init];
    info.placeId = [json stringForKey:@"placeId"];
    info.name = [json stringForKey:@"name"];
    info.photo = [json stringForKey:@"photo"];
    info.lat = [json floatForKey:@"lat" def:0];
    info.lng = [json floatForKey:@"lng" def:0];
    info.feedCount = [json integerForKey:@"feedCount" def:0];
    info.userCount = [json integerForKey:@"userCount" def:0];
    
    return info;
}




@end


