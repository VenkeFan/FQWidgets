//
//  FQGradientCircleLayer.m
//  WeLike
//
//  Created by fan qi on 2018/4/2.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQGradientCircleLayer.h"

static NSString * const rotation_key = @"rotation_key";

@interface FQGradientCircleLayer ()

@property (nonatomic, weak) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CABasicAnimation *rotationAnimation;

@end

@implementation FQGradientCircleLayer

- (void)layoutSublayers {
    self.gradientLayer.frame = self.bounds;
}

#pragma mark - Public

- (void)setStrokeEnd:(CGFloat)strokeEnd {
    self.circleLayer.strokeEnd = strokeEnd;
}

- (CGFloat)strokeEnd {
    return self.circleLayer.strokeEnd;
}

- (void)beginAnimating {
    [self addAnimation:[self rotationAnimation] forKey:rotation_key];
}

- (void)stopAnimating {
    [self removeAnimationForKey:rotation_key];
}

#pragma mark - Getter

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        CAGradientLayer *layer = [CAGradientLayer layer];
        layer.frame = self.bounds;
        layer.colors = @[(__bridge id)kUIColorFromRGB(0xEEEEEE).CGColor , (__bridge id)kUIColorFromRGB(0xCECECE).CGColor];
        layer.startPoint = CGPointMake(1.0, 0.0);
        layer.endPoint = CGPointMake(0.0, 0.0);
        [self addSublayer:layer];
        _gradientLayer = layer;
        
        layer.mask = self.circleLayer;
    }
    return _gradientLayer;
}

- (CAShapeLayer *)circleLayer {
    if (!_circleLayer) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = self.bounds;
        shapeLayer.lineWidth = 3;
        shapeLayer.lineCap = kCALineCapRound;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.strokeColor = [UIColor redColor].CGColor;
        shapeLayer.strokeStart = 0.0;
        shapeLayer.strokeEnd = 0.0;
        _circleLayer = shapeLayer;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
                                                            radius:(CGRectGetWidth(self.frame) - shapeLayer.lineWidth) * 0.5
                                                        startAngle:0
                                                          endAngle:M_PI * 2
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
        _rotationAnimation.removedOnCompletion = NO;
        _rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    }
    
    return _rotationAnimation;
}

@end
