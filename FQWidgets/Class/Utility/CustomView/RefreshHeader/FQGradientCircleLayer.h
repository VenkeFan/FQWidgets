//
//  FQGradientCircleLayer.h
//  WeLike
//
//  Created by fan qi on 2018/4/2.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface FQGradientCircleLayer : CALayer

@property (nonatomic, assign) CGFloat strokeEnd;

- (void)beginAnimating;
- (void)stopAnimating;

@end
