//
//  WLApoloPlayerView.m
//  welike
//
//  Created by fan qi on 2018/6/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLApoloPlayerView.h"
#import "U3Player.h"
#import "WLPlayerOperateView.h"
#import "WLVideoDownloadManager.h"
#import "WLAuthorizationHelper.h"

@interface WLApoloPlayerView () <U3PlayerDelegate, WLPlayerOperateViewDelegate, WLVideoDownloadManagerDelegate>

@property (nonatomic, strong) U3Player *player;
@property (nonatomic, strong) WLVideoDownloadAbstractManager *downloadManager;

@end

@implementation WLApoloPlayerView {
    NSTimer *_timer;
    BOOL _isCaching;
    BOOL _isCompleted;
}

- (instancetype)init {
    if (self = [self initWithFrame:CGRectZero]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        
        _isCaching = NO;
        _isCompleted = NO;
        
        self.operateView.playerViewType = WLPlayerViewType_Welike;
        self.operateView.delegate = self;
        [self.operateView prepare];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_player setFrame:self.bounds];
}

- (void)dealloc {
    [_downloadManager cancel];
    _downloadManager = nil;
    
    [self p_destroyPlayer];
}

- (void)initializePlayer {
    _player = [[U3Player alloc] init];
    [_player setFrame:self.bounds];
    _player.delegate = self;
    [self p_setVolume:[WLPlayerOperateView isMute]];
    
    _player.playBackView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_player.playBackView];
    _player.scaleMode = kVideoRenderingScaleModeAspectFit;
    [self sendSubviewToBack:_player.playBackView];
    
    [self addObservers];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 / 60.0
                                              target:self
                                            selector:@selector(timerStep)
                                            userInfo:nil
                                             repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

#pragma mark - Public

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    _player.playBackView.backgroundColor = backgroundColor;
}

- (void)play {
    if (![self checkNetworkReachable]) {
        return;
    }
    
    if (_player) {
        [_timer setFireDate:[NSDate date]];
        [_player play];
        return;
    }
    
    [self initializePlayer];
    _player.mediaFilePath = [NSURL URLWithString:_urlString];
    
    BOOL succeed = [_player prepare];
    if (!succeed) {
        [self setPlayerViewStatus:WLPlayerViewStatus_Failed];
    }
}

- (void)pause {
    [_timer setFireDate:[NSDate distantFuture]];
    [_player pause];
}

- (void)stop {
    [self p_stopPlay];
}

- (void)seekToPosition:(CGFloat)position {
    [_player seek:position];
}

#pragma mark - Observer

- (void)timerStep {
    if (_player == nil) {
        return;
    }
    
    float duration = _player.duration;
    float position = _player.position;
    
    self.operateView.playSeconds = position;
    self.operateView.duration = duration;
}

- (void)addObservers {
    [_player addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObservers {
    [_player removeObserver:self forKeyPath:@"state"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"state"]) {
        VideoPlayerState state = [change[NSKeyValueChangeNewKey] integerValue];
        
        switch (state) {
            case VideoPlayer_Unknown:
                [self setPlayerViewStatus:WLPlayerViewStatus_Unknown];
                break;
            case VideoPlayer_Playing:
                if (_isCaching) {
                    [self setPlayerViewStatus:WLPlayerViewStatus_CachingPaused];
                } else {
                    [self setPlayerViewStatus:WLPlayerViewStatus_Playing];
                }
                break;
            case VideoPlayer_Ready:
                [self setPlayerViewStatus:WLPlayerViewStatus_ReadyToPlay];
                break;
            case VideoPlayer_Pause:
                [self setPlayerViewStatus:WLPlayerViewStatus_Paused];
                break;
            case VideoPlayer_Buffering:
                [self setPlayerViewStatus:WLPlayerViewStatus_CachingPaused];
                break;
            case VideoPlayer_Stop:
                [self setPlayerViewStatus:WLPlayerViewStatus_Stopped];
                break;
            case VideoPlayer_End:
                [self setPlayerViewStatus:WLPlayerViewStatus_Completed];
                break;
            case VideoPlayer_Error:
                [self setPlayerViewStatus:WLPlayerViewStatus_Failed];
                break;
        }
        
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - U3PlayerDelegate

- (void)onPrepared {
    [_player play];
    
//    NSLog(@"-------> onPrepared");
}

- (void)onSeekCompleted {
    if (self.playerViewStatus != WLPlayerViewStatus_Completed) {
        [_player play];
    }
}

- (void)onEndOfStream {
    _isCompleted = YES;
    _isCaching = NO;
    [self p_resetPlayer];
}

- (void)onStopped {
    _isCompleted = YES;
    _isCaching = NO;
//    NSLog(@"-------> onStopped");
}

- (void)onBufferingUpdate:(int)percent {
//    NSLog(@"-----> onBufferingUpdate: %d", percent);
    
    self.operateView.cacheProgress = percent;
}

- (void)onBufferingStateUpdate:(bool)is_start {
    if (_isCompleted) {
        return;
    }
    _isCaching = is_start;
    
    if (is_start) {
        [self setPlayerViewStatus:WLPlayerViewStatus_CachingPaused];
    } else if (self.playerViewStatus == WLPlayerViewStatus_CachingPaused) {
        [self setPlayerViewStatus:WLPlayerViewStatus_Playing];
    }
    
//    NSLog(@"*****> onBufferingStateUpdate: %d", is_start);
}

- (void)onDownloadRateChange:(int)bytes_per_second {
//    NSLog(@"=====> onDownloadRateChange: %d", bytes_per_second);
}

- (void)onErrorOfStream:(int)what Extra:(int)extra {
//    NSLog(@"onErrorOfStream: %d - %d", what, extra);
}

- (void)onVideoSizeChanged:(int)width height:(int)height {
    
}

- (void)onStatT3:(int64_t)timeMs startTime:(int64_t)startMs endTime:(int64_t)endMs {
//    NSLog(@"onStatT3:startTime:endTime: %ld - %ld - %ld", (long)timeMs, (long)startMs, (long)endMs);
}

#pragma mark - WLPlayerOperateViewDelegate

- (void)playerOperateViewDidClickedPlay:(WLPlayerOperateView *)operateView {
    if (self.playerViewStatus != WLPlayerViewStatus_Playing) {
        [self play];
    } else {
        [self pause];
    }
}

- (void)playerOperateViewDidClickedRotate:(WLPlayerOperateView *)operateView {
    if ([self.delegate respondsToSelector:@selector(playerViewOrientationDidChanged:)]) {
        [self.delegate playerViewOrientationDidChanged:self];
    }
}

- (void)playerOperateView:(WLPlayerOperateView *)operateView didVolumeChanged:(BOOL)mute {
    [self p_setVolume:mute];
}

- (void)playerOperateViewDidClickedDownload:(WLPlayerOperateView *)operateView {
    [WLAuthorizationHelper requestPhotoAuthorizationWithFinished:^(BOOL granted) {
        if (granted) {
            if ([[self.urlString lowercaseString] hasSuffix:kM3U8Suffix]) {
                self->_downloadManager = [[FQM3U8DownloadManager alloc] init];
            } else {
                self->_downloadManager = [[WLVideoDownloadManager alloc] init];
            }
            
            self->_downloadManager.delegate = self;
            [self->_downloadManager setDownloadUrlString:self.urlString];
            BOOL started = [self->_downloadManager start];
            
            if (started) {
                [self.operateView setDownloading:YES];
                self.operateView.downloadProgressLayer.strokeEnd = 0.01;
            }
        }
    }];
}

- (void)playerOperateView:(WLPlayerOperateView *)operateView didSliderValueChanged:(CGFloat)changedValue {
    if (_player) {
        [_player pause];
        
        CGFloat position = changedValue * _player.duration;
        [_player seek:position];
    }
}

- (void)playerOperateView:(WLPlayerOperateView *)operateView didDiaplayToolsChanged:(BOOL)displayTools{
    if ([self.delegate respondsToSelector:@selector(playerView:didDiaplayToolsChanged:)]) {
        [self.delegate playerView:self didDiaplayToolsChanged:displayTools];
    }
}

#pragma mark - WLVideoDownloadManagerDelegate

- (void)videoDownloadManager:(WLVideoDownloadAbstractManager *)manager progress:(CGFloat)progress {
    self.operateView.downloadProgressLayer.strokeEnd = progress;
}

- (void)videoDownloadManagerDidCompleted:(WLVideoDownloadAbstractManager *)manager error:(NSError *)error {
    [self.operateView setDownloading:NO];
    self.operateView.downloadProgressLayer.strokeEnd = 0.0;
    
    if (error) {
        [self.operateView setDownloaded:NO];
    } else {
        [self.operateView setDownloaded:YES];
    }
}

#pragma mark - Private

- (void)p_setVolume:(BOOL)mute {
    [_player setVolume:mute ? 0.0 : 1.0 right:mute ? 0.0 : 1.0];
}

- (void)p_resetPlayer {
    [_player seek:0.0];
    [_player pause];
    
    self.operateView.playSeconds = 0;
    self.operateView.duration = _player.duration;
}

- (void)p_destroyPlayer {
    if (_player != nil) {
        [_player stop];
        _player.delegate = nil;
        [_player.playBackView removeFromSuperview];
        [self removeObservers];
        _player = nil;
        
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)p_stopPlay {
    [self p_destroyPlayer];
}

#pragma mark - Setter

- (void)setVideoGravity:(WLPlayerViewGravity)videoGravity {
    [super setVideoGravity:videoGravity];
    
    switch (videoGravity) {
        case WLPlayerViewGravity_ResizeAspectFill:
            _player.scaleMode = kVideoRenderingScaleModeAspectFill;
            break;
        case WLPlayerViewGravity_ResizeAspect:
            _player.scaleMode = kVideoRenderingScaleModeAspectFit;
            break;
    }
}

- (void)setUrlString:(NSString *)urlString {
    if ([_urlString isEqualToString:urlString]) {
        return;
    }
    
    _urlString = [urlString copy];
    
//    {
//        // just for test
//        _urlString = @"https://d1oeqqihcawq66.cloudfront.net/2018/7/19/14987388/14987388.m3u8";
//    }
    
    [self p_destroyPlayer];
    
//    if (_player.mediaFilePath) {
//        [_player switchVideoPath:_urlString header:_player.httpHeaders];
//    } else {
//        _player.mediaFilePath = [NSURL URLWithString:_urlString];
//    }
}

#pragma mark - Getter

- (CGFloat)position {
    return _player.position;
}

@end
