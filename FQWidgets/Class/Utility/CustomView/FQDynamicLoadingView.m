//
//  FQDynamicLoadingView.m
//  FQWidgets
//
//  Created by fan qi on 2018/7/7.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQDynamicLoadingView.h"

@interface FQDynamicLoadingView ()

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, assign, readwrite) BOOL isAnimating;

@end

@implementation FQDynamicLoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [self.layer addSublayer:self.progressLayer];
}

- (void)dealloc {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.progressLayer.frame = self.bounds;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    self.progressLayer.strokeColor = self.tintColor.CGColor;
}

#pragma mark - Public

- (void)startAnimating {
    if (self.isAnimating)
        return;
    
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation";
    animation.duration = 2.0;
    animation.fromValue = @(0.0);
    animation.toValue = @(M_PI * 2);
    
    CABasicAnimation *headAnimation = [CABasicAnimation animation];
    headAnimation.keyPath = @"strokeStart";
    headAnimation.duration = 1.f;
    headAnimation.fromValue = @(0.0);
    headAnimation.toValue = @(0.25);
    headAnimation.timingFunction = timingFunction;
    
    CABasicAnimation *tailAnimation = [CABasicAnimation animation];
    tailAnimation.keyPath = @"strokeEnd";
    tailAnimation.duration = 1.f;
    tailAnimation.fromValue = @(0.0);
    tailAnimation.toValue = @(1.0);
    tailAnimation.timingFunction = timingFunction;
    
    
    CABasicAnimation *endHeadAnimation = [CABasicAnimation animation];
    endHeadAnimation.keyPath = @"strokeStart";
    endHeadAnimation.beginTime = 1.0;
    endHeadAnimation.duration = 0.5;
    endHeadAnimation.fromValue = @(0.25);
    endHeadAnimation.toValue = @(1.0);
    endHeadAnimation.timingFunction = timingFunction;
    
    CABasicAnimation *endTailAnimation = [CABasicAnimation animation];
    endTailAnimation.keyPath = @"strokeEnd";
    endTailAnimation.beginTime = 1.0;
    endTailAnimation.duration = 0.5;
    endTailAnimation.fromValue = @(1.0);
    endTailAnimation.toValue = @(1.0);
    endTailAnimation.timingFunction = timingFunction;
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    [animations setDuration:1.5];
    [animations setAnimations:@[animation, headAnimation, tailAnimation, endHeadAnimation, endTailAnimation]];
    animations.repeatCount = INFINITY;
    animations.removedOnCompletion = NO;
    [self.progressLayer addAnimation:animations forKey:nil];
    
    self.isAnimating = YES;
}

- (void)stopAnimating {
    if (!self.isAnimating)
        return;
    
    [self.progressLayer removeAllAnimations];
    self.isAnimating = NO;
}

#pragma mark - Getter

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = self.bounds;
        _progressLayer.strokeColor = self.tintColor.CGColor;
        _progressLayer.fillColor = nil;
        _progressLayer.lineWidth = 2.0;
        _progressLayer.strokeStart = 0.0;
        _progressLayer.strokeEnd = 0.0;
        
        CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        CGFloat radius = MIN(CGRectGetWidth(self.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5) - _progressLayer.lineWidth * 0.5;
        CGFloat startAngle = 0.0;
        CGFloat endAngle = M_PI * 2;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        _progressLayer.path = path.CGPath;
    }
    return _progressLayer;
}

@end
