//
//  WLAboutPersonListTableViewCell.m
//  welike
//
//  Created by gyb on 2018/5/5.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLContactPersonListTableViewCell.h"
#import "WLContactsManager.h"
#import "WLHeadView.h"

@implementation WLContactPersonListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        avatar = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
        avatar.frame = CGRectMake(12, 8, 40, 40);
        avatar.backgroundColor = [UIColor whiteColor];
        avatar.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:avatar];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(avatar.right + 8, 0, kScreenWidth - avatar.right - 8 - 12, 56)];
        nameLabel.font = kRegularFont(14);
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.textColor = kBodyFontColor;
        nameLabel.text = @"";
        [self addSubview:nameLabel];

        lineView = [[UIView alloc] initWithFrame:CGRectMake(52, 55, kScreenWidth - 13, 1)];
        lineView.backgroundColor = kSeparateLineColor;
        [self addSubview:lineView];
        
    }
    return self;
}

-(void)setContact:(WLContact *)contact
{
    _contact = contact;
    
    [avatar setHeadUrl:_contact.head];

    [avatar handleVip:_contact.vip];
    
    nameLabel.text = _contact.nickName;
}

-(void)setSearchStr:(NSString *)searchStr
{
    _searchStr = searchStr;
    
    NSRange range = [_contact.nickName rangeOfString:_searchStr options:NSCaseInsensitiveSearch];
    if (range.length > 0)
    {
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:_contact.nickName] ;
        [attributedText addAttribute:NSForegroundColorAttributeName value:kMainColor range:range];
        
        nameLabel.attributedText = attributedText;
        
    }
    else
    {
        nameLabel.attributedText = [[NSAttributedString alloc] initWithString:_contact.nickName];
    }
}


@end
