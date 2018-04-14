//
//  FQZoomScaleView.h
//  WeLike
//
//  Created by fan qi on 2018/4/9.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FQZoomScaleView;

@protocol FQZoomScaleViewDelegate <NSObject>

- (void)zoomScaleViewDidTapped:(FQZoomScaleView *)scaleView;

@end

@interface FQZoomScaleView : UIScrollView

@property (nonatomic, weak, readonly) UIImageView *imageView;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) id<FQZoomScaleViewDelegate> zoomScaleDelegate;

- (void)setImageWithUrlString:(NSString *)urlString;

@end
