//
//  WLPlayerOperateView.m
//  WeLike
//
//  Created by fan qi on 2018/4/10.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLPlayerOperateView.h"
#import "WLDynamicLoadingView.h"
#import "WLVideoPost.h"
#import "WLHeadView.h"
#import "WLAbstractPlayerView.h"
#import "WLFollowButton.h"
#import "WLImageButton.h"
#import "WLFoldRichView.h"
#import "WLShareViewController.h"
#import "WLUserDetailViewController.h"
#import "WLTopicDetailViewController.h"
#import "WLLocationDetailViewController.h"
#import "WLFeedDetailViewController.h"
#import "WLSingleContentManager.h"
#import "WLTrackerPlayer.h"
#import "WLTrackerLogin.h"

#define kBottomHeight           44
#define kSecondsLabelWidth      35
#define kLabelsViewWidth        74
#define kLabelsViewHeight       30
#define kPaddingX               8
#define kMarginX                12

static BOOL _mute = YES;

@interface WLPlayerOperateView () <WLHeadViewDelegate, WLFoldRichViewDelegate, WLFollowButtonDelegate>

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, weak) WLDynamicLoadingView *loadingView;
@property (nonatomic, strong) UIButton *playBtn;

@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIButton *rotateBtn;
@property (nonatomic, strong) UIButton *volumeBtn;

@property (nonatomic, strong) UIView *infoView;
@property (nonatomic, strong) WLFoldRichView *richView;
@property (nonatomic, strong) UIButton *collpaseBtn;

//@property (nonatomic, strong) UIView *labelsView;
//@property (nonatomic, strong) UILabel *leftLab;
//@property (nonatomic, strong) UILabel *rightLab;
@property (nonatomic, strong) UISlider *cacheProgressBar;
@property (nonatomic, strong) UISlider *playProgressBar;

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) WLHeadView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) WLFollowButton *followBtn;

@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) WLImageButton *downloadBtn;
@property (nonatomic, strong) WLImageButton *shareBtn;
@property (nonatomic, strong) WLImageButton *likeBtn;
@property (nonatomic, strong, readwrite) CAShapeLayer *downloadProgressLayer;

@property (nonatomic, strong) WLSingleContentManager *deleteManager;

@end

@implementation WLPlayerOperateView {
    UITapGestureRecognizer *_selfTap;
}

#pragma mark - LifeCycle

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        
        _playProgress = 0.0;
        _cacheProgress = 0.0;
        _displayToos = NO;
        _downloading = NO;
        _downloaded = NO;
        _playerOrientation = WLPlayerViewOrientation_Vertical;
        
        [self layoutUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat statusBarHeight = kIsiPhoneX ? 44 : 20;
    
    self.maskView.frame = self.bounds;
    
    {
        self.progressView.transform = CGAffineTransformIdentity;
        self.progressView.frame = CGRectMake(0,
                                             CGRectGetHeight(self.bounds) - (kBottomHeight + kSafeAreaBottomY),
                                             CGRectGetWidth(self.bounds),
                                             kBottomHeight + kSafeAreaBottomY);
        self.gradientLayer.frame = self.progressView.bounds;
    }
    
    {
        CGPoint centerPoint = CGPointMake(CGRectGetWidth(self.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5);
        self.loadingView.center = centerPoint;
        self.playBtn.center = centerPoint;
    }
    
    {
        self.topView.transform = CGAffineTransformIdentity;
        self.topView.frame = CGRectMake(0, 0, kScreenWidth, statusBarHeight + kSingleNavBarHeight);
        
        CGFloat x = 12, y = kIsiPhoneX ? (12 + statusBarHeight) : 12, paddingX = 8;
        
        self.avatarView.frame = CGRectMake(x, y, CGRectGetWidth(self.avatarView.bounds), CGRectGetHeight(self.avatarView.bounds));
        x += (CGRectGetWidth(self.avatarView.bounds) + paddingX);
        y -= 4;
        
        self.nameLabel.frame = CGRectMake(x, y, CGRectGetWidth(self.nameLabel.bounds), CGRectGetHeight(self.nameLabel.bounds));
        y += CGRectGetHeight(self.nameLabel.bounds);
        
        self.timeLabel.frame = CGRectMake(x, y, CGRectGetWidth(self.timeLabel.bounds), CGRectGetHeight(self.timeLabel.bounds));
        
        x += ((CGRectGetWidth(self.nameLabel.bounds) > CGRectGetWidth(self.timeLabel.bounds)
               ? CGRectGetWidth(self.nameLabel.bounds)
               : CGRectGetWidth(self.timeLabel.bounds)) + paddingX);
        
        self.followBtn.center = CGPointMake(x + CGRectGetWidth(self.followBtn.bounds) * 0.5, self.avatarView.center.y);
    }
    
    {
        self.rightView.frame = CGRectMake(CGRectGetWidth(self.bounds) - 66,
                                          statusBarHeight + kSingleNavBarHeight,
                                          66,
                                          CGRectGetHeight(self.bounds) - statusBarHeight - kSingleNavBarHeight - CGRectGetHeight(self.progressView.bounds) - kBottomHeight);
        
        CGFloat width = CGRectGetWidth(self.rightView.bounds);
        CGFloat height = CGRectGetHeight(self.downloadBtn.imageView.bounds) + self.downloadBtn.titleLabel.font.pointSize + 2;
        CGFloat centerX = CGRectGetWidth(self.rightView.bounds) - width * 0.5;
        CGFloat centerY = CGRectGetHeight(self.rightView.bounds) - height * 0.5;
        CGFloat paddingY = 16;
        
        self.downloadBtn.frame = CGRectMake(0, 0, width, height);
        self.downloadBtn.center = CGPointMake(centerX, centerY);
        self.downloadProgressLayer.position = self.downloadBtn.imageView.center;
        centerY -= (CGRectGetHeight(self.downloadBtn.bounds) + paddingY);
        
        self.shareBtn.frame = self.downloadBtn.bounds;
        self.shareBtn.center = CGPointMake(centerX, centerY);
        centerY -= (CGRectGetHeight(self.shareBtn.bounds) + paddingY);
        
        self.likeBtn.frame = self.downloadBtn.bounds;
        self.likeBtn.center = CGPointMake(centerX, centerY);
    }
    
    {
        [self layoutInfoView];
    }
    
    [self p_setToolsDisplay:self.isDisplayTools animated:NO allTools:NO];
}

- (void)layoutInfoView {
    self.infoView.height = self.richView.height;
    self.infoView.top = CGRectGetHeight(self.bounds) - (self.infoView.height + kSafeAreaBottomY + 8);
    self.collpaseBtn.center = CGPointMake(CGRectGetWidth(self.infoView.bounds) - CGRectGetWidth(self.collpaseBtn.bounds) * 0.5,
                                          CGRectGetHeight(self.infoView.bounds) - CGRectGetHeight(self.collpaseBtn.bounds) * 0.5);
}

- (void)layoutUI {
    [self addSubview:self.maskView];
    [self addSubview:self.topView];
    [self addSubview:self.rightView];
    [self addSubview:self.progressView];
    [self addSubview:self.playBtn];
    [self addSubview:self.infoView];
}

#pragma mark - Public

- (void)prepare {
    self.playBtn.alpha = 0.0;
    [self setCaching:YES];
}

#pragma mark - Event

- (void)selfOnTapped {
//    [self setDisplayToos:!self.displayToos animated:YES allTools:YES];
    
    if ([self.delegate respondsToSelector:@selector(playerOperateViewDidClickedPlay:)]) {
        [self.delegate playerOperateViewDidClickedPlay:self];
    }
    
    [WLTrackerPlayer appendTrackerWithPlayerOperateType:WLTrackerPlayerOperateType_Play_Pause];
}

- (void)playBtnClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(playerOperateViewDidClickedPlay:)]) {
        [self.delegate playerOperateViewDidClickedPlay:self];
    }
    
    [WLTrackerPlayer appendTrackerWithPlayerOperateType:WLTrackerPlayerOperateType_Play_Pause];
}

- (void)sliderUpInside:(UISlider *)slider {
    if ([self.delegate respondsToSelector:@selector(playerOperateView:didSliderValueChanged:)]) {
        [self.delegate playerOperateView:self didSliderValueChanged:slider.value];
    }
}

- (void)sliderValueChanged:(UISlider *)slider {
    
}

- (void)sliderTapped:(UITapGestureRecognizer *)gesture {
    UISlider *slider = (UISlider *)gesture.view;
    
    if (!slider.tracking) {
        CGPoint location = [gesture locationInView:slider];
        CGRect trackFrame = [slider trackRectForBounds:slider.bounds];
        float r = (location.x - trackFrame.origin.x) / trackFrame.size.width;
        float value = slider.minimumValue + (slider.maximumValue - slider.minimumValue) * r;
        [slider setValue:value animated:YES];
    }
    
    if ([self.delegate respondsToSelector:@selector(playerOperateView:didSliderValueChanged:)]) {
        [self.delegate playerOperateView:self didSliderValueChanged:slider.value];
    }
}

- (void)rotateBtnClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(playerOperateViewDidClickedRotate:)]) {
        [self.delegate playerOperateViewDidClickedRotate:self];
    }
}

- (void)volumeBtnClicked:(UIButton *)sender {
    [WLTrackerPlayer appendTrackerWithPlayerOperateType:WLTrackerPlayerOperateType_Mute
                                               muteType:_mute ? WLTrackerPlayerMuteType_Closed : WLTrackerPlayerMuteType_Opened];
    
    [WLPlayerOperateView setMute:!_mute];
    
    [self p_muteChanged];
}

- (void)downloadBtnClicked:(UIButton *)sender {
    if (!sender.isEnabled) {
        return;
    }
    sender.enabled = NO;
    
    if ([self.delegate respondsToSelector:@selector(playerOperateViewDidClickedDownload:)]) {
        [self.delegate playerOperateViewDidClickedDownload:self];
    }
    
    [WLTrackerPlayer appendTrackerWithPlayerOperateType:WLTrackerPlayerOperateType_Download];
}

- (void)shareBtnClicked:(UIButton *)sender {
//    NSString *imgUrl = self.videoModel.headUrl;
    
    WLShareModel *shareModel = [WLShareModel modelWithPost:self.videoModel];
    
    WLShareViewController *ctr = [[WLShareViewController alloc] init];
    ctr.shareModel = shareModel;
    [[AppContext rootViewController] presentViewController:ctr animated:YES completion:nil];
}

- (void)likeBtnClicked:(UIButton *)sender {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Like];
    kNeedLogin
    
    if (self.videoModel.like) {
        [self.deleteManager dislikePost:self.videoModel];
    } else {
        [self.deleteManager likePost:self.videoModel];
    }
    
    self.videoModel.like = !self.videoModel.like;
    
    [self p_setLikeBtnVideoModel:self.videoModel];
}

- (void)userInfoTapped {
    WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithUserID:self.videoModel.uid];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
    
    [WLTrackerPlayer appendTrackerWithPlayerOperateType:WLTrackerPlayerOperateType_Text];
}

- (void)collapseBtnClicked:(UIButton *)sender {
    if ([self.richView isFold]) {
        [self.richView unfold];
        [self layoutInfoView];
        
        [UIView animateWithDuration:0.25
                         animations:^{
                             sender.imageView.transform = CGAffineTransformIdentity;
                         }];
    } else {
        [self.richView fold];
        [self layoutInfoView];
        
        [UIView animateWithDuration:0.25
                         animations:^{
                             sender.imageView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
                         }];
    }
}

- (void)infoViewTapped:(UIGestureRecognizer *)gesture {
    //do nothing
}

- (void)rightViewTapped:(UIGestureRecognizer *)gesture {
    [self selfOnTapped];
}

#pragma mark - Touches

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(self.infoView.frame, point)) {
        WLFeedDetailViewController *ctr = [[WLFeedDetailViewController alloc] initWithID:self.videoModel.pid];
        [[AppContext rootViewController] pushViewController:ctr animated:YES];
        
        [WLTrackerPlayer appendTrackerWithPlayerOperateType:WLTrackerPlayerOperateType_Text];
    }
}

#pragma mark - WLHeadViewDelegate

- (void)onClick:(WLHeadView *)headView {
    WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithUserID:self.videoModel.uid];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
    
    [WLTrackerPlayer appendTrackerWithPlayerOperateType:WLTrackerPlayerOperateType_Avatar];
}

#pragma mark - WLFoldRichViewDelegate

- (void)clickUser:(NSString *)userId {
    WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithUserID:userId];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
    
    [WLTrackerPlayer appendTrackerWithPlayerOperateType:WLTrackerPlayerOperateType_Text];
}

- (void)clickTopic:(NSString *)topicID {
    WLTopicDetailViewController *ctr = [[WLTopicDetailViewController alloc] initWithTopicID:topicID];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
    
    [WLTrackerPlayer appendTrackerWithPlayerOperateType:WLTrackerPlayerOperateType_Text];
}

- (void)clickLoction:(NSString *)placeID {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Other];
    kNeedLogin
    
    WLLocationDetailViewController *locationDetailViewController = [[WLLocationDetailViewController alloc] init];
    locationDetailViewController.placeId = placeID;
    [[AppContext rootViewController] pushViewController:locationDetailViewController animated:YES];
    
    [WLTrackerPlayer appendTrackerWithPlayerOperateType:WLTrackerPlayerOperateType_Text];
}

#pragma mark - WLFollowButtonDelegate

- (void)followButtonFinished:(WLFollowButton *)followBtn {
    followBtn.hidden = self.videoModel.following;
}

#pragma mark - Private

- (NSString *)p_translateTotalSeconds:(NSInteger)totalSeconds {
    NSInteger hours = totalSeconds / 3600;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger seconds = totalSeconds % 60;
    
    if (hours > 0) {
        return [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld", (long)hours, (long)minutes, (long)seconds];
    } else {
        return [NSString stringWithFormat:@"%.2ld:%.2ld", (long)minutes, (long)seconds];
    }
}

- (void)p_delayHideTools {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(p_setDisplayToos:) withObject:@(NO) afterDelay:3.0];
}

- (void)p_setDisplayToos:(id)display {
    [self setDisplayToos:[display boolValue] animated:YES allTools:YES];
}

- (void)p_setToolsDisplay:(BOOL)display animated:(BOOL)animated allTools:(BOOL)allTools {
    CGFloat duration = animated ? 0.3 : 0.0;
    
    if (display) {
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.playBtn.alpha = 1.0;
                             
//                             if (allTools) {
//                                 if (!self.caching) {
//                                     self.playBtn.alpha = 1.0;
//                                 }
//                             }
//
//                             if ([self.delegate respondsToSelector:@selector(playerOperateView:didDiaplayToolsChanged:)]) {
//                                 [self.delegate playerOperateView:self didDiaplayToolsChanged:display];
//                             }
//
//                             self.topView.transform = CGAffineTransformIdentity;
//
//                             {
//                                 self.progressView.transform = CGAffineTransformIdentity;
//
//                                 [self.labelsView mas_updateConstraints:^(MASConstraintMaker *make) {
//                                     make.left.mas_equalTo(self.progressView).offset(kPaddingX);
//                                 }];
//
//                                 [self.playProgressBar mas_updateConstraints:^(MASConstraintMaker *make) {
//                                     make.centerY.mas_equalTo(self.progressView.mas_top).offset(kBottomHeight * 0.5);
//                                 }];
//                                 [self.playProgressBar setThumbImage:[AppContext getImageForKey:@"player_slider_thumb"] forState:UIControlStateNormal];
//
//                                 [self.rotateBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//                                     make.right.mas_equalTo(self.progressView);
//                                 }];
//
//                                 [self.progressView layoutIfNeeded];
//                             }
                         }
                         completion:^(BOOL finished) {
                             if (self.playerViewStatus == WLPlayerViewStatus_Playing) {
                                 [self p_delayHideTools];
                             }
                         }];
    } else {
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.playBtn.alpha = 0.0;
                             
//                             if (allTools) {
//                                 self.playBtn.alpha = 0.0;
//                             }
//
//                             if ([self.delegate respondsToSelector:@selector(playerOperateView:didDiaplayToolsChanged:)]) {
//                                 [self.delegate playerOperateView:self didDiaplayToolsChanged:display];
//                             }
//
//                             self.topView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.topView.bounds));
//
//                             {
//                                 self.progressView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.progressView.bounds));
//
//                                 [self.labelsView mas_updateConstraints:^(MASConstraintMaker *make) {
//                                     make.left.mas_equalTo(self.progressView).offset(-kLabelsViewWidth - kPaddingX);
//                                 }];
//
//                                 CGRect trackFrame = [self.playProgressBar trackRectForBounds:self.playProgressBar.bounds];
//                                 [self.playProgressBar mas_updateConstraints:^(MASConstraintMaker *make) {
//                                     make.centerY.mas_equalTo(self.progressView.mas_top).offset(-CGRectGetHeight(trackFrame));
//                                 }];
//                                 [self.playProgressBar setThumbImage:[UIImage new] forState:UIControlStateNormal];
//
//                                 [self.rotateBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//                                     make.right.mas_equalTo(self.progressView).offset(CGRectGetWidth(self.rotateBtn.frame));
//                                 }];
//
//                                 [self.progressView layoutIfNeeded];
//                             }
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

- (void)p_setToolViewHiddenWithOrientation:(WLPlayerViewOrientation)orientation
                                windowMode:(WLPlayerViewWindowMode)windowMode
                            playerViewType:(WLPlayerViewType)playerViewType {
    if (orientation == WLPlayerViewOrientation_Vertical
        && windowMode == WLPlayerViewWindowMode_Screen
        && playerViewType == WLPlayerViewType_Welike) {
        self.topView.hidden = NO;
        self.rightView.hidden = NO;
        self.infoView.hidden = NO;
    } else {
        self.topView.hidden = YES;
        self.rightView.hidden = YES;
        self.infoView.hidden = YES;
    }
    
    [self layoutIfNeeded];
}

- (void)p_setLikeBtnVideoModel:(WLVideoPost *)videoModel {
    self.likeBtn.selected = videoModel.like;
    
    videoModel.likeCount > 0
    ? [self.likeBtn setAttributedTitle:[self btnAttributedTitleWithString:[NSString stringWithFormat:@"%lld", videoModel.likeCount]]
                              forState:UIControlStateNormal]
    : [self.likeBtn setAttributedTitle:[self btnAttributedTitleWithString:[AppContext getStringForKey:@"comment_menu_like" fileName:@"feed"]]
                              forState:UIControlStateNormal];
}

- (void)p_muteChanged {
    self.volumeBtn.selected = _mute;
    
    if ([self.delegate respondsToSelector:@selector(playerOperateView:didVolumeChanged:)]) {
        [self.delegate playerOperateView:self didVolumeChanged:_mute];
    }
}

#pragma mark - Setter

+ (void)setMute:(BOOL)mute {
    _mute = mute;
}

- (void)setVideoModel:(WLVideoPost *)videoModel {
    _videoModel = videoModel;
    
    [self p_setToolViewHiddenWithOrientation:_playerOrientation
                                  windowMode:_windowMode
                              playerViewType:_playerViewType];
    
    [self.avatarView setFeedModel:videoModel];
    self.nameLabel.attributedText = [self attributedTextWithString:videoModel.nickName
                                                              font:kBoldFont(14.0)
                                                         fontColor:[UIColor whiteColor]];
    [self.nameLabel sizeToFit];
    
    self.timeLabel.attributedText = [self attributedTextWithString:[NSDate feedTimeStringFromTimestamp:videoModel.time]
                                                              font:kRegularFont(10.0)
                                                         fontColor:[UIColor whiteColor]];
    [self.timeLabel sizeToFit];
    
    self.followBtn.hidden = videoModel.following;
    [self.followBtn setFeedModel:videoModel];
    
    [self p_setLikeBtnVideoModel:videoModel];
    
    [self.richView setPostBase:videoModel];
    self.collpaseBtn.hidden = ![self.richView canUnfold];
}

- (void)setDownloading:(BOOL)downloading {
    _downloading = downloading;
    
    self.downloadProgressLayer.hidden = !downloading;
}

- (void)setDownloaded:(BOOL)downloaded {
    _downloaded = downloaded;
    
    self.downloadBtn.enabled = !downloaded;
    if (downloaded) {
        [self.downloadBtn setImage:[AppContext getImageForKey:@"video_downloaded"] forState:UIControlStateNormal];
    }
}

- (void)setWindowMode:(WLPlayerViewWindowMode)windowMode {
    _windowMode = windowMode;
    
    switch (windowMode) {
        case WLPlayerViewWindowMode_Screen: {
            if (self.playerViewStatus == WLPlayerViewStatus_Playing) {
                [self.playBtn setBackgroundImage:[AppContext getImageForKey:@"common_pause"] forState:UIControlStateNormal];
            } else {
                [self.playBtn setBackgroundImage:[AppContext getImageForKey:@"common_play"] forState:UIControlStateNormal];
            }
            [self.playBtn sizeToFit];
            
            self.rotateBtn.hidden = NO;
            self.volumeBtn.hidden = YES;
            
            {
                [WLPlayerOperateView setMute:NO];
                [self p_muteChanged];
            }
            
            if (!_selfTap) {
                _selfTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnTapped)];
                _selfTap.cancelsTouchesInView = NO;
                [self.maskView addGestureRecognizer:_selfTap];
            }
        }
            break;
        case WLPlayerViewWindowMode_Widget:
            [self setDisplayToos:NO animated:NO allTools:YES];
            [self.playBtn setBackgroundImage:[AppContext getImageForKey:@"feed_play"] forState:UIControlStateNormal];
            [self.playBtn sizeToFit];
            
            self.rotateBtn.hidden = YES;
            self.volumeBtn.hidden = NO;
            
            if (_selfTap) {
                [self.maskView removeGestureRecognizer:_selfTap];
                _selfTap = nil;
            }
            
            break;
    }
    
    [self p_setToolViewHiddenWithOrientation:_playerOrientation
                                  windowMode:_windowMode
                              playerViewType:_playerViewType];
}

- (void)setPlayerViewType:(WLPlayerViewType)playerViewType {
    _playerViewType = playerViewType;
    
    [self p_setToolViewHiddenWithOrientation:_playerOrientation
                                  windowMode:_windowMode
                              playerViewType:_playerViewType];
}

- (void)setPlayerOrientation:(WLPlayerViewOrientation)playerOrientation {
    _playerOrientation = playerOrientation;
    
    if (playerOrientation == WLPlayerViewOrientation_Vertical) {
        [self.rotateBtn setImage:[AppContext getImageForKey:@"player_rotate_v"] forState:UIControlStateNormal];
    } else {
        [self.rotateBtn setImage:[AppContext getImageForKey:@"player_rotate_h"] forState:UIControlStateNormal];
    }
    
    [self p_setToolViewHiddenWithOrientation:_playerOrientation
                                  windowMode:_windowMode
                              playerViewType:_playerViewType];
}

- (void)setPlayerViewStatus:(WLPlayerViewStatus)playerViewStatus {
    if (playerViewStatus == _playerViewStatus) {
        return;
    }
    _playerViewStatus = playerViewStatus;
    
    [self.playBtn setBackgroundImage:[AppContext getImageForKey:@"common_play"] forState:UIControlStateNormal];
    
    switch (playerViewStatus) {
        case WLPlayerViewStatus_ReadyToPlay:
            [self setCaching:YES];
            self.playBtn.alpha = 0.0;
            break;
        case WLPlayerViewStatus_Playing:
            [self setCaching:NO];
            [self.playBtn setBackgroundImage:[AppContext getImageForKey:@"common_pause"] forState:UIControlStateNormal];
            self.playBtn.alpha = 0.0;
            [self p_delayHideTools];
            break;
        case WLPlayerViewStatus_Paused:
            [self setCaching:NO];
            self.playBtn.alpha = 1.0;
            break;
        case WLPlayerViewStatus_CachingPaused:
            [self setCaching:YES];
            self.playBtn.alpha = 0.0;
            break;
        case WLPlayerViewStatus_Stopped:
            [self setCaching:NO];
            self.playBtn.alpha = 1.0;
            break;
        case WLPlayerViewStatus_Completed:
            [self setCaching:NO];
            if (self.playerView.isLoop) {
                self.playBtn.alpha = 0.0;
            } else {
                self.playBtn.alpha = 1.0;
            }
            break;
        default:
            [self setCaching:NO];
            self.playBtn.alpha = 1.0;
            break;
    }
}

- (void)setPlayProgress:(CGFloat)playProgress {
    _playProgress = playProgress;
    [self.playProgressBar setValue:playProgress animated:NO];
}

- (void)setCacheProgress:(CGFloat)cacheProgress {
    _cacheProgress = cacheProgress;
    [self.cacheProgressBar setValue:cacheProgress animated:NO];
}

- (void)setPlaySeconds:(CGFloat)playSeconds {
    _playSeconds = playSeconds;
    
    if (_duration > 0) {
        [self setPlayProgress:_playSeconds / _duration];
    }
//    if (playSeconds <= 0) {
//        self.leftLab.text = @"00:00";
//    } else {
//        self.leftLab.text = [self p_translateTotalSeconds:(int)floorf(playSeconds)];
//    }
}

- (void)setDuration:(CGFloat)duration {
    _duration = duration;
    
    if (_duration > 0) {
        [self setPlayProgress:_playSeconds / _duration];
    }
}

- (void)setCaching:(BOOL)caching {
    _caching = caching;
    
    if (caching) {
        [self.loadingView startAnimating];
    } else {
        [self.loadingView stopAnimating];
    }
}

- (void)setDisplayToos:(BOOL)displayToos {
    [self setDisplayToos:displayToos animated:YES allTools:NO];
}

- (void)setDisplayToos:(BOOL)displayToos animated:(BOOL)animated allTools:(BOOL)allTools {
    if (_displayToos == displayToos) {
        return;
    }
    
    _displayToos = displayToos;
    
    [self p_setToolsDisplay:displayToos animated:animated allTools:allTools];
}

#pragma mark - Getter

+ (BOOL)isMute {
    return _mute;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
        _maskView.backgroundColor = [UIColor clearColor];
    }
    return _maskView;
}

- (WLDynamicLoadingView *)loadingView {
    if (!_loadingView) {
        WLDynamicLoadingView *view = [[WLDynamicLoadingView alloc] init];
        view.lineWidth = 3.0;
        [self addSubview:view];
        
        _loadingView = view;
    }
    return _loadingView;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[AppContext getImageForKey:@"common_play"] forState:UIControlStateNormal];
        [btn sizeToFit];
        [btn addTarget:self action:@selector(playBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.alpha = 0.0;
        _playBtn = btn;
    }
    return _playBtn;
}

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.colors = @[(__bridge id)kUIColorFromRGBA(0x000000, 0.4).CGColor, (__bridge id)kUIColorFromRGBA(0x000000, 0.0).CGColor];
        _gradientLayer.startPoint = CGPointMake(0.5, 1.0);
        _gradientLayer.endPoint = CGPointMake(0.5, 0.0);
    }
    return _gradientLayer;
}

- (UIView *)progressView {
    if (!_progressView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                CGRectGetHeight(self.bounds) - (kBottomHeight + kSafeAreaBottomY),
                                                                CGRectGetWidth(self.bounds),
                                                                kBottomHeight + kSafeAreaBottomY)];
        view.backgroundColor = kUIColorFromRGBA(0x000000, 0.0);
        view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _progressView = view;
        
        self.gradientLayer.frame = view.bounds;
        [view.layer addSublayer:self.gradientLayer];
        
//        [view addSubview:self.labelsView];
//        [self.labelsView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(view).offset(kPaddingX);
//            make.centerY.mas_equalTo(view.mas_top).offset(kBottomHeight * 0.5);
//            make.width.mas_equalTo(kLabelsViewWidth);
//            make.height.mas_equalTo(kLabelsViewHeight);
//        }];
        
        [view addSubview:self.rotateBtn];
        [self.rotateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(view);
//            make.centerY.mas_equalTo(self.labelsView);
            make.centerY.mas_equalTo(view.mas_top).offset(kBottomHeight * 0.5 - 3.0);
            make.size.mas_equalTo(kSingleNavBarHeight);
        }];
        
        [view addSubview:self.volumeBtn];
        [self.volumeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(view);
            make.bottom.mas_equalTo(view).offset(-5.0);
            make.size.mas_equalTo(kSingleNavBarHeight);
        }];

//        [view addSubview:self.cacheProgressBar];
//        [self.cacheProgressBar mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerY.mas_equalTo(view.mas_top).offset(kBottomHeight * 0.5);
//            make.left.mas_equalTo(self.leftLab.mas_right).offset((10));
//            make.right.mas_equalTo(self.rightLab.mas_left).offset(-(10));
//        }];

        [view addSubview:self.playProgressBar];
        CGRect trackFrame = [self.playProgressBar trackRectForBounds:self.playProgressBar.bounds];
        [self.playProgressBar mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.mas_equalTo(self.cacheProgressBar);
            
//            make.centerY.mas_equalTo(view.mas_top).offset(kBottomHeight * 0.5);
//            make.left.mas_equalTo(self.labelsView.mas_right).offset(kPaddingX);
//            make.right.mas_equalTo(self.rotateBtn.mas_left);
            
            make.bottom.mas_equalTo(view).offset(-CGRectGetHeight(trackFrame) + 1);
            make.left.mas_equalTo(view);
            make.right.mas_equalTo(view);
        }];
    }
    return _progressView;
}

//- (UIView *)labelsView {
//    if (!_labelsView) {
//        UIView *view = [[UIView alloc] init];
//        _labelsView = view;
//
//        [view addSubview:self.leftLab];
//        [self.leftLab mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(view);
//            make.centerY.mas_equalTo(view);
//        }];
//
//        UILabel *separateLab = [[UILabel alloc] init];
//        separateLab.text = @" / ";
//        separateLab.textColor = self.leftLab.textColor;
//        separateLab.font = self.leftLab.font;
//        [separateLab sizeToFit];
//        [view addSubview:separateLab];
//        [separateLab mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.mas_equalTo(view);
//        }];
//
//        [view addSubview:self.rightLab];
//        [self.rightLab mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.mas_equalTo(view);
//            make.centerY.mas_equalTo(view);
//        }];
//    }
//    return _labelsView;
//}
//
//- (UILabel *)leftLab {
//    if (!_leftLab) {
//        UILabel *lab = [[UILabel alloc] init];
//        lab.text = @"00:00";
//        lab.textColor = [UIColor whiteColor];
//        lab.font = [UIFont systemFontOfSize:(12)];
//        lab.textAlignment = NSTextAlignmentLeft;
//        _leftLab = lab;
//    }
//    return _leftLab;
//}
//
//- (UILabel *)rightLab {
//    if (!_rightLab) {
//        UILabel *lab = [[UILabel alloc] init];
//        lab.text = @"00:00";
//        lab.textColor = [UIColor whiteColor];
//        lab.font = [UIFont systemFontOfSize:(12)];
//        lab.textAlignment = NSTextAlignmentRight;
//        _rightLab = lab;
//    }
//    return _rightLab;
//}

- (UISlider *)cacheProgressBar {
    if (!_cacheProgressBar) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0.0;
        slider.maximumValue = 1.0;
        slider.minimumTrackTintColor = kLightBackgroundViewColor;
        slider.maximumTrackTintColor = [UIColor clearColor];
        [slider setThumbImage:[UIImage new] forState:UIControlStateNormal];
        slider.userInteractionEnabled = NO;
        _cacheProgressBar = slider;
    }
    return _cacheProgressBar;
}

- (UISlider *)playProgressBar {
    if (!_playProgressBar) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0.0;
        slider.maximumValue = 1.0;
        slider.minimumTrackTintColor = kMainColor;
        slider.maximumTrackTintColor = kUIColorFromRGB(0xD5D5D5);
//        [slider setThumbImage:[AppContext getImageForKey:@"player_slider_thumb"] forState:UIControlStateNormal];
        [slider setThumbImage:[UIImage new] forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(sliderUpInside:) forControlEvents:UIControlEventTouchUpInside];
        _playProgressBar = slider;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)];
        [slider addGestureRecognizer:tap];
    }
    return _playProgressBar;
}

- (UIButton *)rotateBtn {
    if (!_rotateBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[AppContext getImageForKey:@"player_rotate_v"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(rotateBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _rotateBtn = btn;
    }
    return _rotateBtn;
}

- (UIButton *)volumeBtn {
    if (!_volumeBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.selected = _mute;
        [btn setImage:[AppContext getImageForKey:@"player_volume_open"] forState:UIControlStateNormal];
        [btn setImage:[AppContext getImageForKey:@"player_volume_close"] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(volumeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _volumeBtn = btn;
    }
    return _volumeBtn;
}

- (UIView *)infoView {
    if (!_infoView) {
        _infoView = [[UIView alloc] initWithFrame:CGRectMake(kMarginX, 0,
                                                             kScreenWidth - kMarginX * 2 - kSingleNavBarHeight,
                                                             kBottomHeight - kPaddingX)];
        _infoView.backgroundColor = [UIColor clearColor];
        
//        _collpaseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _collpaseBtn.hidden = YES;
//        _collpaseBtn.frame = CGRectMake(0, 0, 16, 16);
//        _collpaseBtn.backgroundColor = [UIColor whiteColor];
//        _collpaseBtn.layer.cornerRadius = 4.0;
//        _collpaseBtn.layer.masksToBounds = YES;
//        [_collpaseBtn setImage:[AppContext getImageForKey:@"player_arrow"] forState:UIControlStateNormal];
//        _collpaseBtn.center = CGPointMake(CGRectGetWidth(_infoView.bounds) - CGRectGetWidth(_collpaseBtn.bounds) * 0.5,
//                                          CGRectGetHeight(_infoView.bounds) - CGRectGetHeight(_collpaseBtn.bounds) * 0.5);
//        [_collpaseBtn addTarget:self action:@selector(collapseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [_infoView addSubview:_collpaseBtn];
        
        _richView = [[WLFoldRichView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_infoView.bounds) - CGRectGetWidth(_collpaseBtn.bounds), 0)
                                           withMinLineNum:2];
        _richView.contentColor = [UIColor whiteColor];
        _richView.delegate = self;
        [_infoView addSubview:_richView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infoViewTapped:)];
        tap.cancelsTouchesInView = NO;
        [_infoView addGestureRecognizer:tap];
    }
    return _infoView;
}

- (UIView *)topView {
    if (!_topView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        _topView = view;
        
        [view addSubview:self.avatarView];
        [view addSubview:self.nameLabel];
        [view addSubview:self.timeLabel];
        [view addSubview:self.followBtn];
        
//        CGFloat size = kSingleNavBarHeight;
//        CGFloat centerX = CGRectGetWidth(view.bounds) - size * 0.5;
//        CGFloat centerY = CGRectGetHeight(view.bounds) - size * 0.5;
//
//        self.volumeBtn.frame = CGRectMake(0, 0, size, size);
//        self.volumeBtn.center = CGPointMake(centerX, centerY);
//        [view addSubview:self.volumeBtn];
//        centerX -= CGRectGetWidth(self.volumeBtn.bounds);
//
//        if (self.playerViewType == WLPlayerViewType_Welike) {
//            self.downloadBtn.frame = CGRectMake(0, 0, size, size);
//            self.downloadBtn.center = CGPointMake(centerX, centerY);
//            [view addSubview:self.downloadBtn];
//
//            self.downloadProgressLayer.position = self.downloadBtn.center;
//            [view.layer addSublayer:self.downloadProgressLayer];
//        }
    }
    return _topView;
}

- (WLHeadView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
        _avatarView.frame = CGRectMake(0, 0, 24, 24);
        _avatarView.delegate = self;
        _avatarView.layer.borderColor = [UIColor whiteColor].CGColor;
        _avatarView.layer.borderWidth = 1.0;
        _avatarView.layer.cornerRadius = CGRectGetWidth(_avatarView.bounds) * 0.5;
    }
    return _avatarView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        
        _nameLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userInfoTapped)];
        [_nameLabel addGestureRecognizer:tap];
    }
    return _nameLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _timeLabel;
}

- (WLFollowButton *)followBtn {
    if (!_followBtn) {
        _followBtn = [[WLFollowButton alloc] init];
        _followBtn.delegate = self;
    }
    return _followBtn;
}

- (UIView *)rightView {
    if (!_rightView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSingleNavBarHeight, kScreenHeight)];
        view.backgroundColor = [UIColor clearColor];
        _rightView = view;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightViewTapped:)];
        [view addGestureRecognizer:tap];
        
        [view addSubview:self.downloadBtn];
        [self.downloadBtn.layer addSublayer:self.downloadProgressLayer];
        
        [view addSubview:self.shareBtn];
        [view addSubview:self.likeBtn];
    }
    return _rightView;
}

- (WLImageButton *)downloadBtn {
    if (!_downloadBtn) {
        WLImageButton *btn = [self buttonWithTitle:[AppContext getStringForKey:@"video_download" fileName:@"common"]];
        btn.enabled = YES;
        [btn setImage:[AppContext getImageForKey:@"video_download"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(downloadBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _downloadBtn = btn;
    }
    return _downloadBtn;
}

- (WLImageButton *)shareBtn {
    if (!_shareBtn) {
        WLImageButton *btn = [self buttonWithTitle:[AppContext getStringForKey:@"feed_share" fileName:@"feed"]];
        btn.imageOrientation = WLImageButtonOrientation_Top;
        [btn setImage:[AppContext getImageForKey:@"video_share"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(shareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        _shareBtn = btn;
    }
    return _shareBtn;
}

- (WLImageButton *)likeBtn {
    if (!_likeBtn) {
        WLImageButton *btn = [self buttonWithTitle:nil];
        [btn setImage:[AppContext getImageForKey:@"video_like"] forState:UIControlStateNormal];
        [btn setImage:[AppContext getImageForKey:@"video_like_liked"] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(likeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _likeBtn = btn;
    }
    return _likeBtn;
}

- (CAShapeLayer *)downloadProgressLayer {
    if (!_downloadProgressLayer) {
        CGFloat lineWidth = 3.0;
        CGFloat cycleSize = CGRectGetHeight(self.downloadBtn.imageView.bounds) - 5.0 - lineWidth * 2;
        _downloadProgressLayer = [CAShapeLayer layer];
        _downloadProgressLayer.backgroundColor = [UIColor clearColor].CGColor;
        _downloadProgressLayer.frame = CGRectMake(0, 0, cycleSize, cycleSize);
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, cycleSize, cycleSize)
                                                        cornerRadius:cycleSize * 0.5];
        _downloadProgressLayer.path = path.CGPath;
        _downloadProgressLayer.fillColor = [UIColor clearColor].CGColor;
        _downloadProgressLayer.strokeColor = kMainColor.CGColor;
        _downloadProgressLayer.lineWidth = lineWidth;
        _downloadProgressLayer.lineCap = kCALineCapRound;
        _downloadProgressLayer.strokeStart = 0.0;
        _downloadProgressLayer.strokeEnd = 0.0;
    }
    return _downloadProgressLayer;
}

- (WLSingleContentManager *)deleteManager {
    if (!_deleteManager) {
        _deleteManager = [AppContext getInstance].singleContentManager;
    }
    return _deleteManager;
}

#pragma mark - Factory

- (WLImageButton *)buttonWithTitle:(NSString *)title {
    WLImageButton *btn = [WLImageButton buttonWithType:UIButtonTypeCustom];
    btn.imageOrientation = WLImageButtonOrientation_Top;
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setAttributedTitle:[self btnAttributedTitleWithString:title] forState:UIControlStateNormal];
    
    return btn;
}

- (NSAttributedString *)btnAttributedTitleWithString:(NSString *)str {
    if (str.length == 0) {
        return nil;
    }
    
    return [self attributedTextWithString:str font:kRegularFont(kLightFontSize) fontColor:[UIColor whiteColor]];
}

- (NSAttributedString *)attributedTextWithString:(NSString *)str font:(UIFont *)font fontColor:(UIColor *)fontColor {
    if (str.length == 0) {
        return nil;
    }
    
    NSShadow *shadow = [self textShadow];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:str
                                                                         attributes:@{NSForegroundColorAttributeName: fontColor,
                                                                                      NSFontAttributeName: font,
                                                                                      NSShadowAttributeName: shadow}];
    
    return attributedText;
}

- (NSShadow *)textShadow {
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    shadow.shadowOffset = CGSizeMake(0.0, 0.0);
    shadow.shadowBlurRadius = 3.0;
    
    return shadow;
}

@end
