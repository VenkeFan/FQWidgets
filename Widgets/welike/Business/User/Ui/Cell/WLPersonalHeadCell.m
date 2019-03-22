//
//  WLPersonalHeadCell.m
//  welike
//
//  Created by 刘斌 on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPersonalHeadCell.h"
#import "WLHeadView.h"
#import "WLAccountManager.h"

#define kPersonalHeadCellHeight           142.f
#define kPersonalHeadCellHeadSize         kAvatarSizeLarge
#define kPersonalHeadCellHeadTop          16.f
#define kPersonalHeadCellHeadBottom       13.f
#define kPersonalHeadCellTitleHeight      18.f

@implementation WLPersonalHeadDataSourceItem

- (id)init
{
    self = [super init];
    if (self)
    {
        _cellHeight = kPersonalHeadCellHeight;
        self.head = [[AppContext getInstance].accountManager myAccount].headUrl;
    }
    return self;
}

@end

@interface WLPersonalHeadCell () <WLHeadViewDelegate>

@property (nonatomic, strong) WLHeadView *headView;
@property (nonatomic, strong) UIView *separateLine;

@end

@implementation WLPersonalHeadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setDataSourceItem:(WLPersonalHeadDataSourceItem *)item
{
    [self.contentView removeAllSubviews];
    
    self.backgroundColor = [UIColor whiteColor];
    
    if (self.headView == nil)
    {
        self.headView = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
        self.headView.delegate = self;
    }
    self.headView.frame = CGRectMake((kScreenWidth - kPersonalHeadCellHeadSize) / 2.f, kPersonalHeadCellHeadTop, kPersonalHeadCellHeadSize, kPersonalHeadCellHeadSize);
    self.headView.headUrl = item.head;
    [self.contentView addSubview:self.headView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.headView.bottom + kPersonalHeadCellHeadBottom, kScreenWidth, kPersonalHeadCellTitleHeight)];
    titleLabel.font = [UIFont systemFontOfSize:kNoteFontSize];
    titleLabel.textColor = kPlaceHolderColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = [AppContext getStringForKey:@"mine_user_host_update_photo_title" fileName:@"user"];
    [self.contentView addSubview:titleLabel];
    
    if (self.separateLine == nil)
    {
        self.separateLine = [[UIView alloc] init];
        self.separateLine.backgroundColor = kSeparateLineColor;
    }
    self.separateLine.frame = CGRectMake(0, item.cellHeight - 0.5f, kScreenWidth, 0.5f);
    [self.contentView addSubview:self.separateLine];
}

- (void)onClick:(WLHeadView *)headView
{
    if ([self.delegate respondsToSelector:@selector(onClickHead)])
    {
        [self.delegate onClickHead];
    }
}

@end
