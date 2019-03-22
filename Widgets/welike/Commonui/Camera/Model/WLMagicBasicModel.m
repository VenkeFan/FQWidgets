//
//  WLMagicBasicModel.m
//  welike
//
//  Created by fan qi on 2018/11/27.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLMagicBasicModel.h"
#import "RDLocalizationManager.h"

@implementation WLMagicBasicModel

+ (instancetype)defaultModel {
    WLMagicBasicModel *model = [[WLMagicBasicModel alloc] init];
    model.ID = @"-1";
    model.groupID = @"-1";
    model.online = YES;
    return model;
}

+ (instancetype)parseWithNetworkJson:(NSDictionary *)json {
    if (!json) {
        return nil;
    }
    
    WLMagicBasicModel *model = [[WLMagicBasicModel alloc] init];
    model.ID = [json stringForKey:@"id"];
    model.groupID = [json stringForKey:@"groupid"];
    model.name = [model displayName:[json objectForKey:@"name"]];
    model.iconUrl = [[json stringForKey:@"iconurl"] convertToHttps];
    model.resourceUrl = [[json stringForKey:@"url"] convertToHttps];
    model.online = [json boolForKey:@"online" def:NO];
    model.localPath = nil;
    model.downloadProgress = 0;
    model.downloading = NO;
    
    return model;
}

- (NSString *)displayName:(NSArray *)jsonNames {
    NSString *displayName = nil;
    if (![jsonNames isKindOfClass:[NSArray class]]) {
        return displayName;
    }
    
    for (int i = 0; i < jsonNames.count; i++) {
        NSDictionary *dicName = jsonNames[i];
        displayName = [dicName objectForKey:[[RDLocalizationManager getInstance] getCurrentLanguage]];
        if (displayName.length == 0) {
            displayName = [dicName objectForKey:@"default"];
        }
    }
    
    return displayName;
}

- (BOOL)isDownloaded {
    if (self.localPath.length == 0) {
        return NO;
    }
    return YES;
}

@end
