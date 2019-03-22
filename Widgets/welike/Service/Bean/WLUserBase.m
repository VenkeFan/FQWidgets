//
//  WLUserBase.m
//  welike
//
//  Created by 刘斌 on 2018/4/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUserBase.h"

@implementation WLUserBase

@end

@implementation WLUserLinkModel

+ (instancetype)parseWithNetworkJson:(NSDictionary *)json {
    if (!json) {
        return nil;
    }
    
    WLUserLinkModel *model = [[WLUserLinkModel alloc] init];
    model.linkId = [json stringForKey:@"linkId"];
    model.linkType = (WLUserLinkType)[json integerForKey:@"linkType" def:0];
    model.link = [json stringForKey:@"link"];
    return model;
}

@end

@implementation WLUserHonorModel

+ (instancetype)parseWithNetworkJson:(NSDictionary *)json {
    if (!json) {
        return nil;
    }
    
    WLUserHonorModel *model = [[WLUserHonorModel alloc] init];
    model.ID = [json stringForKey:@"id"];
    model.picUrl = [json stringForKey:@"honorPic"];
    model.forwardUrl = [json stringForKey:@"forwardUrl"];
    model.index = [json integerForKey:@"index" def:0];
    model.type = [json integerForKey:@"type" def:0];
    return model;
}

+ (NSArray<WLUserHonorModel *> *)honorsFromNetworkJSON:(NSArray *)honorJsons {
    if (honorJsons.count > 0) {
        NSMutableArray<WLUserHonorModel *> *honorArray = [NSMutableArray array];
        
        for (int i = 0; i < honorJsons.count; i++) {
            WLUserHonorModel *model = [WLUserHonorModel parseWithNetworkJson:honorJsons[i]];
            if (model) {
                [honorArray addObject:model];
            }
        }
        
        [honorArray sortUsingComparator:^NSComparisonResult(WLUserHonorModel *obj1, WLUserHonorModel *obj2) {
            return obj1.index > obj2.index;
        }];
        
        return honorArray;
    }
    return nil;
}

@end
