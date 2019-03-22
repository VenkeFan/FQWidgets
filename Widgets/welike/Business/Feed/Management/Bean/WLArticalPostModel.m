//
//  WLArticalPostModel.m
//  welike
//
//  Created by gyb on 2019/1/19.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLArticalPostModel.h"
#import "WLRichItem.h"

@implementation WLArticalPostModel

- (instancetype)init {
    if (self = [super init]) {
        self.type = WELIKE_POST_TYPE_ARTICAL;
      
    }
    return self;
}

+ (instancetype)modelWithDic:(NSDictionary *)dic
{
    WLArticalPostModel *model = [[WLArticalPostModel alloc] init];

    // [WLPostBase parseFromNetworkJSON:dic];
    
    model.articalId = [dic stringForKey:@"id"];
    model.content = [dic stringForKey:@"content"];
    model.title = [dic stringForKey:@"title"];
    model.cover = [dic stringForKey:@"cover"];
    
    NSArray *attachList = [dic objectForKey:@"attachments"];
    model.attachments = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSInteger i = 0; i < [attachList count]; i++)
    {
        NSDictionary *itemDic = attachList[i];
        
        WLRichItem *item = [WLRichItem parseFromJSON:itemDic];
       
        [model.attachments addObject:item];
        
        if (model.cover.length == 0 &&
            ([item.type isEqualToString:WLRICH_TYPE_ARTICLE_IMAGE]
             || [item.type isEqualToString:WLRICH_TYPE_ARTICLE_VIDEO])) {
            model.cover = item.icon;
        }
    }
    
    model.created = [dic integerForKey:@"created" def:0];
    model.isDeleted = [dic boolForKey:@"deleted" def:NO];
    model.userInfo = [WLUser parseFromNetworkJSON:[dic objectForKey:@"user"]];
   
    return model;
}

@end
