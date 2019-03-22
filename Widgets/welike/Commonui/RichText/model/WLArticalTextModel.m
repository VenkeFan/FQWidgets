//
//  WLArticalTextModel.m
//  welike
//
//  Created by gyb on 2019/1/24.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLArticalTextModel.h"
#import "WLTextParse.h"
#import "TYTextRender.h"
#import "WLRichItem.h"

@implementation WLArticalTextModel

-(void)handleRichModel:(NSString *)text
{
    if (!text || text.length == 0)
    {
        return;
    }
    
    _urlArray = [NSMutableArray arrayWithCapacity:0];
    
   // [self parseAllKeywords:text];
    
   // [self calculateHegihtAndAttributedString:text];
}

//-(void)parseAllKeywords:(NSString *)text
//{
//   // self.urlArray = [WLTextParse keywordRangesOfURLInString:richContent.richItemList];
//
//
//  //  self.urlArray = [WLTextParse urlsInString:text];
//
//}


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
}

@end
