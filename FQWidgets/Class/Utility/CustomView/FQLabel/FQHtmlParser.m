//
//  FQHtmlParser.m
//  FQWidgets
//
//  Created by fan qi on 2019/3/5.
//  Copyright © 2019 fan qi. All rights reserved.
//

#import "FQHtmlParser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <CoreText/CoreText.h>
#import "FQHtmlTextAttachment.h"
#import "FQHtmlRunDelegate.h"
#import "FQHtmlHighlight.h"

#define UrlFontColor        ([self.linkTextAttributes objectForKey:NSForegroundColorAttributeName] ?: kUIColorFromRGB(0x48779D))
#define RichTextViewBold    UIFontWeightHeavy

NSString * const FQCustomImageAttributeName  = @"FQCustomImageAttribute";
NSString * const FQCustomURLAttributeName    = @"FQCustomURLAttribute";
NSString * const MyCustomEmojiAttributeName  = @"FQCustomEmojiAttribute";

static NSString * const UrlNameKey      = @"name";
static NSString * const UrlLinkKey      = @"url";
static NSString * const EmojiNameKey    = @"emoji";

@interface FQHtmlParser ()

@property (nonatomic, strong, readwrite) NSString *html;
@property (nonatomic, strong, readwrite) NSAttributedString *attributedText;
@property (nonatomic, strong) NSMutableArray *highlightArrayM;

@end

@implementation FQHtmlParser

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (NSAttributedString *)attributedTextWithHtml:(NSString *)html {
    self.html = html;
    
    self.attributedText = [[NSAttributedString alloc] initWithString:html attributes:@{NSFontAttributeName: kRegularFont(16), NSForegroundColorAttributeName: kUIColorFromRGB(0x616161)}];
    
    self.attributedText = [self p_parseBoldHtmlString:self.attributedText];
    self.attributedText = [self p_parseUrlHtmlString:self.attributedText];
    self.attributedText = [self p_parseImgHtmlString:self.attributedText];
    //    [self parserEmoji:filterStr];
    self.attributedText = [self p_parseLineBreakHtmlString:self.attributedText];
    
    return self.attributedText;
}

#pragma mark - Private

- (BOOL)p_isBoldFont:(UIFont *)font {
    UIFontDescriptor *fontDescriptor = font.fontDescriptor;
    UIFontDescriptorSymbolicTraits fontDescriptorSymbolicTraits = fontDescriptor.symbolicTraits;
    BOOL isBold = (fontDescriptorSymbolicTraits & UIFontDescriptorTraitBold) != 0;
    
    return isBold;
}

- (NSMutableAttributedString *)p_parseBoldHtmlString:(NSAttributedString *)attrStr {
    NSMutableAttributedString *mutAttr = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
    
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"<b>[^<]*</b>"
                                                                             options:kNilOptions
                                                                               error:nil];
    NSArray<NSTextCheckingResult *> *resultArray = [regular matchesInString:attrStr.string
                                                                    options:kNilOptions
                                                                      range:NSMakeRange(0, attrStr.length)];
    
    NSInteger boldLength = 0;
    for (NSTextCheckingResult *result in resultArray) {
        if (result.range.location == NSNotFound || result.range.length < 1) {
            continue;
        }
        NSRange range = result.range;
        range.location -= boldLength;
        NSString *boldHtmlText = [mutAttr.string substringWithRange:range];
        NSString *boldText = [self p_filterHtml:boldHtmlText];
        NSRange boldTextRange = NSMakeRange(range.location, boldText.length);
        
        UIFont *font = [attrStr attribute:NSFontAttributeName atIndex:range.location effectiveRange:nil];
        [mutAttr replaceCharactersInRange:range withString:boldText];
        [mutAttr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:font.pointSize], NSForegroundColorAttributeName: [UIColor redColor]} range:boldTextRange];
        boldLength += range.length - boldText.length;
    }
    
    return mutAttr;
}

- (NSMutableAttributedString *)p_parseUrlHtmlString:(NSAttributedString *)attrStr {
    NSMutableAttributedString *mutAttr = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
    
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"<a[^<>]+>.+?</a>"
                                                                             options:kNilOptions
                                                                               error:nil];
    NSArray<NSTextCheckingResult *> *resultArray = [regular matchesInString:attrStr.string
                                                                    options:kNilOptions
                                                                      range:NSMakeRange(0, attrStr.length)];
    
    NSInteger urlLength = 0;
    for (NSTextCheckingResult *result in resultArray) {
        if (result.range.location == NSNotFound || result.range.length < 1) {
            continue;
        }
        NSRange range = result.range;
        range.location -= urlLength;
        NSString *urlHtmlText = [mutAttr.string substringWithRange:range];
        
        NSString *url = @"";
        if ([urlHtmlText containsString:@"href"]) {
            url = [self p_parseUrlLink:urlHtmlText];
        }
        if (url.length == 0) {
            continue;
        }
        
        NSString *urlText = [self p_filterHtml:urlHtmlText];
        if (urlText.length == 0) {
            urlText = @"网页链接";
            continue;
        }
        NSRange urlTextRange = NSMakeRange(range.location, urlText.length);
        
//        NSDictionary *dic = [self p_getCustomURLDictionary:urlText url:url];
//        if (!dic) {
//            continue;
//        }
        
        if (![url hasPrefix:@"http"] && ![url hasPrefix:@"https"]) {
            url = [NSString stringWithFormat:@"http://%@", url];
        }
        
        FQHtmlHighlight *hightlight = [FQHtmlHighlight new];
        hightlight.type = FQHtmlHighlightType_Link;
        hightlight.range = urlTextRange;
        hightlight.text = urlText;
        hightlight.linkUrl = url;
        [self.highlightArrayM addObject:hightlight];
        
        [mutAttr replaceCharactersInRange:range withString:hightlight.text];
        [mutAttr addAttributes:@{NSUnderlineStyleAttributeName: @(YES),
                                 NSForegroundColorAttributeName: UrlFontColor}
                         range:urlTextRange];
        
        urlLength += range.length - urlText.length;
    }
    
    return mutAttr;
}

- (NSMutableAttributedString *)p_parseImgHtmlString:(NSAttributedString *)attrStr {
    NSMutableAttributedString *mutAttr = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
    
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"<img(.*?)/>"
                                                                             options:kNilOptions
                                                                               error:nil];
    NSArray<NSTextCheckingResult *> *resultArray = [regular matchesInString:attrStr.string
                                                                    options:kNilOptions
                                                                      range:NSMakeRange(0, attrStr.length)];
    
    __block NSInteger imgLength = 0;
    for (NSTextCheckingResult *result in resultArray) {
        if (result.range.location == NSNotFound || result.range.length < 1) {
            continue;
        }
        NSRange range = result.range;
        range.location -= imgLength;
        NSString *imgHtmlText = [mutAttr.string substringWithRange:range];
        
        NSString *imgSrc = [self p_parseCustomImgSrc:imgHtmlText];
        
        if (imgSrc.length == 0) {
            continue;
        }
        
        UIImage *customImg = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imgSrc];
        if (!customImg) {
            customImg = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imgSrc];
        }
        
        if (!customImg) {
            CGSize size = [self p_parseCustomImgSize:imgSrc];
            customImg = [self p_redrawPlaceholderImgWithSize:size];
        }
        
        NSMutableAttributedString *imgAttr = [self p_parseCustomImage:customImg
                                                             imageUrl:imgSrc
                                                           imageRange:range];
        [mutAttr replaceCharactersInRange:range withAttributedString:imgAttr];
        imgLength += range.length - imgAttr.length;
        
        if (!customImg) {
            [self p_downWebImage:imgSrc];
        }
    }
    
    return mutAttr;
}

- (NSMutableAttributedString *)p_parseCustomImage:(UIImage *)image
                                         imageUrl:(NSString *)imageUrl
                                       imageRange:(NSRange)imageRange {
    unichar objectReplacementChar = 0xFFFC;
    NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString *imageText = [[NSMutableAttributedString alloc] initWithString:content];
    
    NSRange range = NSMakeRange(0, imageText.length);
    if (self.typingAttributes) {
        [imageText addAttributes:self.typingAttributes range:range];
    }
    
    FQHtmlHighlight *hightlight = [FQHtmlHighlight new];
    hightlight.type = FQHtmlHighlightType_Image;
    hightlight.range = NSMakeRange(imageRange.location, imageText.length);
    hightlight.imgUrl = imageUrl;
    [self.highlightArrayM addObject:hightlight];
    
    FQHtmlTextAttachment *attachment = [[FQHtmlTextAttachment alloc] init];
    attachment.image = image ?: [UIImage imageNamed:FQHtmlTextAttachmentPlaceholder];
    attachment.imgUrl = imageUrl;
    
    FQHtmlRunDelegate *delegate = [FQHtmlRunDelegate new];
    [self p_setDelegate:delegate attachment:attachment];
    
    [imageText addAttributes:@{FQCustomImageAttributeName: delegate,
                               (id)kCTRunDelegateAttributeName: (id)delegate.delegateRef} range:range];
    
    return imageText;
}

- (NSMutableAttributedString *)p_parseLineBreakHtmlString:(NSAttributedString *)attrStr {
    NSMutableAttributedString *mutAttr = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
    
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"<br([ |/]?)>"
                                                                             options:kNilOptions
                                                                               error:nil];
    NSArray<NSTextCheckingResult *> *resultArray = [regular matchesInString:attrStr.string
                                                                    options:kNilOptions
                                                                      range:NSMakeRange(0, attrStr.length)];
    
    NSInteger breakLength = 0;
    for (NSTextCheckingResult *result in resultArray) {
        if (result.range.location == NSNotFound || result.range.length < 1) {
            continue;
        }
        NSRange range = result.range;
        range.location -= breakLength;
        NSString *breakText = @"\n";
        [mutAttr replaceCharactersInRange:range withString:breakText];
        breakLength += range.length - breakText.length;
    }
    
    return mutAttr;
}

- (void)p_downWebImage:(NSString *)url {
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:url]
                                                          options:kNilOptions
                                                         progress:nil
                                                        completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                if (error) {
                                                                    NSLog(@"%@", error);
                                                                    return;
                                                                }
                                                                
                                                                [self p_resetImage:image url:url];
                                                            });
                                                        }];
}

- (void)p_resetImage:(UIImage *)image url:(NSString *)url {
    [self.attributedText enumerateAttributesInRange:NSMakeRange(0, self.attributedText.string.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        FQHtmlRunDelegate *delegate = (FQHtmlRunDelegate *)[attrs objectForKey:FQCustomImageAttributeName];
        FQHtmlTextAttachment *attachment = (FQHtmlTextAttachment *)delegate.content;
        if ([attachment.imgUrl isEqualToString:url]) {
            attachment.image = image;
            
            [self p_setDelegate:delegate attachment:attachment];
            
            if ([self.delegate respondsToSelector:@selector(htmlParserAttributedTextChanged:)]) {
                [self.delegate htmlParserAttributedTextChanged:self];
            }
        }
    }];
}

- (void)p_setDelegate:(FQHtmlRunDelegate *)delegate attachment:(FQHtmlTextAttachment *)attachment {
    delegate.content = attachment;
    
    CGFloat width = self.contentWidth;
    CGFloat height = kFQHtmlTextAttachmentDefaultHeight;
    
    if (attachment.image) {
        height = attachment.image.size.height / attachment.image.size.width * width;
    }
    delegate.width = width;
    delegate.height = height;
}

- (NSString *)p_parseCustomImgID:(NSString *)str {
    NSString *imgID = @"";
    
    NSRange srcRange = [str rangeOfString:@"id=['|\"](.*?)['|\"]" options:NSRegularExpressionSearch];
    if (srcRange.location != NSNotFound && srcRange.length > 0) {
        NSString *srcStr = [str substringWithRange:srcRange];
        NSRange r = [srcStr rangeOfString:@"id="];
        imgID = [srcStr substringWithRange:NSMakeRange(r.length + 1, srcStr.length - (r.length + 1) - 1)];
    }
    
    return imgID;
}

- (NSString *)p_parseCustomImgSrc:(NSString *)str {
    NSString *src = @"";
    
    NSRange srcRange = [str rangeOfString:@"src=['|\"](.*?)['|\"]" options:NSRegularExpressionSearch];
    if (srcRange.location != NSNotFound && srcRange.length > 0) {
        NSString *srcStr = [str substringWithRange:srcRange];
        NSRange r = [srcStr rangeOfString:@"src="];
        src = [srcStr substringWithRange:NSMakeRange(r.length + 1, srcStr.length - (r.length + 1) - 1)];
    }
    
    return src;
}

- (CGSize)p_parseCustomImgSize:(NSString *)src {
    CGSize size = CGSizeZero;
    
    NSRange range = [src rangeOfString:@"original_dimensions=" options:NSBackwardsSearch];
    if (range.location == NSNotFound || range.length < 1) {
        return size;
    }
    
    NSString *sizeStr = [src substringFromIndex:range.location + range.length];
    NSArray *array = [sizeStr componentsSeparatedByString:@"x"];
    if (!array || array.count < 2) {
        return size;
    }
    
    CGFloat width = [array[0] floatValue];
    CGFloat height = [array[1] floatValue];
    
    if (width <= 0 || height <= 0) {
        return size;
    }
    
    if (width > kScreenWidth) {
        height = (kScreenWidth / width) * height;
        width = kScreenWidth;
    }
    
    size = CGSizeMake(width, height);
    
    return size;
}

- (UIImage *)p_redrawPlaceholderImgWithSize:(CGSize)size {
    UIImage *image = [UIImage imageNamed:@"rich_img_placeholder"];
    UIImage *placeholderImg = nil;
    
    CGSize imgSize = image.size;
    CGFloat x = (size.width - imgSize.width) * 0.5;
    CGFloat y = (size.height - imgSize.height) * 0.5;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(x, y, imgSize.width, imgSize.height)];
    placeholderImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return placeholderImg;
}

- (UIImage *)p_redrawImage:(UIImage *)image containerWidth:(CGFloat)containerWidth {
    CGSize newSize = CGSizeZero;
    CGFloat y = 10;
    
    newSize.width = image.size.width < containerWidth ? containerWidth : image.size.width;
    newSize.height = image.size.height + y * 2;
    
    CGFloat x = (newSize.width - image.size.width) * 0.5;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    
    [image drawInRect:CGRectMake(x, y, image.size.width, image.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (NSString *)p_parseUrlLink:(NSString *)str {
    NSString *url = @"";
    
    NSString *urlRegex = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"
    "|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    
    NSRange range = [str rangeOfString:urlRegex options:NSRegularExpressionSearch];
    if (range.location != NSNotFound && range.length > 0) {
        url = [str substringWithRange:range];
    }
    
    return url;
}

- (NSString *)p_filterHtml:(NSString *)htmlString {
    if ([htmlString containsString:@"&lt;"]) {
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    }
    if ([htmlString containsString:@"&gt;"]) {
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:htmlString];
    NSString *text = nil;
    
    while (!scanner.isAtEnd) {
        [scanner scanUpToString:@"<" intoString:nil];
        [scanner scanUpToString:@">" intoString:&text];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    
    return htmlString;
}

- (NSDictionary *)p_getCustomURLDictionary:(NSString *)name url:(NSString *)url {
    if (name.length == 0 || url.length == 0) {
        return nil;
    }
    
    if (![url hasPrefix:@"http"] && ![url hasPrefix:@"https"]) {
        url = [NSString stringWithFormat:@"http://%@", url];
    }
    
    return @{UrlNameKey: name,
             UrlLinkKey: url};
}

//- (void)parserEmoji:(NSMutableAttributedString *)text {
//    NSArray<NSTextCheckingResult *> *emoticonResults = [[self regexEmoji] matchesInString:text.string
//                                                                                  options:kNilOptions
//                                                                                    range:NSMakeRange(0, text.length)];
//    NSUInteger emoClipLength = 0;
//    for (NSTextCheckingResult *emo in emoticonResults) {
//        if (emo.range.location == NSNotFound && emo.range.length <= 1) {
//            continue;
//        }
//        NSRange range = emo.range;
//        range.location -= emoClipLength;
//
//        NSTextAttachment *attach = [text attribute:NSAttachmentAttributeName atIndex:range.location effectiveRange:nil];
//        if (attach) {
//            continue;
//        }
//
//        NSString *emoString = [text.string substringWithRange:range];
//        if (emoString.length == 0) {
//            continue;
//        }
//
//        UIImage *image = UIImageFile([[JMInputEmoticonManager sharedManager] emojiPath:emoString]);
//        if (!image) {
//            continue;
//        }
//
//        UIFont *font = [text attribute:NSFontAttributeName atIndex:range.location effectiveRange:nil];
//        CGFloat imgSize = font.pointSize * 1.25;
//
//        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
//        attachment.image = image;
//        attachment.bounds = CGRectMake(0, font.pointSize - imgSize, imgSize, imgSize);
//        NSAttributedString *emojiText = [NSAttributedString attributedStringWithAttachment:attachment];
//        NSMutableAttributedString *mutEmojiText = [[NSMutableAttributedString alloc] initWithAttributedString:emojiText];
//        [mutEmojiText addAttributes:self.typingAttributes range:NSMakeRange(0, mutEmojiText.length)];
//        [mutEmojiText addAttributes:@{MyCustomEmojiAttributeName: @{EmojiNameKey: emoString}} range:NSMakeRange(0, mutEmojiText.length)];
//
//        [text replaceCharactersInRange:range withAttributedString:mutEmojiText];
//        emoClipLength += range.length - mutEmojiText.length;
//    }
//}
//
//- (NSRegularExpression *)regexEmoji {
//    static NSRegularExpression *regex;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        regex = [NSRegularExpression regularExpressionWithPattern:@"\\[[^ \\[\\]]+?\\]" options:kNilOptions error:NULL];
//    });
//    return regex;
//}
//
//- (NSRange)rangeForEmoticon {
//    NSString *text = [self text];
//    NSRange range = [self selectedRange];
//    NSString *selectedText = range.length ? [text substringWithRange:range] : text;
//    NSInteger endLocation =range.location;
//    if (endLocation <= 0) {
//        return NSMakeRange(NSNotFound, 0);
//    }
//    NSInteger index = -1;
//    if ([selectedText hasSuffix:@"]"]) {
//        for (NSInteger i = endLocation; i >= endLocation - 4 && i-1 >= 0 ; i--) {
//            NSRange subRange = NSMakeRange(i - 1, 1);
//            NSString *subString = [text substringWithRange:subRange];
//            if ([subString compare:@"["] == NSOrderedSame) {
//                index = i - 1;
//                break;
//            }
//        }
//    }
//    if (index == -1) {
//        return NSMakeRange(endLocation - 1, 1);
//    } else {
//        NSRange emoticonRange = NSMakeRange(index, endLocation - index);
//        NSString *name = [text substringWithRange:emoticonRange];
//        // 判断是不是表情
//        BOOL isApple = [[JMInputEmoticonManager sharedManager] isAppleEmoji:name];
//        return isApple ? emoticonRange : NSMakeRange(endLocation - 1, 1);
//    }
//}
//
//- (void)deleteTextRange: (NSRange)range {
//    NSMutableAttributedString *mutTxt = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
//    if (range.location + range.length <= mutTxt.length
//        && range.location != NSNotFound && range.length != 0) {
//        [mutTxt replaceCharactersInRange:range withString:@""];
//        NSRange newSelectRange = NSMakeRange(range.location, 0);
//        self.attributedText = mutTxt;
//        self.selectedRange = newSelectRange;
//    }
//}

#pragma mark - Getter

- (NSMutableArray *)highlightArrayM {
    if (!_highlightArrayM) {
        _highlightArrayM = [NSMutableArray array];
    }
    return _highlightArrayM;
}

- (NSArray *)highlightArray {
    return _highlightArrayM;
}

@end
