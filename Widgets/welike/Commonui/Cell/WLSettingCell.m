//
//  WLSettingCell.m
//  welike
//
//  Created by 刘斌 on 2018/5/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSettingCell.h"
#import "WLBadgeView.h"

#define kSettingCellNavLeftMargin            10.f
#define kSettingCellBadgeSize                18.f

@interface WLSettingCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *rightContentLabel;
@property (nonatomic, strong) UIView *separateLine;
@property (nonatomic, strong) UIImageView *enterView;
@property (nonatomic, strong) WLBadgeView *badgeView;

@end

@implementation WLSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setDataSourceItem:(WLSettingDataSourceItem *)item
{
    [self.contentView removeAllSubviews];
    
    if ([item.iconResId length] > 0)
    {
        if (self.iconView == nil)
        {
            self.iconView = [[UIImageView alloc] init];
        }
        UIImage *icon = [AppContext getImageForKey:item.iconResId];
        self.iconView.image = icon;
        [self.contentView addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView).offset(kSettingCellMarginX);
            make.centerY.mas_equalTo(self.contentView);
            make.width.mas_equalTo(icon.size.width);
            make.height.mas_equalTo(icon.size.height);
        }];
    }
    else
    {
        self.iconView = nil;
    }
    
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
        if (self.iconView != nil)
        {
            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.iconView.mas_right).offset(kSettingCellMarginX);
                make.centerY.mas_equalTo(self.contentView);
            }];
        }
        else
        {
            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(kSettingCellMarginX);
                make.centerY.mas_equalTo(self.contentView);
            }];
        }
    }
    else
    {
        self.titleLabel = nil;
    }
    
    if (self.enterView == nil)
    {
        self.enterView = [[UIImageView alloc] init];
    }
    self.enterView.image = [AppContext getImageForKey:@"profile_enter_thin"];
    [self.enterView sizeToFit];
    [self.contentView addSubview:self.enterView];
    if (item.enableNavMark == YES)
    {
        self.contentView.hidden = NO;
    }
    else
    {
        self.contentView.hidden = YES;
    }
    [self.enterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).offset(-kSettingCellMarginX);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    if (item.badgeNum > 0)
    {
        if (self.badgeView == nil)
        {
            self.badgeView = [[WLBadgeView alloc] initWithSize:kSettingCellBadgeSize fontSize:12];
        }
        self.badgeView.badgeType = WLBadgeViewType_Number;
        self.badgeView.badgeNumber = item.badgeNum;
        [self.contentView addSubview:self.badgeView];
        [self.badgeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.enterView.mas_left).offset(-kSettingCellNavLeftMargin);
            make.centerY.mas_equalTo(self.contentView);
            make.size.mas_equalTo(kSettingCellBadgeSize);
        }];
    }
    else
    {
        self.badgeView = nil;
    }
    
    if ([item.rightContent length] > 0)
    {
        if (self.rightContentLabel == nil)
        {
            self.rightContentLabel = [[UILabel alloc] init];
        }
        self.rightContentLabel.textColor = kSettingRightContentFontColor;
        self.rightContentLabel.font = kMediumFont(kNameFontSize);
        self.rightContentLabel.text = item.rightContent;
        [self.contentView addSubview:self.rightContentLabel];
        if (item.enableNavMark == YES)
        {
            [self.rightContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.enterView.mas_left).offset(-kSettingCellNavLeftMargin);
                make.centerY.mas_equalTo(self.contentView);
            }];
        }
        else
        {
            [self.rightContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.contentView).offset(-kSettingCellMarginX);
                make.centerY.mas_equalTo(self.contentView);
            }];
        }
    }
    else
    {
        self.rightContentLabel = nil;
    }
    
    if (self.separateLine == nil)
    {
        self.separateLine = [[UIView alloc] init];
        self.separateLine.backgroundColor = kSeparateLineColor;
    }
    self.separateLine.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 1.5f, kScreenWidth, 0);
    if (item.isTail == YES)
    {
        [self.contentView addSubview:self.separateLine];
    }
}

@end
