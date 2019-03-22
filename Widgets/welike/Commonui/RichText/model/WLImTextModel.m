//
//  WLImTextModel.m
//  welike
//
//  Created by gyb on 2018/5/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLImTextModel.h"
#import "WLTextParse.h"
#import "TYTextRender.h"
#import "WLRichItem.h"


@implementation WLImTextModel

-(void)handleRichModel:(NSString *)text
{
    if (!text || text.length == 0)
    {
        return;
    }
    
    [self parseAllKeywords:text];
    
    [self calculateHegihtAndAttributedString:text];
}

-(void)parseAllKeywords:(NSString *)text
{
    self.urlArray = [WLTextParse urlsInString:text];
    
    self.emotionArray = [WLTextParse keywordRangesOfEmotionInString:text];
}


-(void)calculateHegihtAndAttributedString:(NSString *)text
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    
    //链接
    for (NSInteger i = 0; i < self.urlArray.count;++i)
    {
        
        WLRichItem *item = [self.urlArray objectAtIndex:i];
        
        TYTextAttribute *textAttribute = [[TYTextAttribute alloc]init];
        textAttribute.color = kRichFontColor;
        TYTextHighlight *linkTextStorage = [[TYTextHighlight alloc]init];
        linkTextStorage.backgroundColor = kRichHightFontColor;
        linkTextStorage.userInfo = @{item.type:item.target};
        linkTextStorage.backgroudInset = UIEdgeInsetsMake(1, 0, 1, 1);
        //NSLog(@"%d",text.length);
        if (item.index + item.length > text.length)
        {
            break;
        }
        [attributedString addTextAttribute:textAttribute range:NSMakeRange(item.index, item.length)];
        [attributedString addTextHighlightAttribute:linkTextStorage range:NSMakeRange(item.index, item.length)];
    }
    
    
    
    //表情
    for (NSInteger i = self.emotionArray.count-1;i<self.emotionArray.count;--i)
    {
        
        WLRichItem *item = [self.emotionArray objectAtIndex:i];
        
        TYTextAttachment *imageStorage = [[TYTextAttachment alloc]init];
        imageStorage.image = [self imageScaledToSize:CGSizeMake(20,20) image:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",item.icon,nil]]];
        imageStorage.baseline = -4;
        [attributedString replaceCharactersInRange:NSMakeRange(item.index, item.length) withAttributedString:[NSAttributedString attributedStringWithAttachment:imageStorage]];
    }
    
    attributedString.ty_characterSpacing = 0;
    attributedString.ty_lineSpacing = 3;
    attributedString.ty_font = _font;
    
    _textRender = [[TYTextRender alloc] initWithAttributedText:attributedString];
    _textRender.lineBreakMode = _lineBreakMode;
    _textRender.highlightBackgroudRadius = 3;
    _textRender.highlightBackgroudInset = UIEdgeInsetsMake(2, 0, 2, 1);
    _textRender.onlySetRenderSizeWillGetTextBounds = YES;
    
    if (_renderHeight == 0)
    {
        _textRender.size = CGSizeMake(_renderWidth, [_textRender textSizeWithRenderWidth:_renderWidth].height+2);
    }
    else
    {
        _textRender.size = CGSizeMake(_renderWidth, _renderHeight);
    }
    
    _richTextHeight = _textRender.size.height;
    
    
    self.emotionArray = nil;
    self.urlArray = nil;
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
