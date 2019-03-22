//
//  WLLoginHintView.m
//  welike
//
//  Created by fan qi on 2018/7/25.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLoginHintView.h"
#import "WLGuideViewController.h"

#define kBottom         24.0

@implementation WLLoginHintView {
    BOOL _isDisplayed;
    UILabel *_titleLab;
    UIButton *_btn;
}

+ (instancetype)instance {
    static WLLoginHintView *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[WLLoginHintView alloc] init];
        _instance.style = WLLoginHintViewStyle_Dark;
    });
    return _instance;
}

- (instancetype)init {
    CGFloat x = 16;
    if (self = [super initWithFrame:CGRectMake(x, kScreenHeight, kScreenWidth - x * 2, 56)]) {
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        self.layer.cornerRadius = kCornerRadius;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnTapped)];
        [self addGestureRecognizer:tap];
        
        [self addSubview:({
            UILabel *label = [[UILabel alloc] init];
            label.text = [self labelTitle];
            label.font = kBoldFont(kNameFontSize);
            label.textColor = [UIColor whiteColor];
            [label sizeToFit];
            label.center = CGPointMake(x + CGRectGetWidth(label.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5);
            _titleLab = label;
            
            label;
        })];
        
        [self addSubview:({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.enabled = NO;
            btn.frame = CGRectMake(0, 0, 64, 24);
            btn.center = CGPointMake(CGRectGetWidth(self.bounds) - x - CGRectGetWidth(btn.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5);
            btn.backgroundColor = kMainColor;
            [btn setTitle:[self btnTitle] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.titleLabel.font = kBoldFont(kLightFontSize);
            btn.layer.cornerRadius = kCornerRadius;
            _btn = btn;
            
            btn;
        })];
    }
    return self;
}

#pragma mark - Public

- (void)display {
    if (_isDisplayed) {
        [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:3.0];
        return;
    }
    
    _titleLab.text = [self labelTitle];
    [_btn setTitle:[self btnTitle] forState:UIControlStateNormal];
    
    _isDisplayed = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.top = kScreenHeight - kBottom - CGRectGetHeight(self.bounds);
                     }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(dismiss) withObject:nil afterDelay:3.0];
                     }];
}

- (void)setStyle:(WLLoginHintViewStyle)style {
    _style = style;
    
    switch (style) {
        case WLLoginHintViewStyle_Dark: {
            self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
            _titleLab.textColor = [UIColor whiteColor];
        }
            break;
        case WLLoginHintViewStyle_Light: {
            self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
            _titleLab.textColor = kNameFontColor;
        }
            break;
    }
}

#pragma mark - Private

- (void)dismiss {
    _isDisplayed = NO;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.top = kScreenHeight + kBottom;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

#pragma mark - Event

- (void)selfOnTapped {
    [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    [self dismiss];
    
    WLGuideViewController *ctr = [[WLGuideViewController alloc] init];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
}

#pragma mark - Getter

- (NSString *)labelTitle {
    return [AppContext getStringForKey:@"need_login" fileName:@"common"];
}

- (NSString *)btnTitle {
    return [AppContext getStringForKey:@"regist_phone_num_title" fileName:@"register"];
}

@end
