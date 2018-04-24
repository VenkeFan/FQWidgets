//
//  FQTabBarView.m
//  WeLike
//
//  Created by fan qi on 2018/3/27.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQTabBarView.h"

#define CenterViewHeight    (60)
#define MarginX             kSizeScale(10)
#define MarginY             (2)

#pragma mark - ************************* FQTabBarView *************************

@interface FQTabBarView ()

@property (nonatomic, weak) UIView *publishView;

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
    
    self.layer.shadowColor = kUIColorFromRGB(0x000000).CGColor;
    self.layer.shadowOffset = CGSizeMake(0, -3);
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowPath = CGPathCreateWithRect(self.bounds, NULL);
    
    FQTabBarItem *publishView = ({
        FQTabBarItem *view = [[FQTabBarItem alloc] initWithFrame:CGRectMake(0, 0, CenterViewHeight, CenterViewHeight)];
        view.type = FQTabBarItemType_Present;
        view.layer.cornerRadius = CenterViewHeight * 0.5;
        view.backgroundColor = self.backgroundColor;
        view.layer.shadowColor = self.layer.shadowColor;
        view.layer.shadowOffset = self.layer.shadowOffset;
        view.layer.shadowOpacity = self.layer.shadowOpacity;
        view.layer.shadowPath = CGPathCreateWithRoundedRect(view.bounds, CenterViewHeight * 0.5, CenterViewHeight * 0.5, NULL);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(barItemTapped:)];
        [view addGestureRecognizer:tap];
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_publish"]];
        imgView.frame = CGRectMake(0, 0, CenterViewHeight - 12, CenterViewHeight - 12);
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
        make.bottom.mas_equalTo(self).offset(-MarginY);
        make.size.mas_equalTo(CenterViewHeight);
    }];
    
    FQTabBarItem *homeBtn = [self createBtnWithTitle:kLocalizedString(@"main_home")
                                           normalImg:@"main_home_normal"
                                         selectedImg:@"main_home_selected"];
    homeBtn.selected = YES;
    [homeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(MarginX);
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(kSingleTabBarHeight);
    }];
    
    FQTabBarItem *disBtn = [self createBtnWithTitle:kLocalizedString(@"main_discovery")
                                          normalImg:@"main_discovery_normal"
                                        selectedImg:@"main_discovery_selected"];
    [disBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self).multipliedBy(0.5).offset(MarginX);
        make.centerY.mas_equalTo(homeBtn);
        make.size.mas_equalTo(homeBtn);
    }];
    
    FQTabBarItem *msgBtn = [self createBtnWithTitle:kLocalizedString(@"main_msg")
                                          normalImg:@"main_msg_normal"
                                        selectedImg:@"main_msg_selected"];
    [msgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self).multipliedBy(1.5).offset(-MarginX);
        make.centerY.mas_equalTo(homeBtn);
        make.size.mas_equalTo(homeBtn);
    }];
    
    FQTabBarItem *userBtn = [self createBtnWithTitle:kLocalizedString(@"main_user")
                                           normalImg:@"main_user_normal"
                                         selectedImg:@"main_user_selected"];
    [userBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-MarginX);
        make.centerY.mas_equalTo(homeBtn);
        make.size.mas_equalTo(homeBtn);
    }];
    
    self.items = @[homeBtn, disBtn, msgBtn, userBtn];
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

@end

#pragma mark - ************************* FQTabBarItem *************************

@interface FQTabBarItem ()

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIImageView *imgView;
@property (nonatomic, weak) UILabel *titleLab;
@property (nonatomic, weak) FQBadgeView *badgeView;

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
    if (!kIsNullOrEmpty(_imgName) && !kIsNullOrEmpty(_title)) {
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView);
            make.centerX.mas_equalTo(self.contentView);
        }];
        
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView);
            make.centerX.mas_equalTo(self.imgView);
        }];
    } else if (!kIsNullOrEmpty(_imgName)) {
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.contentView);
        }];
    } else if (!kIsNullOrEmpty(_title)) {
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.contentView);
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
    self.imgView.image = [UIImage imageNamed:_imgName];
}

- (void)setSelectedImgName:(NSString *)selectedImgName {
    _selectedImgName = selectedImgName;
    self.imgView.highlightedImage = [UIImage imageNamed:_selectedImgName];
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    
    self.titleLab.textColor = selected ? kHeaderFontColor : kLightFontColor;
    self.imgView.highlighted = selected;
}

- (void)setBadgeNum:(NSInteger)badgeNum {
    _badgeNum = badgeNum <= 0 ? 0 : badgeNum;
    self.badgeView.badgeNumber = _badgeNum;
}

#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        CGFloat padding = 5;
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(padding, padding, CGRectGetWidth(self.bounds) - padding * 2, CGRectGetHeight(self.bounds) - padding * 2);
        [self addSubview:view];
        _contentView = view;
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
        lab.font = [UIFont systemFontOfSize:kSizeScale(10)];
        [self.contentView addSubview:lab];
        _titleLab = lab;
    }
    return _titleLab;
}

- (FQBadgeView *)badgeView {
    if (!_badgeView) {
        FQBadgeView *badgeView = [[FQBadgeView alloc] initWithParentView:self.contentView];
        badgeView.hidden = YES;
        _badgeView = badgeView;
    }
    return _badgeView;
}

@end
