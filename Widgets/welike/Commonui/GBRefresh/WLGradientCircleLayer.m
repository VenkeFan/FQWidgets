//
//  FQGradientCircleLayer.m
//  WeLike
//
//  Created by fan qi on 2018/4/2.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLGradientCircleLayer.h"

static NSString * const rotation_key = @"rotation_key";

@interface WLGradientCircleLayer ()<CAAnimationDelegate>

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CABasicAnimation *rotationAnimation;

@end

@implementation WLGradientCircleLayer

+ (id)layer
{
    WLGradientCircleLayer *layer = [super layer];
    if (layer)
    {
        layer.lineWidth = 3;
    }
    return layer;
}

- (void)layoutSublayers {
    self.circleLayer.frame = self.bounds;
}

#pragma mark - Public

- (void)setStrokeEnd:(CGFloat)strokeEnd {
    if (self.hidden) {
        self.hidden = NO;
    }
    
//    NSLog(@"======%f",strokeEnd);
//    if (strokeEnd >= 0.2 && strokeEnd < 0.3)
//    {
//        self.circleLayer.strokeStart = 0;
//    }
//
//    if (strokeEnd >= 0.4 && strokeEnd < 0.5)
//    {
//          self.circleLayer.strokeStart = 0.2;
//    }
//
//    if (strokeEnd >= 0.6 && strokeEnd < 0.7)
//    {
//          self.circleLayer.strokeStart = 0.4;
//    }
//
//    if (strokeEnd >= 0.8 && strokeEnd < 0.9)
//    {
//          self.circleLayer.strokeStart = 0.5;
//    }
//
//    if (strokeEnd >= 1.0)
//    {
//         self.circleLayer.strokeStart = 0.6;
//    }
    
    self.circleLayer.strokeEnd = strokeEnd;
}

- (CGFloat)strokeEnd {
    return self.circleLayer.strokeEnd;
}

- (void)beginAnimating {
    self.hidden = NO;
    [self addAnimation:[self rotationAnimation] forKey:rotation_key];
}

- (void)beginListRefreshAnimating
{
      self.hidden = NO;
      [self addAnimation:[self listRotationAnimation] forKey:rotation_key];
}

- (void)stopAnimating {
    [self removeAnimationForKey:rotation_key];
    self.hidden = YES;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.strokeEnd = 0.0;
    [CATransaction commit];
}

#pragma mark - Getter

- (CAShapeLayer *)circleLayer {
    if (!_circleLayer) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = self.bounds;
        shapeLayer.lineWidth = self.lineWidth;
        shapeLayer.lineCap = kCALineCapRound;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.strokeColor = _circleColor.CGColor;//kRefreshProgressColor.CGColor;
        shapeLayer.strokeStart = 0.0;
        shapeLayer.strokeEnd = 0.0;
        _circleLayer = shapeLayer;
        [self addSublayer:shapeLayer];
        
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
                                                            radius:(CGRectGetWidth(self.frame) - shapeLayer.lineWidth) * 0.5
                                                        startAngle:-M_PI_2
                                                          endAngle:M_PI_2*(3)
                                                         clockwise:YES];
        shapeLayer.path = path.CGPath;
    }
    return _circleLayer;
}

- (CABasicAnimation *)rotationAnimation {
    if (!_rotationAnimation) {
        _rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        _rotationAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
        _rotationAnimation.duration = 1.0;
        _rotationAnimation.repeatCount = INFINITY;
        _rotationAnimation.autoreverses = NO;
        _rotationAnimation.delegate = self;
        _rotationAnimation.removedOnCompletion = NO;
        _rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    }
    
    return _rotationAnimation;
}

- (CABasicAnimation *)listRotationAnimation {
    if (!_rotationAnimation) {
        _rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        _rotationAnimation.toValue = [NSNumber numberWithFloat:(-2) * M_PI];
        _rotationAnimation.duration = 0.8;
        _rotationAnimation.repeatCount = INFINITY;
        _rotationAnimation.autoreverses = NO;
        _rotationAnimation.delegate = self;
        _rotationAnimation.removedOnCompletion = NO;
        _rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    }
    
    return _rotationAnimation;
}



- (void)animationDidStart:(CAAnimation *)anim
{
    _isAnimating = YES;
    
//    NSLog(@"======animationDidStart=====");
    
    
    
//    _circleLayer.strokeStart = 0.2;
//
//    _circleLayer.strokeEnd = 0.5;
    
    
//     _rotationAnimation.timeOffset
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    _isAnimating = NO;
//    NSLog(@"======animationDidStop=====");
    
    
    
    
}

@end
