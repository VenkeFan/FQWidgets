//
//  WLRichItem.m
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRichItem.h"
#import "NSDictionary+JSON.h"

#define WLRICH_TEXT_ATTACHMENT_KEY_TYPE     @"type"
#define WLRICH_TEXT_ATTACHMENT_KEY_SOURCE   @"source"
#define WLRICH_TEXT_ATTACHMENT_KEY_INDEX    @"index"
#define WLRICH_TEXT_ATTACHMENT_KEY_LENGTH   @"length"
#define WLRICH_TEXT_ATTACHMENT_KEY_TARGET   @"target"
#define WLRICH_TEXT_ATTACHMENT_KEY_DISPLAY  @"display"
#define WLRICH_TEXT_ATTACHMENT_KEY_ID       @"richId"
#define WLRICH_TEXT_ATTACHMENT_KEY_TITLE    @"title"
#define WLRICH_TEXT_ATTACHMENT_KEY_ICON     @"icon"

@implementation WLRichItem

+ (WLRichItem *)parseFromJSON:(NSDictionary *)json
{
    if (json != nil)
    {
        WLRichItem *item = [[WLRichItem alloc] init];
        item.type = [json stringForKey:WLRICH_TEXT_ATTACHMENT_KEY_TYPE];
        item.source = [json stringForKey:WLRICH_TEXT_ATTACHMENT_KEY_SOURCE];
        item.rid = [json stringForKey:WLRICH_TEXT_ATTACHMENT_KEY_ID];
        item.index = [json integerForKey:WLRICH_TEXT_ATTACHMENT_KEY_INDEX def:0];
        item.length = [json integerForKey:WLRICH_TEXT_ATTACHMENT_KEY_LENGTH def:0];
        item.target = [json stringForKey:WLRICH_TEXT_ATTACHMENT_KEY_TARGET];
        item.display = [json stringForKey:WLRICH_TEXT_ATTACHMENT_KEY_DISPLAY];
        item.title = [json stringForKey:WLRICH_TEXT_ATTACHMENT_KEY_TITLE];
        item.icon = [[json stringForKey:WLRICH_TEXT_ATTACHMENT_KEY_ICON] convertToHttps];
        return item;
    }
    return nil;
}

- (WLRichItem *)copy
{
    WLRichItem *rich = [[WLRichItem alloc] init];
    rich.type = self.type;
    rich.source = self.source;
    rich.rid = self.rid;
    rich.index = self.index;
    rich.length = self.length;
    rich.target = self.target;
    rich.display = self.display;
    rich.title = self.title;
    rich.icon = self.icon;
    return rich;
}

@end
