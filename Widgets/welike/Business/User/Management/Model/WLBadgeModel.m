//
//  WLBadgeModel.m
//  welike
//
//  Created by fan qi on 2019/2/20.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLBadgeModel.h"

@implementation WLBadgeModel

+ (instancetype)parseWithNetworkJson:(NSDictionary *)json {
    if (!json) {
        return nil;
    }
    
    WLBadgeModel *model = [[WLBadgeModel alloc] init];
    model.beginTime = [json longLongForKey:@"beginTime" def:0];
    model.endTime = [json longLongForKey:@"endTime" def:0];
    model.receivedTime = [json longLongForKey:@"receivedTime" def:0];
    model.expired = [json boolForKey:@"expired" def:NO];
    model.have = [json boolForKey:@"have" def:NO];
    model.weard = [json boolForKey:@"weard" def:NO];
    model.type = (WLBadgeModelType)[json integerForKey:@"type" def:1];
    model.index = [json integerForKey:@"index" def:0] - 1;
    model.ID = [json stringForKey:@"id"];
    model.name = [json stringForKey:@"name"];
    model.desc = [json stringForKey:@"desc"];
    model.forwardUrl = [json stringForKey:@"forwardUrl"];
    model.iconUrl = [json stringForKey:@"iconUrl"];
    
    return model;
}

@end
