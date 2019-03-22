//
//  WLFeedCommentCell.m
//  welike
//
//  Created by fan qi on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFeedCommentCell.h"
#import "WLHeadView.h"
#import "TYLabel.h"
#import "WLRichItem.h"
#import "WLWebViewController.h"

#define kToolBarFontSize                    12.0
#define kToolBarNormalFontColor             kUIColorFromRGB(0x859EBC)
#define kToolBarRedFontColor                kUIColorFromRGB(0xFF6A49)

@interface WLFeedCommentCell () <TYLabelDelegate, WLHeadViewDelegate>

@property (nonatomic, strong) WLHeadView *avatarView;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) TYLabel *commentLabel;
@property (nonatomic, strong) UIView *childContentView;

@property (nonatomic, strong) UIButton *transpondBtn;
@property (nonatomic, strong) UIButton *commentBtn;
@property (nonatomic, strong) UIButton *likeBtn;
@property (nonatomic, strong) UILabel *timeLab;

@property (nonatomic, strong) UIView *separateLine;

@end

@implementation WLFeedCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _avatarView = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
        _avatarView.delegate = self;
        _avatarView.backgroundColor = [UIColor whiteColor];
        _avatarView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_avatarView];
        
        _nameLab = [self labelWithFont:commentNameFont textColor:kLightLightFontColor];
        [self.contentView addSubview:_nameLab];
        
        _commentLabel = [[TYLabel alloc] init];
        _commentLabel.delegate = self;
        [self.contentView addSubview:_commentLabel];
        
        _timeLab = [self labelWithFont:commentTimeFont textColor:kDateTimeFontColor];
        [self.contentView addSubview:_timeLab];
        
        _childContentView = [[UIView alloc] init];
        _childContentView.backgroundColor = kUIColorFromRGB(0xF8F8F8);
        _childContentView.layer.cornerRadius = kCornerRadius;
        [self.contentView addSubview:_childContentView];
        {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(childTapped)];
            [_childContentView addGestureRecognizer:tap];
        }
        
        _transpondBtn = [self buttonWithImgName:@"feed_transpond"
                                          title:nil
                                         action:@selector(transpondBtnClicked)];
        [self.contentView addSubview:_transpondBtn];
        
        _commentBtn = [self buttonWithImgName:@"feed_comment"
                                        title:nil
                                       action:@selector(commentBtnClicked)];
        [self.contentView addSubview:_commentBtn];
        
        _likeBtn = [self buttonWithImgName:@"feed_unlike"
                                     title:nil
                                    action:@selector(likeBtnClicked)];
        [self.contentView addSubview:_likeBtn];
        
        _separateLine = [[UIView alloc] init];
        _separateLine.backgroundColor = kSeparateLineColor;
        [self.contentView addSubview:_separateLine];
    }
    return self;
}

- (UILabel *)labelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *lab = [[UILabel alloc] init];
    lab.textColor = textColor;
    lab.font = font;
    lab.numberOfLines = 0;
    
    return lab;
}

- (UIButton *)buttonWithImgName:(NSString *)imgName
                          title:(NSString *)title
                         action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, commentBarBtnWidth, commentToolBarHeight);
    [btn setImage:[AppContext getImageForKey:imgName] forState:UIControlStateNormal];
    [btn setTitleColor:kToolBarNormalFontColor forState:UIControlStateNormal];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    btn.titleLabel.font = kRegularFont(kToolBarFontSize);
    btn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

#pragma mark - Public

- (void)setLayout:(WLCommentLayout *)layout {
    _layout = layout;
    
    _avatarView.frame = layout.avatarFrame;
    [_avatarView setComment:layout.commentModel];
    
    _nameLab.frame = layout.nameFrame;
    _nameLab.text = layout.commentModel.nickName;
    
    _commentLabel.frame = layout.textFrame;
    [_commentLabel setTextRender:layout.handledFeedModel.textRender];
    
    _childContentView.frame = layout.childContentFrame;
    [_childContentView removeAllSubviews];
    CGFloat y = commentPaddingY;
    for (int i = 0; i < layout.commentModel.children.count; i++) {
        if (i >= layout.childrenHandledFeedModels.count) {
            break;
        }
        
        WLHandledFeedModel *childHandleModel = layout.childrenHandledFeedModels[i];
        
        TYLabel *childLab = [[TYLabel alloc] init];
        childLab.frame = CGRectMake(commentPaddingX, y,
                                    commentContentWidth - commentPaddingX * 2, childHandleModel.richTextHeight);
        [childLab setTextRender:childHandleModel.textRender];
        [_childContentView addSubview:childLab];
        
        y += (commentPaddingY + childHandleModel.richTextHeight);
    }
    
    CGFloat centerX = kScreenWidth - commentPaddingLeft - commentBarBtnWidth * 0.5;
    CGFloat centerY = layout.toolBarTop + commentToolBarHeight * 0.5;
    {
        _likeBtn.center = CGPointMake(centerX, centerY);
        centerX -= commentBarBtnWidth;
        
        _commentBtn.center = CGPointMake(centerX, centerY);
        centerX -= commentBarBtnWidth;
        
        _transpondBtn.center = CGPointMake(centerX, centerY);
        
        layout.commentModel.likeCount > 0
        ? [_likeBtn setTitle:[NSString stringWithFormat:@"%lld", layout.commentModel.likeCount] forState:UIControlStateNormal]
        : [_likeBtn setTitle:nil forState:UIControlStateNormal];
        
        [_likeBtn setImage:layout.commentModel.like ? [AppContext getImageForKey:@"feed_liked"] : [AppContext getImageForKey:@"feed_unlike"]
                  forState:UIControlStateNormal];
        [_likeBtn setTitleColor:layout.commentModel.like ? kToolBarRedFontColor : kToolBarNormalFontColor forState:UIControlStateNormal];
    }
    
    _timeLab.text = layout.timeString;
    _timeLab.frame = CGRectMake(0, 0, centerX - CGRectGetMinX(layout.nameFrame) - commentBarBtnWidth * 0.5, _timeLab.font.pointSize);
    _timeLab.center = CGPointMake(CGRectGetMinX(layout.nameFrame) + CGRectGetWidth(_timeLab.frame) * 0.5, centerY);
    
    _separateLine.frame = CGRectMake(commentPaddingLeft + commentAvatarSize + commentPaddingX, layout.cellHeight - commentLineHeight, commentContentWidth, commentLineHeight);
}

#pragma mark - TYLabelDelegate

- (void)label:(TYLabel *)label didTappedTextHighlight:(TYTextHighlight *)textHighlight {
    NSString *key = textHighlight.userInfo.allKeys.firstObject;
    if ([key isEqualToString:WLRICH_TYPE_MENTION]) {
        if ([self.delegate respondsToSelector:@selector(feedCommentCell:didClickedUser:)]) {
            [self.delegate feedCommentCell:self didClickedUser:textHighlight.userInfo[key]];
        }
    } else if ([key isEqualToString:WLRICH_TYPE_TOPIC]) {
        if ([self.delegate respondsToSelector:@selector(feedCommentCell:didClickedTopic:)]) {
            [self.delegate feedCommentCell:self didClickedTopic:textHighlight.userInfo[key]];
        }
    } else if ([key isEqualToString:WLRICH_TYPE_LINK]) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:textHighlight.userInfo[key]]];
        WLWebViewController *webViewController = [[WLWebViewController alloc] initWithUrl:textHighlight.userInfo[key]];
        [[AppContext rootViewController] pushViewController:webViewController animated:YES];
    } else if ([key isEqualToString:WLRICH_TYPE_MORE]) {
        
    }
}

#pragma mark - WLHeadViewDelegate

- (void)onClick:(WLHeadView *)headView {
    if ([self.delegate respondsToSelector:@selector(feedCommentCell:didClickedUser:)]) {
        [self.delegate feedCommentCell:self didClickedUser:_layout.commentModel.uid];
    }
}

#pragma mark - Event

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(feedCommentCell:didClickedSelf:)]) {
        [self.delegate feedCommentCell:self didClickedSelf:_layout];
    }    
}

- (void)childTapped {
    if ([self.delegate respondsToSelector:@selector(feedCommentCell:didClickedChild:)]) {
        [self.delegate feedCommentCell:self didClickedChild:_layout];
    }
}

- (void)transpondBtnClicked {
    if ([self.delegate respondsToSelector:@selector(feedCommentCell:didClickedTranspond:)]) {
        [self.delegate feedCommentCell:self didClickedTranspond:_layout];
    }
}

- (void)commentBtnClicked {
    if ([self.delegate respondsToSelector:@selector(feedCommentCell:didClickedComment:)]) {
        [self.delegate feedCommentCell:self didClickedComment:_layout];
    }
}

- (void)likeBtnClicked {
    if ([self.delegate respondsToSelector:@selector(feedCommentCell:didClickedLike:)]) {
        [self.delegate feedCommentCell:self didClickedLike:_layout];
    }
}

@end
