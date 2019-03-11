//
//  FQHtmlLabel.m
//  FQWidgets
//
//  Created by fan qi on 2019/3/6.
//  Copyright © 2019 fan qi. All rights reserved.
//

#import "FQHtmlLabel.h"
#import <CoreText/CoreText.h>
#import "FQHtmlParser.h"
#import "FQHtmlTextAttachment.h"
#import "FLAnimatedImage.h"

@interface FQHtmlLabel () <FQHtmlParserDelegate>

@property (nonatomic, strong) FQHtmlParser *htmlParser;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation FQHtmlLabel {
    CTFrameRef _ctFrame;
}

#pragma mark - LifeCycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _contentView = [[UIView alloc] initWithFrame:frame];
        _contentView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_contentView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _htmlParser.contentWidth = CGRectGetWidth(self.frame);
}

- (void)dealloc {
    CFRelease(_ctFrame);
    
    NSLog(@"FQHtmlLabel dealloc !!!!!!!!!!!!!!");
}

#pragma mark -

- (void)setText:(NSString *)text {
    _text = [text copy];
    
    [self setAttributedText:[self.htmlParser attributedTextWithHtml:text]];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    if (!attributedText) {
        return;
    }
    
    _attributedText = attributedText;
    
    CTFramesetterRef framesetter= CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedText);
    
    CGSize bounds = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attributedText.length), nil, CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX), nil);
    CGSize contentSize = CGSizeMake(self.bounds.size.width, bounds.height);
    
    
    CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, bounds.width, bounds.height), NULL);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    _ctFrame = frameRef;
    
    CFArrayRef lines = CTFrameGetLines(frameRef);
    CFIndex lineCount = CFArrayGetCount(lines);
    
    CGPoint *lineOrigins = malloc(lineCount * sizeof(CGPoint));
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), lineOrigins);
    
    {
        // draw run
        UIGraphicsBeginImageContextWithOptions(contentSize, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, contentSize.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        for (CFIndex index = 0; index < lineCount; index++) {
            CTLineRef line = CFArrayGetValueAtIndex(lines, index);
            CGPoint ctLineOrigin = lineOrigins[index];
            CGFloat positionY = ctLineOrigin.y;
            
//            CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
//            CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
//            CGRect lineBounds = CGRectMake(0.0f, 0.0f, width, ascent + ABS(descent));
            
            CFArrayRef runs = CTLineGetGlyphRuns(line);
            for (CFIndex i = 0; i < CFArrayGetCount(runs); i++) {
                CTRunRef runRef = CFArrayGetValueAtIndex(runs, i);
                NSDictionary *attrs = (id)CTRunGetAttributes(runRef);
                
                FQHtmlTextAttachment *attachment = attrs[FQHtmlImageAttributeName];
                CTRunDelegateRef ctDelegate = (__bridge CTRunDelegateRef)[attrs valueForKey:(id)kCTRunDelegateAttributeName];
                if (!attachment || !ctDelegate) {
                    // draw run
                    CGContextSetTextMatrix(context , CGAffineTransformIdentity);
                    CGContextSetTextPosition(context, ctLineOrigin.x, positionY);
                    CTRunDraw(runRef, context, CFRangeMake(0, 0));
                    
                    continue;
                }
                
                // draw attachment
                
                CGRect runBounds;
                CGFloat ascent;
                CGFloat descent;
                
                runBounds.size.width = CTRunGetTypographicBounds(runRef, CFRangeMake(0, 0), &ascent, &descent, (CGFloat *)0);
                runBounds.size.height = ascent + descent;
                
                CGFloat offsetX = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(runRef).location, NULL);
                runBounds.origin.x = ctLineOrigin.x + offsetX;
                runBounds.origin.y = ctLineOrigin.y - descent;
                
//                CGPathRef pathRef = CTFrameGetPath(frameRef);
//                CGRect colRect = CGPathGetBoundingBox(pathRef);
//                CGRect imageRect = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
                
                if ([attachment.content isKindOfClass:[UIImage class]]) {
                    UIImage *img = (UIImage *)attachment.content;
                    CGContextSaveGState(context);
                    CGContextSetAlpha(context, 0.2);
                    CGContextDrawImage(context, runBounds, img.CGImage);
                    CGContextRestoreGState(context);
                } else if ([attachment.content isKindOfClass:[UIView class]]) {
                    CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0, contentSize.height);
                    transform = CGAffineTransformScale(transform, 1.0, -1.0);
                    runBounds = CGRectApplyAffineTransform(runBounds, transform);

                    UIView *view = (UIView *)attachment.content;
                    view.frame = runBounds;
                    if (!view.superview) {
                        [self.contentView addSubview:view];
                    }
                }
            }
        }
        
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.contentView.layer.contents = (__bridge id)img.CGImage;
        
        CGPathRelease(path);
        CFRelease(framesetter);
        CFRelease(lineOrigins);
//        CFRelease(frameRef);
    }
    
    {
        // draw frame
//        CFIndex index = 0;
//        for (id line in lines) {
//            CGPoint ctLineOrigin = lineOrigins[index];
//
//            CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
//            CGFloat width = (CGFloat)CTLineGetTypographicBounds((__bridge CTLineRef)line, &ascent, &descent, &leading);
//            CGRect lineBounds = CGRectMake(0.0f, 0.0f, width, ascent + ABS(descent) + leading);
//
//            index++;
//        }
//
//        UIImage *img = [self p_drawContent:contentSize frameRef:frameRef];
//        self.contentView.layer.contents = (__bridge id)img.CGImage;
//
//        CGPathRelease(path);
//        CFRelease(framesetter);
//        CFRelease(frameRef);
    }
    
    {
        CGRect contentFrame = self.contentView.frame;
        contentFrame.size.width = contentSize.width;
        contentFrame.size.height = contentSize.height;
        self.contentView.frame = contentFrame;
        
        if (self.contentView.frame.size.height > self.frame.size.height) {
            self.contentSize = CGSizeMake(self.frame.size.width, self.contentView.frame.size.height);
        } else {
            self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height + 1);
        }
    }
}

#pragma mark - FQHtmlParserDelegate

- (void)htmlParserAttributedTextChanged:(FQHtmlParser *)parser {
    [self setAttributedText:parser.attributedText];
}

#pragma mark - Private

- (UIImage *)p_drawContent:(CGSize)size frameRef:(CTFrameRef)frameRef {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context , CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CTFrameDraw(frameRef, context);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    CFArrayRef lines = CTFrameGetLines(_ctFrame);
    CFIndex lineCount = CFArrayGetCount(lines);
    
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(_ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0, CGRectGetHeight(self.contentView.frame));
    transform = CGAffineTransformScale(transform, 1.0, -1.0);
    
    for (CFIndex i = 0; i < lineCount; i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        CGPoint ctLineOrigin = lineOrigins[i];
        
        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
        CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat height = ascent + ABS(descent);
        
        CGRect lineFrame = CGRectMake(ctLineOrigin.x, ctLineOrigin.y - descent, width, height);
        lineFrame = CGRectApplyAffineTransform(lineFrame, transform);
        
//        NSLog(@"-->(%f, %f, %f, %f) / (%f, %f)", lineFrame.origin.x, lineFrame.origin.y, lineFrame.size.width, lineFrame.size.height, point.x, point.y);
        
        if (CGRectContainsPoint(lineFrame, point)) {
            CFIndex index = CTLineGetStringIndexForPosition(line, point);
            
            for (int j = 0; j < self.htmlParser.highlightArray.count; j++) {
                FQHtmlHighlight *highlight = self.htmlParser.highlightArray[j];
                if (NSLocationInRange(index, highlight.range)) {
                    if ([self.htmlDelegate respondsToSelector:@selector(htmlLabel:didHighlight:)]) {
                        [self.htmlDelegate htmlLabel:self didHighlight:highlight];
                    }
                    return;
                }
            }
        }
    }
}

#pragma mark - Getter

- (FQHtmlParser *)htmlParser {
    if (!_htmlParser) {
        _htmlParser = [FQHtmlParser new];
        _htmlParser.delegate = self;
        _htmlParser.contentWidth = CGRectGetWidth(self.frame);
    }
    return _htmlParser;
}

@end
