//
//  WLPersonalCell.m
//  welike
//
//  Created by 刘斌 on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPersonalCell.h"

#define kPersonalTitleHeight              42.f
#define kPersonalTitleLeftMargin          15.f
#define kPersonalTitleRightMargin         15.f
#define kPersonalSingleContentHeight      29.f
#define kPersonalMultiContentBottom       15.f
#define kPersonalNoteHeight               32.f
#define kPersonalNavWidth                 8.f
#define kPersonalNavHeight                13.f

@implementation WLPersonalDataSourceItem

- (id)init
{
    self = [super init];
    if (self)
    {
        _contentHeight = 0;
    }
    return self;
}

- (CGFloat)cellHeight
{
    CGFloat height = kPersonalTitleHeight;
    if (self.contentSingleLine == YES)
    {
        height += kPersonalSingleContentHeight;
        _contentHeight = 19.f;
    }
    else
    {
        if (_contentHeight == 0 && [self.content length] > 0)
        {
            CGSize contentSize = CGSizeMake(kScreenWidth - kPersonalTitleLeftMargin - kPersonalTitleRightMargin - kPersonalNavWidth - kPersonalTitleRightMargin, CGFLOAT_MAX);
            _contentHeight = [self.content sizeWithFont:[UIFont systemFontOfSize:kNameFontSize] size:contentSize].height;
        }
        
        if (_contentHeight == 0)
        {
            _contentHeight = 30;
        }
        
        height += _contentHeight;
    }
    height += 0.5f;
    return height;
}

@end

@interface WLPersonalCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *navIcon;
@property (nonatomic, strong) UIView *separateLine;

@end

@implementation WLPersonalCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setDataSourceItem:(WLPersonalDataSourceItem *)item
{
    [self.contentView removeAllSubviews];
    
    if (self.titleLabel == nil)
    {
        self.titleLabel = [[UILabel alloc] init];
    }
    self.titleLabel.frame = CGRectMake(kPersonalTitleLeftMargin, (kPersonalTitleHeight - 19.f) / 2.f, kScreenWidth - kPersonalTitleLeftMargin - kPersonalTitleRightMargin - kPersonalNavWidth, 19.f);
    self.titleLabel.font = [UIFont systemFontOfSize:kMediumNameFontSize];
    self.titleLabel.textColor = kPlaceHolderColor;
    self.titleLabel.text = item.title;
    [self.contentView addSubview:self.titleLabel];
    
    if (self.navIcon == nil)
    {
        self.navIcon = [[UIImageView alloc] initWithImage:[AppContext getImageForKey:@"profile_enter_thin"]];
    }
    self.navIcon.frame = CGRectMake(kScreenWidth - kPersonalTitleRightMargin - kPersonalNavWidth, (kPersonalTitleHeight - kPersonalNavHeight) / 2.f + 20, kPersonalNavWidth, kPersonalNavHeight);
    [self.contentView addSubview:self.navIcon];
    
    if (self.contentLabel == nil)
    {
        self.contentLabel = [[UILabel alloc] init];
    }
    self.contentLabel.frame = CGRectMake(kPersonalTitleLeftMargin, kPersonalTitleHeight, kScreenWidth - kPersonalTitleLeftMargin - kPersonalTitleRightMargin - kPersonalNavWidth - kPersonalTitleRightMargin, item.contentHeight);
    self.contentLabel.textColor = kNameFontColor;
    self.contentLabel.font = [UIFont systemFontOfSize:kMediumNameFontSize];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.text = item.content;
    [self.contentView addSubview:self.contentLabel];
    
    if (self.separateLine == nil)
    {
        self.separateLine = [[UIView alloc] init];
        self.separateLine.backgroundColor = kSeparateLineColor;
    }
    self.separateLine.frame = CGRectMake(10, item.cellHeight - 0.5f, kScreenWidth - 20, 1);
    if (item.isTail == YES)
    {
        [self.contentView addSubview:self.separateLine];
    }
}

@end
