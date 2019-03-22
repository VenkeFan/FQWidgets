//
//  FLAnimatedImageView+WLExtension.h
//  welike
//
//  Created by fan qi on 2018/5/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "FLAnimatedImageView.h"

typedef void(^WLImageDownloaderProgressBlock)(CGFloat progress, NSURL *targetURL);
typedef void(^WLImageCompletionBlock)(UIImage *image, FLAnimatedImage *animatedImage, NSError *error, NSURL *targetURL);

@interface FLAnimatedImageView (WLExtension)

- (void)wl_setImageWithURL:(NSString *)urlString
          placeholderImage:(UIImage *)placeholder
                   options:(SDWebImageOptions)options
                  progress:(WLImageDownloaderProgressBlock)progressBlock
                 completed:(WLImageCompletionBlock)completedBlock;

@end
