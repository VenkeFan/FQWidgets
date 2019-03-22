//
//  WLMagicPasterModel.m
//  welike
//
//  Created by fan qi on 2018/11/27.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLMagicPasterModel.h"

@implementation WLMagicPasterModel

+ (instancetype)defaultModel {
    WLMagicPasterModel *model = [super defaultModel];
    model.type = WLMagicBasicModelType_Paster;
    return model;
}

+ (instancetype)parseWithNetworkJson:(NSDictionary *)json {
    WLMagicPasterModel *model = [super parseWithNetworkJson:json];
    model.type = WLMagicBasicModelType_Paster;
    return model;
}

@end
