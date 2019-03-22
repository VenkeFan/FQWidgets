//
//  WLChatBoxCell.m
//  welike
//
//  Created by luxing on 2018/6/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLChatBoxCell.h"
#import "WLHeadView.h"
#import "WLUIResourceDefine.h"
#import "WLUnreadView.h"

#define kChatCellAvatarLeftMargin                 13.f
#define kChatCellAvatarSize                       45.f
#define kChatCellTextLeftMargin                   14.f
#define kChatCellNameHeight                       19.f
#define kChatCellNameWidth                        100.f

@interface WLChatBoxCell ()

@property (nonatomic, strong) WLHeadView *avatarView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) WLUnreadView *unreadView;
@property (nonatomic, strong) UIView *separateLine;

@end

@implementation WLChatBoxCell

- (void)bindChat:(WLIMSession *)session
{
    [self.contentView removeAllSubviews];
    self.session = session;
    NSString *iconId = nil;
    NSString *titleStr = nil;
    if ([session.sessionId isEqualToString:MENTION_SESSION_SID]) {
        iconId = @"msgbox_me";
        titleStr = [AppContext getStringForKey:@"message_mention_text" fileName:@"im"];
    } else if ([session.sessionId isEqualToString:COMMENT_SESSION_SID]) {
        iconId = @"msgbox_comment";
        titleStr = [AppContext getStringForKey:@"message_comment_text" fileName:@"im"];
    } else if ([session.sessionId isEqualToString:LIKE_SESSION_SID]) {
        iconId = @"msgbox_like";
        titleStr = [AppContext getStringForKey:@"message_comment_like_text" fileName:@"im"];
    }
    if (self.avatarView == nil)
    {
        self.avatarView = [[WLHeadView alloc] initWithDefaultImageId:iconId];
        self.avatarView.userInteractionEnabled = NO;
    }
    self.avatarView.frame = CGRectMake(kChatCellAvatarLeftMargin, (kChatCellHeight - kChatCellAvatarSize) / 2.f, kChatCellAvatarSize, kChatCellAvatarSize);
    [self.contentView addSubview:self.avatarView];
    if (self.titleLabel == nil)
    {
        self.titleLabel = [[UILabel alloc] init];
    }
    self.titleLabel.frame = CGRectMake(self.avatarView.right + kChatCellTextLeftMargin, (kChatCellHeight - kChatCellNameHeight) / 2.f, kChatCellNameWidth, kChatCellNameHeight);
    self.titleLabel.textColor = kWeightTitleFontColor;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:kNameFontSize];
    self.titleLabel.text = titleStr;
    [self.contentView addSubview:self.titleLabel];
    
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
