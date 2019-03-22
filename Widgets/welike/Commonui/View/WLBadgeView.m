//
//  WLBadgeView.m
//  chongchongtv
//
//  Created by fanqi on 2017/8/8.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import "WLBadgeView.h"

static NSUInteger const WLBadgeViewMaxNumber = 99;

#define WLBadgeViewSize                 (26)
#define WLBadgeViewNormalSize           10
#define WLBadgeViewFontSize             12
#define WLBadgeViewContentPadding       (3)
#define WLBadgeViewAdjust               (5)

@interface WLBadgeView ()

@property (nonatomic, weak) UIView *parentView;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CATextLayer *txtLayer;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) CGPoint badgePosition;

@end

@implementation WLBadgeView

#pragma mark - LifeCycle

- (instancetype)initWithParentView:(UIView *)parentView size:(CGFloat)size fontSize:(CGFloat)fontSize {
    if (self = [self initWithSize:size fontSize:fontSize]) {
        _badgeType = WLBadgeViewType_Number;
        [parentView addSubview:self];
        _parentView = parentView;
    }
    return self;
}

- (instancetype)initWithParentView:(UIView *)parentView {
    if (self = [self initWithParentView:parentView size:WLBadgeViewNormalSize fontSize:0]) {
        _badgeType = WLBadgeViewType_Normal;
    }
    return self;
}

- (instancetype)initWithSize:(CGFloat)size fontSize:(CGFloat)fontSize {
    
    if (size == 0) {
        size = WLBadgeViewSize;
    }
    
    if (fontSize == 0) {
        fontSize = WLBadgeViewNormalSize;
    }
    
    if (self = [super initWithFrame:CGRectMake(0, 0, size, size)]) {
        self.font = [UIFont systemFontOfSize:fontSize];
        
        [self.layer addSublayer:self.shapeLayer];
    }
    return self;
}

- (instancetype)init {
    if (self = [self initWithSize:0 fontSize:0]) {
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    CGRect parentBounds = self.superview.bounds;
//    self.center = CGPointMake(parentBounds.size.width - WLBadgeViewAdjust, WLBadgeViewAdjust);
    
    if (_parentView) {
        self.center = self.badgePosition;
    }
    
    if (_badgeType == WLBadgeViewType_Number) {
        self.txtLayer.hidden = NO;
        
        CGSize fontSize = [(NSString *)self.txtLayer.string sizeWithAttributes:@{NSFontAttributeName: self.font}];
        self.txtLayer.frame = CGRectMake(0, 0, fontSize.width, fontSize.height);
        self.txtLayer.position = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
    } else {
        self.txtLayer.hidden = YES;
    }
}

#pragma mark - Setter

- (void)setBadgeNumber:(NSInteger)badgeNumber {
    if (_badgeType == WLBadgeViewType_Normal) {
        return;
    }
    
    _badgeNumber = badgeNumber;
    
    self.txtLayer.string = badgeNumber <= WLBadgeViewMaxNumber ?  [NSString stringWithFormat:@"%ld", (long)badgeNumber] : [NSString stringWithFormat:@"%ld+", (long)WLBadgeViewMaxNumber];
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
        layer.fillColor = kMarkViewColor.CGColor;
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
        [self.shapeLayer addSublayer:layer];
        
        _txtLayer = layer;
    }
    return _txtLayer;
}

@end
