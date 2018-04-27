//
//  UIImageView+FQExtension.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/23.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "UIImageView+FQExtension.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UIImageView (FQExtension)

- (void)fq_setImageWithURLString:(NSString *)urlString {
    [self fq_setImageWithURLString:urlString
                       placeholder:nil
                      cornerRadius:0
                       borderWidth:0
                       borderColor:nil
                         completed:nil];
}

- (void)fq_setImageWithURLString:(NSString *)urlString
                     placeholder:(UIImage *)placeholder {
    [self fq_setImageWithURLString:urlString
                       placeholder:placeholder
                      cornerRadius:0
                       borderWidth:0
                       borderColor:nil
                         completed:nil];
}

- (void)fq_setImageWithURLString:(NSString *)urlString
                       completed:(FQWebImageCompletionBlock)completed {
    [self fq_setImageWithURLString:urlString
                       placeholder:nil
                      cornerRadius:0
                       borderWidth:0
                       borderColor:nil
                         completed:completed];
}

- (void)fq_setImageWithURLString:(NSString *)urlString
                    cornerRadius:(CGFloat)cornerRadius {
    [self fq_setImageWithURLString:urlString
                       placeholder:nil
                      cornerRadius:cornerRadius
                       borderWidth:0
                       borderColor:nil
                         completed:nil];
}

- (void)fq_setImageWithURLString:(NSString *)urlString
                     placeholder:(UIImage *)placeholder
                    cornerRadius:(CGFloat)cornerRadius
                     borderWidth:(CGFloat)borderWidth
                     borderColor:(UIColor *)borderColor
                       completed:(FQWebImageCompletionBlock)completed {
    NSURL *url = nil;
    if ([urlString isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:urlString];
    } else if ([urlString isKindOfClass:[NSURL class]]) {
        url = (NSURL *)urlString;
    }
    
    if (!url) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    [self setImageWithURL:url
              placeholder:placeholder
                  options:YYWebImageOptionAvoidSetImage
               completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                   if (!image) {
                       return;
                   }

                   CGSize size = weakSelf.frame.size;

                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                       UIImage *img = image;
                       if (cornerRadius > 0.0) {
                           img = [image imageByResizeToSize:size];
                           img = [img imageByRoundCornerRadius:cornerRadius borderWidth:borderWidth borderColor:borderColor];
                       }

                       dispatch_sync(dispatch_get_main_queue(), ^{
                           weakSelf.image = image;

                           if (completed) {
                               completed(image, url, error);
                           }
                       });
                   });
               }];
}

@end
