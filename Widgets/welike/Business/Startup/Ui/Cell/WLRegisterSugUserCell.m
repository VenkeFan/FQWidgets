//
//  WLRegisterSugUserCell.m
//  welike
//
//  Created by 刘斌 on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRegisterSugUserCell.h"
#import "WLRegisterSugUserDataSourceItem.h"
#import "WLHeadView.h"

#define kSugUserCellBottomMargin           15.f
#define kSugUserCellHeadHeight             kAvatarSizeMedium
#define kSugUserCellHeadYMargin            2.f
#define kSugUserCellHeadRightMargin        13.f
#define kSugUserCellCheckBoxWidth          22.f
#define kSugUserCellNameHeight             18.f
#define kSugUserCellCheckBoxLeftMargin     15.f
#define kSugUserCellNameBottomMargin       3.f
#define kSugUserCellIntroHeight            29.f
#define kSugUserCellCheckBoxTopMargin      14.f

@interface WLRegisterSugUserCell ()

@property (nonatomic, strong) WLHeadView *head;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *intro;
@property (nonatomic, strong) UIImageView *checkBox;

@end

@implementation WLRegisterSugUserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setDataSourceItem:(WLRegisterSugUserDataSourceItem *)item
{
    [self.contentView removeAllSubviews];
    
    if (self.head == nil)
    {
        self.head = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
    }
    self.head.frame = CGRectMake(kLargeBtnXMargin, kSugUserCellHeadYMargin, kSugUserCellHeadHeight, kSugUserCellHeadHeight);
    self.head.headUrl = item.head;
    [self.contentView addSubview:self.head];
    
    if (self.name == nil)
    {
        self.name = [[UILabel alloc] init];
    }
    self.name.frame = CGRectMake(self.head.right + kSugUserCellHeadRightMargin, self.head.top, kScreenWidth - (self.head.right + kSugUserCellHeadRightMargin) - kSugUserCellCheckBoxWidth - kSugUserCellCheckBoxLeftMargin - kLargeBtnXMargin, kSugUserCellNameHeight);
    self.name.backgroundColor = [UIColor clearColor];
    self.name.textAlignment = NSTextAlignmentLeft;
    self.name.numberOfLines = 1;
    self.name.font = [UIFont systemFontOfSize:kNoteFontSize];
    self.name.textColor = kNameFontColor;
    self.name.text = item.name;
    [self.contentView addSubview:self.name];
    
    if (self.intro == nil)
    {
        self.intro = [[UILabel alloc] init];
    }
    self.intro.frame = CGRectMake(self.head.right + kSugUserCellHeadRightMargin, self.name.bottom + kSugUserCellNameBottomMargin, kScreenWidth - (self.head.right + kSugUserCellHeadRightMargin) - kSugUserCellCheckBoxWidth - kSugUserCellCheckBoxLeftMargin - kLargeBtnXMargin, kSugUserCellIntroHeight);
    self.intro.backgroundColor = [UIColor clearColor];
    self.intro.textAlignment = NSTextAlignmentLeft;
    self.intro.numberOfLines = 2;
    self.intro.font = [UIFont systemFontOfSize:kLightFontSize];
    self.intro.textColor = kLightLightFontColor;
    self.intro.text = item.intro;
    [self.contentView addSubview:self.intro];
    
    if (self.checkBox == nil)
    {
        self.checkBox = [[UIImageView alloc] init];
    }
    self.checkBox.frame = CGRectMake(kScreenWidth - kSugUserCellCheckBoxWidth - kLargeBtnXMargin, kSugUserCellCheckBoxTopMargin, kSugUserCellCheckBoxWidth, kSugUserCellCheckBoxWidth);
    if (item.isSelected == YES)
    {
        self.checkBox.image = [AppContext getImageForKey:@"normal_checkbox_selected"];
    }
    else
    {
        self.checkBox.image = [AppContext getImageForKey:@"normal_checkbox_unselected"];
    }
    [self.contentView addSubview:self.checkBox];
}

@end
