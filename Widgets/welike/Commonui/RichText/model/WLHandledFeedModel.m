//
//  WLHandledFeedModel.m
//  GBRichLabel
//
//  Created by gyb on 2018/4/16.
//  Copyright © 2018年 gyb. All rights reserved.
//

#import "WLHandledFeedModel.h"
#import "WLTextParse.h"
#import "TYTextRender.h"
#import "WLPostBase.h"
#import "WLRichContent.h"
#import "WLRichItem.h"


@implementation WLHandledFeedModel


-(void)handleRichModel:(WLRichContent *)richContent
{
    for (WLRichItem *item in richContent.richItemList)
    {
        //if (item.index < 0 || item.source.length == 0 || item.length == 0)
        if (item.index < 0  || item.length == 0)
        {
            return;
        }
    }
    
    if (_isSummaryDisplay)  //显示summary
    {
        [self parseAllKeywordsWithSummary:richContent];
    }
    else  //显示全部
    {
         [self parseAllKeywords:richContent];
    }
    
    [self calculateHegihtAndAttributedString:richContent];
    
}

-(void)parseAllKeywords:(WLRichContent *)richContent
{
    if (richContent.text.length > 0)
    {
        self.atPersonArray = [WLTextParse keywordRangesOfAtPersonInString:richContent.richItemList];
        self.urlArray = [WLTextParse keywordRangesOfURLInString:richContent.richItemList];
        self.topicArray = [WLTextParse keywordRangesOfSharpTrendInString:richContent.richItemList];
        self.emotionArray = [WLTextParse keywordRangesOfEmotionInString:richContent.text];
        self.articleArray = [WLTextParse keywordRangesOfArticalInString:richContent.richItemList];
    }
}

-(void)parseAllKeywordsWithSummary:(WLRichContent *)richContent
{
    if (richContent.text.length > 0)
    {
        self.atPersonArray = [WLTextParse keywordRangesOfAtPersonInString:richContent.richItemList];
        self.urlArray = [WLTextParse keywordRangesOfURLInString:richContent.richItemList];
        self.topicArray = [WLTextParse keywordRangesOfSharpTrendInString:richContent.richItemList];
        self.articleArray = [WLTextParse keywordRangesOfArticalInString:richContent.richItemList];
        
        if ([richContent.text isEqualToString:richContent.summary])
        {
            self.emotionArray = [WLTextParse keywordRangesOfEmotionInString:richContent.text];
        }
        else
        {
            if (richContent.summary.length > 0)
            {
                self.emotionArray = [WLTextParse keywordRangesOfEmotionInString:richContent.summary];
                
                NSMutableArray *newAtPersonArray = [[NSMutableArray alloc]  initWithCapacity:0];
                NSMutableArray *newUrlArray  = [[NSMutableArray alloc]  initWithCapacity:0];
                NSMutableArray *newTopicArray  = [[NSMutableArray alloc]  initWithCapacity:0];
                NSMutableArray *newArticalArray  = [[NSMutableArray alloc]  initWithCapacity:0];
                
                //在这里切掉超出summary范围的字符
                NSInteger lenght = richContent.summary.length;
                
                for (WLRichItem *item in self.atPersonArray)
                {
                    if (item.index + item.length <= lenght)
                    {
                        [newAtPersonArray addObject:item];
                    }
                }
                
                self.atPersonArray = newAtPersonArray;
                
                
                for (WLRichItem *item in self.urlArray)
                {
                    if (item.index + item.length <= lenght)
                    {
                        [newUrlArray addObject:item];
                    }
                }
                
                self.urlArray = newUrlArray;
                
                for (WLRichItem *item in self.topicArray)
                {
                    if (item.index + item.length <= lenght)
                    {
                        [newTopicArray addObject:item];
                    }
                }
                
                self.topicArray = newTopicArray;
                
                for (WLRichItem *item in self.articleArray)
                {
                    if (item.index + item.length <= lenght)
                    {
                        [newArticalArray addObject:item];
                    }
                }
            }
            else
            {
                self.emotionArray = [WLTextParse keywordRangesOfEmotionInString:richContent.text];
            }
        }
    }
}


-(void)calculateHegihtAndAttributedString:(WLRichContent *)richContent
{
    NSMutableAttributedString *text;
    
    
    if (_isSummaryDisplay)
    {
        if ([richContent.text isEqualToString:richContent.summary])
        {
            text = [[NSMutableAttributedString alloc]initWithString:richContent.text];
            text.ty_color = _textColor;
            
            if (_location.place.length > 0)
            {
                // publish_location@
                text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ %@ %@",richContent.text,@"•",_location.place,nil]];
                text.ty_color = _textColor;
                TYTextAttribute *textAttribute = [[TYTextAttribute alloc] init];
                textAttribute.color = kRichFontColor;
                TYTextHighlight *linkTextStorage = [[TYTextHighlight alloc]init];
                linkTextStorage.backgroundColor = kRichHightFontColor;
                linkTextStorage.userInfo = @{@"Location": _location.placeId};
                linkTextStorage.backgroudInset = UIEdgeInsetsMake(1, 12, 1, 3);
                [text addTextAttribute:textAttribute range:NSMakeRange(richContent.text.length + 1,_location.place.length + 2)];
                [text addTextHighlightAttribute:linkTextStorage range:NSMakeRange(richContent.text.length + 1, _location.place.length + 2)];
                
                TYTextAttachment *imageStorage = [[TYTextAttachment alloc]init];
                imageStorage.image = [AppContext getImageForKey:@"publish_location"];
                imageStorage.baseline = -2;
                [text replaceCharactersInRange:NSMakeRange(richContent.text.length + 1, 1) withAttributedString:[NSAttributedString attributedStringWithAttachment:imageStorage]];
            }
        }
        else
        {
            if (richContent.summary.length > 0)
            {
                if (_location.place.length > 0)
                {
                    text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@..%@ %@ %@",richContent.summary,[AppContext getStringForKey:@"feed_summary_more" fileName:@"feed"],@"•",_location.place,nil]];
                    text.ty_color = _textColor;
                    TYTextAttribute *textAttribute = [[TYTextAttribute alloc] init];
                    textAttribute.color = kRichFontColor;
                    TYTextHighlight *linkTextStorage = [[TYTextHighlight alloc]init];
                    linkTextStorage.backgroundColor = kRichHightFontColor;
                    linkTextStorage.userInfo = @{ @"MORE": @"MORE"};
                    linkTextStorage.backgroudInset = UIEdgeInsetsMake(1, 0, 1, 1);
                    [text addTextAttribute:textAttribute range:NSMakeRange(richContent.summary.length + 2, [AppContext getStringForKey:@"feed_summary_more" fileName:@"feed"].length)];
                    [text addTextHighlightAttribute:linkTextStorage range:NSMakeRange(richContent.summary.length + 2, [AppContext getStringForKey:@"feed_summary_more" fileName:@"feed"].length)];
                    
                    NSInteger moreLength = [AppContext getStringForKey:@"feed_summary_more" fileName:@"feed"].length;
                    
                  
                    TYTextHighlight *locationTextStorage = [[TYTextHighlight alloc]init];
                    locationTextStorage.backgroundColor = kRichHightFontColor;
                    locationTextStorage.userInfo = @{@"Location": _location.placeId};
                    locationTextStorage.backgroudInset = UIEdgeInsetsMake(1, 12, 1, 3);
                    [text addTextAttribute:textAttribute range:NSMakeRange(richContent.summary.length + 2 + moreLength + 1, _location.place.length + 2)];
                    [text addTextHighlightAttribute:locationTextStorage range:NSMakeRange(richContent.summary.length + 2 + moreLength + 1, _location.place.length + 2)];

                    TYTextAttachment *imageStorage = [[TYTextAttachment alloc]init];
                    imageStorage.image = [AppContext getImageForKey:@"publish_location"];
                    imageStorage.baseline = -2; 
                    [text replaceCharactersInRange:NSMakeRange(richContent.summary.length + 2 + moreLength + 1, 1) withAttributedString:[NSAttributedString attributedStringWithAttachment:imageStorage]];
                }
                else
                {
                    text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@..%@",richContent.summary,[AppContext getStringForKey:@"feed_summary_more" fileName:@"feed"],nil]];
                    text.ty_color = _textColor;
                    TYTextAttribute *textAttribute = [[TYTextAttribute alloc] init];
                    textAttribute.color = kRichFontColor;
                    TYTextHighlight *linkTextStorage = [[TYTextHighlight alloc]init];
                    linkTextStorage.backgroundColor = kRichHightFontColor;
                    linkTextStorage.userInfo = @{ @"MORE": @"MORE"};
                    linkTextStorage.backgroudInset = UIEdgeInsetsMake(1, 0, 1, 1);
                    [text addTextAttribute:textAttribute range:NSMakeRange(richContent.summary.length + 2, [AppContext getStringForKey:@"feed_summary_more" fileName:@"feed"].length)];
                    [text addTextHighlightAttribute:linkTextStorage range:NSMakeRange(richContent.summary.length + 2, [AppContext getStringForKey:@"feed_summary_more" fileName:@"feed"].length)];
                }
                
            }
            else
            {
                text = [[NSMutableAttributedString alloc]initWithString:richContent.text ?: @""];
                text.ty_color = _textColor;
                if (_location.place.length > 0)
                {
                    // publish_location@
                    text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ %@ %@",richContent.text,@"•",_location.place,nil]];
                    text.ty_color = _textColor;
                    TYTextAttribute *textAttribute = [[TYTextAttribute alloc] init];
                    textAttribute.color = kRichFontColor;
                    TYTextHighlight *linkTextStorage = [[TYTextHighlight alloc]init];
                    linkTextStorage.backgroundColor = kRichHightFontColor;
                    linkTextStorage.userInfo = @{@"Location": _location.placeId};
                    linkTextStorage.backgroudInset = UIEdgeInsetsMake(1, 12, 1, 3);
                    [text addTextAttribute:textAttribute range:NSMakeRange(richContent.text.length + 1,_location.place.length + 2)];
                    [text addTextHighlightAttribute:linkTextStorage range:NSMakeRange(richContent.text.length + 1, _location.place.length + 2)];
                    
                    TYTextAttachment *imageStorage = [[TYTextAttachment alloc]init];
                    imageStorage.image = [AppContext getImageForKey:@"publish_location"];
                    imageStorage.baseline = -2;
                    [text replaceCharactersInRange:NSMakeRange(richContent.text.length + 1, 1) withAttributedString:[NSAttributedString attributedStringWithAttachment:imageStorage]];
                }
            }
        }
    }
    else
    {
        text = [[NSMutableAttributedString alloc]initWithString:richContent.text];
        text.ty_color = _textColor;
        if (_location.place.length > 0) //添加位置到富文本
        {
            // publish_location@
            text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ %@ %@",richContent.text,@"•",_location.place,nil]];
            text.ty_color = _textColor;
            TYTextAttribute *textAttribute = [[TYTextAttribute alloc] init];
            textAttribute.color = kRichFontColor;
            TYTextHighlight *linkTextStorage = [[TYTextHighlight alloc]init];
            linkTextStorage.backgroundColor = kRichHightFontColor;
            linkTextStorage.userInfo = @{@"Location": _location.placeId};
            linkTextStorage.backgroudInset = UIEdgeInsetsMake(1, 12, 1, 3);
            [text addTextAttribute:textAttribute range:NSMakeRange(richContent.text.length + 1,_location.place.length + 2)];
            [text addTextHighlightAttribute:linkTextStorage range:NSMakeRange(richContent.text.length + 1, _location.place.length + 2)];
            
            TYTextAttachment *imageStorage = [[TYTextAttachment alloc]init];
            imageStorage.image = [AppContext getImageForKey:@"publish_location"];
            imageStorage.baseline = -2;
            [text replaceCharactersInRange:NSMakeRange(richContent.text.length + 1, 1) withAttributedString:[NSAttributedString attributedStringWithAttachment:imageStorage]];
        }

    }

    
    
    //二级评论使用
    if (_rangeOfSpecial.length > 0)
    {
        if (_rangeOfSpecial.location + _rangeOfSpecial.length <= richContent.text.length)
        {
            TYTextAttribute *textAttribute = [[TYTextAttribute alloc] init];
            textAttribute.color = kRichFontColor;
            [text addTextAttribute:textAttribute range:_rangeOfSpecial];
        }
    }
    
   
    
    //话题
    for (NSInteger i = 0; i < self.topicArray.count;++i)
    {
        WLRichItem *item = [self.topicArray objectAtIndex:i];
        
     //   NSString *topicWithoutBlankLeftAndRight = [[item.source substringFromIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        TYTextAttribute *textAttribute = [[TYTextAttribute alloc] init];
        textAttribute.color = kRichFontColor;
        TYTextHighlight *linkTextStorage = [[TYTextHighlight alloc]init];
        linkTextStorage.backgroundColor = kRichHightFontColor;
        
        if (item.index + item.length > richContent.text.length) //异常处理
        {
            break;
        }
        
        if (item.rid.length > 0)
        {
            linkTextStorage.userInfo = @{item.type:item.rid};
        }
        else
        {
            linkTextStorage.userInfo = @{item.type:[item.source substringFromIndex:1]};
        }
        
        linkTextStorage.backgroudInset = UIEdgeInsetsMake(1, 0, 1, 1);
        [text addTextAttribute:textAttribute range:NSMakeRange(item.index, item.length)];
        [text addTextHighlightAttribute:linkTextStorage range:NSMakeRange(item.index, item.length)];
    }
    
    //文章
    for (NSInteger i = 0; i < self.articleArray.count;++i)
    {
        WLRichItem *item = [self.articleArray objectAtIndex:i];
        
        //   NSString *topicWithoutBlankLeftAndRight = [[item.source substringFromIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        TYTextAttribute *textAttribute = [[TYTextAttribute alloc] init];
        textAttribute.color = kRichFontColor;
        TYTextHighlight *linkTextStorage = [[TYTextHighlight alloc]init];
        linkTextStorage.backgroundColor = kRichHightFontColor;
        linkTextStorage.userInfo = @{item.type:item.rid};
        if (item.index + item.length > richContent.text.length) //异常处理
        {
            break;
        }
        
        if (item.rid.length > 0)
        {
            linkTextStorage.userInfo = @{item.type:item.rid};
        }
     
        
        linkTextStorage.backgroudInset = UIEdgeInsetsMake(1, 0, 1, 1);
        [text addTextAttribute:textAttribute range:NSMakeRange(item.index, item.length)];
        [text addTextHighlightAttribute:linkTextStorage range:NSMakeRange(item.index, item.length)];
    }
    
    
    //提到
    for (NSInteger i = 0; i < self.atPersonArray.count;++i)
    {
        WLRichItem *item = [self.atPersonArray objectAtIndex:i];
        
        TYTextAttribute *textAttribute = [[TYTextAttribute alloc]init];
        textAttribute.color = kRichFontColor;
        TYTextHighlight *linkTextStorage = [[TYTextHighlight alloc]init];
        linkTextStorage.backgroundColor = kRichHightFontColor;
        linkTextStorage.userInfo = @{item.type:item.rid};
        linkTextStorage.backgroudInset = UIEdgeInsetsMake(1, 0, 1, 1);
        
        if (item.index + item.length > richContent.text.length) //异常处理
        {
            break;
        }
        
        [text addTextAttribute:textAttribute range:NSMakeRange(item.index, item.length)];
        [text addTextHighlightAttribute:linkTextStorage range:NSMakeRange(item.index, item.length)];
    }
    
    
    
    //链接
     for (NSInteger i = 0; i < self.urlArray.count;++i)
     {
      
         WLRichItem *item = [self.urlArray objectAtIndex:i];
         
         TYTextAttribute *textAttribute = [[TYTextAttribute alloc]init];
         textAttribute.color = kRichFontColor;
         TYTextHighlight *linkTextStorage = [[TYTextHighlight alloc]init];
         linkTextStorage.backgroundColor = kRichHightFontColor;
         linkTextStorage.userInfo = @{item.type:item.source};
         linkTextStorage.backgroudInset = UIEdgeInsetsMake(1, 0, 1, 1);
         //NSLog(@"%d",text.length);
         if (item.index + item.length > text.length)//异常处理
         {
             break;
         }
         [text addTextAttribute:textAttribute range:NSMakeRange(item.index + 1, item.length - 1)];
         [text addTextHighlightAttribute:linkTextStorage range:NSMakeRange(item.index + 1, item.length - 1)];
         
         TYTextAttachment *imageStorage = [[TYTextAttachment alloc]init];
         imageStorage.image = [AppContext getImageForKey:@"common_link"];
         imageStorage.baseline = -1;
         [text replaceCharactersInRange:NSMakeRange(item.index, 1) withAttributedString:[NSAttributedString attributedStringWithAttachment:imageStorage]];
     }
    
    
    
    //表情
    for (NSInteger i = self.emotionArray.count-1;i<self.emotionArray.count;--i)
    {
     
        WLRichItem *item = [self.emotionArray objectAtIndex:i];
        
        TYTextAttachment *imageStorage = [[TYTextAttachment alloc]init];
        imageStorage.image = [self imageScaledToSize:CGSizeMake(20,20) image:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",item.icon,nil]]];
        imageStorage.baseline = -4;
        [text replaceCharactersInRange:NSMakeRange(item.index, item.length) withAttributedString:[NSAttributedString attributedStringWithAttachment:imageStorage]];
    }
    
    
    
    
    
    text.ty_characterSpacing = 0;
    text.ty_lineSpacing = 2;
    text.ty_font = _font;

    
    _textRender = [[TYTextRender alloc] initWithAttributedText:text];
    _textRender.lineBreakMode = _lineBreakMode;
    _textRender.highlightBackgroudRadius = 3;
    _textRender.maximumNumberOfLines = _maxLineNum;
    _textRender.highlightBackgroudInset = UIEdgeInsetsMake(2, 0, 2, 1);
    if (_renderHeight == 0)
    {
        _textRender.size = CGSizeMake(_renderWidth, [_textRender textSizeWithRenderWidth:_renderWidth].height+2);
    }
    else
    {
        _textRender.size = CGSizeMake(_renderWidth, _renderHeight);
    }
    
    
    _richTextHeight = _textRender.size.height;
    
    
    self.atPersonArray = nil;
    self.emotionArray = nil;
    self.urlArray = nil;
    self.topicArray = nil;
}


- (UIImage *)imageScaledToSize:(CGSize)size image:(UIImage *)originalImage
{
 //   if (&UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(size, NO, 0);
//    else
//        UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, size.width, size.height),
                       originalImage.CGImage);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end
