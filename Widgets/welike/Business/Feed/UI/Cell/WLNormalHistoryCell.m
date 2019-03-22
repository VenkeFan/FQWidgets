//
//  WLNormalHistoryCell.m
//  welike
//
//  Created by 刘斌 on 2018/5/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNormalHistoryCell.h"
#import "WLSugResult.h"

#define kSearchCellIconRightMargin               4.f
#define kSearchCellTitleHeight                   19.f
#define kSearchCellNavRightMargin                14.f

@interface WLNormalHistoryCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *delBtn;
@property (nonatomic, strong) UIImageView *rightIcon;
@property (nonatomic, strong) UIView *separateLine;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation WLNormalHistoryCell

- (void)setDataSourceItem:(WLNormalHisDataSourceItem *)item indexPath:(NSIndexPath *)indexPath
{
    [self.contentView removeAllSubviews];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.indexPath = indexPath;
    
    if (self.iconView == nil)
    {
        self.iconView = [[UIImageView alloc] init];
    }
    if (item.sug.type == WELIKE_SUG_RESULT_TYPE_HIS)
    {
        self.iconView.image = [AppContext getImageForKey:@"search_sug_his"];
    }
    else if (item.sug.type == WELIKE_SUG_RESULT_TYPE_SUG)
    {
        self.iconView.image = [AppContext getImageForKey:@"search_sug_sug"];
    }
    else
    {
        self.iconView.image = nil;
    }
    self.iconView.frame = CGRectMake(kSearchCellLeftMargin, (item.cellHeight - self.iconView.image.size.height) / 2.f, self.iconView.image.size.width, self.iconView.image.size.height);
    [self.contentView addSubview:self.iconView];
    
    if (item.actionType == WELIKE_NORMAL_HISTORY_ACTION_TYPE_DEL)
    {
        if (self.delBtn == nil)
        {
            self.delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.delBtn.backgroundColor = [UIColor clearColor];
            [self.delBtn setImage:[AppContext getImageForKey:@"search_sug_del"] forState:UIControlStateNormal];
            [self.delBtn addTarget:self action:@selector(onClickRemove) forControlEvents:UIControlEventTouchUpInside];
        }
        self.delBtn.frame = CGRectMake(kScreenWidth - item.cellHeight, 0, item.cellHeight, item.cellHeight);
        [self.contentView addSubview:self.delBtn];
    }
    else if (item.actionType == WELIKE_NORMAL_HISTORY_ACTION_TYPE_NAV)
    {
        if (self.rightIcon == nil)
        {
            UIImage *icon = [AppContext getImageForKey:@"search_sug_nav"];
            self.rightIcon = [[UIImageView alloc] initWithImage:icon];
            self.rightIcon.frame = CGRectMake(kScreenWidth - kSearchCellNavRightMargin - icon.size.width, (item.cellHeight - icon.size.height) / 2.f, icon.size.width, icon.size.height);
        }
        [self.contentView addSubview:self.rightIcon];
    }
    
    NSString *resultStr = [item.sug.object copy];
    NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc] initWithString:resultStr];
    if ([item.keyword length] > 0)
    {
        NSRange kRang = [resultStr rangeOfString:item.keyword options:NSCaseInsensitiveSearch];
        if (kRang.location != NSNotFound)
        {
            [titleStr addAttribute:NSForegroundColorAttributeName value:kRichFontColor range:kRang];
        }
    }
    
    if (self.titleLabel == nil)
    {
        self.titleLabel = [[UILabel alloc] init];
    }
    self.titleLabel.frame = CGRectMake(self.iconView.right + kSearchCellIconRightMargin, (item.cellHeight - kSearchCellTitleHeight) / 2.f, kScreenWidth - (self.iconView.right + kSearchCellIconRightMargin) - item.cellHeight, kSearchCellTitleHeight);
    self.titleLabel.font = [UIFont systemFontOfSize:kNameFontSize];
    self.titleLabel.textColor = kSearchSugContentFontColor;
    self.titleLabel.attributedText = titleStr;
    [self.contentView addSubview:self.titleLabel];
    
    if (self.separateLine == nil)
    {
        self.separateLine = [[UIView alloc] init];
        self.separateLine.backgroundColor = kSeparateLineColor;
    }
    self.separateLine.frame = CGRectMake(self.titleLabel.left, item.cellHeight - 1.f, kScreenWidth - self.titleLabel.left, 1.f);
    if (item.isTail == YES)
    {
        [self.contentView addSubview:self.separateLine];
    }
}

- (void)onClickRemove
{
    if ([self.delegate respondsToSelector:@selector(onRemove:)])
    {
        [self.delegate onRemove:self.indexPath];
    }
}

@end
