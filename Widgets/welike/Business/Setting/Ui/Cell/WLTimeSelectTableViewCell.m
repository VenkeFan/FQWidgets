//
//  WLTimeSelectTableViewCell.m
//  welike
//
//  Created by luxing on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTimeSelectTableViewCell.h"

#define kTimeSelectTitleMaxWidth                  180.f
#define kTimeSelectTimeMaxWidth                   65.f
#define kTimeSelectTimeTopPading                  15.f
#define kTimeSelectTimeHeight                     20.f
#define kTimeSelectTimeFont                       14.f

@interface WLTimeSelectTableViewCell ()

@property (nonatomic, strong) UILabel *fromTitleLabel;
@property (nonatomic, strong) UILabel *toTitleLabel;
@property (nonatomic, strong) UILabel *fromTimeLabel;
@property (nonatomic, strong) UILabel *toTimeLabel;
@property (nonatomic, strong) UIView *separateLine;
@property (nonatomic, strong) UIImageView *enterView;

@property (nonatomic, strong) WLTimeSelectViewModel *timeModel;

@end

@implementation WLTimeSelectTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _fromTitleLabel = [[UILabel alloc] init];
        _fromTitleLabel.backgroundColor = [UIColor clearColor];
        _fromTitleLabel.textColor = kNotificationSettingTimeTitleColor;
        _fromTitleLabel.font = kRegularFont(kTimeSelectTimeFont);
        _fromTitleLabel.numberOfLines = 1;
        [self.contentView addSubview:_fromTitleLabel];
        
        _fromTimeLabel = [[UILabel alloc] init];
        _fromTimeLabel.backgroundColor = [UIColor clearColor];
        _fromTimeLabel.textColor = kNotificationSettingTimeColor;
        _fromTimeLabel.font = [UIFont systemFontOfSize:kTimeSelectTimeFont];
        _fromTimeLabel.numberOfLines = 1;
        [self.contentView addSubview:_fromTimeLabel];
        
        _toTitleLabel = [[UILabel alloc] init];
        _toTitleLabel.backgroundColor = [UIColor clearColor];
        _toTitleLabel.textColor = kNotificationSettingTimeTitleColor;
        _toTitleLabel.font = kRegularFont(kTimeSelectTimeFont);
        _toTitleLabel.numberOfLines = 1;
        [self.contentView addSubview:_toTitleLabel];
        
        _toTimeLabel = [[UILabel alloc] init];
        _toTimeLabel.backgroundColor = [UIColor clearColor];
        _toTimeLabel.textColor = kNotificationSettingTimeColor;
        _toTimeLabel.font = [UIFont systemFontOfSize:kTimeSelectTimeFont];
        _toTimeLabel.numberOfLines = 1;
        [self.contentView addSubview:_toTimeLabel];
        
        _enterView = [[UIImageView alloc] init];
        _enterView.image = [AppContext getImageForKey:@"profile_enter_thin"];
        [_enterView sizeToFit];
        [self.contentView addSubview:self.enterView];
    }
    return self;
}

- (void)setDataSourceItem:(WLTimeSelectViewModel *)item
{
    self.timeModel = item;
    self.fromTitleLabel.text = self.timeModel.fromTitle;
    self.fromTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)self.timeModel.fromHours,(long)self.timeModel.fromMinute];
    self.toTitleLabel.text = self.timeModel.toTitle;
    self.toTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)self.timeModel.toHours,(long)self.timeModel.toMinute];
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.fromTitleLabel.frame = CGRectMake(kSettingCellMarginX, kTimeSelectTimeTopPading, kTimeSelectTitleMaxWidth, kTimeSelectTimeHeight);
    self.fromTimeLabel.frame = CGRectMake(CGRectGetWidth(self.bounds)-kSettingCellMarginX-kTimeSelectTimeMaxWidth, kTimeSelectTimeTopPading, kTimeSelectTimeMaxWidth, kTimeSelectTimeHeight);
    self.toTitleLabel.frame = CGRectMake(kSettingCellMarginX, CGRectGetHeight(self.frame)- kTimeSelectTimeTopPading-kTimeSelectTimeHeight, kTimeSelectTitleMaxWidth, kTimeSelectTimeHeight);
    self.toTimeLabel.frame = CGRectMake(CGRectGetWidth(self.bounds)-kSettingCellMarginX-kTimeSelectTimeMaxWidth,  CGRectGetHeight(self.frame)- kTimeSelectTimeTopPading-kTimeSelectTimeHeight, kTimeSelectTimeMaxWidth, kTimeSelectTimeHeight);
    CGSize size = self.enterView.frame.size;
    self.enterView.frame = CGRectMake(CGRectGetWidth(self.frame)-kSettingCellMarginX-size.width, (CGRectGetHeight(self.frame)-size.height)/2.0, size.width, size.height);
}

@end
