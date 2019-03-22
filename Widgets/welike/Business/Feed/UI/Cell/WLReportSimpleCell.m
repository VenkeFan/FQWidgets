//
//  WLReportSimpleCell.m
//  welike
//
//  Created by 刘斌 on 2018/5/27.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLReportSimpleCell.h"

#define kReportSimpleCellSelSize               20.f
#define kReportSimpleCellTopMargin             15.f

@interface WLReportSimpleDataSourceItem ()

@property (nonatomic, assign) CGFloat h;

@end

@implementation WLReportSimpleDataSourceItem

- (id)init
{
    self = [super init];
    if (self)
    {
        self.selected = NO;
        _titleHeight = 0;
        _h = 0;
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
    [self cellHeight];
}

- (CGFloat)cellHeight
{
    if (_h == 0)
    {
        CGFloat width = kScreenWidth - kLargeBtnXMargin * 2 - kReportSimpleCellSelSize - kLargeBtnXMargin;
        UIFont *font = [UIFont systemFontOfSize:kLinkFontSize];
        _titleHeight = [self.title sizeWithFont:font size:CGSizeMake(width, MAXFLOAT)].height;
        if (_titleHeight < kReportSimpleCellSelSize)
        {
            _titleHeight = kReportSimpleCellSelSize;
        }
        _h = kReportSimpleCellTopMargin + _titleHeight;
    }
    return _h;
}

@end

@interface WLReportSimpleCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *selView;

@end

@implementation WLReportSimpleCell

- (void)setDataSourceItem:(WLReportSimpleDataSourceItem *)item
{
    [self.contentView removeAllSubviews];
    
    self.backgroundColor = kLightBackgroundViewColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.titleLabel == nil)
    {
        self.titleLabel = [[UILabel alloc] init];
    }
    self.titleLabel.frame = CGRectMake(kLargeBtnXMargin, kReportSimpleCellTopMargin, kScreenWidth - kLargeBtnXMargin * 2 - kReportSimpleCellSelSize - kLargeBtnXMargin, item.titleHeight);
    self.titleLabel.font = [UIFont systemFontOfSize:kLinkFontSize];
    self.titleLabel.textColor = kNameFontColor;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.text = item.title;
    [self.contentView addSubview:self.titleLabel];
    
    if (self.selView == nil)
    {
        self.selView = [[UIImageView alloc] init];
    }
    self.selView.frame = CGRectMake(kScreenWidth - kLargeBtnXMargin - kReportSimpleCellSelSize, kReportSimpleCellTopMargin, kReportSimpleCellSelSize, kReportSimpleCellSelSize);
    if (item.selected == YES)
    {
        self.selView.image = [AppContext getImageForKey:@"radio_on"];
    }
    else
    {
        self.selView.image = [AppContext getImageForKey:@"radio_off"];
    }
    [self.contentView addSubview:self.selView];
}

@end
