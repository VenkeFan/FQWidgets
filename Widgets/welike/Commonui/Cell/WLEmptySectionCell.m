//
//  WLEmptySectionCell.m
//  welike
//
//  Created by 刘斌 on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLEmptySectionCell.h"

@implementation WLEmptySectionDataSourceItem

- (id)init
{
    self = [super init];
    if (self)
    {
        self.sectionMark = NO;
    }
    return self;
}

@end

@interface WLEmptySectionCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation WLEmptySectionCell

- (void)setDataSourceItem:(WLEmptySectionDataSourceItem *)item
{
    if (item.backgroundColor == nil)
    {
        self.backgroundColor = kLightBackgroundViewColor;
    }
    else
    {
        self.backgroundColor = item.backgroundColor;
    }
    
    [self.contentView removeAllSubviews];
    
    if (item.sectionMark == YES)
    {
        UIView *lightView = [[UIView alloc] initWithFrame:CGRectMake(-4, (item.cellHeight - 16)/2.0, 8, 16)];
        lightView.backgroundColor = kMainColor;
        lightView.layer.cornerRadius = 3;
        lightView.clipsToBounds = YES;
        [self addSubview:lightView];
    }
    
    if ([item.title length] > 0)
    {
        if (self.titleLabel == nil)
        {
            self.titleLabel = [[UILabel alloc] init];
        }
        self.titleLabel.frame = CGRectMake(kLargeBtnXMargin, 0, kScreenWidth - kLargeBtnXMargin, item.cellHeight);
        self.titleLabel.font = [UIFont systemFontOfSize:kMediumNameFontSize];
        self.titleLabel.textColor = kNameFontColor;
        self.titleLabel.text = item.title;
        [self.contentView addSubview:self.titleLabel];
    }
}

@end
