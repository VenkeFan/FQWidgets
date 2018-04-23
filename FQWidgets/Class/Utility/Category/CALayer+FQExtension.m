//
//  CALayer+FQExtension.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/20.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "CALayer+FQExtension.h"

@implementation CALayer (FQExtension)

- (void)fq_setImageWithURLString:(NSString *)urlString {
    [self fq_setImageWithURLString:urlString
                      cornerRadius:0
                       borderWidth:0
                       borderColor:nil];
}

- (void)fq_setImageWithURLString:(NSString *)urlString
                    cornerRadius:(CGFloat)cornerRadius {
    [self fq_setImageWithURLString:urlString
                      cornerRadius:cornerRadius
                       borderWidth:0
                       borderColor:nil];
}

- (void)fq_setImageWithURLString:(NSString *)urlString
                    cornerRadius:(CGFloat)cornerRadius
                     borderWidth:(CGFloat)borderWidth
                     borderColor:(UIColor *)borderColor {
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
              placeholder:nil
                  options:YYWebImageOptionAvoidSetImage
               completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                   if (!image) {
                       return;
                   }
                   
                   CGSize size = weakSelf.frame.size;
                   
                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                       
                       UIImage *img = [image imageByResizeToSize:size];
                       if (cornerRadius > 0.0) {
                           img = [img imageByRoundCornerRadius:cornerRadius borderWidth:borderWidth borderColor:borderColor];
                       }
                       
                       dispatch_sync(dispatch_get_main_queue(), ^{
                           [CATransaction begin];
                           [CATransaction setDisableActions:YES];
                           weakSelf.contents = (__bridge id)img.CGImage;
                           [CATransaction commit];
                       });
                       
                   });
               }];
}

@end
