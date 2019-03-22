//
//  WLZoomScaleView.h
//  WeLike
//
//  Created by fan qi on 2018/4/9.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLZoomScaleView, FLAnimatedImageView, FLAnimatedImage;

@protocol WLZoomScaleViewDelegate <NSObject>

- (void)zoomScaleViewDidTapped:(WLZoomScaleView *)scaleView;

@end

@interface WLZoomScaleView : UIScrollView

@property (nonatomic, weak, readonly) FLAnimatedImageView *imageView;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) FLAnimatedImage *animatedImage;
@property (nonatomic, copy) NSString *userName;

@property (nonatomic, assign) BOOL useCache;

@property (nonatomic, weak) id<WLZoomScaleViewDelegate> zoomScaleDelegate;

- (void)setImageWithUrlString:(NSString *)urlString placeholder:(UIImage *)placeholder imageSize:(CGSize)imageSize;

- (void)save;

@end
