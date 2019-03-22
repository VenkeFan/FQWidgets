//
//  WLSwitchCell.m
//  welike
//
//  Created by 刘斌 on 2018/5/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSwitchCell.h"

@implementation WLSwitchCellDataSourceItem

- (id)init
{
    self = [super init];
    if (self)
    {
        self.switchVal = NO;
    }
    return self;
}

@end

@interface WLSwitchCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *switcher;
@property (nonatomic, copy) NSString *t;
@property (nonatomic, strong) UIView *separateLine;

@end

@implementation WLSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setDataSourceItem:(WLSwitchCellDataSourceItem *)item
{
    [self.contentView removeAllSubviews];
    
    if ([item.title length] > 0)
    {
        if (self.titleLabel == nil)
        {
            self.titleLabel = [[UILabel alloc] init];
        }
        self.titleLabel.textColor = kNameFontColor;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:kMediumNameFontSize];
        self.titleLabel.text = item.title;
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kSettingCellMarginX);
            make.centerY.mas_equalTo(self.contentView);
        }];
    }
    else
    {
        self.titleLabel = nil;
    }
    
    if (self.switcher == nil)
    {
        self.switcher = [[UISwitch alloc] initWithFrame:CGRectZero];
        self.switcher.onTintColor = kMainColor;
        [self.switcher addTarget:self action:@selector(onSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    [self.switcher setOn:item.switchVal animated:NO];
    [self.contentView addSubview:self.switcher];
    [self.switcher mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-kSearchCellLeftMargin);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    self.t = item.tag;
    
    if (self.separateLine == nil)
    {
        self.separateLine = [[UIView alloc] init];
        self.separateLine.backgroundColor = kSeparateLineColor;
    }
    self.separateLine.frame = CGRectMake(kSettingCellMarginX, CGRectGetHeight(self.bounds) - 1.f, kScreenWidth - kSettingCellMarginX * 2.f, 1.f);
    if (item.isTail == YES)
    {
        [self.contentView addSubview:self.separateLine];
    }
}

- (void)onSwitchChanged:(id)sender
{
    UISwitch *switcher = (UISwitch *)sender;
    if (self.switcher == switcher)
    {
        if ([self.delegate respondsToSelector:@selector(switchCellTag:switchOn:)])
        {
            [self.delegate switchCellTag:self.t switchOn:switcher.isOn];
        }
    }
}

@end
