//
//  FQPlayerView.m
//  WeLike
//
//  Created by fan qi on 2018/4/8.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQPlayerView.h"

@interface FQPlayerView () <FQPlayerOperateViewDelegate> {
    NSString *_urlString;
    AVAsset *_asset;
    id _timeObserver;
}

@property (nonatomic, weak) FQPlayerOperateView *operateView;

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, assign) CGFloat totalDurationSeconds;
@property (nonatomic, assign) CGFloat playBuffer;

@end

@implementation FQPlayerView

#pragma mark - LifeCycle

- (instancetype)initWithURLString:(NSString *)urlString {
    if (self = [super init]) {
        _urlString = [urlString copy];
    }
    return self;
}

- (instancetype)initWithAsset:(AVAsset *)asset {
    if (self = [super init]) {
        _asset = asset;
    }
    return self;
}

- (instancetype)init {
    if (self = [self initWithFrame:CGRectZero]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [(AVPlayerLayer *)self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    return self;
}

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (void)layoutSubviews {
    [self.operateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

- (void)dealloc {
    NSLog(@"FQPlayerView dealloc");
    
    [self removeNotifications];
}

#pragma mark - Public

- (void)playWithUrlString:(NSString *)urlString {
    NSURL *url = nil;
    if ([urlString isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:urlString];
    } else if ([urlString isKindOfClass:[NSURL class]]) {
        url = (NSURL *)urlString;
    }
    
    if (!url) {
        return;
    }
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    [self p_playWithPlayerItem:playerItem];
}

- (void)playWithAsset:(AVAsset *)asset {
    if (!asset) {
        return;
    }
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self p_playWithPlayerItem:playerItem];
}

- (void)play {
    if (_player) {
        [_player play];
    } else {
        if (_asset) {
            [self playWithAsset:_asset];
        } else if (!kIsNullOrEmpty(_urlString)) {
            [self playWithUrlString:_urlString];
        }
    }
}

- (void)pause {
    [_player pause];
}

- (void)stop {
    [_player pause];
    [_player seekToTime:kCMTimeZero];
    
    self.operateView.playProgress = 0;
    self.operateView.playSeconds = 0;
    self.operateView.restSeconds = self.totalDurationSeconds;
    
    [self setPlayerViewStatus:FQPlayerViewStatus_Stopped];
}

#pragma mark - Notification

- (void)addNotifications {
    [_player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    [_player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    [_player.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    [_player.currentItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    [_player.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
//    [_player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didPlayTimeJumped:)
                                                 name:AVPlayerItemTimeJumpedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didPlayToEndTime:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFailedToPlayToEndTime:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didPlaybackStalled:)
                                                 name:AVPlayerItemPlaybackStalledNotification
                                               object:nil];
}

- (void)removeNotifications {
    [_player removeObserver:self forKeyPath:@"status"];
    [_player removeObserver:self forKeyPath:@"rate"];
    [_player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [_player.currentItem removeObserver:self forKeyPath:@"playbackBufferFull"];
    [_player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
//    [_player removeObserver:self forKeyPath:@"timeControlStatus"];
    
    [_player removeTimeObserver:_timeObserver];
    _timeObserver = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [change[@"new"] integerValue];
        switch (status) {
            case AVPlayerStatusUnknown:
                [self setPlayerViewStatus:FQPlayerViewStatus_Unknown];
                break;
            case AVPlayerStatusReadyToPlay:
                [_player play];
                [self setPlayerViewStatus:FQPlayerViewStatus_ReadyToPlay];
                break;
            case AVPlayerStatusFailed:
                [self setPlayerViewStatus:FQPlayerViewStatus_Failed];
                break;
        }
        
    } else if ([keyPath isEqualToString:@"rate"]) {
        CGFloat rate = [change[@"new"] floatValue];
        if (rate == 0 && self.playerViewStatus != FQPlayerViewStatus_Stopped && self.playerViewStatus != FQPlayerViewStatus_Completed) {
            [self setPlayerViewStatus:FQPlayerViewStatus_Paused];
        } else {
            [self setPlayerViewStatus:FQPlayerViewStatus_Playing];
        }
        
    } else if ([keyPath isEqualToString:@"timeControlStatus"]) {
//        AVPlayerTimeControlStatus ctrStatus = [change[@"new"] integerValue];
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        CMTimeRange timeRange = [playerItem.loadedTimeRanges.firstObject CMTimeRangeValue];//本次缓冲时间范围
        CGFloat startSeconds = CMTimeGetSeconds(timeRange.start);
        CGFloat durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        
        NSLog(@"缓冲区间: [%f, %f], 共缓冲: %f, 当前播放进度: %f, 总时长: %f", startSeconds, durationSeconds, totalBuffer, self.playBuffer, self.totalDurationSeconds);
        
        if (!isnan(totalBuffer)) {
            self.operateView.cacheProgress = totalBuffer / self.totalDurationSeconds;
            
            if (self.playerViewStatus != FQPlayerViewStatus_Paused && self.playerViewStatus != FQPlayerViewStatus_Stopped) {
                if (self.playBuffer == 0 || startSeconds == self.playBuffer) {
                    [self setPlayerViewStatus:FQPlayerViewStatus_CachingPaused];
                } else {
                    [self setPlayerViewStatus:FQPlayerViewStatus_Playing];
                }
            }
        } else {
            [self setPlayerViewStatus:FQPlayerViewStatus_CachingPaused];
        }
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        NSLog(@"playbackLikelyToKeepUp: %zd", [change[@"new"] boolValue]);
    } else if ([keyPath isEqualToString:@"playbackBufferFull"]) {
        NSLog(@"playbackBufferFull: %zd", [change[@"new"] boolValue]);
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        NSLog(@"playbackBufferEmpty: %zd", [change[@"new"] boolValue]);
    }
}

- (void)didPlayTimeJumped:(NSNotification *)notification {
    NSLog(@"didPlayTimeJumped");
}

- (void)didPlayToEndTime:(NSNotification *)notification {
    [self p_playCompleted];
}

- (void)didFailedToPlayToEndTime:(NSNotification *)notification {
    [self stop];
}

- (void)didPlaybackStalled:(NSNotification *)notification {
    NSLog(@"didPlaybackStalled");
}

#pragma mark - FQPlayerOperateViewDelegate

- (void)playerOperateViewDidClickedPlay:(FQPlayerOperateView *)operateView {
    if (self.playerViewStatus != FQPlayerViewStatus_Playing) {
        [self play];
    } else {
        [self pause];
    }
}

- (void)playerOperateViewDidClickedStop:(FQPlayerOperateView *)operateView {
    [self stop];
}

- (void)playerOperateView:(FQPlayerOperateView *)operateView didSliderValueChanged:(CGFloat)changedValue {
    NSLog(@"%f", changedValue);
    
    [self pause];
    CMTime durationTime = _player.currentItem.duration;
    CGFloat changedSeconds = changedValue * self.totalDurationSeconds;
    CMTime changedTime = CMTimeMake(changedSeconds * durationTime.timescale, durationTime.timescale);
    
    if (_player) {
        [_player seekToTime:changedTime
          completionHandler:^(BOOL finished) {
              if (self.operateView.playProgress != changedValue) {
                  self.operateView.playProgress = changedValue;
              }
              [self play];
          }];
    }
}

#pragma mark - Private

- (void)p_playWithPlayerItem:(AVPlayerItem *)playerItem {
    if (!playerItem) {
        return;
    }
    
    _player = [AVPlayer playerWithPlayerItem:playerItem];
    [(AVPlayerLayer *)self.layer setPlayer:_player];
    
    if (!_timeObserver) {
        __weak typeof(self) weakSelf = self;
        _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1)
                                                              queue:dispatch_get_main_queue()
                                                         usingBlock:^(CMTime time) {
                                                             CGFloat duration = weakSelf.totalDurationSeconds;
                                                             if (!isnan(duration)) {
                                                                 CGFloat seconds = CMTimeGetSeconds(time);
                                                                 weakSelf.playBuffer = seconds;
                                                                 
                                                                 weakSelf.operateView.playProgress = seconds / duration;
                                                                 weakSelf.operateView.playSeconds = seconds;
                                                                 weakSelf.operateView.restSeconds = duration - seconds;
                                                             }
                                                         }];
        
        [self addNotifications];
    }
}

- (void)p_playCompleted {
    [self removeNotifications];
    
    [_player replaceCurrentItemWithPlayerItem:nil];
    _player = nil;
    
    
    self.operateView.playSeconds = self.operateView.restSeconds = 0;
    self.operateView.playProgress = 0.0;
    self.operateView.cacheProgress = 0.0;
    
    [self setPlayerViewStatus:FQPlayerViewStatus_Completed];
}

// iOS 10.0
//- (void)p_updatePlayerViewStatusWithCtrStatus:(AVPlayerTimeControlStatus)status {
//    switch (status) {
//        case AVPlayerTimeControlStatusPlaying:
//            self.playerViewStatus = FQPlayerViewStatus_Playing;
//            break;
//        case AVPlayerTimeControlStatusPaused:
//            self.playerViewStatus = FQPlayerViewStatus_Paused;
//            break;
//        default:
//            break;
//    }
//}

#pragma mark - Setter

- (void)setPlayerViewStatus:(FQPlayerViewStatus)playerViewStatus {
    if (playerViewStatus == _playerViewStatus) {
        return;
    }
    _playerViewStatus = playerViewStatus;
    
    self.operateView.playerViewStatus = playerViewStatus;
    
    switch (playerViewStatus) {
        case FQPlayerViewStatus_ReadyToPlay:
            NSLog(@"-------------------->准备播放");
            break;
        case FQPlayerViewStatus_Playing:
            NSLog(@"-------------------->开始播放");
            break;
        case FQPlayerViewStatus_Paused:
            NSLog(@"-------------------->手动暂停");
            break;
        case FQPlayerViewStatus_CachingPaused:
            NSLog(@"-------------------->因缓冲而自动暂停");
            
            break;
        case FQPlayerViewStatus_Stopped:
            NSLog(@"-------------------->停止播放");
            break;
        case FQPlayerViewStatus_Completed:
            NSLog(@"-------------------->播放完成");
            break;
        default:
            
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(playerView:statusDidChanged:)]) {
        [self.delegate playerView:self statusDidChanged:playerViewStatus];
    }
}

#pragma mark - Getter

- (FQPlayerOperateView *)operateView {
    if (!_operateView) {
        FQPlayerOperateView *view = [[FQPlayerOperateView alloc] init];
        view.delegate = self;
        [self addSubview:view];
        _operateView = view;
    }
    return _operateView;
}

- (CGFloat)totalDurationSeconds {
    if (_totalDurationSeconds == 0.0 || isnan(_totalDurationSeconds)) {
        _totalDurationSeconds = CMTimeGetSeconds(_player.currentItem.duration);
    }
    return _totalDurationSeconds;
}

@end
