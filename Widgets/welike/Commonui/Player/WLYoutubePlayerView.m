//
//  WLYoutubePlayerView.m
//  welike
//
//  Created by fan qi on 2018/6/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLYoutubePlayerView.h"
#import "WLPlayerOperateView.h"
#import "YTPlayerView.h"

@interface WLYoutubePlayerView () <YTPlayerViewDelegate, WLPlayerOperateViewDelegate, UIWebViewDelegate>

@property (nonatomic, strong) YTPlayerView *playerView;

@end

@implementation WLYoutubePlayerView

- (instancetype)init {
    if (self = [self initWithFrame:CGRectZero]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializePlayer];
        
        self.operateView.playerViewType = WLPlayerViewType_YouTube;
        self.operateView.delegate = self;
        [self.operateView prepare];
    }
    return self;
}

- (void)initializePlayer {
    [self addSubview:self.playerView];
    [self sendSubviewToBack:self.playerView];
    
//    {
//        TODO("Test data")
//        self.videoID = @"Y3PqeSkX2vk";
//    }
    
    NSDictionary *playerVars = @{@"controls" : @0,
                                 @"playsinline" : @1,
                                 @"autohide" : @1,
                                 @"showinfo" : @0,
                                 @"modestbranding" : @1};
    [self.playerView loadWithVideoId:self.videoID playerVars:playerVars];
    [self.playerView.webView setDelegate:self];
    self.playerView.webView.opaque = NO;
    self.playerView.webView.backgroundColor = [UIColor blackColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.playerView.frame = self.bounds;
}

#pragma mark - Public

- (void)play {
    if (![self checkNetworkReachable]) {
        return;
    }
    
    [self.playerView playVideo];
}

- (void)pause {
    [self.playerView pauseVideo];
}

- (void)stop {
    [self.playerView stopVideo];
}

#pragma mark - YTPlayerViewDelegate

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView {
    [self setPlayerViewStatus:WLPlayerViewStatus_Paused];
    
    if (playerView.playerState == kYTPlayerStateQueued) {
        [playerView playVideo];
    }
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state {
    switch (state) {
        case kYTPlayerStateUnstarted:
            [self setPlayerViewStatus:WLPlayerViewStatus_ReadyToPlay];
            break;
        case kYTPlayerStateEnded:
            [self setPlayerViewStatus:WLPlayerViewStatus_Completed];
            [self p_resetPlayer];
            break;
        case kYTPlayerStatePlaying:
            [self setPlayerViewStatus:WLPlayerViewStatus_Playing];
            break;
        case kYTPlayerStatePaused:
            [self setPlayerViewStatus:WLPlayerViewStatus_Paused];
            break;
        case kYTPlayerStateBuffering:
            [self setPlayerViewStatus:WLPlayerViewStatus_CachingPaused];
            break;
        case kYTPlayerStateQueued:
            [self setPlayerViewStatus:WLPlayerViewStatus_Stopped];
            break;
        case kYTPlayerStateUnknown:
            [self setPlayerViewStatus:WLPlayerViewStatus_Unknown];
            break;
    }
}

- (void)playerView:(YTPlayerView *)playerView didPlayTime:(float)playTime {
    self.operateView.playSeconds = playTime;
    self.operateView.duration = self.playerView.duration;
    self.operateView.playProgress = playTime / self.playerView.duration;
}

- (void)playerView:(YTPlayerView *)playerView didChangeToQuality:(YTPlaybackQuality)quality {
    
}

- (void)playerView:(YTPlayerView *)playerView receivedError:(YTPlayerError)error {
    
}

- (UIColor *)playerViewPreferredWebViewBackgroundColor:(nonnull YTPlayerView *)playerView {
    return [UIColor blackColor];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return [self.playerView webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self playerView:self.playerView didChangeToState:self.playerView.playerState];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.playerView webView:webView didFailLoadWithError:error];
}

#pragma mark - WLPlayerOperateViewDelegate

- (void)playerOperateViewDidClickedPlay:(WLPlayerOperateView *)operateView {
    if (self.playerViewStatus != WLPlayerViewStatus_Playing) {
        [self.playerView playVideo];
    } else {
        [self.playerView pauseVideo];
    }
}

- (void)playerOperateViewDidClickedRotate:(WLPlayerOperateView *)operateView {
    if ([self.delegate respondsToSelector:@selector(playerViewOrientationDidChanged:)]) {
        [self.delegate playerViewOrientationDidChanged:self];
    }
}

- (void)playerOperateView:(WLPlayerOperateView *)operateView didVolumeChanged:(BOOL)mute {
    
}

- (void)playerOperateView:(WLPlayerOperateView *)operateView didSliderValueChanged:(CGFloat)changedValue {
    CGFloat seekToTime = self.playerView.duration * changedValue;
    [self.playerView seekToSeconds:seekToTime allowSeekAhead:YES];
}

- (void)playerOperateView:(WLPlayerOperateView *)operateView didDiaplayToolsChanged:(BOOL)displayTools {
    if ([self.delegate respondsToSelector:@selector(playerView:didDiaplayToolsChanged:)]) {
        [self.delegate playerView:self didDiaplayToolsChanged:displayTools];
    }
}

#pragma mark - Private

- (void)p_resetPlayer {
    self.operateView.playProgress = 0.0;
    self.operateView.playSeconds = 0;
    self.operateView.duration = self.playerView.duration;
}

#pragma mark - Setter

// 暂时这样解决某些YouTube视频无法播放的问题
- (void)setPlayerViewStatus:(WLPlayerViewStatus)playerViewStatus {
    [super setPlayerViewStatus:playerViewStatus];
    
    self.operateView.hidden = NO;
    
    switch (playerViewStatus) {
        case WLPlayerViewStatus_Unknown:
            if ([self checkNetworkReachable]) {
                self.operateView.hidden = YES;
                
                if ([self.delegate respondsToSelector:@selector(playerView:didDiaplayToolsChanged:)]) {
                    [self.delegate playerView:self didDiaplayToolsChanged:YES];
                }
            }
            break;
        default:
            break;
    }
}

#pragma mark - Getter

- (YTPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[YTPlayerView alloc] init];
        _playerView.delegate = self;
    }
    return _playerView;
}

@end
