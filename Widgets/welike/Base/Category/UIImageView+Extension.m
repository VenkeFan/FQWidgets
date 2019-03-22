//
//  UIImageView+Extension.m
//  welike
//
//  Created by fan qi on 2018/4/25.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "UIImageView+Extension.h"
#import "UIImageView+WebCache.h"
#import "WLHeadView.h"
#import <objc/runtime.h>

@interface UIImageView ()

@property (nonatomic, assign) UIViewContentMode originalContentMode;

@end

@implementation UIImageView (Extension)

- (void)fq_setImageWithURLString:(NSString *)urlString {
    [self fq_setImageWithURLString:urlString
                       placeholder:nil
                           options:kNilOptions
                      cornerRadius:0
                       borderWidth:0
                       borderColor:nil
                         completed:nil];
}

- (void)fq_setImageWithURLString:(NSString *)urlString
                     placeholder:(UIImage *)placeholder {
    [self fq_setImageWithURLString:urlString
                       placeholder:placeholder
                           options:kNilOptions
                      cornerRadius:0
                       borderWidth:0
                       borderColor:nil
                         completed:nil];
}

- (void)fq_setImageWithURLString:(NSString *)urlString
                       completed:(FQWebImageCompletionBlock)completed {
    [self fq_setImageWithURLString:urlString
                       placeholder:nil
                           options:kNilOptions
                      cornerRadius:0
                       borderWidth:0
                       borderColor:nil
                         completed:completed];
}

- (void)fq_setImageWithURLString:(NSString *)urlString
                     placeholder:(UIImage *)placeholder
                       completed:(FQWebImageCompletionBlock)completed {
    [self fq_setImageWithURLString:urlString
                       placeholder:placeholder
                           options:kNilOptions
                      cornerRadius:0
                       borderWidth:0
                       borderColor:nil
                         completed:completed];
}

- (void)fq_setImageWithURLString:(NSString *)urlString
                     placeholder:(UIImage *)placeholder
                    cornerRadius:(CGFloat)cornerRadius
                       completed:(FQWebImageCompletionBlock)completed {
    [self fq_setImageWithURLString:urlString
                       placeholder:placeholder
                      cornerRadius:cornerRadius
                       borderWidth:0
                       borderColor:nil
                         completed:completed];
}

- (void)fq_setImageWithURLString:(NSString *)urlString
                     placeholder:(UIImage *)placeholder
                    cornerRadius:(CGFloat)cornerRadius
                     borderWidth:(CGFloat)borderWidth
                     borderColor:(UIColor *)borderColor
                       completed:(FQWebImageCompletionBlock)completed
{
    [self fq_setImageWithURLString:urlString
                       placeholder:placeholder
                           options:SDWebImageAvoidAutoSetImage
                      cornerRadius:cornerRadius
                       borderWidth:borderWidth
                       borderColor:borderColor
                         completed:completed];
}

- (void)fq_setImageWithURLString:(NSString *)urlString
                     placeholder:(UIImage *)placeholder
                         options:(SDWebImageOptions)options
                    cornerRadius:(CGFloat)cornerRadius
                     borderWidth:(CGFloat)borderWidth
                     borderColor:(UIColor *)borderColor
                       completed:(FQWebImageCompletionBlock)completed {
    [SDWebImageDownloader.sharedDownloader setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
                                 forHTTPHeaderField:@"Accept"];
    
    bool isHeadView = [self isKindOfClass:[WLHeadView class]];
    
    self.originalContentMode = self.contentMode;
    
    if (!placeholder) {
        placeholder = [self p_defaultPlaceholder];
    }
    
    if (!isHeadView && placeholder.isPlaceholder) {
        self.contentMode = UIViewContentModeCenter;
    }
    
    NSURL *url = nil;
    if ([urlString isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:urlString];
    } else if ([urlString isKindOfClass:[NSURL class]]) {
        url = (NSURL *)urlString;
    }
    
    if (!url) {
        self.image = placeholder;
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    CGSize size = weakSelf.frame.size;
    
    [self sd_setImageWithURL:url
            placeholderImage:placeholder
                     options:options
                   completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                       if (!image) {
                           if (!isHeadView) {
                               weakSelf.contentMode = UIViewContentModeCenter;
                               weakSelf.image = [weakSelf p_defaultBadImage];
                           }
                           
                           if (completed) {
                               completed(image, url, error);
                           }
                           return;
                       }
                       
                       weakSelf.contentMode = weakSelf.originalContentMode;
                       
                       if (cornerRadius > 0.0) {
                           dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                               UIImage *img = image;
                               
                               img = [image resizeWithSize:size];
                               img = [img imageByRoundCornerRadius:cornerRadius borderWidth:borderWidth borderColor:borderColor];
                               
                               dispatch_sync(dispatch_get_main_queue(), ^{
                                   weakSelf.image = img;
                                   
                                   if (completed) {
                                       completed(img, url, error);
                                   }
                               });
                               
                           });
                       } else {
                           weakSelf.image = image;
                           
                           if (completed) {
                               completed(image, url, error);
                           }
                       }
                     }];
}

#pragma mark - Private

- (UIViewContentMode)originalContentMode {
    return [objc_getAssociatedObject(self, @selector(originalContentMode)) integerValue];
}

- (void)setOriginalContentMode:(UIViewContentMode)originalContentMode {
    objc_setAssociatedObject(self, @selector(originalContentMode), @(originalContentMode), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)p_defaultPlaceholder {
    UIImage *image = nil;
    
    if (self.width >= kScreenWidth / 2.0) {
        image = [AppContext getImageForKey:@"img_thumb_default_big"];
    } else if (self.width <= kScreenWidth / 3.0) {
        image = [AppContext getImageForKey:@"img_thumb_default_small"];
    } else {
        image = [AppContext getImageForKey:@"img_thumb_default_middle"];
    }
    
    image.isPlaceholder = YES;
    
    return image;
}

- (UIImage *)p_defaultBadImage {
    UIImage *image = nil;
    
    if (self.width >= kScreenWidth) {
        image = [AppContext getImageForKey:@"common_placeholder_bad"];
    } else if (self.width <= kScreenWidth / 3.0) {
        image = [AppContext getImageForKey:@"common_placeholder_bad"];
    } else {
        image = [AppContext getImageForKey:@"common_placeholder_bad"];
    }
    
    image.isPlaceholder = YES;
    
    return image;
}

@end
