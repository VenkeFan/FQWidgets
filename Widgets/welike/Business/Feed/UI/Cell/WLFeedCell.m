//
//  WLFeedCell.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/18.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLFeedCell.h"
#import "UIImageView+Extension.h"
#import "WLTextPost.h"
#import "WLPicPost.h"
#import "WLVideoPost.h"
#import "WLLinkPost.h"
#import "WLForwardPost.h"
#import "WLPollPost.h"
#import "WLArticalPostModel.h"
#import "WLHandledFeedModel.h"
#import "WLRichItem.h"
#import "WLAccountManager.h"
#import "WLWebViewController.h"
#import "WLTrackerPlayer.h"

CATextLayer * textLayerWithFont(UIFont *font) {
    CATextLayer *txtLayer = [CATextLayer layer];
    txtLayer.backgroundColor = [UIColor clearColor].CGColor;
    txtLayer.contentsScale = kScreenScale;
    txtLayer.alignmentMode = kCAAlignmentLeft;
    txtLayer.truncationMode = kCATruncationEnd;
    
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    txtLayer.font = fontRef;
    txtLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    
    return txtLayer;
}

@implementation WLFeedDeletedView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = kLightBackgroundViewColor;
        self.layer.cornerRadius = kCornerRadius;
        self.layer.masksToBounds = YES;
        
        UIImageView *coverLayer = [[UIImageView alloc] init];
        coverLayer.frame = CGRectMake(0, 0, CGRectGetHeight(frame), CGRectGetHeight(frame));
        coverLayer.backgroundColor = kUIColorFromRGB(0xE9E9E9);
        coverLayer.contentMode = UIViewContentModeCenter;
        coverLayer.image = [AppContext getImageForKey:@"common_placeholder_bad"];
        [self addSubview:coverLayer];
        
        CGFloat paddingX = 8;
        CGFloat x = CGRectGetMaxX(coverLayer.frame) + paddingX, y = 10;
        CGFloat textWidth = CGRectGetWidth(frame) - x - paddingX;
        
        CATextLayer *titleLayer = textLayerWithFont(cellBodyFont);
        titleLayer.frame = CGRectMake(x, y, textWidth, CGRectGetHeight(frame) - y * 2);
        titleLayer.foregroundColor = kDescFontColor.CGColor;
        titleLayer.truncationMode = kCATruncationNone;
        titleLayer.wrapped = YES;
        titleLayer.string = [AppContext getStringForKey:@"forward_feed_delete_content" fileName:@"feed"];
        
        [self.layer addSublayer:titleLayer];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnTapped)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)selfOnTapped {
    if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedFeed:)]) {
        [_cell.delegate feedCell:_cell didClickedFeed:_cell.layout];
    }
    
    [_cell setTrackerReadClickedArea:WLTrackerPostClickedArea_Text];
}

@end

@implementation WLFeedOtherInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _infoLabel = [[UILabel alloc] initWithFrame:frame];
        _infoLabel.textColor = kBodyFontColor;
        _infoLabel.textAlignment = NSTextAlignmentRight;
        _infoLabel.font = kRegularFont(kLightFontSize);
        [self addSubview:_infoLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _infoLabel.frame = self.bounds;
}

- (void)setLayout:(WLFeedLayout *)layout {
    _layout = layout;
    
    NSMutableString *strM = [[NSMutableString alloc] init];
    [strM appendString:[NSString stringWithFormat:@"%ld ", (long)layout.feedModel.commentCount]];
    [strM appendString:[AppContext getStringForKey:@"feed_detail_menu_comment" fileName:@"feed"]];
    [strM appendString:@"・"];
    [strM appendString:[NSString stringWithFormat:@"%ld ", (long)layout.feedModel.likeCount]];
    [strM appendString:[AppContext getStringForKey:@"feed_detail_menu_like" fileName:@"feed"]];
    [strM appendString:@"・"];
    [strM appendString:[NSString stringWithFormat:@"%ld ", (long)layout.feedModel.forwardCount]];
    [strM appendString:[AppContext getStringForKey:@"feed_detail_menu_forward" fileName:@"feed"]];
    
    _infoLabel.text = strM;
}

@end

@implementation WLFeedToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, cellToolBarHeight)]) {
        CGFloat width = (kScreenWidth) / 4.0;
        CGFloat x = 0;
        
        _likeBtn = [self buttonWithImgName:@"feed_unlike"
                                     title:[AppContext getStringForKey:@"comment_menu_like" fileName:@"feed"] x:x
                                     width:width
                                    action:@selector(likeBtnClicked)];
        [self addSubview:_likeBtn];
        x += width;
        
        _commentBtn = [self buttonWithImgName:@"feed_comment"
                                        title:[AppContext getStringForKey:@"comment_menu_reply" fileName:@"feed"]
                                            x:x
                                        width:width
                                       action:@selector(commentBtnClicked)];
        [self addSubview:_commentBtn];
        x += width;
        
        _transpondBtn = [self buttonWithImgName:@"feed_transpond"
                                          title:[AppContext getStringForKey:@"comment_menu_forward" fileName:@"feed"]
                                              x:x
                                          width:width
                                         action:@selector(transpondBtnClicked)];
        [self addSubview:_transpondBtn];
        x += width;
        
        _shareBtn = [self buttonWithImgName:@"feed_share"
                                      title:[AppContext getStringForKey:@"feed_share" fileName:@"feed"]
                                          x:x
                                      width:width
                                     action:@selector(shareBtnClicked)];
        [self addSubview:_shareBtn];
    }
    return self;
}

- (WLImageButton *)buttonWithImgName:(NSString *)imgName
                          title:(NSString *)title
                              x:(CGFloat)x
                          width:(CGFloat)width
                         action:(SEL)action {
    CGFloat height = cellToolBarHeight;
    
    WLImageButton *btn = [WLImageButton buttonWithType:UIButtonTypeCustom];
    btn.imageOrientation = WLImageButtonOrientation_Top;
    btn.frame = CGRectMake(x, cellLineHeight, width, height);
    [btn setImage:[AppContext getImageForKey:imgName] forState:UIControlStateNormal];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(8, 0, 2, 0)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:kFeedToolBarNormalFontColor forState:UIControlStateNormal];
    btn.titleLabel.font = kMediumFont(kFeedToolBarFontSize);
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)setLayout:(WLFeedLayout *)layout {
    _layout = layout;
    
    layout.feedModel.forwardCount > 0
    ? [_transpondBtn setTitle:[NSString stringWithFormat:@"%ld", (long)layout.feedModel.forwardCount] forState:UIControlStateNormal]
    : [_transpondBtn setTitle:[AppContext getStringForKey:@"comment_menu_forward" fileName:@"feed"] forState:UIControlStateNormal];
    
    layout.feedModel.commentCount > 0
    ? [_commentBtn setTitle:[NSString stringWithFormat:@"%ld", (long)layout.feedModel.commentCount] forState:UIControlStateNormal]
    : [_commentBtn setTitle:[AppContext getStringForKey:@"comment_menu_reply" fileName:@"feed"] forState:UIControlStateNormal];
    
    layout.feedModel.likeCount > 0
    ? [_likeBtn setTitle:[NSString stringWithFormat:@"%lld", layout.feedModel.likeCount] forState:UIControlStateNormal]
    : [_likeBtn setTitle:[AppContext getStringForKey:@"comment_menu_like" fileName:@"feed"] forState:UIControlStateNormal];
    [_likeBtn setTitleColor:layout.feedModel.like ? kFeedToolBarRedFontColor : kFeedToolBarNormalFontColor forState:UIControlStateNormal];
    [_likeBtn setImage:layout.feedModel.like ? [AppContext getImageForKey:@"feed_liked"] : [AppContext getImageForKey:@"feed_unlike"] forState:UIControlStateNormal];
//    _likeBtn.expCount = (NSUInteger)layout.feedModel.superLikeExp;
//    [_likeBtn changeLikeImageWithExp:_likeBtn.expCount];
}

- (void)shareBtnClicked {
    if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedShare:)]) {
        [_cell.delegate feedCell:_cell didClickedShare:_layout];
    }
}

- (void)transpondBtnClicked {
    if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedTranspond:)]) {
        [_cell.delegate feedCell:_cell didClickedTranspond:_layout];
    }
}

- (void)commentBtnClicked {
    if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedComment:)]) {
        [_cell.delegate feedCell:_cell didClickedComment:_layout];
    }
}

- (void)likeBtnClicked {
    if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedLike:)]) {
        [_cell.delegate feedCell:_cell didClickedLike:_layout];
    }
}

@end

@implementation WLFeedCardView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = kTableViewBgColor;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnTap)];
        [self addGestureRecognizer:tap];
        
        _coverView = [[UIImageView alloc] init];
        _coverView.backgroundColor = kUIColorFromRGB(0xE9E9E9);
        _coverView.contentMode = UIViewContentModeScaleAspectFill;
        _coverView.clipsToBounds = YES;
        [self addSubview:_coverView];
        
        _titleLayer = textLayerWithFont(cellNameFont);
        _titleLayer.foregroundColor = kNameFontColor.CGColor;
        [self.layer addSublayer:_titleLayer];
        
        _descLayer = textLayerWithFont(cellBodyFont);
        _descLayer.foregroundColor = kDescFontColor.CGColor;
        [self.layer addSublayer:_descLayer];
        
        UIColor *lineColor = kUIColorFromRGB(0xF4F4F4);
        _topLine = [CALayer layer];
        _topLine.backgroundColor = lineColor.CGColor;
        [self.layer addSublayer:_topLine];
        
        _bottomLine = [CALayer layer];
        _bottomLine.backgroundColor = lineColor.CGColor;
        [self.layer addSublayer:_bottomLine];
    }
    return self;
}

- (void)setLinkModel:(WLLinkPost *)linkModel {
    _linkModel = linkModel;
    
    __weak typeof(self) weakSelf = self;
    _coverView.frame = CGRectMake(0, 0, CGRectGetHeight(self.frame), CGRectGetHeight(self.frame));
    _coverView.contentMode = UIViewContentModeScaleAspectFill;
    [_coverView fq_setImageWithURLString:linkModel.linkThumbUrl
                             placeholder:[AppContext getImageForKey:@"link_default"]
                            cornerRadius:0
                               completed:^(UIImage *image, NSURL *url, NSError *error) {
                                   if (!image) {
                                       weakSelf.coverView.contentMode = UIViewContentModeCenter;
                                       weakSelf.coverView.image = [AppContext getImageForKey:@"link_default"];
                                   }
                               }];;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _titleLayer.string = linkModel.linkTitle;
    _descLayer.string = linkModel.linkText;
    
    CGFloat paddingX = 8, paddingY = 2;
    CGFloat x = CGRectGetMaxX(_coverView.frame) + paddingX, y = 10;
    CGFloat textWidth = CGRectGetWidth(self.frame) - x - paddingX, textHeight = 20;
    CGFloat centerY = CGRectGetHeight(self.frame) * 0.5;
    
    _titleLayer.frame = CGRectMake(x, y, textWidth, textHeight);
    _descLayer.frame = CGRectMake(x, y + paddingY + CGRectGetHeight(_titleLayer.frame), textWidth, textHeight);
    
    if (linkModel.linkTitle.length > 0 && linkModel.linkText.length > 0) {
        
    } else if (linkModel.linkTitle.length > 0) {
        _titleLayer.position = CGPointMake(_titleLayer.position.x, centerY);
    } else if (linkModel.linkText.length > 0) {
        _descLayer.position = CGPointMake(_titleLayer.position.x, centerY);
    }
    
    CGFloat lineHeight = 0.5;
    _topLine.frame = CGRectMake(CGRectGetMaxX(_coverView.frame), 0, CGRectGetWidth(self.frame) - CGRectGetMaxX(_coverView.frame), lineHeight);
    _bottomLine.frame = CGRectMake(CGRectGetMaxX(_coverView.frame), CGRectGetHeight(self.frame) - lineHeight, CGRectGetWidth(self.frame) - CGRectGetMaxX(_coverView.frame), lineHeight);
    
    [CATransaction commit];
}

- (void)selfOnTap {
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_linkModel.linkUrl]];
    WLWebViewController *webViewController = [[WLWebViewController alloc] initWithUrl:_linkModel.linkUrl];
    [[AppContext rootViewController] pushViewController:webViewController animated:YES];
    
    [_cell setTrackerReadClickedArea:WLTrackerPostClickedArea_Text];
}

@end

@implementation WLFeedProfileView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        
        _avatarView = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
        _avatarView.delegate = self;
        _avatarView.frame = CGRectMake(0, 0, cellAvatarSize, cellAvatarSize);
        _avatarView.backgroundColor = [UIColor whiteColor];
        _avatarView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_avatarView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = kNameFontColor;
        _nameLabel.font = cellNameFont;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.numberOfLines = 1;
        [self addSubview:_nameLabel];
        
        _honorIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _honorIcon.contentMode = UIViewContentModeScaleAspectFit;
        _honorIcon.backgroundColor = [UIColor clearColor];
        [self addSubview:_honorIcon];
        
        _timeLayer = textLayerWithFont(cellDateTimeFont);
        _timeLayer.foregroundColor = kLightLightFontColor.CGColor;
        [self.layer addSublayer:_timeLayer];
        
        _followBtn = [[WLFollowButton alloc] init];
        _followBtn.delegate = self;
        [self addSubview:_followBtn];
        
        _readCountLab = [[UILabel alloc] init];
        _readCountLab.numberOfLines = 2;
        _readCountLab.font = cellDateTimeFont;
        _readCountLab.textColor = kLightLightFontColor;
        _readCountLab.layer.borderWidth = 1.0;
        _readCountLab.layer.borderColor = kBorderLineColor.CGColor;
        _readCountLab.layer.cornerRadius = kCornerRadius;
        [self addSubview:_readCountLab];
        
        _arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cellAvatarSize, cellAvatarSize)];
        _arrowView.image = [AppContext getImageForKey:@"feed_more"];
        _arrowView.contentMode = UIViewContentModeCenter;
        [self addSubview:_arrowView];
    }
    return self;
}

- (void)setLayout:(WLFeedLayout *)layout {
    _layout = layout;
    
    self.frame = CGRectMake(0, 0, cellContentWidth + cellPaddingLeft, layout.profileHeight);
    
    [_avatarView setFeedModel:layout.feedModel];
    
    if (layout.layoutType == WLFeedLayoutType_FeedDetail
        || layout.layoutType == WLFeedLayoutType_RepostInDetail
        || layout.layoutType == WLFeedLayoutType_TopicTop) {
        _arrowView.hidden = YES;
        _arrowView.frame = CGRectMake(0, 0, cellPaddingLeft, cellPaddingLeft);
    } else {
        _arrowView.hidden = NO;
        _arrowView.frame = CGRectMake(0, 0, cellAvatarSize, cellAvatarSize);
        _arrowView.center = CGPointMake(CGRectGetWidth(self.frame) - CGRectGetWidth(_arrowView.frame) * 0.5 , CGRectGetHeight(self.frame) * 0.5);
    }
    
    [self setFollowBtnWithLayout:layout];
    [self setReadCountWithLayout:layout];

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CGRect timeFrame = layout.timeFrame;
    timeFrame.size.width -= (CGRectGetWidth(_arrowView.frame) + CGRectGetWidth(_followBtn.frame));
    _timeLayer.frame = timeFrame;
    
    CGRect nameFrame = layout.nameFrame;
    if (nameFrame.size.width > _timeLayer.frame.size.width) {
        nameFrame.size.width = _timeLayer.frame.size.width;
    }
    _nameLabel.frame = nameFrame;
    
    _nameLabel.text = layout.feedModel.nickName;
    _timeLayer.string = layout.souceTail;
    
    [CATransaction commit];
    
    _honorIcon.center = CGPointMake(CGRectGetMaxX(_nameLabel.frame) + CGRectGetWidth(_honorIcon.frame) * 0.5 + cellPaddingX * 0.5, CGRectGetMidY(_nameLabel.frame));
    if (layout.feedModel.userHonors.count > 0) {
        _honorIcon.hidden = NO;
        [_honorIcon fq_setImageWithURLString:layout.feedModel.userHonors[0].picUrl placeholder:[UIImage new]];
    } else {
        _honorIcon.hidden = YES;
        _honorIcon.image = nil;
    }
}

- (void)setFollowBtnWithLayout:(WLFeedLayout *)layout {
    if ([layout.feedModel.uid isEqual:[AppContext getInstance].accountManager.myAccount.uid]
        || layout.layoutType == WLFeedLayoutType_RepostInDetail
        || layout.layoutType == WLFeedLayoutType_UserDetail) {
        _followBtn.hidden = YES;
        _followBtn.frame = CGRectZero;
    } else {
        _followBtn.hidden = layout.feedModel.following;
        
        if (_followBtn.hidden) {
            _followBtn.frame = CGRectZero;
        } else {
            _followBtn.frame = kFollowDefaultFrame;
        }
        
        CGFloat centerX = CGRectGetWidth(self.bounds) - CGRectGetWidth(_arrowView.frame) - CGRectGetWidth(_followBtn.frame) * 0.5;
        _followBtn.center = CGPointMake(centerX, CGRectGetHeight(self.frame) * 0.5);
        
        [_followBtn setLoading:layout.followLoading];
        
        [_followBtn setFeedModel:layout.feedModel];
    }
}

- (void)setReadCountWithLayout:(WLFeedLayout *)layout {
    if ([layout.feedModel.uid isEqual:[AppContext getInstance].accountManager.myAccount.uid]
        && layout.layoutType == WLFeedLayoutType_UserDetail) {
        _readCountLab.hidden = NO;
        
        _readCountLab.frame = layout.readCountFrame;
        CGFloat centerX = CGRectGetWidth(self.bounds) - CGRectGetWidth(_arrowView.frame) - CGRectGetWidth(_readCountLab.frame) * 0.5;
        _readCountLab.center = CGPointMake(centerX, CGRectGetHeight(self.frame) * 0.5);
        
        _readCountLab.attributedText = layout.readCountStr;
        
    } else {
        _readCountLab.hidden = YES;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(_avatarView.frame, point) || CGRectContainsPoint(_nameLabel.frame, point)) {
        if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedUser:)]) {
            [_cell.delegate feedCell:_cell didClickedUser:_layout.feedModel.uid];
        }
        
        [_cell setTrackerReadClickedArea:WLTrackerPostClickedArea_Avatar];
        
    } else if (CGRectContainsPoint(_arrowView.frame, point)) {
        if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedArrow:)]) {
            [_cell.delegate feedCell:_cell didClickedArrow:_layout];
        }
        
        [_cell setTrackerReadClickedArea:WLTrackerPostClickedArea_More];
        
    } else {
        if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedFeed:)]) {
            [_cell.delegate feedCell:_cell didClickedFeed:_layout];
        }
        
        [_cell setTrackerReadClickedArea:WLTrackerPostClickedArea_Avatar];
    }
}

#pragma mark - WLHeadViewDelegate

- (void)onClick:(WLHeadView *)headView {
    if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedUser:)]) {
        [_cell.delegate feedCell:_cell didClickedUser:_layout.feedModel.uid];
    }
    
    [_cell setTrackerReadClickedArea:WLTrackerPostClickedArea_Avatar];
}

#pragma mark - WLFollowButtonDelegate

- (void)followButtonLoadingChanged:(WLFollowButton *)followBtn {
    _layout.followLoading = followBtn.isLoading;
    
    if ([_cell.delegate respondsToSelector:@selector(feedCellDidFollowLoadingChanged:)]) {
        [_cell.delegate feedCellDidFollowLoadingChanged:_layout];
    }
}

- (void)followButtonFinished:(WLFollowButton *)followBtn {
    if ([_cell.delegate respondsToSelector:@selector(feedCellDidFollowLoadingFinished:)]) {
        [_cell.delegate feedCellDidFollowLoadingFinished:_layout];
    }
}

@end

@implementation WLFeedVideoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        _iconView = [[UIImageView alloc] init];
        _iconView.image = [AppContext getImageForKey:@"feed_play"];
        [_iconView sizeToFit];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        [_imageView addSubview:_iconView];
        
        UITapGestureRecognizer *videoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnTapped)];
        [self addGestureRecognizer:videoTap];
    }
    return self;
}

- (void)setLayout:(WLFeedLayout *)layout {
    _layout = layout;
    
    self.hidden = NO;
    
    CGRect videoFrame = self.frame;
    videoFrame.origin.x = layout.videoLeft;
    videoFrame.origin.y = layout.videoTop;
    videoFrame.size = layout.videoSize;
    self.frame = videoFrame;
    
    _iconView.center = CGPointMake(layout.videoSize.width * 0.5, layout.videoSize.height * 0.5);
    _imageView.frame = self.bounds;
    
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    if (layout.feedModel.type == WELIKE_POST_TYPE_FORWARD) {
        [_imageView fq_setImageWithURLString:[(WLVideoPost *)[(WLForwardPost *)layout.feedModel rootPost] coverUrl]
                                 placeholder:[UIImage new]
                                cornerRadius:0
                                   completed:^(UIImage *image, NSURL *url, NSError *error) {
                                       if (error) {
                                           self->_imageView.image = nil;
                                       }
                                   }];;
    } else {
        [_imageView fq_setImageWithURLString:[(WLVideoPost *)layout.feedModel coverUrl]
                                 placeholder:[UIImage new]
                                cornerRadius:0
                                   completed:^(UIImage *image, NSURL *url, NSError *error) {
                                       if (error) {
                                           self->_imageView.image = nil;
                                       }
                                   }];;
    }
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    
    _iconView.hidden = YES;
}

- (void)playerViewRemoved {
    _iconView.hidden = NO;
}

- (void)selfOnTapped {
    [WLTrackerPlayer setForwardPost:_layout.feedModel];
    
    if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedVideo:)]) {
        if (_layout.feedModel.type == WELIKE_POST_TYPE_FORWARD) {
            WLPostBase *feedModel = [(WLForwardPost *)_layout.feedModel rootPost];
            if (feedModel.type == WELIKE_POST_TYPE_VIDEO) {
                [_cell.delegate feedCell:_cell didClickedVideo:(WLVideoPost *)feedModel];
            }
        } else {
            if (_layout.feedModel.type == WELIKE_POST_TYPE_VIDEO) {
                [_cell.delegate feedCell:_cell didClickedVideo:(WLVideoPost *)_layout.feedModel];
            }
        }
    }
    
    [_cell setTrackerReadClickedArea:WLTrackerPostClickedArea_Video];
}

@end

@implementation WLFeedContentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(cellPaddingLeft,
                                                                cellPaddingTop,
                                                                cellContentWidth,
                                                                0)];
        _contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_contentView];
        
        // profile
        _profileView = [[WLFeedProfileView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_contentView.bounds), 0)];
        [_contentView addSubview:_profileView];
        
        // topsign
        _topSign = [CALayer layer];
        _topSign.hidden = YES;
        [_contentView.layer addSublayer:_topSign];
        
        // text
        _feedLabel = [[TYLabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_contentView.bounds), 0)];
        _feedLabel.delegate = self;
        _feedLabel.backgroundColor = [UIColor whiteColor];
        [_contentView addSubview:_feedLabel];
        
        _deletedView = [[WLFeedDeletedView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_contentView.bounds), cellCardHeight)];
        [_contentView addSubview:_deletedView];
        
        // retweet
        _retweetedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_contentView.bounds), 0)];
        _retweetedBackgroundView.backgroundColor = kTableViewBgColor;
        _retweetedBackgroundView.layer.cornerRadius = kCornerRadius;
        [_contentView addSubview:_retweetedBackgroundView];
        
        _retweetedTextLabel = [[TYLabel alloc] initWithFrame:CGRectMake(cellPaddingLeft, 0, CGRectGetWidth(_contentView.bounds) - cellPaddingLeft * 2, 0)];
        _retweetedTextLabel.delegate = self;
        [_contentView addSubview:_retweetedTextLabel];
        
        // poll
        _pollView = [[WLPollView alloc] initWithFrame:CGRectZero];
        _pollView.delegate = self;
        [_contentView addSubview:_pollView];
        
        // article
        _articleView = [[WLFeedArticleView alloc] initWithFrame:CGRectZero];
        [_contentView addSubview:_articleView];
        
        // pictures
        _thumbView = [[WLThumbnailView alloc] initWithFrame:CGRectZero];
        [_contentView addSubview:_thumbView];
        
        // video
        _videoView = [[WLFeedVideoView alloc] initWithFrame:CGRectZero];
        [_contentView addSubview:_videoView];
        
        // card
        _cardView = [[WLFeedCardView alloc] initWithFrame:CGRectZero];
        _cardView.hidden = YES;
        [_contentView addSubview:_cardView];
        
        // other info
        _otherInfoView = [[WLFeedOtherInfoView alloc] initWithFrame:CGRectZero];
        _otherInfoView.hidden = YES;
        [_contentView addSubview:_otherInfoView];
        
        // toolbar
        _toolBar = [[WLFeedToolBar alloc] init];
        [self addSubview:_toolBar];
        
//        _separateLine = [[UIView alloc] init];
//        _separateLine.backgroundColor = kSeparateLineColor;
//        [self addSubview:_separateLine];
    }
    return self;
}

- (void)setCell:(WLFeedCell *)cell {
    _cell = cell;
    
    _profileView.cell = cell;
    _cardView.cell = cell;
    _toolBar.cell = cell;
    _deletedView.cell = cell;
    _videoView.cell = cell;
}

- (void)setLayout:(WLFeedLayout *)layout {
    _layout = layout;
    
    {
        _retweetedBackgroundView.hidden = YES;
        _retweetedTextLabel.hidden = YES;
        _pollView.hidden = YES;
        _articleView.hidden = YES;
        _thumbView.hidden = YES;
        _videoView.hidden = YES;
        _cardView.hidden = YES;
        _deletedView.hidden = YES;
        _topSign.hidden = YES;
        _otherInfoView.hidden = YES;
    }
    
    {
        CGRect contentFrame = _contentView.frame;
        contentFrame.size.height = layout.contentHeight;
        _contentView.frame = contentFrame;
    }
    
    {
        if (layout.feedModel.trackerSource == WLTrackerFeedSource_User_Posts
            && layout.feedModel.isTop) {
            _topSign.hidden = NO;
            UIImage *icon = [AppContext getImageForKey:@"user_feed_pin"];
            _topSign.frame = CGRectMake(-cellPaddingLeft, -cellPaddingTop, icon.size.width, icon.size.height);
            _topSign.contents = (__bridge id)icon.CGImage;
        } else {
            _topSign.hidden = YES;
            _topSign.contents = nil;
        }
    }
    
    {
        [_profileView setLayout:layout];
    }
    
    {   
        CGRect textFrame = _feedLabel.frame;
        textFrame.origin.y = layout.textTop;
        textFrame.size.height = layout.textHeight;
        _feedLabel.frame = textFrame;
        [_feedLabel setTextRender:layout.handledFeedModel.textRender];
    }
    
    if (layout.layoutType == WLFeedLayoutType_RepostInDetail) {
        _toolBar.hidden = YES;
        self.frame = CGRectMake(0, 0, kScreenWidth, layout.cellHeight - cellSeparateHeight);
        return;
    }
    
    {
        if (layout.feedModel.type == WELIKE_POST_TYPE_FORWARD) {
            WLForwardPost *retweetedModel = (WLForwardPost *)layout.feedModel;
            
            if (retweetedModel.forwardDeleted) {
                _deletedView.hidden = NO;
                CGRect deletedFrame = _deletedView.frame;
                deletedFrame.origin.y = layout.retweetedViewTop;
                _deletedView.frame = deletedFrame;
                
            } else {
                _retweetedBackgroundView.hidden = NO;
                _retweetedTextLabel.hidden = NO;
                
                CGRect retweetedFrame = _retweetedBackgroundView.frame;
                retweetedFrame.origin.y = layout.retweetedViewTop;
                retweetedFrame.size.height = layout.retweetedViewHeight;
                _retweetedBackgroundView.frame = retweetedFrame;
                
                CGRect retweetedLabFrame = _retweetedTextLabel.frame;
                retweetedLabFrame.origin.y = layout.retweetedTextTop;
                retweetedLabFrame.size.height = layout.retweetedTextHeight;
                _retweetedTextLabel.frame = retweetedLabFrame;
                [_retweetedTextLabel setTextRender:layout.rootPostHandledFeedModel.textRender];
                
                if (retweetedModel.rootPost.type == WELIKE_POST_TYPE_PIC) {
                    [self p_setThumbView:layout];
                    
                } else if (retweetedModel.rootPost.type == WELIKE_POST_TYPE_VIDEO) {
                    [self p_setVideoView:layout];
                    
                } else if (retweetedModel.rootPost.type == WELIKE_POST_TYPE_LINK) {
                    [self p_setCardView:layout];
                    
                } else if (retweetedModel.rootPost.type == WELIKE_POST_TYPE_POLL) {
                    [self p_setPollView:layout];
                    
                } else if (retweetedModel.rootPost.type == WELIKE_POST_TYPE_ARTICAL) {
                    [self p_setArticleView:layout];
                }
                
                [self p_setOtherInfoView:layout];
            }
            
        } else if (layout.feedModel.type == WELIKE_POST_TYPE_PIC) {
            [self p_setThumbView:layout];
            
        } else if (layout.feedModel.type == WELIKE_POST_TYPE_VIDEO) {
            [self p_setVideoView:layout];
            
        } else if (layout.feedModel.type == WELIKE_POST_TYPE_LINK) {
            [self p_setCardView:layout];
            
        } else if (layout.feedModel.type == WELIKE_POST_TYPE_POLL) {
            [self p_setPollView:layout];
            
        } else if (layout.feedModel.type == WELIKE_POST_TYPE_ARTICAL) {
            [self p_setArticleView:layout];
        }
        
        [self p_setOtherInfoView:layout];
        
        [self p_setToolBar:layout];
    }
    
    {
//        _separateLine.frame = CGRectMake(0, CGRectGetMaxY(_toolBar.frame), CGRectGetWidth(self.bounds), cellSeparateHeight);
    }
    
    self.frame = CGRectMake(0, 0, kScreenWidth, layout.cellHeight - cellSpacingY);
    
    self.layer.shadowColor = kUIColorFromRGB(0x000000).CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowOpacity = 0.08;
    self.layer.shadowPath = CGPathCreateWithRect(CGRectMake(0, CGRectGetHeight(self.bounds) - 10, CGRectGetWidth(self.bounds), 10), NULL);
}

- (void)p_setPollView:(WLFeedLayout *)layout {
    _pollView.hidden = NO;
    
    WLPollPost *pollModel = nil;
    if (layout.feedModel.type == WELIKE_POST_TYPE_FORWARD) {
        pollModel = (WLPollPost *)[(WLForwardPost *)layout.feedModel rootPost];
    } else {
        pollModel = (WLPollPost *)layout.feedModel;
    }
    
    CGRect frame = _pollView.frame;
    frame.origin.x = layout.voteGroupLeft;
    frame.origin.y = layout.voteGroupTop;
    frame.size = layout.voteGroupSize;
    _pollView.frame = frame;
    
    [_pollView setPollModel:pollModel
                  viewWidth:layout.voteViewSize.width
                 viewHeight:layout.voteViewSize.height
             imgCellSpacing:cellPicSpacing
               noImgSpacing:cellPaddingY];
}

- (void)p_setArticleView:(WLFeedLayout *)layout {
    _articleView.hidden = NO;
    
    WLArticalPostModel *articleModel = nil;
    if (layout.feedModel.type == WELIKE_POST_TYPE_FORWARD) {
        articleModel = (WLArticalPostModel *)[(WLForwardPost *)layout.feedModel rootPost];
    } else {
        articleModel = (WLArticalPostModel *)layout.feedModel;
    }
    
    CGRect frame = _articleView.frame;
    frame.origin.x = layout.articleLeft;
    frame.origin.y = layout.articleTop;
    frame.size = layout.articleSize;
    _articleView.frame = frame;
    
    [_articleView setArticleModel:articleModel];
}

- (void)p_setThumbView:(WLFeedLayout *)layout {
    _thumbView.hidden = NO;
    
    WLPicPost *picModel = nil;
    if (layout.feedModel.type == WELIKE_POST_TYPE_FORWARD) {
        picModel = (WLPicPost *)[(WLForwardPost *)layout.feedModel rootPost];
    } else {
        picModel = (WLPicPost *)layout.feedModel;
    }
    
    [_thumbView setImages:picModel.picInfoList
             imgViewWidth:layout.picSize.width
            imgViewHeight:layout.picSize.height
                  spacing:cellPicSpacing];
    _thumbView.userName = picModel.nickName;
    _thumbView.feedModel = layout.feedModel;
    
    CGRect thumbFrame = _thumbView.frame;
    thumbFrame.origin.x = layout.picGroupLeft;
    thumbFrame.origin.y = layout.picGroupTop;
    thumbFrame.size = layout.picGroupSize;
    _thumbView.frame = thumbFrame;
}

- (void)p_setVideoView:(WLFeedLayout *)layout {
    [_videoView setLayout:layout];
}

- (void)p_setCardView:(WLFeedLayout *)layout {
    _cardView.hidden = NO;
    
    WLLinkPost *linkModel = nil;
    if (layout.feedModel.type == WELIKE_POST_TYPE_FORWARD) {
        _cardView.backgroundColor = [UIColor whiteColor];
        linkModel = (WLLinkPost *)[(WLForwardPost *)layout.feedModel rootPost];
    } else {
        _cardView.backgroundColor = kTableViewBgColor;
        linkModel = (WLLinkPost *)layout.feedModel;
    }
    
    CGRect cardFrame = _cardView.frame;
    cardFrame.origin.x = layout.cardLeft;
    cardFrame.origin.y = layout.cardTop;
    cardFrame.size = layout.cardSize;
    _cardView.frame = cardFrame;
    
    [_cardView setLinkModel:linkModel];
}

- (void)p_setOtherInfoView:(WLFeedLayout *)layout {
    if (layout.layoutType == WLFeedLayoutType_FeedDetail) {
        _otherInfoView.hidden = NO;
        _otherInfoView.frame = CGRectMake(0, layout.otherInfoTop, cellContentWidth, cellOtherInfoHeight);
        
        [_otherInfoView setLayout:layout];
    } else {
        _otherInfoView.hidden = YES;
        _otherInfoView.frame = CGRectZero;
    }
}

- (void)p_setToolBar:(WLFeedLayout *)layout {
    if (layout.layoutType == WLFeedLayoutType_FeedDetail) {
        _toolBar.hidden = YES;
        _toolBar.frame = CGRectZero;
    } else {
        _toolBar.hidden = NO;
        _toolBar.frame = CGRectMake(0, CGRectGetMaxY(_contentView.frame), kScreenWidth, cellToolBarHeight);
        [_toolBar setLayout:layout];
    }
}

#pragma mark - TYLabelDelegate

- (void)label:(TYLabel *)label didTappedTextHighlight:(TYTextHighlight *)textHighlight {
    NSString *key = textHighlight.userInfo.allKeys.firstObject;
    if ([key isEqualToString:WLRICH_TYPE_MENTION]) {
        if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedUser:)]) {
            [_cell.delegate feedCell:_cell didClickedUser:textHighlight.userInfo[key]];
        }
    } else if ([key isEqualToString:WLRICH_TYPE_TOPIC]) {
        if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedTopic:)]) {
            [_cell.delegate feedCell:_cell didClickedTopic:textHighlight.userInfo[key]];
        }
    } else if ([key isEqualToString:WLRICH_TYPE_LINK]) {
       // NSString *urlStr = [textHighlight.userInfo[key] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
       // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        WLWebViewController *webViewController = [[WLWebViewController alloc] initWithUrl:textHighlight.userInfo[key]];
        [[AppContext rootViewController] pushViewController:webViewController animated:YES];
    }
    else if ([key isEqualToString:WLRICH_TYPE_MORE]) {
        if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedFeed:)]) {
            [_cell.delegate feedCell:_cell didClickedFeed:_layout];
        }
    }
    else if ([key isEqualToString:WLRICH_TYPE_LOCATION]) {
        if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedLocation:)]) {
            [_cell.delegate feedCell:_cell didClickedLocation:_layout];
        }
    }
    else if ([key isEqualToString:WLRICH_TYPE_ARTICLE]) {
        if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedArtical:)]) {
            [_cell.delegate feedCell:_cell didClickedArtical:_layout];
        }
    }
    
    [_cell setTrackerReadClickedArea:WLTrackerPostClickedArea_Text];
}

#pragma mark - WLPollViewDelegate

- (void)pollView:(WLPollView *)pollView didPolled:(nonnull WLPollPost *)polledModel {
    if ([_cell.delegate respondsToSelector:@selector(feedCell:didPolled:)]) {
        [_cell.delegate feedCell:_cell didPolled:polledModel];
    }
    
    [_cell setTrackerReadClickedArea:WLTrackerPostClickedArea_Poll];
}

#pragma mark - Event

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(_retweetedBackgroundView.frame, point)) {
        WLFeedLayout *layout = _layout;
        
        if (_layout.feedModel.type == WELIKE_POST_TYPE_FORWARD) {
            if (![(WLForwardPost *)_layout.feedModel rootPost].deleted) {
               layout = [WLFeedLayout layoutWithFeedModel:[(WLForwardPost *)_layout.feedModel rootPost]];
            }
        }
        
        if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedFeed:)]) {
            [_cell.delegate feedCell:_cell didClickedFeed:layout];
        }
        
        [_cell setTrackerReadClickedArea:WLTrackerPostClickedArea_Text];
        
    } else if (CGRectContainsPoint(CGRectMake(cellPaddingLeft, cellPaddingTop, CGRectGetWidth(self.bounds) - cellPaddingLeft, CGRectGetHeight(_profileView.frame)), point)) {
        if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedArrow:)]) {
            [_cell.delegate feedCell:_cell didClickedArrow:_layout];
        }
        
        [_cell setTrackerReadClickedArea:WLTrackerPostClickedArea_More];
        
    } else {
        if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedFeed:)]) {
            [_cell.delegate feedCell:_cell didClickedFeed:_layout];
        }
        
        [_cell setTrackerReadClickedArea:WLTrackerPostClickedArea_Text];
    }
}

@end

@interface WLFeedCell ()

@end

@implementation WLFeedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _feedView = [[WLFeedContentView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
        [self.contentView addSubview:_feedView];
    }
    return self;
}

- (void)setLayout:(WLFeedLayout *)layout {
    _layout = layout;
    
    _feedView.cell = self;
    [_feedView setLayout:layout];
}

- (void)setFollowLoading:(BOOL)followLoading {
    [_feedView.profileView setFollowBtnWithLayout:_layout];
}

- (void)setTrackerReadClickedArea:(WLTrackerPostClickedArea)clickedArea {
    [WLTrackerPostRead appendTrackerWithClickedArea:clickedArea post:self.layout.feedModel];
}

@end
