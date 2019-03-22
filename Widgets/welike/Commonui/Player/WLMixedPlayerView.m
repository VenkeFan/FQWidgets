//
//  WLMixedPlayerView.m
//  welike
//
//  Created by fan qi on 2018/6/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLMixedPlayerView.h"
#import "WLAVPlayerView.h"
#import "WLYoutubePlayerView.h"
#import "WLApoloPlayerView.h"
#import "WLPlayerCollectionView.h"
#import "WLVideoPost.h"
#import "WLFeedCell.h"

@interface WLMixedPlayerView () <WLPlayerViewDelegate> {
    UIView *_previousSuperView;
}

@property (nonatomic, strong) WLAbstractPlayerView *playerView;

@property (nonatomic, copy, readwrite) NSString *urlString;
@property (nonatomic, copy, readwrite) NSString *videoID;
@property (nonatomic, strong, readwrite) AVAsset *asset;

@end

@implementation WLMixedPlayerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnTapped)];
        tap.cancelsTouchesInView = YES;
        [self addGestureRecognizer:tap];
        
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    self.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.playerView.frame = self.bounds;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview && !_previousSuperView) {
        _previousSuperView = newSuperview;
    }
}

- (void)dealloc {
    [_playerView stop];
    _playerView = nil;
}

- (void)initializePlayer {
    if (_videoID.length > 0) {
        if (![_playerView isKindOfClass:[WLYoutubePlayerView class]]) {
            [self p_destroyPlayerView];
            
            _playerView = [[WLYoutubePlayerView alloc] init];
            [self addSubview:_playerView];
            [self sendSubviewToBack:_playerView];
        }
        [(WLYoutubePlayerView *)_playerView setVideoID:_videoID];
        
    } else if (_urlString.length > 0) {
        if (![_playerView isKindOfClass:[WLApoloPlayerView class]]) {
            [self p_destroyPlayerView];

            _playerView = [[WLApoloPlayerView alloc] init];
            [self addSubview:_playerView];
            [self sendSubviewToBack:_playerView];
        }
        [(WLApoloPlayerView *)_playerView setUrlString:_urlString];
        
    } else if (_asset) {
        if (![_playerView isKindOfClass:[WLAVPlayerView class]]) {
            [self p_destroyPlayerView];
            
            _playerView = [[WLAVPlayerView alloc] init];
            [self addSubview:_playerView];
            [self sendSubviewToBack:_playerView];
        }
        [(WLAVPlayerView *)_playerView setAsset:_asset];
    }
    
    _playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _playerView.delegate = self;
    [_playerView setVideoGravity:WLPlayerViewGravity_ResizeAspect];
    _playerView.operateView.cacheProgress = 0.0;
}

#pragma mark - Public

- (void)setVideoModel:(WLVideoPost *)videoModel {
    _videoModel = videoModel;
    
    [self setURLString:videoModel.videoUrl videoSite:videoModel.videoSite];
    
    [self.playerView.operateView setVideoModel:videoModel];
}

- (void)setAsset:(AVAsset *)asset {
    if (_asset == asset) {
        return;
    }
    
    _asset = asset;
    
    [self initializePlayer];
}

- (void)dismiss {
    if (self.playerView.windowMode == WLPlayerViewWindowMode_Screen) {
        self.playerView.windowMode = WLPlayerViewWindowMode_Widget;
        
        CGRect frame = [self->_previousSuperView convertRect:self->_previousSuperView.bounds
                                                      toView:[AppContext currentViewController].view];
        [[AppContext currentViewController].view addSubview:self];
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.frame = frame;
                         }
                         completion:^(BOOL finished) {
                             self.frame = self->_previousSuperView.bounds;
                             [self->_previousSuperView addSubview:self];
                         }];
    }
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    
    if ([_previousSuperView isKindOfClass:[WLFeedVideoView class]]) {
        WLFeedVideoView *superView = (WLFeedVideoView *)_previousSuperView;
        [superView playerViewRemoved];
    }
}

#pragma mark - WLPlayerViewDelegate

- (void)playerView:(WLAbstractPlayerView *)playerView statusDidChanged:(WLPlayerViewStatus)status {
    if ([self.delegate respondsToSelector:@selector(mixedPlayerView:statusDidChanged:)]) {
        [self.delegate mixedPlayerView:self statusDidChanged:status];
    }
    
    if (playerView.operateView.cacheProgress <= kMarginalCacheValue) {
        playerView.backgroundColor = [UIColor clearColor];
    } else {
        playerView.backgroundColor = [UIColor blackColor];
    }
    
    if (status == WLPlayerViewStatus_Stopped || status == WLPlayerViewStatus_Completed) {
        [WLTrackerPlayer appendTrackerWithPlayerAction:playerView.windowMode == WLPlayerViewWindowMode_Screen
                                                        ? WLTrackerPlayerAction_Screen
                                                        : WLTrackerPlayerAction_Widget
                                             videoPost:playerView.operateView.videoModel
                                              playTime:playerView.operateView.playSeconds
                                              duration:playerView.operateView.duration
                                              muteType:WLPlayerOperateView.isMute ? WLTrackerPlayerMuteType_Closed : WLTrackerPlayerMuteType_Opened];
    }
}

- (void)playerViewOrientationDidChanged:(WLAVPlayerView *)playerView {
    if ([self.delegate respondsToSelector:@selector(mixedPlayerViewOrientationDidChanged:)]) {
        [self.delegate mixedPlayerViewOrientationDidChanged:self];
    }
}

#pragma mark - Event

- (void)selfOnTapped {
    if (self.playerView.windowMode == WLPlayerViewWindowMode_Widget) {
        WLPlayerCollectionView *playerCollectionView = [[WLPlayerCollectionView alloc] initWithPostID:self.videoModel.pid];
        [playerCollectionView displayWithSubView:self];
    }
}

#pragma mark - Private

- (void)setURLString:(NSString *)urlString videoSite:(NSString *)videoSite {
    _urlString = [urlString copy];
    
    if (videoSite.length > 0) {
        _videoID = [[urlString componentsSeparatedByString:@"/"].lastObject copy];
    }
    
    [self initializePlayer];
}

- (void)p_destroyPlayerView {
    [_playerView stop];
    [_playerView removeFromSuperview];
    _playerView = nil;
}

@end
