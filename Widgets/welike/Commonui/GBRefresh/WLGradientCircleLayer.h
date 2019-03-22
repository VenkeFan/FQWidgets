//
//  FQGradientCircleLayer.h
//  WeLike
//
//  Created by fan qi on 2018/4/2.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface WLGradientCircleLayer : CALayer

@property (nonatomic, assign) CGFloat strokeEnd;
@property (nonatomic, strong) UIColor *circleColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) BOOL isAnimating;

- (void)beginAnimating;
- (void)stopAnimating;

- (void)beginListRefreshAnimating;
+(WLGradientCircleLayer *)layer;

@end
