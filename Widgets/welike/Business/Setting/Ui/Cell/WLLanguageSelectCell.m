//
//  WLLanguageSelectCell.m
//  welike
//
//  Created by 刘斌 on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLanguageSelectCell.h"

@implementation WLLanguageSelectDataSourceItem

- (id)init
{
    self = [super init];
    if (self)
    {
        _cellHeight = kSettingCellHeight;
    }
    return self;
}

@end

@interface WLLanguageSelectCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *radioView;
@property (nonatomic, strong) UIView *separateLine;
@property (nonatomic, strong) UIImage *selectedIcon;
@property (nonatomic, strong) UIImage *unselectIcon;

@end

@implementation WLLanguageSelectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectedIcon = [AppContext getImageForKey:@"radio_on"];
        self.unselectIcon = [AppContext getImageForKey:@"radio_off"];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setDataSourceItem:(WLLanguageSelectDataSourceItem *)item
{
    [self.contentView removeAllSubviews];
    
    if ([item.display length] > 0)
    {
        if (self.titleLabel == nil)
        {
            self.titleLabel = [[UILabel alloc] init];
        }
        self.titleLabel.textColor = kNameFontColor;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:kMediumNameFontSize];
        self.titleLabel.text = item.display;
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
    
    if (self.radioView == nil)
    {
        self.radioView = [[UIImageView alloc] init];
    }
    if (item.selected == YES)
    {
        self.radioView.image = self.selectedIcon;
    }
    else
    {
        self.radioView.image = self.unselectIcon;
    }
    [self.contentView addSubview:self.radioView];
    [self.radioView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-kSearchCellLeftMargin);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    if (self.separateLine == nil)
    {
        self.separateLine = [[UIView alloc] init];
        self.separateLine.backgroundColor = kSeparateLineColor;
    }
    self.separateLine.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 0.5f, kScreenWidth, 0.5f);
    if (item.isTail == YES)
    {
        [self.contentView addSubview:self.separateLine];
    }
}

@end
