//
//  WLTabBar.m
//  welike
//
//  Created by fan qi on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTabBar.h"

@interface WLTabBar ()

@property (nonatomic, weak) UIView *publishView;

@end

@implementation WLTabBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    self.shadowImage = [UIImage new];
    self.backgroundImage = [UIImage new];
    
    self.layer.masksToBounds = NO;
    self.backgroundColor = [UIColor whiteColor];
    
    self.layer.shadowColor = kUIColorFromRGB(0x000000).CGColor;
    self.layer.shadowOffset = CGSizeMake(0, -3);
    self.layer.shadowOpacity = 0.2;
    CGPathRef path = CGPathCreateWithRect(self.bounds, NULL);
    self.layer.shadowPath = path;
    CGPathRelease(path);
    
    CGFloat centerViewHeight = 60;
    UIView *publishView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, centerViewHeight, centerViewHeight)];
        view.layer.cornerRadius = centerViewHeight * 0.5;
        view.backgroundColor = [UIColor whiteColor];
        view.layer.shadowColor = self.layer.shadowColor;
        view.layer.shadowOffset = self.layer.shadowOffset;
        view.layer.shadowOpacity = self.layer.shadowOpacity;
        CGPathRef path = CGPathCreateWithRoundedRect(view.bounds, centerViewHeight * 0.5, centerViewHeight * 0.5, NULL);
        view.layer.shadowPath = path;
        CGPathRelease(path);

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(barItemTapped:)];
        [view addGestureRecognizer:tap];

        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_publish"]];
        imgView.frame = CGRectMake(0, 0, centerViewHeight - 12, centerViewHeight - 12);
        [view addSubview:imgView];
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(view);
        }];

        view;
    });
    self.publishView = publishView;
    [self addSubview:publishView];
    [publishView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self).offset(-kSingleTabBarHeight * 0.3);
        make.size.mas_equalTo(centerViewHeight);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat buttonW = self.frame.size.width / 5.0;
    CGFloat buttonH = self.frame.size.height - kSafeAreaBottomY;
    
    NSInteger tabbarIndex = 0;
    for (UIView * subview in self.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            subview.frame = CGRectMake(tabbarIndex * buttonW, 0, buttonW, buttonH);
            tabbarIndex ++;
            
            if (tabbarIndex == 2) {
                tabbarIndex ++;
            }
        }
    }
}

#pragma mark - Event

- (void)barItemTapped:(UIGestureRecognizer *)gesture {
    if ([self.myDelegate respondsToSelector:@selector(tabBarDidTappedCustomView:)]) {
        [self.myDelegate tabBarDidTappedCustomView:self];
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

@end
