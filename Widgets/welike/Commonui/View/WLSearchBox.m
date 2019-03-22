//
//  WLSearchBox.n
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchBox.h"

#define kSearchBoxYMargin                10.f
#define kSearchBoxXMargin                12.f
#define kSearchBoxIconLeftMargin         12.f
#define kSearchBoxIconRightMargin        7.f
#define kSearchBoxRightBtnRightMargin    13.f
#define kSearchBoxRightBtnLeftMargin     10.f

@interface WLSearchBox ()

@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, assign) CGFloat rightBtnWidth;
@property (nonatomic, strong) UIButton *rightBtn;

- (void)layout;

@end

@implementation WLSearchBox

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.rightBtnWidth = 0;
        self.backgroundColor = [UIColor whiteColor];
        [self layout];
    }
    return self;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = [placeholder copy];
    [self layout];
}

- (void)setLeftIconResId:(NSString *)leftIconResId
{
    _leftIconResId = [leftIconResId copy];
    [self layout];
}

- (void)setRightBtnTitle:(NSString *)rightBtnTitle
{
    _rightBtnTitle = [rightBtnTitle copy];
    if ([_rightBtnTitle length] > 0)
    {
        UIFont *font = [UIFont systemFontOfSize:kMediumNameFontSize];
        _rightBtnWidth = [_rightBtnTitle sizeWithFont:font size:CGSizeMake(self.width / 2.f, self.height - kSearchBoxYMargin * 2)].width;
    }
    else
    {
        _rightBtnWidth = 0;
    }
    [self layout];
}

- (void)layout
{
    [self removeAllSubviews];
    
    if ([self.rightBtnTitle length] > 0)
    {
        if (self.rightBtn == nil)
        {
            self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.rightBtn.backgroundColor = [UIColor clearColor];
            [self.rightBtn.titleLabel setFont:[UIFont systemFontOfSize:kMediumNameFontSize]];
            [self.rightBtn setTitleColor:kNameFontColor forState:UIControlStateNormal];
            [self.rightBtn addTarget:self action:@selector(onClickRight) forControlEvents:UIControlEventTouchUpInside];
        }
        self.rightBtn.frame = CGRectMake(self.width - kSearchBoxRightBtnRightMargin - self.rightBtnWidth, kSearchBoxYMargin, self.rightBtnWidth, self.height - kSearchBoxYMargin * 2);
        [self.rightBtn setTitle:self.rightBtnTitle forState:UIControlStateNormal];
        [self addSubview:self.rightBtn];
    }
    else
    {
        if (self.rightBtn != nil)
        {
            [self.rightBtn removeTarget:self action:@selector(onClickRight) forControlEvents:UIControlEventTouchUpInside];
        }
        self.rightBtn = nil;
    }
    
    CGRect boxFrame = CGRectZero;
    if (self.rightBtn != nil)
    {
        boxFrame = CGRectMake(kSearchBoxXMargin, kSearchBoxYMargin, self.width - kSearchBoxXMargin - self.rightBtn.width - kSearchBoxRightBtnRightMargin - kSearchBoxRightBtnLeftMargin, self.height - kSearchBoxYMargin * 2);
    }
    else
    {
        boxFrame = CGRectMake(kSearchBoxXMargin, kSearchBoxYMargin, self.width - kSearchBoxXMargin * 2, self.height - kSearchBoxYMargin * 2);
    }
    UIView *searchBoxView = [[UIView alloc] initWithFrame:boxFrame];
    searchBoxView.backgroundColor = kSearchEditorColor;
    [searchBoxView.layer setMasksToBounds:YES];
    [searchBoxView.layer setCornerRadius:kCornerRadius];
    [self addSubview:searchBoxView];
    
    if ([self.leftIconResId length] > 0)
    {
        if (self.iconView == nil)
        {
            self.iconView = [[UIImageView alloc] init];
        }
        UIImage *icon = [AppContext getImageForKey:self.leftIconResId];
        self.iconView.image = icon;
        self.iconView.frame = CGRectMake(kSearchBoxXMargin + kSearchBoxIconLeftMargin, (self.height - icon.size.height) / 2.f, icon.size.width, icon.size.height);
        [self addSubview:self.iconView];
    }
    else
    {
        self.iconView = nil;
    }
    
    if (self.searchTextField == nil)
    {
        self.searchTextField = [[UITextField alloc] init];
        self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    if (self.iconView != nil)
    {
        self.searchTextField.frame = CGRectMake(self.iconView.right + kSearchBoxIconRightMargin, boxFrame.origin.y + 1.f, boxFrame.size.width - (kSearchBoxIconLeftMargin + self.iconView.width + kSearchBoxIconRightMargin), boxFrame.size.height);
    }
    else
    {
        self.searchTextField.frame = CGRectMake(kSearchBoxIconLeftMargin, boxFrame.origin.y + 1.f, boxFrame.size.width - kSearchBoxIconLeftMargin, boxFrame.size.height);
    }
    self.searchTextField.font = [UIFont systemFontOfSize:kMediumNameFontSize];
    if ([self.placeholder length] > 0)
    {
        self.searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName:kPlaceHolderColor}];
    }
    self.searchTextField.backgroundColor = [UIColor clearColor];
    [self addSubview:self.searchTextField];
}

- (void)onClickRight
{
    if ([self.delegate respondsToSelector:@selector(onClickRightButton:)])
    {
        [self.delegate onClickRightButton:self];
    }
}

@end
