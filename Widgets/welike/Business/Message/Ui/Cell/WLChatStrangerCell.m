//
//  WLChatStrangerCell.m
//  welike
//
//  Created by 刘斌 on 2018/5/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLChatStrangerCell.h"
#import "WLHeadView.h"

#define kChatCellAvatarLeftMargin                 13.f
#define kChatCellAvatarSize                       45.f
#define kChatCellTextLeftMargin                   14.f
#define kChatCellNameHeight                       19.f
#define kChatCellNameWidth                        180.f
#define kChatCellBadgeRightMargin                 36.f
#define kChatCellBadgeSize                        10.f

@interface WLChatStrangerCell ()

@property (nonatomic, strong) WLHeadView *avatarView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *redNote;
@property (nonatomic, strong) UIView *separateLine;

@end

@implementation WLChatStrangerCell

- (void)bindChat:(WLIMSession *)session
{
    [self.contentView removeAllSubviews];
    self.session = session;
    
    if (self.avatarView == nil)
    {
        self.avatarView = [[WLHeadView alloc] initWithDefaultImageId:@"chat_stranger"];
    }
    self.avatarView.frame = CGRectMake(kChatCellAvatarLeftMargin, (kChatCellHeight - kChatCellAvatarSize) / 2.f, kChatCellAvatarSize, kChatCellAvatarSize);
    [self.contentView addSubview:self.avatarView];
    
    if (self.titleLabel == nil)
    {
        self.titleLabel = [[UILabel alloc] init];
    }
    self.titleLabel.frame = CGRectMake(self.avatarView.right + kChatCellTextLeftMargin, (kChatCellHeight - kChatCellNameHeight) / 2.f, kChatCellNameWidth, kChatCellNameHeight);
    self.titleLabel.textColor = kWeightTitleFontColor;
    self.titleLabel.font = [UIFont systemFontOfSize:kNameFontSize];
    self.titleLabel.text = [AppContext getStringForKey:@"stranger" fileName:@"common"];
    [self.contentView addSubview:self.titleLabel];
    
    if (self.redNote == nil)
    {
        self.redNote = [[UIView alloc] init];
    }
    self.redNote.frame = CGRectMake(kScreenWidth - kChatCellBadgeRightMargin - kChatCellBadgeSize, (kChatCellHeight - kChatCellBadgeSize) / 2.f, kChatCellBadgeSize, kChatCellBadgeSize);
    self.redNote.backgroundColor = kMarkViewColor;
    self.redNote.layer.cornerRadius = 5.f;
    if (session.unreadCount > 0)
    {
        [self.contentView addSubview:self.redNote];
    }
    
    if (self.separateLine == nil)
    {
        self.separateLine = [[UIView alloc] init];
    }
    self.separateLine.frame = CGRectMake(self.titleLabel.left, kChatCellHeight - 1.f, kScreenWidth - self.titleLabel.left, 1.f);
    self.separateLine.backgroundColor = kSeparateLineColor;
    if (self.isTail == YES)
    {
        [self.contentView addSubview:self.separateLine];
    }
    UIImageView *enterView = [[UIImageView alloc] init];
    enterView.image = [AppContext getImageForKey:@"profile_enter_thin"];
    [enterView sizeToFit];
    self.accessoryView = enterView;
}

@end
