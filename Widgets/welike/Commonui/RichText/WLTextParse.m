//
//  WLTextParse.m
//  GBRichLabel
//
//  Created by gyb on 2018/4/14.
//  Copyright © 2018年 gyb. All rights reserved.
//

#import "WLTextParse.h"
#import "WLEmojiManager.h"
#import "WLRichItem.h"


@implementation WLTextParse


+ (NSArray *)keywordRangesOfAtPersonInString:(NSArray *)attachments
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (WLRichItem *item in attachments)
    {
        if ([item.type isEqualToString:WLRICH_TYPE_MENTION])
        {
            [array addObject:item];
        }
    }
    
    return array;
}


+ (NSArray *)keywordRangesOfEmotionInString:(NSString *)textStr
{
    NSArray* matches = [self matcheInString:textStr regularExpressionWithPattern:emojiRegular];
    NSMutableArray *array = [NSMutableArray array];
    
    NSArray *allEmoji =  [WLEmojiManager emotionsArray];
    
    for(NSTextCheckingResult* match in matches)
    {

        NSString *keyword = [self replacementStringForResult:match inString:textStr regularExpressionWithPattern:emojiRegular];
       
        WLRichItem *keywordModel = [[WLRichItem alloc] init];
        keywordModel.type = WLRICH_TYPE_EMOJI;
        keywordModel.display = keyword;
        keywordModel.index = [match range].location;
        keywordModel.length = [match range].length;
        keywordModel.icon = [keyword substringWithRange:NSMakeRange(1, keyword.length - 2)];
        keywordModel.target = @"";
        
        if ([allEmoji containsObject:keywordModel.icon])
        {
            [array addObject:keywordModel];
        }
    }
    return array;
}

//额外说明:链接前边的点号标记为[dot],也属于emoji范畴
+ (NSArray *)keywordRangesOfURLInString:(NSArray *)attachments
{
    NSMutableArray *array = [NSMutableArray array];
    
    
     for (WLRichItem *item in attachments)
    {
        if ([item.type isEqualToString:WLRICH_TYPE_LINK] && item.source.length > 0)
        {
            [array addObject:item];
        }
    }
    
    return array;
}

//从字符串中取出链接
+ (NSArray *)urlsInString:(NSString *)linkString
{
    NSArray *matches = [self matcheInString:linkString regularExpressionWithPattern:linkRegular];
    
     NSMutableArray *array = [NSMutableArray array];
    
     for(NSTextCheckingResult *match in matches)
     {
         NSString *keyword = [self replacementStringForResult:match inString:linkString regularExpressionWithPattern:linkRegular];
         
         WLRichItem *keywordModel = [[WLRichItem alloc] init];
         keywordModel.type = WLRICH_TYPE_LINK;
         keywordModel.source = keyword;
         keywordModel.display = @"";
         keywordModel.index = [match range].location;
         keywordModel.length = [match range].length;
         keywordModel.icon = @"";
         keywordModel.target = keyword;
         [array addObject:keywordModel];
     }
    
     return array;
}



+ (NSArray *)keywordRangesOfSharpTrendInString:(NSArray *)attachments
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (WLRichItem *item in attachments)
    {
         if ([item.type isEqualToString:WLRICH_TYPE_TOPIC])
        {
            [array addObject:item];
        }
    }
    
    return array;
}

+ (NSArray *)keywordRangesOfArticalInString:(NSArray *)attachments
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (WLRichItem *item in attachments)
    {
        if ([item.type isEqualToString:WLRICH_TYPE_ARTICLE] && item.source.length > 0)
        {
            [array addObject:item];
        }
    }
    
    return array;
}



+(NSArray *)matcheInString:(NSString *)string regularExpressionWithPattern:(NSString *)regularExpressionWithPattern
{
    NSError *error;
    NSRange range = NSMakeRange(0,[string length]);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpressionWithPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray* matches = [regex matchesInString:string options:0 range:range];
    return matches;
}

+(NSString *)replacementStringForResult:(NSTextCheckingResult *)result inString:(NSString *)string regularExpressionWithPattern:(NSString *)regularExpressionWithPattern
{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpressionWithPattern options:NSRegularExpressionCaseInsensitive error:&error];
    return   [regex replacementStringForResult:result inString:string offset:0 template:@"$0"];
}

@end
