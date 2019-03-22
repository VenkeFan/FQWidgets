//
//  WLDynamicLoadingView.m
//  welike
//
//  Created by fan qi on 2018/7/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLDynamicLoadingView.h"

@interface WLDynamicLoadingView ()

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation WLDynamicLoadingView

- (instancetype)init {
    if (self = [self initWithFrame:CGRectMake(0, 0, 26, 26)]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.tintColor = kMainColor;
    [self.layer addSublayer:self.progressLayer];
    
    [self p_updatePath];
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
    if (_isAnimating)
        return;
    
    self.hidden = NO;
    
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    CGFloat strokeDuration = 1.0;
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation.z";
    animation.duration = 2.0;
    animation.fromValue = @(0.0);
    animation.toValue = @(M_PI * 2);
    
    CABasicAnimation *headAnimation = [CABasicAnimation animation];
    headAnimation.keyPath = @"strokeStart";
    headAnimation.duration = strokeDuration;
    headAnimation.fromValue = @(0.0);
    headAnimation.toValue = @(0.25);
    headAnimation.timingFunction = timingFunction;
    
    CABasicAnimation *tailAnimation = [CABasicAnimation animation];
    tailAnimation.keyPath = @"strokeEnd";
    tailAnimation.duration = strokeDuration;
    tailAnimation.fromValue = @(0.0);
    tailAnimation.toValue = @(1.0);
    tailAnimation.timingFunction = timingFunction;
    
    
    CABasicAnimation *endHeadAnimation = [CABasicAnimation animation];
    endHeadAnimation.keyPath = @"strokeStart";
    endHeadAnimation.beginTime = strokeDuration;
    endHeadAnimation.duration = strokeDuration * 0.5;
    endHeadAnimation.fromValue = @(0.25);
    endHeadAnimation.toValue = @(1.0);
    endHeadAnimation.timingFunction = timingFunction;
    
    CABasicAnimation *endTailAnimation = [CABasicAnimation animation];
    endTailAnimation.keyPath = @"strokeEnd";
    endTailAnimation.beginTime = strokeDuration;
    endTailAnimation.duration = strokeDuration * 0.5;
    endTailAnimation.fromValue = @(1.0);
    endTailAnimation.toValue = @(1.0);
    endTailAnimation.timingFunction = timingFunction;
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    [animations setDuration:1.5];
    [animations setAnimations:@[animation, headAnimation, tailAnimation, endHeadAnimation, endTailAnimation]];
    animations.repeatCount = INFINITY;
    animations.removedOnCompletion = NO;
    [self.progressLayer addAnimation:animations forKey:nil];
    
    _isAnimating = YES;
}

- (void)stopAnimating {
    if (!_isAnimating)
        return;
    
    self.hidden = YES;
    
    [self.progressLayer removeAllAnimations];
    _isAnimating = NO;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    self.progressLayer.lineWidth = lineWidth;
    [self p_updatePath];
}

- (void)setStrokeEnd:(CGFloat)strokeEnd {
    self.hidden = NO;
    self.progressLayer.strokeEnd = strokeEnd;
}

#pragma mark - Private

- (void)p_updatePath {
    self.progressLayer.strokeStart = 0.0;
    self.progressLayer.strokeEnd = 0.0;
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = MIN(CGRectGetWidth(self.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5) - self.progressLayer.lineWidth * 0.5;
    CGFloat startAngle = 0;
    CGFloat endAngle = M_PI * 2;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    self.progressLayer.path = path.CGPath;
}

#pragma mark - Getter

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = self.bounds;
        _progressLayer.strokeColor = self.tintColor.CGColor;
        _progressLayer.fillColor = nil;
        _progressLayer.lineWidth = 4.0;
        _progressLayer.strokeStart = 0.0;
        _progressLayer.strokeEnd = 0.0;
        _progressLayer.lineCap = kCALineCapRound;
    }
    return _progressLayer;
}

@end
