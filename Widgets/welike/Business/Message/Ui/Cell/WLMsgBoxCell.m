//
//  WLMsgBoxCell.m
//  welike
//
//  Created by 刘斌 on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLMsgBoxCell.h"
#import "WLHeadView.h"
#import "WLMsgBoxMentionNotification.h"
#import "WLMsgBoxForwardPostNotification.h"
#import "WLMsgBoxCommentNotification.h"
#import "WLMsgBoxReplyNotification.h"
#import "WLMsgBoxLikePostNotification.h"
#import "WLMsgBoxLikeCommentNotification.h"
#import "WLMsgBoxLikeReplyNotification.h"
#import "WLHandledFeedModel.h"
#import "RDLinkLabel.h"
#import "TYLabel.h"
#import "WLMsgBoxThumbView.h"
#import "WLPicPost.h"
#import "WLVideoPost.h"
#import "WLForwardPost.h"
#import "WLPicInfo.h"
#import "WLUserDetailViewController.h"
#import "WLFeedDetailViewController.h"
#import "WLSingleContentManager.h"
#import "NSDate+LuuBase.h"

#define kMsgBoxCellHeadSize               kAvatarSizeMedium
#define kMsgBoxCellYMargin                10.f
#define kMsgBoxTextLeftMargin             12.f
#define kMsgBoxTextRightMargin            24.f
#define kMsgBoxTextHeight                 18.f
#define kMsgBoxActionHeight               17.f
#define kMsgBoxTextXMargin                5.f
#define kMsgBoxActionYMargin              4.f
#define kMsgBoxTextYMargin                5.f
#define kMsgBoxSuperLikeYMargin           15.f
#define kMsgBoxSuperLikeWidth             15.f
#define kMsgBoxSuperLikeHeight            13.f
#define kMsgBoxTimeTopMargin              5.f
#define kMsgBoxTimeHeight                 14.f
#define kMsgBoxTimeWidth                  65.f
#define kMsgBoxRichMaxHeight              40.f

#define kUserLabelColor                      kUIColorFromRGB(0x2B98EE)
#define kActionLabelColor                    kUIColorFromRGB(0xAFB0B1)
#define kContentLabelColor                   kUIColorFromRGB(0x626262)
#define kUserLabelFontSize                   14.f
#define kActionLabelFontSize                 14.f
#define kContentLabelFontSize                14.f

@interface WLMsgBoxDataSourceItem ()

@property (nonatomic, assign) BOOL actionNewLine;
@property (nonatomic, strong) WLHandledFeedModel *textModel;
@property (nonatomic, copy) NSString *timeStr;
@property (nonatomic, assign) CGFloat nickNameWidth;
@property (nonatomic, assign) CGFloat actionWidth;
@property (nonatomic, copy) NSString *action;

- (NSString *)actionName;
- (WLRichContent *)richContent;

@end

@implementation WLMsgBoxDataSourceItem

- (id)init
{
    self = [super init];
    if (self)
    {
        self.end = NO;
        _cellHeight = 0;
        _actionNewLine = NO;
    }
    return self;
}

- (void)calcCellHeigth
{
    self.action = [self actionName];
    if ([self.action length] > 0)
    {
        CGFloat baseHeight = kMsgBoxCellYMargin * 2 + kMsgBoxCellThumbSize + kMsgBoxTimeTopMargin + kMsgBoxTimeHeight;
        _cellHeight = kMsgBoxCellYMargin;
        CGFloat textWidth = kScreenWidth - kLargeBtnXMargin - kMsgBoxCellHeadSize - kMsgBoxTextLeftMargin - kMsgBoxTextRightMargin - kMsgBoxCellThumbSize - kLargeBtnXMargin;
        UIFont *textFont = [UIFont systemFontOfSize:kUserLabelFontSize];
        UIFont *actionFont = [UIFont systemFontOfSize:kActionLabelFontSize];
        self.nickNameWidth = [self.notification.sourceNickName sizeWithFont:textFont size:CGSizeMake(textWidth, kMsgBoxTextHeight)].width;
        self.actionWidth = [self.action sizeWithFont:actionFont size:CGSizeMake(textWidth, kMsgBoxTextHeight)].width;
        if ((self.nickNameWidth + self.actionWidth + kMsgBoxTextXMargin) > textWidth)
        {
            _cellHeight += kMsgBoxTextHeight;
            _cellHeight += (kMsgBoxTextHeight + kMsgBoxActionYMargin + kMsgBoxActionHeight);
            _actionNewLine = YES;
        }
        else
        {
            _cellHeight += kMsgBoxTextHeight;
            _actionNewLine = NO;
        }
        
        BOOL likeType = NO;
        if ([self.notification isKindOfClass:[WLMsgBoxLikePostNotification class]] ||
            [self.notification isKindOfClass:[WLMsgBoxLikeCommentNotification class]] ||
            [self.notification isKindOfClass:[WLMsgBoxLikeReplyNotification class]])
        {
            likeType = YES;
        }
        
        if (likeType == YES)
        {
            _cellHeight = baseHeight;
        }
        else
        {
            WLRichContent *rich = [self richContent];
            if (rich != nil)
            {
                self.textModel = [[WLHandledFeedModel alloc] init];
                self.textModel.font = [UIFont systemFontOfSize:kContentLabelFontSize];;
                self.textModel.renderWidth = textWidth;
                self.textModel.lineBreakMode = NSLineBreakByCharWrapping;
                self.textModel.renderHeight = kMsgBoxRichMaxHeight;
                self.textModel.textColor = kBodyFontColor;
                [self.textModel handleRichModel:rich];
                CGFloat h = _cellHeight + self.textModel.richTextHeight + kMsgBoxCellYMargin;
                if (h > baseHeight)
                {
                    _cellHeight += kMsgBoxTextHeight * 2 + kMsgBoxCellYMargin;
                }
                else
                {
                    _cellHeight = baseHeight;
                }
            }
        }
        
        _cellHeight += 1;
        
        self.timeStr = [NSDate commentTimeStringFromTimestamp:self.notification.time];
    }
}

- (NSString *)actionName
{
    if ([self.notification isKindOfClass:[WLMsgBoxMentionNotification class]])
    {
        return [AppContext getStringForKey:@"message_comment_mentioned_you" fileName:@"im"];
    }
    else if ([self.notification isKindOfClass:[WLMsgBoxForwardPostNotification class]])
    {
        return [AppContext getStringForKey:@"message_comment_forward_text" fileName:@"im"];
    }
    else if ([self.notification isKindOfClass:[WLMsgBoxCommentNotification class]])
    {
        return [AppContext getStringForKey:@"message_comment_commented_you_post_text" fileName:@"im"];
    }
    else if ([self.notification isKindOfClass:[WLMsgBoxReplyNotification class]])
    {
        return [AppContext getStringForKey:@"message_comment_reply_you_text" fileName:@"im"];
    }
    else if ([self.notification isKindOfClass:[WLMsgBoxLikePostNotification class]])
    {
        return [AppContext getStringForKey:@"message_comment_liked_your_post_text" fileName:@"im"];
    }
    else if ([self.notification isKindOfClass:[WLMsgBoxLikeCommentNotification class]])
    {
        return [AppContext getStringForKey:@"message_comment_liked_your_comment_text" fileName:@"im"];
    }
    else if ([self.notification isKindOfClass:[WLMsgBoxLikeReplyNotification class]])
    {
        return [AppContext getStringForKey:@"message_comment_liked_your_reply_text" fileName:@"im"];
    }
    return nil;
}

- (WLRichContent *)richContent
{
    if ([self.notification isKindOfClass:[WLMsgBoxMentionNotification class]])
    {
        WLMsgBoxMentionNotification *n = (WLMsgBoxMentionNotification *)self.notification;
        if (n.parentType == WELIKE_MSG_BOX_MENTION_NOTIFICATION_TYPE_POST)
        {
            return n.parentPost.richContent;
        }
        else if (n.parentType == WELIKE_MSG_BOX_MENTION_NOTIFICATION_TYPE_COMMENT)
        {
            return n.comment.content;
        }
        else if (n.parentType == WELIKE_MSG_BOX_MENTION_NOTIFICATION_TYPE_REPLY)
        {
            return n.reply.content;
        }
    }
    else if ([self.notification isKindOfClass:[WLMsgBoxForwardPostNotification class]])
    {
        WLMsgBoxForwardPostNotification *n = (WLMsgBoxForwardPostNotification *)self.notification;
        return n.parentPost.richContent;
    }
    else if ([self.notification isKindOfClass:[WLMsgBoxCommentNotification class]])
    {
        WLMsgBoxCommentNotification *n = (WLMsgBoxCommentNotification *)self.notification;
        return n.comment.content;
    }
    else if ([self.notification isKindOfClass:[WLMsgBoxReplyNotification class]])
    {
        WLMsgBoxReplyNotification *n = (WLMsgBoxReplyNotification *)self.notification;
        return n.reply.content;
    }
    else if ([self.notification isKindOfClass:[WLMsgBoxLikePostNotification class]])
    {
        WLMsgBoxLikePostNotification *n = (WLMsgBoxLikePostNotification *)self.notification;
        return n.parentPost.richContent;
    }
    else if ([self.notification isKindOfClass:[WLMsgBoxLikeCommentNotification class]])
    {
        WLMsgBoxLikeCommentNotification *n = (WLMsgBoxLikeCommentNotification *)self.notification;
        return n.comment.content;
    }
    else if ([self.notification isKindOfClass:[WLMsgBoxLikeReplyNotification class]])
    {
        WLMsgBoxLikeReplyNotification *n = (WLMsgBoxLikeReplyNotification *)self.notification;
        return n.reply.content;
    }
    return nil;
}

@end

@interface WLMsgBoxCell () <WLHeadViewDelegate, RDLinkLabelDelegate, WLMsgBoxThumbViewDelegate>

@property (nonatomic, strong) WLHeadView *headView;
@property (nonatomic, strong) RDLinkLabel *nickNameLabel;
@property (nonatomic, strong) UILabel *actionLabel;
@property (nonatomic, strong) WLMsgBoxThumbView *thumbView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) TYLabel *contentLabel;
@property (nonatomic, strong) UIImageView *superLikeIcon;
@property (nonatomic, strong) UIView *separateLine;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *pid;

@end

@implementation WLMsgBoxCell

- (void)setDataSourceItem:(WLMsgBoxDataSourceItem *)item
{
    [self.contentView removeAllSubviews];
    
    if (self.headView == nil)
    {
        self.headView = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
    }
    self.headView.frame = CGRectMake(kLargeBtnXMargin, kLargeBtnYMargin, kMsgBoxCellHeadSize, kMsgBoxCellHeadSize);
    self.headView.headUrl = item.notification.sourceHead;
    self.headView.delegate = self;
    [self.contentView addSubview:self.headView];
    
    if (self.nickNameLabel == nil)
    {
        self.nickNameLabel = [[RDLinkLabel alloc] initWithFrame:CGRectMake(self.headView.right + kMsgBoxTextLeftMargin, self.headView.top, item.nickNameWidth, kMsgBoxTextHeight) defaultTextColor:kUserLabelColor];
    }
    self.nickNameLabel.frame = CGRectMake(self.headView.right + kMsgBoxTextLeftMargin, self.headView.top, item.nickNameWidth, kMsgBoxTextHeight);
    self.nickNameLabel.font = [UIFont systemFontOfSize:kUserLabelFontSize];
    self.nickNameLabel.text = item.notification.sourceNickName;
    self.nickNameLabel.linkTouchDelegate = self;
    self.nickNameLabel.hideBottomLine = YES;
    [self.contentView addSubview:self.nickNameLabel];
    
    if (self.actionLabel == nil)
    {
        self.actionLabel = [[UILabel alloc] init];
    }
    if (item.actionNewLine == YES)
    {
        self.actionLabel.frame = CGRectMake(self.nickNameLabel.left, self.nickNameLabel.bottom + kMsgBoxActionYMargin, item.actionWidth, kMsgBoxActionHeight);
    }
    else
    {
        self.actionLabel.frame = CGRectMake(self.nickNameLabel.right + kMsgBoxTextXMargin, self.nickNameLabel.top + 0.5f, item.actionWidth, kMsgBoxActionHeight);
    }
    self.actionLabel.font = [UIFont systemFontOfSize:kActionLabelFontSize];
    self.actionLabel.textColor = kActionLabelColor;
    self.actionLabel.text = item.action;
    [self.contentView addSubview:self.actionLabel];
    
    if (item.notification.parentPost != nil)
    {
        if (self.thumbView == nil)
        {
            self.thumbView = [[WLMsgBoxThumbView alloc] initWithFrame:CGRectMake(kScreenWidth - kLargeBtnXMargin - kMsgBoxCellThumbSize, kMsgBoxCellYMargin, kMsgBoxCellThumbSize, kMsgBoxCellThumbSize) placeholder:item.placeholder];
            self.thumbView.delegate = self;
        }
        if (item.notification.parentPost.type == WELIKE_POST_TYPE_TEXT ||
            item.notification.parentPost.type == WELIKE_POST_TYPE_LINK ||
            item.notification.parentPost.type == WELIKE_POST_TYPE_POLL ||
            item.notification.parentPost.type == WELIKE_POST_TYPE_ARTICAL)
        {
            [self thumbText:item.notification.parentPost.richContent.summary];
        }
        else if (item.notification.parentPost.type == WELIKE_POST_TYPE_PIC)
        {
            [self thumbPic:(WLPicPost *)item.notification.parentPost];
        }
        else if (item.notification.parentPost.type == WELIKE_POST_TYPE_VIDEO)
        {
            [self thumbVideo:(WLVideoPost *)item.notification.parentPost];
        }
        else if (item.notification.parentPost.type == WELIKE_POST_TYPE_FORWARD)
        {
            WLForwardPost *forwardPost = (WLForwardPost *)item.notification.parentPost;
            if ([item.notification isKindOfClass:[WLMsgBoxMentionNotification class]])
            {
                WLMsgBoxMentionNotification *mentionNotification = (WLMsgBoxMentionNotification *)item.notification;
                if (mentionNotification.parentType == WELIKE_MSG_BOX_MENTION_NOTIFICATION_TYPE_POST)
                {
                    if (forwardPost.rootPost.type == WELIKE_POST_TYPE_PIC)
                    {
                        [self thumbPic:(WLPicPost *)forwardPost.rootPost];
                    }
                    else if (forwardPost.rootPost.type == WELIKE_POST_TYPE_VIDEO)
                    {
                        [self thumbVideo:(WLVideoPost *)forwardPost.rootPost];
                    }
                    else
                    {
                        [self thumbText:forwardPost.rootPost.richContent.summary];
                    }
                }
                else
                {
                    [self thumbText:forwardPost.richContent.summary];
                }
            }
            else if ([item.notification isKindOfClass:[WLMsgBoxForwardPostNotification class]] ||
                     [item.notification isKindOfClass:[WLMsgBoxLikePostNotification class]])
            {
                if (forwardPost.rootPost.type == WELIKE_POST_TYPE_PIC)
                {
                    [self thumbPic:(WLPicPost *)forwardPost.rootPost];
                }
                else if (forwardPost.rootPost.type == WELIKE_POST_TYPE_VIDEO)
                {
                    [self thumbVideo:(WLVideoPost *)forwardPost.rootPost];
                }
                else
                {
                    [self thumbText:forwardPost.rootPost.richContent.summary];
                }
            }
            else if ([item.notification isKindOfClass:[WLMsgBoxCommentNotification class]] ||
                     [item.notification isKindOfClass:[WLMsgBoxReplyNotification class]] ||
                     [item.notification isKindOfClass:[WLMsgBoxReplyNotification class]] ||
                     [item.notification isKindOfClass:[WLMsgBoxLikeCommentNotification class]] ||
                     [item.notification isKindOfClass:[WLMsgBoxLikeReplyNotification class]])
            {
                [self thumbText:forwardPost.richContent.summary];
            }
        }
       
        [self.contentView addSubview:self.thumbView];
    }
    
    BOOL likeType = NO;
    if ([item.notification isKindOfClass:[WLMsgBoxLikePostNotification class]] ||
        [item.notification isKindOfClass:[WLMsgBoxLikeCommentNotification class]] ||
        [item.notification isKindOfClass:[WLMsgBoxLikeReplyNotification class]])
    {
        likeType = YES;
    }
    if (likeType == YES)
    {
        if (self.superLikeIcon == nil)
        {
            self.superLikeIcon = [[UIImageView alloc] init];
        }
        self.superLikeIcon.frame = CGRectMake(self.nickNameLabel.left, self.actionLabel.bottom + kMsgBoxSuperLikeYMargin, kMsgBoxSuperLikeWidth, kMsgBoxSuperLikeHeight);
        if ([item.notification isKindOfClass:[WLMsgBoxLikePostNotification class]])
        {
            WLMsgBoxLikePostNotification *postNotification = (WLMsgBoxLikePostNotification *)item.notification;
            self.superLikeIcon.image = [WLSingleContentManager superLikeImageWithExp:postNotification.superLikeExp];
        }
        else
        {
            self.superLikeIcon.image = [AppContext getImageForKey:@"feed_like_level_1"];
        }
        [self.contentView addSubview:self.superLikeIcon];
    }
    else
    {
        CGFloat textWidth = kScreenWidth - kLargeBtnXMargin - kMsgBoxCellHeadSize - kMsgBoxTextLeftMargin - kMsgBoxTextRightMargin - kMsgBoxCellThumbSize - kLargeBtnXMargin;
        if (self.contentLabel == nil)
        {
            self.contentLabel = [[TYLabel alloc] init];
        }
        self.contentLabel.frame = CGRectMake(self.nickNameLabel.left, self.actionLabel.bottom + kMsgBoxTextYMargin, textWidth, item.textModel.richTextHeight);
        self.contentLabel.backgroundColor = [UIColor clearColor];
        self.contentLabel.textColor = kContentLabelColor;
        self.contentLabel.font = [UIFont systemFontOfSize:kContentLabelFontSize];
        [self.contentLabel setTextRender:item.textModel.textRender];
        [self.contentView addSubview:self.contentLabel];
    }
    
    self.uid = item.notification.sourceUid;
    self.pid = item.notification.parentPost.pid;
    
    if (self.timeLabel == nil)
    {
        self.timeLabel = [[UILabel alloc] init];
    }
    CGFloat timeX = kScreenWidth - kLargeBtnXMargin - kMsgBoxCellThumbSize / 2.f - kMsgBoxTimeWidth / 2.f;
    self.timeLabel.frame = CGRectMake(timeX, self.thumbView.bottom + kMsgBoxTimeTopMargin, kMsgBoxTimeWidth, kMsgBoxTimeHeight);
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.font = [UIFont systemFontOfSize:kLightFontSize];
    self.timeLabel.textColor = kDateTimeFontColor;
    self.timeLabel.text = item.timeStr;
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.timeLabel];
    
    
    if (self.separateLine == nil)
    {
        self.separateLine = [[UIView alloc] init];
        self.separateLine.backgroundColor = kSeparateLineColor;
    }
    CGFloat leftPading = CGRectGetMaxX(self.headView.frame);
    self.separateLine.frame = CGRectMake(leftPading, item.cellHeight - 1.f, kScreenWidth-leftPading, 1.f);
    [self.contentView addSubview:self.separateLine];
}

- (void)onClick:(WLHeadView *)headView
{
    WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithUserID:self.uid];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
}

- (void)linkLabelClick:(RDLinkLabel *)label
{
    WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithUserID:self.uid];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
}

- (void)msgBoxThumbViewOnClick:(WLMsgBoxThumbView *)view
{
    WLFeedDetailViewController *ctr = [[WLFeedDetailViewController alloc] initWithID:self.pid];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
}

- (void)thumbText:(NSString *)summary
{
    self.thumbView.thumbUrl = nil;
    self.thumbView.isVideo = NO;
    self.thumbView.summary = summary;
}

- (void)thumbPic:(WLPicPost *)picPost
{
    self.thumbView.summary = nil;
    self.thumbView.isVideo = NO;
    if ([picPost.picInfoList count] > 0)
    {
        WLPicInfo *picInfo = [picPost.picInfoList objectAtIndex:0];
        [picInfo calculatePicThumbnailInfoWithWidth:kMsgBoxCellThumbSize];
        self.thumbView.thumbUrl = picInfo.thumbnailPicUrl;
    }
    else
    {
        self.thumbView.thumbUrl = nil;
    }
}

- (void)thumbVideo:(WLVideoPost *)videoPost
{
    self.thumbView.summary = nil;
    self.thumbView.thumbUrl = videoPost.coverUrl;
    self.thumbView.isVideo = YES;
}

@end
