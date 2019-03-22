//
//  UIImageView+Extension.h
//  welike
//
//  Created by fan qi on 2018/4/25.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageManager.h"
#import "UIImage+LuuBase.h"

typedef void (^FQWebImageCompletionBlock)(UIImage *image,
                                          NSURL *url,
                                          NSError *error);

@interface UIImageView (Extension)

- (void)fq_setImageWithURLString:(NSString *)urlString;

- (void)fq_setImageWithURLString:(NSString *)urlString
                     placeholder:(UIImage *)placeholder;

- (void)fq_setImageWithURLString:(NSString *)urlString
                       completed:(FQWebImageCompletionBlock)completed;

- (void)fq_setImageWithURLString:(NSString *)urlString
                     placeholder:(UIImage *)placeholder
                       completed:(FQWebImageCompletionBlock)completed;

- (void)fq_setImageWithURLString:(NSString *)urlString
                    placeholder:(UIImage *)placeholder
                    cornerRadius:(CGFloat)cornerRadius
                       completed:(FQWebImageCompletionBlock)completed;

- (void)fq_setImageWithURLString:(NSString *)urlString
                     placeholder:(UIImage *)placeholder
                    cornerRadius:(CGFloat)cornerRadius
                     borderWidth:(CGFloat)borderWidth
                     borderColor:(UIColor *)borderColor
                       completed:(FQWebImageCompletionBlock)completed;

- (void)fq_setImageWithURLString:(NSString *)urlString
                     placeholder:(UIImage *)placeholder
                         options:(SDWebImageOptions)options
                    cornerRadius:(CGFloat)cornerRadius
                     borderWidth:(CGFloat)borderWidth
                     borderColor:(UIColor *)borderColor
                       completed:(FQWebImageCompletionBlock)completed;

@end
