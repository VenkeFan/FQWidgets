//
//  GBTextEditParser.m
//  GBRichLabel
//
//  Created by gyb on 2018/4/19.
//  Copyright © 2018年 gyb. All rights reserved.
//

#import "WLTextEditParser.h"
#import "NSAttributedString+YYText.h"


static inline UIEdgeInsets UIEdgeInsetPixelFloor(UIEdgeInsets insets) {
    
    CGFloat scale = kScreenScale;
    insets.top = floor(insets.top * scale) / scale;
    insets.left = floor(insets.left * scale) / scale;
    insets.bottom = floor(insets.bottom * scale) / scale;
    insets.right = floor(insets.right * scale) / scale;
    return insets;
}


@implementation WLTextEditParser

- (instancetype)init {
    self = [super init];
    //初始化基本的样式
    _font = kRegularFont(14);
    _textColor = kPublishEditColor;
    _highlightTextColor = kClickableTextColor;
    
    return self;
}

//此函数为核心解析函数,当需求发生变化时更改此函数即可,请勿在此函数各类情况中添加设置颜色的代码
- (BOOL)parseText:(nullable NSMutableAttributedString *)text selectedRange:(nullable NSRangePointer)selectedRange withRange:(NSRange)keyRange
{
    //将所有字符都高亮
    [text addAttribute:NSForegroundColorAttributeName value:_textColor range:NSMakeRange(0, text.length)];
   
    //NSLog(@"======%@", text.string);
    
    NSRange realKeyRange = NSMakeRange((*selectedRange).location - keyRange.length, keyRange.length);
    
    NSString *key = [text.string substringWithRange:NSMakeRange((*selectedRange).location - keyRange.length, keyRange.length)];

    //在这里进行正则匹配,匹配emoji和链接
    NSArray *emojis = [self matcheInString:text.string regularExpressionWithPattern:emojiRegular]; //TODO:判断有问题
  //  NSLog(@"======%@", key);
  //  NSLog(@"======%lu====%lu",(unsigned long)(*selectedRange).location,(unsigned long)(*selectedRange).length);

    //topic
    if ([key hasPrefix:@"<topic=#"] && [key containsString:@"<topic=#"])
    {
        NSRange keyRange = NSMakeRange(7, key.length - 7);
        
        NSMutableAttributedString *replace = [[NSMutableAttributedString alloc] initWithString:[key substringWithRange:keyRange]];
        replace.yy_font = _font;
        [text replaceCharactersInRange:realKeyRange withAttributedString:replace];
        [text yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:YES] range:NSMakeRange(realKeyRange.location, replace.length)];
        
        if (selectedRange) {
            *selectedRange = [self _replaceTextInRange:realKeyRange withLength:keyRange.length selectedRange:*selectedRange];
        }
        
        //因为传过来的范围包含了最后一个空格符号,所以需要去掉
//        NSRange highLightRange = NSMakeRange(realKeyRange.location, realKeyRange.length);
//        [text yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:YES] range:highLightRange];
    }

    //@
   // if ([key hasPrefix:@"@"])
    if ([key hasPrefix:@"<mention=@"] && [key containsString:@"<mention=@"])
    {
         NSRange keyRange = NSMakeRange(9, key.length - 9);
        
        NSMutableAttributedString *replace = [[NSMutableAttributedString alloc] initWithString:[key substringWithRange:keyRange]];
        replace.yy_font = _font;
        [text replaceCharactersInRange:realKeyRange withAttributedString:replace];
        [text yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:YES] range:NSMakeRange(realKeyRange.location, replace.length)];

        if (selectedRange) {
            *selectedRange = [self _replaceTextInRange:realKeyRange withLength:keyRange.length selectedRange:*selectedRange];
        }
        
     
//        NSRange highLightRange = NSMakeRange(realKeyRange.location, realKeyRange.length);
//        [text yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:YES] range:highLightRange];
    }

    //link
    //如果输入链接则在发送时要匹配到链接并转换链接为range和.Web Link
    //如果直接插入.Web Link,则直接高亮记录记录即可
    //判断有没有连接,用于区分复制和加入链接
    
    if ([key containsString:@"•Web Links"] && [key containsString:@"<Link="])
    {
        UIImage *image = [AppContext getImageForKey:@"common_link"];
        
        //重新划定高亮范围
        NSRange keyRange = [key rangeOfString:@"•Web Links"];
        
        NSMutableAttributedString *replace = [[NSMutableAttributedString alloc] initWithString:[key substringWithRange:NSMakeRange(keyRange.location + 1, keyRange.length - 1)]];
        NSAttributedString *pic = [self _attachmentWithFontSize:_font.pointSize image:image shrink:NO];//[NSAttributedString yy_attachmentStringWithEmojiImage:image fontSize:15];//
        [replace insertAttributedString:pic atIndex:0];
        replace.yy_font = _font;
        
        
//        YYTextBackedString *backed = [YYTextBackedString stringWithString:@"•Web Links"];
//      NSMutableAttributedString *emoText = [NSAttributedString yy_attachmentStringWithEmojiImage:image fontSize:_font.pointSize].mutableCopy;
//        [replace yy_setTextBackedString:backed range:NSMakeRange(0, replace.length)];
        
        //复制功能目前设计不完善,只能先这样
        YYTextBackedString *backed = [YYTextBackedString stringWithString:@"•"];
        [replace yy_setTextBackedString:backed range:NSMakeRange(0, pic.length)];
        [text replaceCharactersInRange:NSMakeRange(realKeyRange.location + keyRange.location, key.length) withAttributedString:replace];//去掉后面的链接
        
        if (selectedRange) {
            *selectedRange = [self _replaceTextInRange:realKeyRange withLength:keyRange.length selectedRange:*selectedRange];
        }
        
        
        //高亮链接
        [text yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:YES] range:NSMakeRange(realKeyRange.location + keyRange.location, replace.length)];
    }


    //emoji
    if (emojis.count > 0)
    {
        NSUInteger clipLength = 0;
          for (NSTextCheckingResult *result in emojis)
          {
              if (result.range.location == NSNotFound && result.range.length <= 1) continue;
              NSRange range = result.range;
              range.location -= clipLength;
              if ([text yy_attribute:YYTextAttachmentAttributeName atIndex:range.location]) continue;
              NSString *emoString = [text.string substringWithRange:range];
              NSString *fileName = [NSString stringWithFormat:@"%@.png",[emoString substringWithRange:NSMakeRange(1, emoString.length - 2)]];
              UIImage *emojiImage = [UIImage imageNamed:fileName];
              if (!emojiImage) continue;
              
              YYTextBackedString *backed = [YYTextBackedString stringWithString:emoString];
              NSMutableAttributedString *emoText = [NSAttributedString yy_attachmentStringWithEmojiImage:emojiImage fontSize:_font.pointSize].mutableCopy;
              [emoText yy_setTextBackedString:backed range:NSMakeRange(0, emoText.length)];
              [emoText yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:NO] range:NSMakeRange(0, emoText.length)];
              [text replaceCharactersInRange:range withAttributedString:emoText];
              if (selectedRange) {
                  *selectedRange = [self _replaceTextInRange:range withLength:emoText.length selectedRange:*selectedRange];
              }
              clipLength += range.length - emoText.length;
          }
    }

    __weak typeof(self) weakSelf = self;
    
    [text enumerateAttribute:YYTextBindingAttributeName inRange:text.yy_rangeOfAll options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value && range.length > 1) {
            //将binding的字符都高亮一下
            [text addAttribute:NSForegroundColorAttributeName value:weakSelf.highlightTextColor range:range];
        }
    }];

    [text addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, text.length)];
    
    return YES;
}

// correct the selected range during text replacement
- (NSRange)_replaceTextInRange:(NSRange)range withLength:(NSUInteger)length selectedRange:(NSRange)selectedRange {
    // no change
    if (range.length == length) return selectedRange;
    // right
    if (range.location >= selectedRange.location + selectedRange.length) return selectedRange;
    // left
    if (selectedRange.location >= range.location + range.length) {
        selectedRange.location = selectedRange.location + length - range.length;
        return selectedRange;
    }
    // same
    if (NSEqualRanges(range, selectedRange)) {
        selectedRange.length = length;
        return selectedRange;
    }
    // one edge same
    if ((range.location == selectedRange.location && range.length < selectedRange.length) ||
        (range.location + range.length == selectedRange.location + selectedRange.length && range.length < selectedRange.length)) {
        selectedRange.length = selectedRange.length + length - range.length;
        return selectedRange;
    }
    selectedRange.location = range.location + length;
    selectedRange.length = 0;
    return selectedRange;
}


- (NSAttributedString *)_attachmentWithFontSize:(CGFloat)fontSize image:(UIImage *)image shrink:(BOOL)shrink {
    
    //    CGFloat ascent = YYEmojiGetAscentWithFontSize(fontSize);
    //    CGFloat descent = YYEmojiGetDescentWithFontSize(fontSize);
    //    CGRect bounding = YYEmojiGetGlyphBoundingRectWithFontSize(fontSize);
    
    CGFloat ascent = fontSize * 0.86;
    CGFloat descent = fontSize * 0.14;
    CGRect bounding = CGRectMake(0, -0.14 * fontSize, image.size.width, image.size.height);
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, descent + bounding.origin.y, 0);//changes here to add link flag1

    YYTextRunDelegate *delegate = [YYTextRunDelegate new];
    delegate.ascent = ascent;
    delegate.descent = descent;
    delegate.width = bounding.size.width;

    YYTextAttachment *attachment = [YYTextAttachment new];
    attachment.contentMode = UIViewContentModeScaleAspectFit;
    attachment.contentInsets = contentInsets;
    attachment.content = image;
    
    if (shrink) {
        CGFloat scale = 1 / 10.0;
        contentInsets.top += fontSize * scale;
        contentInsets.bottom += fontSize * scale;
        contentInsets.left += fontSize * scale;
        contentInsets.right += fontSize * scale;
        contentInsets = UIEdgeInsetPixelFloor(contentInsets);
        attachment.contentInsets = contentInsets;
    }
    
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:YYTextAttachmentToken];
    [atr addAttribute:YYTextAttachmentAttributeName value:attachment range:NSMakeRange(0, atr.length)];
    
    
    CTRunDelegateRef ctDelegate = delegate.CTRunDelegate;
     [atr addAttribute:(id)kCTRunDelegateAttributeName value:(__bridge id)ctDelegate range:NSMakeRange(0, atr.length)];
   // [atr setRunDelegate:ctDelegate range:NSMakeRange(0, atr.length)];
    if (ctDelegate) CFRelease(ctDelegate);
    
    return atr;
}


-(NSArray *)matcheInString:(NSString *)string regularExpressionWithPattern:(NSString *)regularExpressionWithPattern
{
    NSError *error;
    NSRange range = NSMakeRange(0,[string length]);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpressionWithPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray* matches = [regex matchesInString:string options:0 range:range];
    return matches;
}







@end
