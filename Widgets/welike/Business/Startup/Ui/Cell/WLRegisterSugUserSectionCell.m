//
//  WLRegisterSugUserSectionCell.m
//  welike
//
//  Created by 刘斌 on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRegisterSugUserSectionCell.h"
#import "WLRegisterSugUserSectionDataSourceItem.h"

#define kRegisterSugUserSectionTopMargin                  15.f
#define kRegisterSugUserSectionTitleHeight                20.f
#define kRegisterSugUserSectionBottomMargin               20.f
#define kRegisterSugUserSectionCheckBoxWidth              22.f
#define kRegisterSugUserSectionCheckBoxLeftMargin         15.f

@interface WLRegisterSugUserSectionCell ()

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIImageView *checkBox;

@end

@implementation WLRegisterSugUserSectionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setDataSourceItem:(WLRegisterSugUserSectionDataSourceItem *)item
{
    [self.contentView removeAllSubviews];
    
    if (self.title == nil)
    {
        self.title = [[UILabel alloc] init];
    }
    self.title.frame = CGRectMake(kLargeBtnXMargin, kRegisterSugUserSectionTopMargin, kScreenWidth - kLargeBtnXMargin - kRegisterSugUserSectionCheckBoxWidth - kRegisterSugUserSectionCheckBoxLeftMargin - kLargeBtnXMargin, kRegisterSugUserSectionTitleHeight);
    self.title.backgroundColor = [UIColor clearColor];
    self.title.textAlignment = NSTextAlignmentLeft;
    self.title.numberOfLines = 1;
    self.title.font = [UIFont systemFontOfSize:kBodyFontSize];
    self.title.textColor = kWeightTitleFontColor;
    self.title.text = item.title;
    [self.contentView addSubview:self.title];
    
    if (self.checkBox == nil)
    {
        self.checkBox = [[UIImageView alloc] init];
    }
    self.checkBox.frame = CGRectMake(kScreenWidth - kRegisterSugUserSectionCheckBoxWidth - kLargeBtnXMargin, kRegisterSugUserSectionTopMargin, kRegisterSugUserSectionCheckBoxWidth, kRegisterSugUserSectionCheckBoxWidth);
    if ([item.users count] > 0)
    {
        if ([item selectedUsersCount] == [item.users count])
        {
            self.checkBox.image = [AppContext getImageForKey:@"normal_checkbox_selected"];
        }
        else
        {
            self.checkBox.image = [AppContext getImageForKey:@"normal_checkbox_unselected"];
        }
    }
    else
    {
        self.checkBox.image = [AppContext getImageForKey:@"normal_checkbox_unselected"];
    }
    [self.contentView addSubview:self.checkBox];
}

@end
