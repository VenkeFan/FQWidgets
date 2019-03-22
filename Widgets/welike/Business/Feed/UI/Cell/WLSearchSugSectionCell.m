//
//  WLSearchSugSectionCell.m
//  welike
//
//  Created by 刘斌 on 2018/5/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchSugSectionCell.h"

#define kSearchSugSectionCellHeight               46.f
#define kSearchSugSectionCellTitleHeight          19.f

@implementation WLSearchSugSectionItem

- (id)init
{
    self = [super init];
    if (self)
    {
        _cellHeight = kSearchSugSectionCellHeight;
    }
    return self;
}

@end

@interface WLSearchSugSectionCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *delBtn;
@property (nonatomic, strong) UIView *separateLine;

@end

@implementation WLSearchSugSectionCell

- (void)setDataSourceItem:(WLSearchSugSectionItem *)item
{
    [self.contentView removeAllSubviews];
    
    self.backgroundColor = [UIColor whiteColor];
    
    if (self.delBtn == nil)
    {
        self.delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.delBtn.backgroundColor = [UIColor clearColor];
        [self.delBtn setImage:[AppContext getImageForKey:@"search_his_section_del"] forState:UIControlStateNormal];
        self.delBtn.frame = CGRectMake(kScreenWidth - item.cellHeight, 0, item.cellHeight, item.cellHeight);
        [self.delBtn addTarget:self action:@selector(onClickRemoveAll) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.contentView addSubview:self.delBtn];
    
    if (self.titleLabel == nil)
    {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSearchCellLeftMargin, (item.cellHeight - kSearchSugSectionCellTitleHeight) / 2.f, (kScreenWidth - item.cellHeight - kSearchCellLeftMargin), kSearchSugSectionCellTitleHeight)];
        self.titleLabel.font = [UIFont systemFontOfSize:kNameFontSize];
        self.titleLabel.textColor = kPlaceHolderColor;
    }
    self.titleLabel.text = item.title;
    [self.contentView addSubview:self.titleLabel];
    
    self.separateLine.frame = CGRectMake(self.titleLabel.left, item.cellHeight - 1.f, kScreenWidth - self.titleLabel.left, 1.f);
    [self.contentView addSubview:self.separateLine];
}

- (void)onClickRemoveAll
{
    if ([self.delegate respondsToSelector:@selector(deleteAll)])
    {
        [self.delegate deleteAll];
    }
}

@end
