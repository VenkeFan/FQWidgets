//
//  WLLargeBtnCell.m
//  welike
//
//  Created by 刘斌 on 2018/4/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLargeBtnCell.h"

@interface WLLargeBtnCell ()

@property (nonatomic, strong) UIButton *btn;

@end

@implementation WLLargeBtnCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.bgColor = kMainColor;
        self.selBgColor = kMainPressColor;
        self.disableBgColor = kLargeBtnDisableColor;
        self.titleColor = kCommonBtnTextColor;
        self.disableTitleColor = kCommonBtnDisableTextColor;
        _btnDisable = NO;
        
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setDataSourceItem:(WLLargeBtnDataSourceItem *)item
{
    _title = [item.title copy];
    
    CGFloat cellHeight = item.cellHeight;
    
    [self.contentView removeAllSubviews];
    
    if (self.btn == nil)
    {
        self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btn addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
    }
    CGFloat width = [LuuUtils mainScreenBounds].width - kLargeBtnXMargin * 2;
    self.btn.frame = CGRectMake(kLargeBtnXMargin, cellHeight / 2.f - kLargeBtnHeight / 2.f, width, kLargeBtnHeight);
    [self.btn.titleLabel setFont:[UIFont systemFontOfSize:kNameFontSize]];
    [self.btn.layer setMasksToBounds:YES];
    [self.btn.layer setCornerRadius:kLargeBtnRadius];
    [self.btn setTitle:self.title forState:UIControlStateNormal];
    [self.btn setTitleColor:self.titleColor forState:UIControlStateNormal];
    [self.btn setTitleColor:self.disableTitleColor forState:UIControlStateDisabled];
    [self.btn setBackgroundImage:[UIImage imageWithColor:self.bgColor] forState:UIControlStateNormal];
    [self.btn setBackgroundImage:[UIImage imageWithColor:self.selBgColor] forState:UIControlStateHighlighted];
    [self.btn setBackgroundImage:[UIImage imageWithColor:self.disableBgColor] forState:UIControlStateDisabled];
    if (self.btnDisable == YES)
    {
        self.btn.enabled = NO;
    }
    else
    {
        self.btn.enabled = YES;
    }
    [self.contentView addSubview:self.btn];
}

- (void)onClick
{
    if ([self.delegate respondsToSelector:@selector(onClickLargeBtn:)])
    {
        [self.delegate onClickLargeBtn:self.indexPath];
    }
}

@end
