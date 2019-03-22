//
//  WLVerticalItem.m
//  welike
//
//  Created by gyb on 2018/7/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLVerticalItem.h"

@implementation WLVerticalItem

+ (WLVerticalItem *)parseFromNetworkJSON:(NSDictionary *)json
{
    if (json == nil) return nil;
    
    WLVerticalItem *verticalItem = [[WLVerticalItem alloc] init];
    verticalItem.verticalId =  [json stringForKey:@"id"];
    verticalItem.icon = [[json stringForKey:@"icon"] convertToHttps];
    verticalItem.name = [json stringForKey:@"name"];
    verticalItem.isDefault =  [json boolForKey:@"isDefault" def:0];
    verticalItem.labelOrder = [json integerForKey:@"labelOrder" def:0];
    verticalItem.isSelected = NO;
    
    return verticalItem;
}

@end
