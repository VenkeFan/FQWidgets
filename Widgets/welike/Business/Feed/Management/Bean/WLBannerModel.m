//
//  WLBannerModel.m
//  welike
//
//  Created by fan qi on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLBannerModel.h"
#import "NSDictionary+JSON.h"

#define KEY_WLBANNER_LINKURL                       @"forwardUrl"
#define KEY_WLBANNER_PICURL                        @"picUrl"

@implementation WLBannerModel

+ (WLBannerModel *)parseFromNetworkJSON:(NSDictionary *)json {
    if (json == nil) return nil;
    
    WLBannerModel *banner = [[WLBannerModel alloc] init];
    banner.ID = [json stringForKey:@"id"];
    banner.lang = [json stringForKey:@"la"];
    banner.linkUrl = [[json stringForKey:KEY_WLBANNER_LINKURL] convertToHttps];
    banner.picUrl = [[json stringForKey:KEY_WLBANNER_PICURL] convertToHttps];
    
    return banner;
}

@end
