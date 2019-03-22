//
//  WLBlockUserCell.m
//  welike
//
//  Created by 刘斌 on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLBlockUserCell.h"
#import "WLHeadView.h"

#define WLBlockUserCellHeight                         56.f
#define WLBlockUserCellHeadSize                       32.f
#define WLBlockUserCellHeadRight                      12.f
#define WLBlockUserCellBtnWidth                       64.f
#define WLBlockUserCellBtnHeight                      24.f
#define WLBlockUserCellBtnLeft                        10.f

@implementation WLBlockUserDataSourceItem

- (CGFloat)cellHeight
{
    return WLBlockUserCellHeight + kCommonCellMarginY;
}

@end

@interface WLBlockUserCell ()

@property (nonatomic, strong) WLHeadView *headView;
@property (nonatomic, strong) UILabel *nameView;
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) NSIndexPath *indexPath;

- (void)onUnblock;

@end

@implementation WLBlockUserCell

- (void)setDataSourceItem:(WLBlockUserDataSourceItem *)item indexPath:(NSIndexPath *)indexPath
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView removeAllSubviews];
    self.backgroundColor = [UIColor whiteColor];
    
    self.indexPath = indexPath;
    
    if (self.headView == nil)
    {
        self.headView = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
    }
    self.headView.frame = CGRectMake(kLargeBtnXMargin, (WLBlockUserCellHeight - WLBlockUserCellHeadSize) / 2.f, WLBlockUserCellHeadSize, WLBlockUserCellHeadSize);
    self.headView.headUrl = item.head;
    [self.contentView addSubview:self.headView];
    
    if (self.nameView == nil)
    {
        self.nameView = [[UILabel alloc] init];
    }
    self.nameView.frame = CGRectMake(self.headView.right + WLBlockUserCellHeadRight, 0, kScreenWidth - (self.headView.right + WLBlockUserCellHeadRight) - kLargeBtnXMargin - WLBlockUserCellBtnWidth - WLBlockUserCellBtnLeft, WLBlockUserCellHeight);
    self.nameView.textColor = kNameFontColor;
    self.nameView.font = [UIFont systemFontOfSize:kMediumNameFontSize];
    self.nameView.text = item.nickName;
    [self.contentView addSubview:self.nameView];
    
    if (self.btn == nil)
    {
        self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    self.btn.frame = CGRectMake(kScreenWidth - kLargeBtnXMargin - WLBlockUserCellBtnWidth, (WLBlockUserCellHeight - WLBlockUserCellBtnHeight) / 2.f, WLBlockUserCellBtnWidth, WLBlockUserCellBtnHeight);
    [self.btn setTitle:[AppContext getStringForKey:@"un_block" fileName:@"user"] forState:UIControlStateNormal];
    [self.btn.titleLabel setFont:[UIFont systemFontOfSize:kLightFontSize]];
    [self.btn setTitleColor:kCommonBtnTextColor forState:UIControlStateNormal];
    [self.btn setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
    [self.btn setBackgroundImage:[UIImage imageWithColor:kMainPressColor] forState:UIControlStateHighlighted];
    [self.btn.layer setMasksToBounds:YES];
    [self.btn.layer setCornerRadius:12.f];
    [self.btn addTarget:self action:@selector(onUnblock) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.btn];

    if (self.line == nil)
    {
        self.line = [[UIView alloc] init];
    }
    self.line.frame = CGRectMake(self.headView.right, WLBlockUserCellHeight - 0.5f, kScreenWidth - self.headView.right, 0.5f);
    self.line.backgroundColor = kLightBackgroundViewColor;
    [self.contentView addSubview:self.line];
}

- (void)onUnblock
{
    if ([self.delegate respondsToSelector:@selector(onUnblock:)])
    {
        [self.delegate onUnblock:self.indexPath];
    }
}

@end
