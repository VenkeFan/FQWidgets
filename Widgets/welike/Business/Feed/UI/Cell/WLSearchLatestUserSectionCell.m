//
//  WLSearchLatestUserSectionCell.m
//  welike
//
//  Created by 刘斌 on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchLatestUserSectionCell.h"

#define kSearchLatestUserSectionCellHeight               42.f
#define kSearchLatestUserSectionCellTitleHeight          19.f

@implementation WLSearchLatestUserSectionDataSourceItem

- (id)init
{
    self = [super init];
    if (self)
    {
        _cellHeight = kSearchLatestUserSectionCellHeight;
    }
    return self;
}

@end

@interface WLSearchLatestUserSectionCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *allBtn;
@property (nonatomic, strong) UIView *separateLine;

- (void)goAll;

@end

@implementation WLSearchLatestUserSectionCell

- (void)setDataSourceItem:(WLSearchLatestUserSectionDataSourceItem *)item
{
    [self.contentView removeAllSubviews];
    
    self.backgroundColor = [UIColor whiteColor];
    
    if (self.allBtn == nil)
    {
        self.allBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.allBtn.backgroundColor = [UIColor clearColor];
        [self.allBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:kMediumNameFontSize]];
        [self.allBtn setTitle:[AppContext getStringForKey:@"search_user_all_btn" fileName:@"search"] forState:UIControlStateNormal];
        [self.allBtn setTitleColor:kMainColor forState:UIControlStateNormal];
        self.allBtn.frame = CGRectMake(kScreenWidth - item.cellHeight, 0, item.cellHeight, item.cellHeight);
        [self.allBtn addTarget:self action:@selector(goAll) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.contentView addSubview:self.allBtn];
    
    if (self.titleLabel == nil)
    {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSearchCellLeftMargin, (item.cellHeight - kSearchLatestUserSectionCellTitleHeight) / 2.f, (kScreenWidth - item.cellHeight - kSearchCellLeftMargin), kSearchLatestUserSectionCellTitleHeight)];
        self.titleLabel.font = [UIFont systemFontOfSize:kNameFontSize];
        self.titleLabel.textColor = kPlaceHolderColor;
    }
    self.titleLabel.text = item.title;
    [self.contentView addSubview:self.titleLabel];
    
    self.separateLine.frame = CGRectMake(self.titleLabel.left, item.cellHeight - 1.f, kScreenWidth - self.titleLabel.left, 1.f);
    [self.contentView addSubview:self.separateLine];
}

- (void)goAll
{
    if ([self.delegate respondsToSelector:@selector(goToAll)])
    {
        [self.delegate goToAll];
    }
}

@end
