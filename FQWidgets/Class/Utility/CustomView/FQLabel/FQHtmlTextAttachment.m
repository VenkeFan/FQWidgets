//
//  FQHtmlTextAttachment.m
//  FQWidgets
//
//  Created by fan qi on 2019/3/7.
//  Copyright © 2019 fan qi. All rights reserved.
//

#import "FQHtmlTextAttachment.h"

#define kPadding            12.0

NSString * const FQHtmlTextAttachmentToken = @"\uFFFC";
static NSString * const FQHtmlTextAttachmentPlaceholder = @"html_bg.png";

@interface FQHtmlTextAttachment ()

@end

@implementation FQHtmlTextAttachment

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)dealloc {
    
}

+ (UIImage *)placeholder {
    return [UIImage imageNamed:FQHtmlTextAttachmentPlaceholder];
}

/*
 
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    CGFloat attachmentWidth = CGRectGetWidth(lineFrag) - textContainer.lineFragmentPadding * 2;
    
    return [self scaleImageSizeToWidth:attachmentWidth];
}

- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex {
    UIImage *image = [self redrawImage:self.image containerWidth:textContainer.size.width];
    
    return image;
}

- (CGRect)scaleImageSizeToWidth:(CGFloat)width {
    if (self.image.size.width < width) {
        return CGRectMake(0, 0, width, self.image.size.height + kPadding * 2);
    }
    
    return CGRectMake(0, 0, width, width / self.image.size.width * self.image.size.height + kPadding * 2);
}

- (UIImage *)redrawImage:(UIImage *)image containerWidth:(CGFloat)containerWidth {
    CGSize newSize = CGSizeZero;
    
    newSize.width = image.size.width < containerWidth ? containerWidth : image.size.width;
    newSize.height = image.size.height + kPadding * 2;
    
    CGFloat x = (newSize.width - image.size.width) * 0.5;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    
    //    {
    //        CGContextRef contextRef = UIGraphicsGetCurrentContext();
    //        CGMutablePathRef path = CGPathCreateMutable();
    //        CGPathAddRect(path, NULL, CGRectMake(0, 0, newSize.width, newSize.height));
    //        CGContextAddPath(contextRef, path);
    //        [[UIColor blackColor] setStroke];
    //        CGContextSetLineWidth(contextRef,1);
    //        CGContextDrawPath(contextRef, kCGPathStroke);
    //        CGPathRelease(path);
    //    }
    
    [image drawInRect:CGRectMake(x, kPadding, image.size.width, image.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
*/

@end
