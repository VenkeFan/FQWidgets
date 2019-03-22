//
//  WLLocationDetail.m
//  welike
//
//  Created by gyb on 2018/5/31.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLocationDetail.h"

@implementation WLLocationDetail

+ (WLLocationDetail *)parseFromNetworkJSON:(NSDictionary *)json
{
    if (json == nil) return nil;
    
    WLLocationDetail *info = [[WLLocationDetail alloc] init];
    info.placeName = [json stringForKey:@"placeName"];
    info.photo = [json stringForKey:@"photo"];
    info.feedCount = [json integerForKey:@"feedCount" def:0];
    info.userCount = [json integerForKey:@"userCount" def:0];
    
    return info;
}

@end
