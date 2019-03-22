//
//  WLNavigationBar.m
//  welike
//
//  Created by fan qi on 2018/5/9.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNavigationBar.h"
#import "WLHeadView.h"

@interface WLNavigationBar () {
    UIView *_titleView;
    UIButton *_leftBtn;
    UIButton *_rightBtn;
    UILabel *_titleLabel;
    UIView *_navLine;
    
    WLHeadView *navAvatarView;
    
    CGFloat gapInRightBtns;
}

@property (nonatomic, strong, readwrite) UIView *contentView;
@property (nonatomic, weak) UIView *subTitleView;

@property (nonatomic, assign) CGFloat statusBarHeight;

@property (nonatomic, copy) NSString *headUrl;

@end

@implementation WLNavigationBar {
    CGFloat _titleLabelWidth;
}

- (instancetype)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavBarHeight)]) {
        self.backgroundColor = kNavbarColor;
        
        [self addSubview:self.contentView];
        [self addSubview:self.navLine];
        
        self.tintColor = kNameFontColor;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = CGRectMake(0, self.statusBarHeight, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - self.statusBarHeight);
    if (CGRectGetWidth(self.leftBtn.frame) < CGRectGetHeight(self.contentView.bounds)) {
//        self.leftBtn.frame = CGRectMake(0, 0, CGRectGetHeight(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds));
        self.leftBtn.width = CGRectGetHeight(self.contentView.bounds);
    }
    
    CGFloat rightBtnWidth = CGRectGetWidth(self.rightBtn.bounds) > CGRectGetHeight(self.contentView.bounds) ? CGRectGetWidth(self.rightBtn.bounds) : CGRectGetHeight(self.contentView.bounds);
    self.rightBtn.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds) - rightBtnWidth, 0, rightBtnWidth, CGRectGetHeight(self.contentView.bounds));
    
    CGFloat left = CGRectGetMaxX(self.leftBtn.frame);
    CGFloat right = CGRectGetWidth(self.contentView.bounds) - CGRectGetMinX(self.rightBtn.frame);
    
    {
        if (self.rightBtnArray.count > 0) {
            right = 0;
            
            CGFloat defaultSize = CGRectGetHeight(self.contentView.bounds);
//            CGFloat previousSize = defaultSize;
            CGFloat left = 0;
//            CGFloat centerY = CGRectGetHeight(self.contentView.bounds) * 0.5;
            for (int i = 0; i < self.rightBtnArray.count; i++) {
                UIButton *btn = self.rightBtnArray[i];
                if (btn.frame.size.width == 0 || btn.frame.size.height == 0) {
                    btn.frame = CGRectMake(0, 0, defaultSize, defaultSize);
                }
                
                if (btn.alpha > 0.0) {
                    right += (btn.frame.size.width + gapInRightBtns);
                }
                
                if (i == 0) {
                    left = CGRectGetWidth(self.contentView.bounds) - gapInRightBtns - btn.frame.size.width;
                } else {
                    left -= (btn.frame.size.width + gapInRightBtns);
                }
                btn.left = left;
                btn.top =  (kSingleNavBarHeight - btn.height)/2.0;
                
//                previousSize = btn.frame.size.width;
            }
        }
    }
    
    CGFloat titleViewWidth = CGRectGetWidth(self.contentView.bounds) - left - right;
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.titleView.left = left;
                         self.titleView.width = titleViewWidth;
                         if (self.titleLabel.width >= titleViewWidth) {
                             self.titleLabel.width = titleViewWidth;
                         } else {
                             self.titleLabel.width = self->_titleLabelWidth;
                         }
                         
                         if (self.titleAlignment == WLNavigationBarTitleAlignment_Left) {
                             
                             if (self->_headUrl.length > 0)
                             {
                                 self.titleLabel.center = CGPointMake(CGRectGetWidth(self.titleLabel.bounds) * 0.5 + 5 + 32, CGRectGetHeight(self.titleView.bounds) * 0.5);
                             }
                             else
                             {
                                  self.titleLabel.center = CGPointMake(CGRectGetWidth(self.titleLabel.bounds) * 0.5, CGRectGetHeight(self.titleView.bounds) * 0.5);
                             }
                         } else {
                             self.titleLabel.center = CGPointMake(CGRectGetWidth(self.titleView.bounds) * 0.5, CGRectGetHeight(self.titleView.bounds) * 0.5);
                         }
                     }];
    
    self.subTitleView.center = CGPointMake(CGRectGetWidth(self.titleView.bounds) * 0.5, CGRectGetHeight(self.titleView.bounds) * 0.5);
}

#pragma mark - Override

- (void)setAlpha:(CGFloat)alpha {
    UIColor *color = self.backgroundColor;
    CGFloat red, greed, blue, oldAlpha;
    
    BOOL getted = [color getRed:&red green:&greed blue:&blue alpha:&oldAlpha];
    if (getted) {
        self.backgroundColor = [UIColor colorWithRed:red green:greed blue:blue alpha:alpha];
    }
    
    if (alpha == 0.0) {
        self.navLine.hidden = YES;
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    
    self.titleLabel.textColor = tintColor;
}

#pragma mark - Public

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
    
    [self.titleLabel sizeToFit];
    _titleLabelWidth = CGRectGetWidth(self.titleLabel.bounds);
    
    if (self.titleAlignment == WLNavigationBarTitleAlignment_Left) {
        self.titleLabel.center = CGPointMake(CGRectGetWidth(self.titleLabel.bounds) * 0.5, CGRectGetHeight(self.titleView.bounds) * 0.5);
    } else {
        self.titleLabel.center = CGPointMake(CGRectGetWidth(self.titleView.bounds) * 0.5, CGRectGetHeight(self.titleView.bounds) * 0.5);
    }
}

- (void)setTitleView:(UIView *)titleView {
    self.subTitleView = titleView;
    [self.titleView addSubview:self.subTitleView];
}

- (void)setLeftBtnTitle:(NSString *)title {
    [self.leftBtn setTitle:title forState:UIControlStateNormal];
    [self.leftBtn setImage:nil forState:UIControlStateNormal];
}

- (void)setLeftBtnImageName:(NSString *)imageName {
    [self.leftBtn setTitle:nil forState:UIControlStateNormal];
    [self.leftBtn setImage:[[AppContext getImageForKey:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
}

- (void)setRightBtnTitle:(NSString *)title {
    [self.rightBtn setTitle:title forState:UIControlStateNormal];
    [self.rightBtn setImage:nil forState:UIControlStateNormal];
}

- (void)setRightBtnImageName:(NSString *)imageName {
    [self.rightBtn setTitle:nil forState:UIControlStateNormal];
    [self.rightBtn setImage:[[AppContext getImageForKey:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
}

- (void)setRightBtnArray:(NSArray<UIButton *> *)rightBtnArray {
    _rightBtnArray = rightBtnArray;
    
    gapInRightBtns = 0;
    
    if (rightBtnArray.count > 0) {
        [self.rightBtn removeFromSuperview];
        
        for (int i = 0; i < rightBtnArray.count; i++) {
            UIButton *btn = rightBtnArray[i];
            [self.contentView addSubview:btn];
        }
    }
}

- (void)setRightBtnArrayWithGap:(NSArray<UIButton *> *)rightBtnArray {
    _rightBtnArray = rightBtnArray;
    
    gapInRightBtns = 5;
    
    if (rightBtnArray.count > 0) {
        [self.rightBtn removeFromSuperview];
        
        for (int i = 0; i < rightBtnArray.count; i++) {
            UIButton *btn = rightBtnArray[i];
            [self.contentView addSubview:btn];
        }
    }
}



- (void)setSeparateLineHidden:(BOOL)hidden {
    self.navLine.hidden = hidden;
}

-(void)addHeadView:(NSString *)headUrl userID:(NSString *)userID tapTarget:(id)target
{
    _headUrl = headUrl;
    navAvatarView = [[WLHeadView alloc] initWithFrame:CGRectMake(0, (CGRectGetHeight(self.titleView.bounds) - 32) * 0.5, 32, 32)];
    [navAvatarView fq_setImageWithURLString:headUrl
                                placeholder:[AppContext getImageForKey:@"head_default"]
                               cornerRadius:16
                                  completed:nil];
    
    
    navAvatarView.delegate = target;
    [self.titleView addSubview:navAvatarView];
    
//    self.titleView.backgroundColor = [UIColor blueColor];
    
    self.titleLabel.left = navAvatarView.right + 5 + 32;
//    self.titleLabel.backgroundColor = [UIColor redColor];
}

#pragma mark - Event

- (void)leftBtnClicked:(UIButton *)sender {
    if (sender.allTargets.count > 1) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(navigationBarLeftBtnDidClicked)]) {
        [self.delegate navigationBarLeftBtnDidClicked];
    }
}

- (void)rightBtnClicked:(UIButton *)sender {
    if (sender.allTargets.count > 1) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(navigationBarRightBtnDidClicked)]) {
        [self.delegate navigationBarRightBtnDidClicked];
    }
}

#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, self.statusBarHeight, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - self.statusBarHeight);
        _contentView = view;
        
        [view addSubview:self.leftBtn];
        [view addSubview:self.rightBtn];
        [view addSubview:self.titleView];
    }
    return _contentView;
}

- (UIView *)navLine {
    if (!_navLine) {
        _navLine = [[UIView alloc] initWithFrame:CGRectMake(0, kNavBarHeight - 0.5, CGRectGetWidth(self.bounds), 0.5)];
        _navLine.backgroundColor = kUIColorFromRGBA(0xDDDDDD, 0.5);
    }
    return _navLine;
}

- (UIButton *)leftBtn {
    if (!_leftBtn) {
        UIImage *image = [[AppContext getImageForKey:@"common_icon_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, CGRectGetHeight(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds));
        btn.hidden = YES;
        [btn setImage:image forState:UIControlStateNormal];
        [btn setTitleColor:kNameFontColor forState:UIControlStateNormal];
        btn.titleLabel.font = kBoldFont(kNoteFontSize);
        [btn addTarget:self action:@selector(leftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _leftBtn = btn;
    }
    return _leftBtn;
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.hidden = YES;
        [btn setTitleColor:kNameFontColor forState:UIControlStateNormal];
        btn.titleLabel.font = kBoldFont(kNoteFontSize);
        [btn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _rightBtn = btn;
    }
    return _rightBtn;
}

- (UIView *)titleView {
    if (!_titleView) {
        CGFloat x = CGRectGetMaxX(self.leftBtn.frame);
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(x, 0, CGRectGetWidth(self.contentView.bounds) - x * 2, CGRectGetHeight(self.contentView.bounds));
        view.clipsToBounds = YES;
        [self.contentView addSubview:view];
        _titleView = view;
    }
    return _titleView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *lab = [[UILabel alloc] init];
        lab.frame = self.titleView.bounds;
        lab.textColor = kNavbarTitleColor;
        lab.font = kBoldFont(kNameFontSize);
        lab.textAlignment = NSTextAlignmentCenter;
        [self.titleView addSubview:lab];
        _titleLabel = lab;
    }
    return _titleLabel;
}

- (CGFloat)statusBarHeight {
    if (kSystemStatusBarHeight > 0) {
        return kSystemStatusBarHeight;
    }
    
    return kIsiPhoneX ? 44 : 20;
}

@end
