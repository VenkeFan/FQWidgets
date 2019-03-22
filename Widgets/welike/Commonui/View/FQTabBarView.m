//
//  FQTabBarView.m
//  WeLike
//
//  Created by fan qi on 2018/3/27.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQTabBarView.h"

#define CenterViewHeight    (60)
#define MarginX             (20)
#define MarginY             (2)

#pragma mark - ************************* FQTabBarView *************************

@interface FQTabBarView ()

@property (nonatomic, weak) UIView *publishView;
@property (nonatomic, weak) UIImageView *publishImgView;
@property (nonatomic, weak) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CABasicAnimation *rotationAnimation;

@end

@implementation FQTabBarView

#pragma mark - LifeCycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    self.backgroundColor = [UIColor whiteColor];
    
    {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = CGRectMake(0, 0, kScreenWidth, 0.0);
        shapeLayer.lineWidth = 2.0;
        shapeLayer.lineCap = kCALineCapRound;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.strokeColor = kMainColor.CGColor;
        shapeLayer.strokeStart = 0.0;
        shapeLayer.strokeEnd = 0.0;
        [self.layer addSublayer:shapeLayer];
        self.circleLayer = shapeLayer;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(shapeLayer.frame), 0)];
        shapeLayer.path = path.CGPath;
    }
    
    {
        self.layer.shadowColor = kUIColorFromRGB(0x000000).CGColor;
        self.layer.shadowOffset = CGSizeMake(0, -1);
        self.layer.shadowOpacity = 0.1;
        self.layer.shadowPath = CGPathCreateWithRect(self.bounds, NULL);
    }
    
    FQTabBarItem *publishView = ({
        FQTabBarItem *view = [[FQTabBarItem alloc] initWithFrame:CGRectMake(0, 0, kSingleTabBarHeight, kSingleTabBarHeight)];
        view.type = FQTabBarItemType_Present;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(barItemTapped:)];
        [view addGestureRecognizer:tap];
        
        UIView *publishView = [[UIView alloc] init];
        publishView.layer.contents = (__bridge id)[AppContext getImageForKey:@"main_publish_bg"].CGImage;
        publishView.frame = view.bounds;
        publishView.center = CGPointMake(CGRectGetWidth(view.bounds) * 0.5, CGRectGetHeight(view.bounds) * 0.5);
        publishView.layer.cornerRadius = publishView.frame.size.width * 0.5;
        publishView.layer.masksToBounds = YES;
        [view addSubview:publishView];
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[AppContext getImageForKey:@"main_publish_shape"]];
        imgView.center = CGPointMake(CGRectGetWidth(publishView.bounds) * 0.5, CGRectGetHeight(publishView.bounds) * 0.5);
        [publishView addSubview:imgView];
        self.publishImgView = imgView;
        
        view;
    });
    self.publishView = publishView;
    [self addSubview:publishView];
    [publishView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self).offset(-kSafeAreaBottomY * 0.5);
        make.size.mas_equalTo(kSingleTabBarHeight);
    }];
    
    FQTabBarItem *homeBtn = [self createBtnWithTitle:[AppContext getStringForKey:@"main_tab_home" fileName:@"feed"]
                                           normalImg:@"main_home_normal"
                                         selectedImg:@"main_home_selected"];
    homeBtn.selected = YES;
    [homeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(MarginX);
        make.centerY.mas_equalTo(self).offset(-kSafeAreaBottomY * 0.5);
        make.size.mas_equalTo(kSingleTabBarHeight);
    }];
    
    FQTabBarItem *disBtn = [self createBtnWithTitle:[AppContext getStringForKey:@"main_tab_discover" fileName:@"feed"]
                                          normalImg:@"main_discovery_normal"
                                        selectedImg:@"main_discovery_selected"];
    [disBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self).multipliedBy(0.5).offset(MarginX);
        make.centerY.mas_equalTo(homeBtn);
        make.size.mas_equalTo(homeBtn);
    }];
    
    FQTabBarItem *msgBtn = [self createBtnWithTitle:[AppContext getStringForKey:@"main_tab_message" fileName:@"feed"]
                                          normalImg:@"main_msg_normal"
                                        selectedImg:@"main_msg_selected"];
    [msgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self).multipliedBy(1.5).offset(-MarginX);
        make.centerY.mas_equalTo(homeBtn);
        make.size.mas_equalTo(homeBtn);
    }];
    
    FQTabBarItem *userBtn = [self createBtnWithTitle:[AppContext getStringForKey:@"main_tab_me" fileName:@"feed"]
                                           normalImg:@"main_user_normal"
                                         selectedImg:@"main_user_selected"];
    [userBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-MarginX);
        make.centerY.mas_equalTo(homeBtn);
        make.size.mas_equalTo(homeBtn);
    }];
    
    self.items = @[homeBtn, disBtn, msgBtn, userBtn];
}

#pragma mark - Public

- (void)setUploadProgress:(CGFloat)progress {
    self.circleLayer.strokeEnd = progress;
//    NSLog(@"上传进度%f",progress);
}

- (void)setUploading:(BOOL)uploading {
    if (uploading) {
        [self.publishImgView.layer addAnimation:self.rotationAnimation forKey:nil];
    } else {
        [self.publishImgView.layer removeAllAnimations];
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.circleLayer.strokeEnd = 0.0;
        [CATransaction commit];
    }
}

#pragma mark - Event

- (void)barItemTapped:(UIGestureRecognizer *)gesture {
    FQTabBarItem *barItem = (FQTabBarItem *)gesture.view;
    if (!barItem) {
        return;
    }
    
    if (barItem.type == FQTabBarItemType_Exclusive) {
        barItem.selected = YES;
        
        [self.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isEqual:barItem]) {
                [(FQTabBarItem *)obj setSelected:NO];
            }
        }];
    }
    
    if ([self.delegate respondsToSelector:@selector(tabBarView:didSelectItem:index:)]) {
        [self.delegate tabBarView:self didSelectItem:barItem index:[self.items indexOfObject:barItem]];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (!view) {
        CGPoint newPoint = [self.publishView convertPoint:point fromView:self];
        if (CGRectContainsPoint(self.publishView.bounds, newPoint)) {
            view = self.publishView;
        }
    }
    return view;
}

#pragma mark - Private

- (FQTabBarItem *)createBtnWithTitle:(NSString *)title normalImg:(NSString *)normalImg selectedImg:(NSString *)selectedImg {
    FQTabBarItem *barItem = [[FQTabBarItem alloc] initWithType:FQTabBarItemType_Exclusive];
    barItem.title = title;
    barItem.imgName = normalImg;
    barItem.selectedImgName = selectedImg;
    barItem.selected = NO;
    [self addSubview:barItem];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(barItemTapped:)];
    [barItem addGestureRecognizer:tap];
    
    return barItem;
}

#pragma mark - Getter

- (CABasicAnimation *)rotationAnimation {
    if (!_rotationAnimation) {
        _rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        _rotationAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
        _rotationAnimation.duration = 1.5;
        _rotationAnimation.repeatCount = INFINITY;
        _rotationAnimation.autoreverses = NO;
        _rotationAnimation.removedOnCompletion = NO;
        _rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    }
    
    return _rotationAnimation;
}

@end

#pragma mark - ************************* FQTabBarItem *************************

@interface FQTabBarItem ()

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIImageView *imgView;
@property (nonatomic, weak) UILabel *titleLab;
@property (nonatomic, weak) WLBadgeView *badgeView;

@end

@implementation FQTabBarItem

#pragma mark - LifeCycle

- (instancetype)initWithType:(FQTabBarItemType)type {
    if (self = [self initWithFrame:CGRectMake(0, 0, kSingleTabBarHeight, kSingleTabBarHeight)]) {
        _type = type;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_imgName.length != 0 && _title.length != 0) {
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView);
            make.centerX.mas_equalTo(self.contentView);
        }];
        
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.imgView.mas_bottom).offset(2);
            make.bottom.mas_equalTo(self.contentView);
            make.centerX.mas_equalTo(self.imgView);
        }];
    } else if (_imgName.length != 0) {
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(self.contentView);
            make.centerX.mas_equalTo(self.contentView);
        }];
    } else if (_title.length != 0) {
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(self.contentView);
            make.centerX.mas_equalTo(self.contentView);
        }];
    }
}

#pragma mark - Setter

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLab.text = title;
}

- (void)setImgName:(NSString *)imgName {
    _imgName = imgName;
    self.imgView.image = [AppContext getImageForKey:_imgName];
}

- (void)setSelectedImgName:(NSString *)selectedImgName {
    _selectedImgName = selectedImgName;
    self.imgView.highlightedImage = [AppContext getImageForKey:_selectedImgName];
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    
    if (selected) {
        self.titleLab.textColor = kMainColor;
        self.titleLab.font = kBoldFont(self.titleLab.font.pointSize);
    } else {
        self.titleLab.textColor = kNameFontColor;
        self.titleLab.font = kRegularFont(self.titleLab.font.pointSize);
    }
    
    
    self.imgView.highlighted = selected;
}

#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        UIView *view = [[UIView alloc] init];
        [self addSubview:view];
        _contentView = view;
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
            make.width.mas_equalTo(self);
        }];
    }
    return _contentView;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        UIImageView *imgView = [[UIImageView alloc] init];
        [self.contentView addSubview:imgView];
        _imgView = imgView;
    }
    return _imgView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        UILabel *lab = [[UILabel alloc] init];
        lab.font = kRegularFont(10.0);
        [self.contentView addSubview:lab];
        _titleLab = lab;
    }
    return _titleLab;
}

- (WLBadgeView *)badgeView {
    if (!_badgeView) {
        WLBadgeView *badgeView = [[WLBadgeView alloc] initWithParentView:self.imgView];
        badgeView.hidden = YES;
        _badgeView = badgeView;
    }
    return _badgeView;
}

@end
