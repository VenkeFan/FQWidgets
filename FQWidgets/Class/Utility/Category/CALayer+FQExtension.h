//
//  CALayer+FQExtension.h
//  FQWidgets
//
//  Created by fan qi on 2018/4/20.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (FQExtension)

- (void)fq_setImageWithURLString:(NSString *)urlString;

- (void)fq_setImageWithURLString:(NSString *)urlString
                    cornerRadius:(CGFloat)cornerRadius;

- (void)fq_setImageWithURLString:(NSString *)urlString
                    cornerRadius:(CGFloat)cornerRadius
                     borderWidth:(CGFloat)borderWidth
                     borderColor:(UIColor *)borderColor;

@end
