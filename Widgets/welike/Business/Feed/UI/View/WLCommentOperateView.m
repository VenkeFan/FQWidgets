//
//  WLCommentOperateView.m
//  welike
//
//  Created by fan qi on 2018/5/18.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLCommentOperateView.h"

@interface WLCommentOperateView ()

@property (nonatomic, strong) UIButton *praiseBtn;

@end

@implementation WLCommentOperateView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shadowColor = kUIColorFromRGB(0x000000).CGColor;
    self.layer.shadowOffset = CGSizeMake(0, -1);
    self.layer.shadowOpacity = 0.1;
    
    CGFloat padding = 8;
    CGFloat size = kCommentOperateContentHeight;
    CGFloat centerX = CGRectGetWidth(self.bounds) - size * 0.5;
    CGFloat centerY = size * 0.5;
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(0, 0, size, size);
    shareBtn.center = CGPointMake(centerX, centerY);
    [shareBtn setImage:[AppContext getImageForKey:@"feed_detail_share"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:shareBtn];
    centerX -= CGRectGetWidth(shareBtn.frame);
    
    UIButton *transpondBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    transpondBtn.frame = CGRectMake(0, 0, size, size);
    transpondBtn.center = CGPointMake(centerX, centerY);
    [transpondBtn setImage:[AppContext getImageForKey:@"feed_detail_transpond"] forState:UIControlStateNormal];
    [transpondBtn addTarget:self action:@selector(transpondBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:transpondBtn];
    centerX -= CGRectGetWidth(transpondBtn.frame);
    
    UIButton *praiseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    praiseBtn.frame = CGRectMake(0, 0, size, size);
    praiseBtn.center = CGPointMake(centerX, centerY);
    [praiseBtn setImage:[AppContext getImageForKey:@"feed_detail_unlike"] forState:UIControlStateNormal];
    [praiseBtn addTarget:self action:@selector(praiseBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:praiseBtn];
    _praiseBtn = praiseBtn;
    centerX -= (CGRectGetWidth(praiseBtn.frame) * 0.5 + padding);
    
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    commentBtn.frame = CGRectMake(padding, padding, centerX - padding, kCommentOperateContentHeight - padding * 2);
    commentBtn.backgroundColor = kLightBackgroundViewColor;
    [commentBtn setImage:[AppContext getImageForKey:@"feed_detail_comment"] forState:UIControlStateNormal];
    [commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
    [commentBtn setTitle:[AppContext getStringForKey:@"comment_detail_input_placeholder" fileName:@"feed"] forState:UIControlStateNormal];
    [commentBtn setTitleColor:kPlaceHolderColor forState:UIControlStateNormal];
    commentBtn.titleLabel.font = kRegularFont(kLinkFontSize);
    commentBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [commentBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 6 + commentBtn.imageEdgeInsets.left, 0, 0)];
    commentBtn.layer.cornerRadius = kCornerRadius;
    [commentBtn addTarget:self action:@selector(commentBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:commentBtn];
}

#pragma mark - Public

- (void)setLiked:(BOOL)liked { 
    _liked = liked;
    
    [self.praiseBtn setImage:liked ? [AppContext getImageForKey:@"feed_detail_liked"] : [AppContext getImageForKey:@"feed_detail_unlike"]
                    forState:UIControlStateNormal];
}

#pragma mark - Event

- (void)transpondBtnClicked {
    if ([self.delegate respondsToSelector:@selector(commentOperateViewDidClickedTranspond:)]) {
        [self.delegate commentOperateViewDidClickedTranspond:self];
    }
}

- (void)praiseBtnClicked {
    if ([self.delegate respondsToSelector:@selector(commentOperateViewDidClickedLike:)]) {
        [self.delegate commentOperateViewDidClickedLike:self];
    }
}

- (void)shareBtnClicked {
    if ([self.delegate respondsToSelector:@selector(commentOperateViewDidClickedShare:)]) {
        [self.delegate commentOperateViewDidClickedShare:self];
    }
}

- (void)commentBtnClicked {
    if ([self.delegate respondsToSelector:@selector(commentOperateViewDidClickedComment:)]) {
        [self.delegate commentOperateViewDidClickedComment:self];
    }
}

@end

@implementation WLCommentDetailOperateView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shadowColor = kUIColorFromRGB(0x000000).CGColor;
    self.layer.shadowOffset = CGSizeMake(0, -1);
    self.layer.shadowOpacity = 0.1;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat padding = 8;
    
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    commentBtn.frame = CGRectMake(padding, padding, CGRectGetWidth(self.bounds) - padding * 2, kCommentOperateContentHeight - padding * 2);
    commentBtn.backgroundColor = kLightBackgroundViewColor;
    [commentBtn setTitle:[AppContext getStringForKey:@"comment_detail_input_placeholder" fileName:@"feed"] forState:UIControlStateNormal];
    [commentBtn setTitleColor:kPlaceHolderColor forState:UIControlStateNormal];
    commentBtn.titleLabel.font = kRegularFont(kLinkFontSize);
    commentBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [commentBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 12, 0, 0)];
    commentBtn.layer.cornerRadius = kCornerRadius;
    [commentBtn addTarget:self action:@selector(commentBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:commentBtn];
}

- (UIButton *)likeButton
{
    if (self.praiseButton == nil) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[AppContext getImageForKey:@"feed_detail_like_normal"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(praiseBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        self.praiseButton = btn;
    }
    return self.praiseButton;
}

@end
