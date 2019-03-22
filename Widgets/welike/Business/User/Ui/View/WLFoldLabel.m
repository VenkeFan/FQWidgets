//
//  WLFoldLabel.m
//  welike
//
//  Created by fan qi on 2019/2/25.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLFoldLabel.h"
#import <CoreText/CoreText.h>
#import "YYText.h"

@interface WLFoldLabel ()

@property (nonatomic, strong) YYLabel *label;

@end

@implementation WLFoldLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _label = [YYLabel new];
        _label.userInteractionEnabled = YES;
        _label.numberOfLines = 0;
        _label.textVerticalAlignment = YYTextVerticalAlignmentTop;
        
        [self addSeeMoreButton];
        [self addSubview:_label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _label.frame = self.bounds;
    _label.center = CGPointMake(self.width * 0.5, self.height * 0.5);
}

- (void)addSeeMoreButton {
    __weak typeof(self) weakSelf = self;
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"...more"];
    
    YYTextHighlight *hi = [YYTextHighlight new];
    [hi setColor:[UIColor colorWithRed:0.578 green:0.790 blue:1.000 alpha:1.000]];
    hi.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
        YYLabel *label = weakSelf.label;
        [label sizeToFit];
        
        if ([self.delegate respondsToSelector:@selector(foldLabel:oldHeight:newHeight:)]) {
            [self.delegate foldLabel:weakSelf oldHeight:weakSelf.height newHeight:label.height];
        }
        
        weakSelf.height = label.height;
    };
    
    [text yy_setColor:[UIColor colorWithRed:0.000 green:0.449 blue:1.000 alpha:1.000] range:[text.string rangeOfString:@"more"]];
    [text yy_setTextHighlight:hi range:[text.string rangeOfString:@"more"]];
    text.yy_font = kRegularFont(kLightFontSize);
    
    YYLabel *seeMore = [YYLabel new];
    seeMore.attributedText = text;
    [seeMore sizeToFit];
    
    NSAttributedString *truncationToken = [NSAttributedString yy_attachmentStringWithContent:seeMore contentMode:UIViewContentModeCenter attachmentSize:seeMore.size alignToFont:text.yy_font alignment:YYTextVerticalAlignmentCenter];
    _label.truncationToken = truncationToken;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedText = attributedText;
    
    _label.attributedText = attributedText;
    
//    CGRect bounds = [attributedText boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.bounds), kScreenHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
//
//    CTFramesetterRef framesetter= CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedText);
//    CGPathRef path = CGPathCreateWithRect(bounds, NULL);
//    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
//    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
//
//    CFIndex lineIndex = 0;
//    CGFloat drawHeight = 0;
//    for (id line in lines) {
//        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
//        CGFloat width = (CGFloat)CTLineGetTypographicBounds((__bridge CTLineRef)line, &ascent, &descent, &leading) ;
//        CGRect lineBounds = CGRectMake(0.0f, 0.0f, width, ascent + ABS(descent) + leading);
//
//        drawHeight += lineBounds.size.height;
//
//        lineIndex++;
//        if (lineIndex >= self.minNumberOfLines) {
//            break;
//        }
//    }
//
//    CGRect selfFrame = self.frame;
//    selfFrame.size.height = drawHeight;
//    self.frame = selfFrame;
//
//    UIGraphicsBeginImageContext(CGSizeMake(bounds.size.width, drawHeight));
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetTextMatrix(context , CGAffineTransformIdentity);
//    CGContextTranslateCTM(context, 0, CGRectGetHeight(self.frame));
//    CGContextScaleCTM(context, 1.0, -1.0);
//    CTFrameDraw(frame, context);
//    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    CGPathRelease(path);
//    CFRelease(framesetter);
//    CFRelease(frame);
//
//    self.layer.contents = (__bridge id)img.CGImage;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(foldLabelDidTapped:)]) {
        [self.delegate foldLabelDidTapped:self];
    }
}

@end
