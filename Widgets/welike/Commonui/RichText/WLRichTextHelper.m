//
//  WLRichTextHelper.m
//  welike
//
//  Created by gyb on 2018/5/9.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRichTextHelper.h"
#import "WLRichItem.h"
#import "YYText.h"
#import "WLTextParse.h"
#import "WLTopicInfoModel.h"

@implementation WLRichTextHelper


+(void)richTextToNormalItems:(NSAttributedString *)attributedText mentionArray:(NSArray *)mentionArray linkArray:(NSMutableArray *)linkArray topicArray:(NSMutableArray *)topicArray result:(void (^)(NSArray *))callback
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *itemsWithoutEmoji = [[NSMutableArray alloc] initWithCapacity:0];
     NSMutableArray *copylinkArray = [NSMutableArray arrayWithArray:linkArray];
     NSMutableArray *newAllItems = [[NSMutableArray alloc] initWithCapacity:0];
    if (attributedText.length == 0)
    {
        if(callback)
        {
            callback(items);
        }
    }
    else
    {
        NSString *plainText = [attributedText yy_plainTextForRange:NSMakeRange(0, attributedText.length)];
        NSArray *linkArray = [WLTextParse urlsInString:plainText];
        
        [attributedText enumerateAttribute:YYTextBindingAttributeName inRange:NSMakeRange(0, attributedText.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
            if (value)
            {
               // NSLog(@"range:%lu====%lu",(unsigned long)range.location,(unsigned long)range.length);
               // NSLog(@"=====%@",[attributedText yy_plainTextForRange:range]);
                
                NSString *keyStr = [attributedText yy_plainTextForRange:range];
                
                if ([keyStr hasPrefix:@"#"])
                {
                    //获取rid,如果获取不到,则设为nil
                    NSString *rid;
                    for (WLTopicInfoModel *info in topicArray)
                    {
                        if ([info.topicName isEqualToString:[keyStr substringFromIndex:1]])
                        {
                            rid = info.topicID;
                            break;
                        }
                    }
                    
                    WLRichItem *richItem = [[WLRichItem alloc] init];
                    richItem.type = WLRICH_TYPE_TOPIC;
                    richItem.source = keyStr;
                    richItem.rid = rid;
                    richItem.index = range.location;
                    richItem.length = range.length;
                    richItem.target = @"";
                    richItem.display = keyStr;
                    richItem.title = @"";
                    richItem.icon = @"";
                    
                    [items addObject:richItem];
                }
                if ([keyStr hasPrefix:@"@"])
                {
                    NSString *rid;
                    //for (NSDictionary *dic in mentionArray)
                    for(int i = 0; i< mentionArray.count; i++)
                    {
                        NSDictionary *dic = mentionArray[i];
                        NSString *name = [dic allKeys].firstObject;
                        if ([name isEqualToString:[keyStr substringFromIndex:1]])
                        {
                            rid = [dic objectForKey:name];
                            break;
                        }
                    }
                    
                    WLRichItem *richItem = [[WLRichItem alloc] init];
                    richItem.type = WLRICH_TYPE_MENTION;
                    richItem.source = keyStr;
                    richItem.rid = rid;
                    richItem.index = range.location;
                    richItem.length = range.length;
                    richItem.target = @"";
                    richItem.display = keyStr;
                    richItem.title = @"";
                    richItem.icon = @"";
                    [items addObject:richItem];
                }
                if ([keyStr containsString:@"Web Links"])
                {
                    WLRichItem *richItem = [[WLRichItem alloc] init];
                    richItem.type = WLRICH_TYPE_LINK;
                    richItem.source = copylinkArray.firstObject;
                    richItem.rid = @"";
                    richItem.index = range.location - 1;
                    richItem.length = range.length + 1;
                    richItem.target =  copylinkArray.firstObject;
                    richItem.display = @"•Web Links";
                    richItem.title = @"";
                    richItem.icon = @"";
                    [items addObject:richItem];
                    
                    [copylinkArray removeObject:copylinkArray.firstObject];
                }
            
                if ([self matcheInString:keyStr regularExpressionWithPattern:emojiRegular].count == 1) //TODO:此处判断有问题,需要对表情进行再次判断
                {
                    WLRichItem *richItem = [[WLRichItem alloc] init];
                    richItem.type = WLRICH_TYPE_EMOJI;
                    richItem.source = keyStr;
                    richItem.rid = @"";
                    richItem.index = 0;
                    richItem.length = 0;
                    richItem.target =  @"";
                    richItem.display = @"";
                    richItem.title = @"";
                    richItem.icon = @"";
                    [items addObject:richItem];
                }

            }
            
            if (range.length + range.location == attributedText.length)
            {
                //NSLog(@"rich text convers end");
                if(callback)
                {
                    for(int i = 0; i< items.count; i++)
                    {
                        WLRichItem *keywordModel = items[i];
                        NSString *key = keywordModel.source;
                        if ([keywordModel.type isEqual:WLRICH_TYPE_EMOJI])
                        {
                            for (int j = i+1; j< items.count; j++)
                            {
                                WLRichItem *richItemChange = items[j];
                                if (![richItemChange.type isEqual:WLRICH_TYPE_EMOJI])
                                {
                                    richItemChange.index = richItemChange.index + key.length - 1;
                                }
                            }
                        }
                    }
                    
                    for (WLRichItem *keywordModel in items)
                    {
                         if (![keywordModel.type isEqual:WLRICH_TYPE_EMOJI])
                         {
                             [itemsWithoutEmoji addObject:keywordModel];
                         }
                    }
                    
                    //在这里进行插入链接的操作
                    if (linkArray.count > 0)
                    {
                       // WLRichItem *insertItem = linkArray.firstObject;
                        
                        //取出原来所有的link
                        NSMutableArray *originalLinks = [[NSMutableArray alloc] initWithCapacity:0];
                        for (NSInteger i = itemsWithoutEmoji.count - 1; i >= 0; i -- )
                        {
                            WLRichItem *richItem = [itemsWithoutEmoji objectAtIndex:i];
                            if ([richItem.type isEqualToString:WLRICH_TYPE_LINK])
                            {
                                [originalLinks addObject:richItem];
                            }
                        }
                        
                        [originalLinks addObjectsFromArray:linkArray];
                        
                         NSMutableArray *newLinks = [[NSMutableArray alloc] initWithCapacity:0];
                        //进行重新排序,这里可以生成一个新的lins,后续用
                        for (int i = 0; i < 1000; i ++)
                        {
                            for (WLRichItem *item in originalLinks)
                            {
                                if (item.index == i)
                                {
                                    [newLinks addObject:item];
                                    break;
                                }
                            }
                        }
                        
                       // NSLog(@"new links:%@",[newLinks description]);
                        //从后往前重新计算
                        for (NSInteger j = newLinks.count - 1; j >= 0; j--)
                        {
                            WLRichItem *linkItem = newLinks[j];
                            if (![linkItem.display isEqualToString:@"•Web Links"])
                            {
                                linkItem.length = 10;
                                linkItem.display = @"•Web Links";
                                NSInteger chazhi = linkItem.source.length - 10;
                                
                                for (NSInteger h = itemsWithoutEmoji.count - 1; h >= 0; h--)
                                {
                                    WLRichItem *otherItem = [itemsWithoutEmoji objectAtIndex:h];
                                    if (otherItem.index > linkItem.index)
                                    {
                                        otherItem.index = otherItem.index - chazhi;
                                    }
                                }
                                
                                [itemsWithoutEmoji addObject:linkItem];
                            }
                        }
                        
                        
                        
                        //重新排序
                        for (int i = 0; i < 2000; i ++)
                        {
                            for (WLRichItem *item in itemsWithoutEmoji)
                            {
                                if (item.index == i)
                                {
                                    [newAllItems addObject:item];
                                    break;
                                }
                            }
                        }
                           callback(newAllItems);
                    }
                    else
                    {
                         callback(itemsWithoutEmoji);
                    }
                }
            }
        }];
    }
}

+(NSArray *)matcheInString:(NSString *)string regularExpressionWithPattern:(NSString *)regularExpressionWithPattern
{
    NSError *error;
    NSRange range = NSMakeRange(0,[string length]);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpressionWithPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray* matches = [regex matchesInString:string options:0 range:range];
    return matches;
}


+(void)allRichItems:(NSAttributedString *)attributedText mentionArray:(NSArray *)mentionArray linkArray:(NSMutableArray *)linkArray result:(void (^)(NSArray *))callback
{
     NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (attributedText.length == 0)
    {
        if(callback)
        {
            callback(items);
        }
    }
    else
    {
        [attributedText enumerateAttribute:YYTextBindingAttributeName inRange:NSMakeRange(0, attributedText.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
            if (value)
            {
                // NSLog(@"range:%lu====%lu",(unsigned long)range.location,(unsigned long)range.length);
                // NSLog(@"=====%@",[attributedText yy_plainTextForRange:range]);
                
                NSString *keyStr = [attributedText yy_plainTextForRange:range];
                
                if ([keyStr hasPrefix:@"#"])
                {
                    WLRichItem *richItem = [[WLRichItem alloc] init];
                    richItem.type = WLRICH_TYPE_TOPIC;
                    richItem.source = keyStr;
                    richItem.rid = keyStr;
                    richItem.index = range.location;
                    richItem.length = range.length;
                    richItem.target = @"";
                    richItem.display = keyStr;
                    richItem.title = @"";
                    richItem.icon = @"";
                    
                    [items addObject:richItem];
                }
                if ([keyStr hasPrefix:@"@"])
                {
                    NSString *rid;
                    //for (NSDictionary *dic in mentionArray)
                    for(int i = 0; i< mentionArray.count; i++)
                    {
                        NSDictionary *dic = mentionArray[i];
                        NSString *name = [dic allKeys].firstObject;
                        if ([name isEqualToString:[keyStr substringFromIndex:1]])
                        {
                            rid = [dic objectForKey:name];
                            break;
                        }
                    }
                    
                    WLRichItem *richItem = [[WLRichItem alloc] init];
                    richItem.type = WLRICH_TYPE_MENTION;
                    richItem.source = keyStr;
                    richItem.rid = rid;
                    richItem.index = range.location;
                    richItem.length = range.length;
                    richItem.target = @"";
                    richItem.display = keyStr;
                    richItem.title = @"";
                    richItem.icon = @"";
                    [items addObject:richItem];
                }
                if ([keyStr containsString:@"Web Links"])
                {
                    WLRichItem *richItem = [[WLRichItem alloc] init];
                    richItem.type = WLRICH_TYPE_LINK;
                    richItem.source = linkArray.firstObject;
                    richItem.rid = @"";
                    richItem.index = range.location - 1;
                    richItem.length = range.length + 1;
                    richItem.target =  linkArray.firstObject;
                    richItem.display = @"•Web Links";
                    richItem.title = @"";
                    richItem.icon = @"";
                    [items addObject:richItem];
                }
                
                if ([self matcheInString:keyStr regularExpressionWithPattern:emojiRegular].count == 1)
                {
                    WLRichItem *richItem = [[WLRichItem alloc] init];
                    richItem.type = WLRICH_TYPE_EMOJI;
                    richItem.source = keyStr;
                    richItem.rid = @"";
                    richItem.index = range.location;
                    richItem.length = range.length;
                    richItem.target =  @"";
                    richItem.display = @"";
                    richItem.title = @"";
                    richItem.icon = @"";
                    [items addObject:richItem];
                }
                
            }
            
            if (range.length + range.location == attributedText.length)
            {
                //NSLog(@"rich text convers end");
                if(callback)
                {
                    callback(items);
                }
            }
        }];
    }
}

+(WLRichContent *)mergeContentWithName:(NSString *)name content:(WLRichContent *)richContent
{
    WLRichContent *content = [[WLRichContent alloc] init];
    content.text = [NSString stringWithFormat:@"%@:%@",name,richContent.text];
    content.summary = richContent.summary;
    
    NSInteger newIndex = name.length + 1;
    
    WLRichContent *copyContent = [richContent copy];
    
    for (WLRichItem *item in copyContent.richItemList)
    {
        item.index = item.index + newIndex;
    }
    
    content.richItemList = copyContent.richItemList;
    
    return content;
}

+(NSString *)clipContentToIndicatelength:(NSInteger)length withContent:(WLRichContent *)richContent
{
    //首先计算出字符数是否已经超过length
    NSInteger contentlength = [WLRichTextHelper caculateRichContentLength:richContent];
    
    NSString *summaryStr;
    
    //若超过,则进行剪切
    if (contentlength > length)
    {
        if (richContent.richItemList == 0)
        {
            NSArray *emotionArray = [WLTextParse keywordRangesOfEmotionInString:richContent.text]; //emoji array
            //NSArray *linkArray = [WLTextParse matcheInString:richContent.text regularExpressionWithPattern:linkRegular]; //NSTextCheckingResult array
            
            NSInteger removeNum = contentlength - length;
            NSInteger i = richContent.text.length - 1;
            
            
            while (removeNum > 0)
            {
                BOOL isLinkOrEmoji = NO;
                for (WLRichItem *keywordModel in emotionArray)
                {
                    if (i >= keywordModel.index && i < (keywordModel.index + keywordModel.length))
                    {
                        removeNum -= 2;
                        isLinkOrEmoji = YES;
                        
                         i -= keywordModel.length;
                        
                        if (removeNum <= 0)
                        {
                            summaryStr = [richContent.text substringToIndex:i];
//                            NSLog(@"find rangge");
//                            NSLog(@"print%@",[richContent.text substringToIndex:i+1]);
                        }
                        else
                        {
                           
                        }
                        
                        break;
                    }
                }
                
                if (isLinkOrEmoji == NO)
                {
                    removeNum -= 1;
                
                    if (removeNum <= 0)
                    {
                         summaryStr = [richContent.text substringToIndex:i];
//                        NSLog(@"find range");
//                        NSLog(@"print%@",[richContent.text substringToIndex:i+1]);
                    }
                    else
                    {
                        i-=1;
                    }
                    
                }
            }
        }
        else
        {
            NSArray *emotionArray = [WLTextParse keywordRangesOfEmotionInString:richContent.text];
            NSInteger removeNum = contentlength - length;
            NSInteger i = richContent.text.length - 1;
             while (removeNum > 0)
             {
                 BOOL isRichItem = NO;
                 for (WLRichItem *keywordModel in emotionArray)
                 {
                     if (i >= keywordModel.index && i < (keywordModel.index + keywordModel.length))
                     {
                         removeNum -= 2;
                         isRichItem = YES;
                         
                         i -= keywordModel.length;
                         
                         if (removeNum <= 0)
                         {
                             summaryStr = [richContent.text substringToIndex:i];
//                             NSLog(@"1find rangge");
//                             NSLog(@"1print:%@",[richContent.text substringToIndex:i+1]);
                         }
                        
                         
                         break;
                     }
                 }
                 
                 for (WLRichItem *keywordModel in richContent.richItemList)
                 {
                     if (i >= keywordModel.index && i < (keywordModel.index + keywordModel.length))
                     {
                         if ([keywordModel.type isEqual: WLRICH_TYPE_MENTION] || [keywordModel.type  isEqual: WLRICH_TYPE_TOPIC])
                         {
                               removeNum -= 4;
                                i -= keywordModel.source.length;
                         }
                         
                         if ([keywordModel.type isEqual: WLRICH_TYPE_LINK])
                         {
                             removeNum -= 10;
                             i -= keywordModel.length;
                         }
                         
                         isRichItem = YES;
                         
                         if (removeNum <= 0)
                         {
                             summaryStr = [richContent.text substringToIndex:i];
//                             NSLog(@"2find rangge");
//                             NSLog(@"2print:%@",[richContent.text substringToIndex:i+1]);
                         }
                      
                         
                         break;
                     }
                 }
                 
                 if (isRichItem == NO)
                 {
                     removeNum -= 1;
                     //NSLog(@"remove char:%@",[richContent.text substringFromIndex:i]);
                     
                     if (removeNum <= 0)
                     {
                         summaryStr = [richContent.text substringToIndex:i];
//                         NSLog(@"3find rangge");
                         //NSLog(@"3print:%@",[richContent.text substringToIndex:i+1]);
                     }
                     else
                     {
                         i-=1;
                     }
                     
                 }
             }
        }
        
        return summaryStr;
    }
    else //若未超过,则不处理
    {
        return richContent.text;
    }

}


//计算富文本的长度
+(NSInteger)caculateRichContentLength:(WLRichContent *)richContent
{
    NSInteger contentLength = 0;
    
    if (richContent.richItemList == 0)
    {
       contentLength = [WLRichTextHelper caculateNormalTextLength:richContent.text];
    }
    else
    {
        for (int i = 0; i < richContent.richItemList.count; i++)
        {
            WLRichItem *richItem = richContent.richItemList[i];
            if (richItem.index > 0) //第一个左边有值
            {
                if (i == 0)
                {
                    NSString *itemStr = [richContent.text substringWithRange:NSMakeRange(0, richItem.index)];
                   
                    contentLength += [WLRichTextHelper caculateNormalTextLength:itemStr];
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_MENTION])
                    {
                        contentLength += 4;
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_LINK])
                    {
                         contentLength += 10;
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_MORE])
                    {
                        
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_TOPIC])
                    {
                        contentLength += 4;
                    }
                    
                }
                else
                {
                    WLRichItem *frontRichItem = richContent.richItemList[i - 1];
                    
                    if ( richItem.index < frontRichItem.index + frontRichItem.length ||  richItem.index - frontRichItem.index - frontRichItem.length < richContent.text.length)
                    {
                        break;
                    }
                    
                    NSString *itemStr = [richContent.text substringWithRange:NSMakeRange(frontRichItem.index + frontRichItem.length, richItem.index - frontRichItem.index - frontRichItem.length)];
                    
                    contentLength += [WLRichTextHelper caculateNormalTextLength:itemStr];
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_MENTION])
                    {
                        contentLength += 4;
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_LINK])
                    {
                        contentLength += 10;
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_MORE])
                    {
                        
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_TOPIC])
                    {
                        contentLength += 4;
                    }
                }
                
            }
            else  //==0  //第一个左边无值
            {
                if (i == 0)
                {
                    if ([richItem.type isEqual:WLRICH_TYPE_MENTION])
                    {
                         contentLength += 4;
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_LINK])
                    {
                        contentLength += 10;
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_MORE])
                    {
                        
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_TOPIC])
                    {
                        contentLength += 4;
                    }
                }
                else
                {
                    WLRichItem *frontRichItem = richContent.richItemList[i - 1];
                    
                    if ( richItem.index < frontRichItem.index + frontRichItem.length ||  richItem.index - frontRichItem.index - frontRichItem.length < richContent.text.length)
                    {
                        break;
                    }
                    
                      NSString *itemStr = [richContent.text substringWithRange:NSMakeRange(frontRichItem.index + frontRichItem.length, richItem.index - frontRichItem.index - frontRichItem.length)];
                    
                      contentLength += [WLRichTextHelper caculateNormalTextLength:itemStr];
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_MENTION])
                    {
                        contentLength += 4;
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_LINK])
                    {
                        contentLength += 10;
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_MORE])
                    {
                        
                    }
                    
                    if ([richItem.type isEqual:WLRICH_TYPE_TOPIC])
                    {
                          contentLength += 4;
                    }
                }
            }
            
            //最后一个item的右侧,还有值
            if (i == richContent.richItemList.count - 1)
            {
                NSString *itemStr = [richContent.text substringFromIndex:richItem.index + richItem.length];
                contentLength += [WLRichTextHelper caculateNormalTextLength:itemStr];
            }
        }
    }
    

    return contentLength;
}

//返回一个文本中的长度,包含链接和表情
+(NSInteger)caculateNormalTextLength:(NSString *)normalStr
{
      NSInteger contentLength = 0;
    
    NSArray *emotionArray = [WLTextParse keywordRangesOfEmotionInString:normalStr]; //emoji array
    NSArray *linkArray = [WLTextParse matcheInString:normalStr regularExpressionWithPattern:linkRegular]; //NSTextCheckingResult array
    
    contentLength = normalStr.length;
    
    for (WLRichItem *item in emotionArray)
    {
        if (item.display.length != 2)
        {
            contentLength -= (item.display.length - 2);
        }
    }
    
    for (NSTextCheckingResult *item in linkArray)
    {
        if (item.range.length != 10)
        {
            contentLength -= (item.range.length - 10);
        }
    }
    
      return contentLength;
}


+(void)removeSpaceAndHuanhang:(WLRichContent *)richContent
{
    NSMutableString *finalText = [NSMutableString stringWithString:richContent.text];
    
    //将所有的转义字符都进行替换
    [finalText replaceOccurrencesOfString:@"\r" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, finalText.length)];
    [finalText replaceOccurrencesOfString:@"\t" withString:@" "  options:NSCaseInsensitiveSearch range:NSMakeRange(0, finalText.length)];
    [finalText replaceOccurrencesOfString:@"\f" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, finalText.length)];
    [finalText replaceOccurrencesOfString:@"\v" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, finalText.length)];
    
    NSMutableArray *charArray = [WLRichTextHelper allHuanhang:finalText];
    
    //若无换行,则不处理
    if (charArray.count == 0)
    {
        return;
    }
    
    BOOL isDeleteSpaceEnd = NO;
    
    while (isDeleteSpaceEnd == NO)
    {
        charArray = [NSMutableArray arrayWithArray:[self allHuanhang:finalText]];
    
        for (int i = 0; i < charArray.count; i++)
        {
            NSInteger index = [charArray[i] integerValue];
            
            int j = 1;
            
            NSString *charStr = [finalText substringWithRange:NSMakeRange(index - j, 1)];
            
            while ([charStr isEqualToString:@" "])
            {
                j = j + 1;
                charStr = [finalText substringWithRange:NSMakeRange(index - j, 1)];
            }
            
          //  NSLog(@"==========%d",j);
            
            
            if (j > 1)
            {
                //去掉所有的/n前面的空格
                [finalText deleteCharactersInRange:NSMakeRange(index - j + 1, j - 1)];
                //NSLog(@"==========%@",finalText);
                
                isDeleteSpaceEnd = NO;
                
                for (int i = 0; i < richContent.richItemList.count; i++)
                {
                    WLRichItem *item = richContent.richItemList[i];
                    if (item.index > index)
                    {
                        item.index = item.index - (j - 1);
                    }
                }
                
                break;
            }
            else
            {
                //没有去掉空格,开始去除换行
                
                //isEnd = YES;
            }
            
            //当循环遍历结束时,则/n前面的空格都已经被清空,此时再去处理/n
            if (i == charArray.count - 1)
            {
                isDeleteSpaceEnd = YES;
            }
        }
    }
    
    //下面处理换行
    //处理多余的/n
    BOOL isHuanghangEnd = NO;
    
    while (isHuanghangEnd == NO)
    {
        charArray = [NSMutableArray arrayWithArray:[self allHuanhang:finalText]];
        
        for (int i = 0; i < charArray.count; i++)
        {
            NSInteger index = [charArray[i] integerValue];
            
            NSInteger chazhi = 0;
            
            for (int j = i + 1; j < charArray.count; j++)
            {
                NSInteger nextIndex = [charArray[j] integerValue];
                
                
                if (nextIndex - index == (j - i))
                {
                    //一次循环就到最后一个
                    if (j == charArray.count - 1)
                    {
                        chazhi = j - 1 - i;
                        [finalText deleteCharactersInRange:NSMakeRange(index + 2, chazhi)];
                        charArray = [NSMutableArray arrayWithArray:[self allHuanhang:finalText]];
                        
                        for (int z = 0; z < richContent.richItemList.count; z++)
                        {
                            WLRichItem *item = richContent.richItemList[z];
                            if (item.index > index+2)
                            {
                                item.index = item.index - chazhi;
                            }
                        }
                    
                    }
                    else
                    {
                        continue;
                    }
                }
                else
                {
                    if (j - i >=2)
                    {
                        //不连续的话就取差值
                        chazhi = j - 1 - i - 1;
                        [finalText deleteCharactersInRange:NSMakeRange(index + 2, chazhi)];
                        charArray = [NSMutableArray arrayWithArray:[self allHuanhang:finalText]];
//                        NSLog(@"这次循环最后一个");
                        
                        for (int z = 0; z < richContent.richItemList.count; z++)
                        {
                            WLRichItem *item = richContent.richItemList[z];
                            if (item.index > index + 2)
                            {
                                item.index = item.index - chazhi;
                            }
                        }
                        
                    }
                    
                    break;
                }
            }
            
            
            if (i == charArray.count - 1)
            {
                isHuanghangEnd = YES;
            }
        }
    }
    
    richContent.text = finalText;
}

//获取所有的
+ (NSMutableArray *)allHuanhang:(NSString *)str
{
    NSMutableArray *charArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    //拿到所有的\n的位置
    for (int i = 0; i < str.length; i++)
    {
        NSString *charStr = [str substringWithRange:NSMakeRange(i, 1)];
        
        if ([charStr isEqualToString:@"\n"])
        {
            [charArray addObject:[NSNumber numberWithInteger:i]];
        }
    }
    
    return charArray;
}

@end
