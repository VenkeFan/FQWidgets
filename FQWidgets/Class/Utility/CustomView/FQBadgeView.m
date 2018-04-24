//
//  FQBadgeView.m
//  chongchongtv
//
//  Created by fanqi on 2017/8/8.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import "FQBadgeView.h"

static NSUInteger const FQBadgeViewMaxNumber = 99;

#define FQBadgeViewSize                 kSizeScale(26)
#define FQBadgeViewContentPadding       kSizeScale(3)
#define FQBadgeViewAdjust               kSizeScale(5)

@interface FQBadgeView ()

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CATextLayer *txtLayer;
@property (nonatomic, strong) UIFont *font;

@end

@implementation FQBadgeView

#pragma mark - LifeCycle

- (instancetype)initWithParentView:(UIView *)parentView {
    if (self = [super initWithFrame:CGRectMake(0, 0, FQBadgeViewSize, FQBadgeViewSize)]) {
        [parentView addSubview:self];
        _adjustX = kSizeScale(-5);
        _adjustY = kSizeScale(5);
        
        [self.layer addSublayer:self.shapeLayer];
        [self.shapeLayer addSublayer:self.txtLayer];
    }
    return self;
}

- (void)layoutSubviews {
//    CGRect parentBounds = self.superview.bounds;
//    self.center = CGPointMake(parentBounds.size.width - FQBadgeViewAdjust, FQBadgeViewAdjust);
    
    self.center = self.badgePosition;
    
    CGSize fontSize = [(NSString *)self.txtLayer.string sizeWithAttributes:@{NSFontAttributeName: self.font}];
    self.txtLayer.frame = CGRectMake(0, 0, fontSize.width, fontSize.height);
    self.txtLayer.position = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
}

#pragma mark - Setter

- (void)setBadgeNumber:(NSInteger)badgeNumber {
    _badgeNumber = badgeNumber;
    
    self.txtLayer.string = badgeNumber < FQBadgeViewMaxNumber ?  [NSString stringWithFormat:@"%zd", badgeNumber] : [NSString stringWithFormat:@"%zd+", FQBadgeViewMaxNumber];
    [self setNeedsLayout];
    
    {
        [self.layer removeAnimationForKey:@"badge_fade"];
        CATransition *transition = [CATransition animation];
        transition.type = kCATransitionFade;
        [self.layer addAnimation:transition forKey:@"badge_fade"];
        self.hidden = badgeNumber <= 0 ? YES : NO;
    }
}

#pragma mark - Getter

- (CGPoint)badgePosition {
    if (CGPointEqualToPoint(_badgePosition, CGPointZero)) {
        _badgePosition = CGPointMake(self.superview.bounds.size.width + self.adjustX, self.adjustY);
    }
    
    return _badgePosition;
}

- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:CGRectGetWidth(self.bounds) / 2];
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.fillColor = kUIColorFromRGB(0xFF6424).CGColor;
        layer.path = path.CGPath;
        _shapeLayer = layer;
    }
    return _shapeLayer;
}

- (CATextLayer *)txtLayer {
    if (!_txtLayer) {
        CATextLayer *layer = [CATextLayer layer];
        layer.contentsScale = [UIScreen mainScreen].scale;
        layer.foregroundColor = [UIColor whiteColor].CGColor;
        layer.alignmentMode = kCAAlignmentJustified;
        
        CFStringRef fontName = (__bridge CFStringRef)self.font.fontName;
        CGFontRef fontRef = CGFontCreateWithFontName(fontName);
        layer.font = fontRef;
        layer.fontSize = self.font.pointSize;
        CGFontRelease(fontRef);
        
        _txtLayer = layer;
    }
    return _txtLayer;
}

- (UIFont *)font {
    if (!_font) {
        _font = [UIFont systemFontOfSize:14];
    }
    return _font;
}

@end
