//
//  WLMagicFilterModel.m
//  welike
//
//  Created by fan qi on 2018/11/27.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLMagicFilterModel.h"

@implementation WLMagicFilterModel

+ (instancetype)defaultModel {
    WLMagicFilterModel *model = [super defaultModel];
    model.type = WLMagicBasicModelType_Filter;
    return model;
}

+ (instancetype)parseWithNetworkJson:(NSDictionary *)json {
    WLMagicFilterModel *model = [super parseWithNetworkJson:json];
    model.type = WLMagicBasicModelType_Filter;
    return model;
}

@end
