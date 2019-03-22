//
//  WLRichContent.m
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRichContent.h"
#import "WLRichItem.h"
#import "NSDictionary+JSON.h"

@interface WLRichContent ()

+ (NSArray *)convertRichItemListToJSON:(NSArray *)richItemList;

@end

@implementation WLRichContent

- (WLRichContent *)copy
{
    WLRichContent *content = [[WLRichContent alloc] init];
    content.text = self.text;
    content.summary = self.summary;
    content.richItemList = [self copyRichItemList];
    return content;
}

- (NSArray *)copyRichItemList
{
    if ([self.richItemList count] > 0)
    {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[self.richItemList count]];
        for (NSInteger i = 0; i < [self.richItemList count]; i++)
        {
            WLRichItem *richItem = [self.richItemList objectAtIndex:i];
            [arr addObject:[richItem copy]];
        }
        return [NSArray arrayWithArray:arr];
    }
    return nil;
}

- (NSArray *)convertRichItemListToJSON
{
    return [WLRichContent convertRichItemListToJSON:self.richItemList];
}

+ (NSArray *)convertRichItemListToJSON:(NSArray *)richItemList
{
    if ([richItemList count] > 0)
    {
        NSMutableArray *jsonArr = [NSMutableArray arrayWithCapacity:[richItemList count]];
        for (NSInteger i = 0; i < [richItemList count]; i++)
        {
            WLRichItem *richItem = [richItemList objectAtIndex:i];
            NSMutableDictionary *itemJSON = [NSMutableDictionary dictionary];
            [itemJSON setObject:[richItem.type copy] forKey:@"type"];
            if ([richItem.source length] > 0)
            {
                [itemJSON setObject:[richItem.source copy] forKey:@"source"];
            }
            if ([richItem.rid length] > 0)
            {
                [itemJSON setObject:[richItem.rid copy] forKey:@"richId"];
            }
            [itemJSON setObject:[NSNumber numberWithInteger:richItem.index] forKey:@"index"];
            [itemJSON setObject:[NSNumber numberWithInteger:richItem.length] forKey:@"length"];
            if ([richItem.target length] > 0)
            {
                [itemJSON setObject:[richItem.target copy] forKey:@"target"];
            }
            else
            {
                [itemJSON setObject:@"" forKey:@"target"];
            }
            if ([richItem.display length] > 0)
            {
                [itemJSON setObject:[richItem.display copy] forKey:@"display"];
            }
            if ([richItem.title length] > 0)
            {
                [itemJSON setObject:[richItem.title copy] forKey:@"title"];
            }
            else
            {
                [itemJSON setObject:@"" forKey:@"title"];
            }
            if ([richItem.icon length] > 0)
            {
                [itemJSON setObject:[richItem.icon copy] forKey:@"icon"];
            }
            else
            {
                [itemJSON setObject:@"" forKey:@"icon"];
            }
            [jsonArr addObject:itemJSON];
        }
        return jsonArr;
    }
    return nil;
}

+ (NSArray *)convertJSONToRichItemList:(NSArray *)jsonArr
{
    if ([jsonArr count] > 0)
    {
        NSMutableArray *richItemList = [NSMutableArray arrayWithCapacity:[jsonArr count]];
        for (NSInteger i = 0; i < [jsonArr count]; i++)
        {
            NSDictionary *item = [jsonArr objectAtIndex:i];
            WLRichItem *richItem = [[WLRichItem alloc] init];
            richItem.type = [item stringForKey:@"type"];
            richItem.source = [item stringForKey:@"source"];
            richItem.rid = [item stringForKey:@"richId"];
            richItem.index = [item integerForKey:@"index" def:0];
            richItem.length = [item integerForKey:@"length" def:0];
            richItem.target = [item stringForKey:@"target"];
            richItem.display = [item stringForKey:@"display"];
            richItem.title = [item stringForKey:@"title"];
            richItem.icon = [item stringForKey:@"icon"];
            [richItemList addObject:richItem];
        }
        return richItemList;
    }
    return nil;
}

@end
