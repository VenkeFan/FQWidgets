//
//  UIImageView+FQExtension.h
//  FQWidgets
//
//  Created by fan qi on 2018/4/23.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^FQWebImageCompletionBlock)(UIImage *image,
                                          NSURL *url,
                                          NSError *error);

@interface UIImageView (FQExtension)

- (void)fq_setImageWithURLString:(NSString *)urlString;

- (void)fq_setImageWithURLString:(NSString *)urlString
                     placeholder:(UIImage *)placeholder;

- (void)fq_setImageWithURLString:(NSString *)urlString
                       completed:(FQWebImageCompletionBlock)completed;

- (void)fq_setImageWithURLString:(NSString *)urlString
                    cornerRadius:(CGFloat)cornerRadius;

- (void)fq_setImageWithURLString:(NSString *)urlString
                     placeholder:(UIImage *)placeholder
                    cornerRadius:(CGFloat)cornerRadius
                     borderWidth:(CGFloat)borderWidth
                     borderColor:(UIColor *)borderColor
                       completed:(FQWebImageCompletionBlock)completed;

@end
