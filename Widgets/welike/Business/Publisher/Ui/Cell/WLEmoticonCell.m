//
//  WLEmoticonCell.m
//  welike
//
//  Created by gyb on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLEmoticonCell.h"
#import <CoreText/CoreText.h>
#import "UIImageView+WebCache.h"

@implementation WLEmoticonCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _imageView = [UIImageView new];
    _imageView.size = CGSizeMake(32, 32);
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_imageView];
    return self;
}

- (void)setEmoticonStr:(NSString *)emoticonStr {
    if (_emoticonStr == emoticonStr) return;
    _emoticonStr = emoticonStr;
    [self updateContent];
}

- (void)setIsDelete:(BOOL)isDelete {
    if (_isDelete == isDelete) return;
    _isDelete = isDelete;
    [self updateContent];
}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//    [self updateLayout];
//}

- (void)updateContent {
    _imageView.image = nil;
    
    if (_isDelete) {
        _imageView.image =  [AppContext getImageForKey:@"publish_emotion_delete"];
    }
    else
        if (_emoticonStr.length > 0)
        {
            //加载emoji图片
           NSString *imagePath = [[NSBundle mainBundle] pathForResource:_emoticonStr ofType:@"png"];
            [_imageView sd_setImageWithURL:[NSURL fileURLWithPath:imagePath]];
        }
}

- (void)updateLayout {
    _imageView.center = CGPointMake(self.width / 2, self.height / 2);
}

+ (UIImage *)imageWithEmoji:(NSString *)emoji size:(CGFloat)size {
    if (emoji.length == 0) return nil;
    if (size < 1) return nil;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CTFontRef font = CTFontCreateWithName(CFSTR("AppleColorEmoji"), size * scale, NULL);
    if (!font) return nil;
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:emoji attributes:@{ (__bridge id)kCTFontAttributeName:(__bridge id)font, (__bridge id)kCTForegroundColorAttributeName:(__bridge id)[UIColor whiteColor].CGColor }];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, size * scale, size * scale, 8, 0, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFTypeRef)str);
    CGRect bounds = CTLineGetBoundsWithOptions(line, kCTLineBoundsUseGlyphPathBounds);
    CGContextSetTextPosition(ctx, 0, -bounds.origin.y);
    CTLineDraw(line, ctx);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    
    CFRelease(font);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(ctx);
    if (line)CFRelease(line);
    if (imageRef) CFRelease(imageRef);
    
    return image;
}


@end
