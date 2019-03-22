//
//  WLStatusInfo.m
//  welike
//
//  Created by gyb on 2018/11/15.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLStatusInfo.h"

@implementation WLStatusInfo

+ (WLStatusInfo *)parseFromNetworkJSON:(NSDictionary *)json
{
    if (json == nil) return nil;
    
    WLStatusInfo *info = [[WLStatusInfo alloc] init];
    info.topic = [json stringForKey:@"topic"];
    info.text = [json stringForKey:@"text"];
    info.idStr = [json stringForKey:@"id"];
    
    if ([json.allKeys containsObject:@"contentList"])
    {
        info.contentList = [json objectForKey:@"contentList"];
    }
    if ([json.allKeys containsObject:@"picUrlList"])
    {
        info.picUrlList = [json objectForKey:@"picUrlList"];
    }
    
    return info;
}

@end

