//
//  WLShowAllHisCell.m
//  welike
//
//  Created by 刘斌 on 2018/5/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLShowAllHisCell.h"

#define kSearchSugCellHeight             36.f

@implementation WLShowAllHisDataSourceItem

- (id)init
{
    self = [super init];
    if (self)
    {
        _cellHeight = kSearchSugCellHeight;
    }
    return self;
}

@end

@interface WLShowAllHisCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *line;

@end

@implementation WLShowAllHisCell

- (void)setDataSourceItem:(WLShowAllHisDataSourceItem *)item
{
    [self.contentView removeAllSubviews];
    
    self.backgroundColor = [UIColor whiteColor];
    
    if (self.titleLabel == nil)
    {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, item.cellHeight)];
        self.titleLabel.font = [UIFont systemFontOfSize:kNameFontSize];
        self.titleLabel.textColor = kRichFontColor;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = [AppContext getStringForKey:@"search_all_history_text" fileName:@"search"];
    }
    [self.contentView addSubview:self.titleLabel];
    
    if (self.line == nil)
    {
        self.line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1.f)];
        self.line.backgroundColor = kSeparateLineColor;
    }
    [self.contentView addSubview:self.line];
}

@end
