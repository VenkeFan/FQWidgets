//
//  FLAnimatedImageView+WLExtension.m
//  welike
//
//  Created by fan qi on 2018/5/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "FLAnimatedImageView+WLExtension.h"
#import "FLAnimatedImageView+WebCache.h"

@implementation FLAnimatedImageView (WLExtension)

- (void)wl_setImageWithURL:(NSString *)urlString
          placeholderImage:(UIImage *)placeholder
                   options:(SDWebImageOptions)options
                  progress:(WLImageDownloaderProgressBlock)progressBlock
                 completed:(WLImageCompletionBlock)completedBlock {
    [SDWebImageDownloader.sharedDownloader setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
                                 forHTTPHeaderField:@"Accept"];
    
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
    
    [self sd_setImageWithURL:url
            placeholderImage:placeholder
                     options:options
                    progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (progressBlock) {
                                progressBlock(receivedSize / (float)expectedSize, targetURL);
                            }
                        });
                    }
                   completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                       FLAnimatedImage *animatedImage = image.sd_FLAnimatedImage;
                       dispatch_async(dispatch_get_main_queue(), ^{
                           if (completedBlock) {
                               completedBlock(image, animatedImage, error, imageURL);
                           }
                       });
                   }];
}

@end
