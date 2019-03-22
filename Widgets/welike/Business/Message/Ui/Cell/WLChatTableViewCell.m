//
//  WLChatTableViewCell.m
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLChatTableViewCell.h"
#import "WLHeadView.h"
#import "WLBadgeView.h"
#import "WLUserDetailViewController.h"
#import "NSDate+LuuBase.h"

#define kChatCellAvatarLeftMargin                 13.f
#define kChatCellAvatarSize                       45.f
#define kChatCellTextLeftMargin                   14.f
#define kChatCellNameTopMargin                    18.f
#define kChatCellNameHeight                       19.f
#define kChatCellDetailHeight                     15.f
#define kChatCellTimeTopMargin                    21.f
#define kChatCellTimeRightMargin                  16.f
#define kChatCellTimeLeftMargin                   3.f
#define kChatCellTimeWidth                        90.f
#define kChatCellTimeHeight                       16.f
#define kChatCellBadgeSize                        18.f

@interface WLChatTableViewCell () <WLHeadViewDelegate>

@property (nonatomic, strong) WLHeadView *avatarView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *separateLine;

@end

@implementation WLChatTableViewCell

- (void)bindChat:(WLIMSession *)session
{
    [self.contentView removeAllSubviews];
    [self.timeLabel removeAllSubviews];
    self.session = session;
    
    if (self.avatarView == nil)
    {
        self.avatarView = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
        self.avatarView.delegate = self;
    }
    self.avatarView.frame = CGRectMake(kChatCellAvatarLeftMargin, (kChatCellHeight - kChatCellAvatarSize) / 2.f, kChatCellAvatarSize, kChatCellAvatarSize);
    self.avatarView.headUrl = session.head;
    [self.contentView addSubview:self.avatarView];
    
    CGFloat contentWidth = kScreenWidth - (self.avatarView.right + kChatCellTextLeftMargin) - kChatCellTimeRightMargin - kChatCellTimeWidth - kChatCellTimeLeftMargin + 30;
    if (self.titleLabel == nil)
    {
        self.titleLabel = [[UILabel alloc] init];
    }
    self.titleLabel.frame = CGRectMake(self.avatarView.right + kChatCellTextLeftMargin, kChatCellNameTopMargin, contentWidth, kChatCellNameHeight);
    self.titleLabel.textColor = kWeightTitleFontColor;
    self.titleLabel.font = [UIFont systemFontOfSize:kNameFontSize];
    self.titleLabel.text = session.nickName;
    [self.contentView addSubview:self.titleLabel];
    
    if (self.detailLabel == nil)
    {
        self.detailLabel = [[UILabel alloc] init];
    }
    self.detailLabel.frame = CGRectMake(self.avatarView.right + kChatCellTextLeftMargin, self.titleLabel.bottom + 3, contentWidth, kChatCellDetailHeight);
    self.detailLabel.textColor = kChatContentColor;
    self.detailLabel.font = [UIFont systemFontOfSize:kChatContentFontSize];
    if (session.msgType == WLIMMessageTypeTxt)
    {
        self.detailLabel.text = session.content;
    }
    else if (session.msgType == WLIMMessageTypePic)
    {
        self.detailLabel.text = [AppContext getStringForKey:@"im_session_pic_message" fileName:@"im"];
    }
    [self.contentView addSubview:self.detailLabel];
    
    if (self.timeLabel == nil)
    {
        self.timeLabel = [[UILabel alloc] init];
    }
    self.timeLabel.frame = CGRectMake(kScreenWidth - kChatCellTimeRightMargin - kChatCellTimeWidth, kChatCellTimeTopMargin, kChatCellTimeWidth, kChatCellTimeHeight);
    self.timeLabel.textColor = kChatContentColor;
    self.timeLabel.font = [UIFont systemFontOfSize:kChatContentFontSize];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.text = [NSDate commentTimeStringFromTimestamp:session.time];
    [self.contentView addSubview:self.timeLabel];
    
    WLBadgeView *badgeView = [[WLBadgeView alloc] initWithParentView:self.timeLabel size:kChatCellBadgeSize fontSize:kSmallBadgeNumFontSize];
    badgeView.adjustX = -14;
    badgeView.adjustY = 28;
    if (session.unreadCount > 0)
    {
        badgeView.badgeNumber = session.unreadCount;
        badgeView.hidden = NO;
    }
    else
    {
        badgeView.hidden = YES;
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
}

#pragma mark - WLHeadViewDelegate

- (void)onClick:(WLHeadView *)headView
{
    WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithUserID:self.session.remoteUid];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
}

@end
