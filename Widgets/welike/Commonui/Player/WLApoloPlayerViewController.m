//
//  WLApoloPlayerViewController.m
//  welike
//
//  Created by fan qi on 2018/6/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLApoloPlayerViewController.h"
#import "U3Player.h"
#import "WLPlayerOperateView.h"

@interface WLApoloPlayerViewController () <U3PlayerDelegate, WLPlayerOperateViewDelegate>

@property (nonatomic, strong) U3Player *player;
@property (nonatomic, copy) NSString *urlString;

@property (nonatomic, strong) WLPlayerOperateView *operateView;
@property (nonatomic, strong) UIButton *closeBtn;

@end

@implementation WLApoloPlayerViewController {
    NSTimer *_timer;
}

- (instancetype)initWithURLString:(NSString *)urlString {
    if (self = [super init]) {
        _urlString = [urlString copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializePlayer];
    [self layoutUI];
    [self addNotifications];
    [self addObservers];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.9
                                              target:self
                                            selector:@selector(timerStep)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.operateView.frame = self.view.bounds;
    [_player setFrame:self.view.bounds];
    
    CGFloat statusBarHeight = kIsiPhoneX ? 44 : 20; // [UIApplication sharedApplication].statusBarFrame.size.height;
    self.closeBtn.frame = CGRectMake(0, statusBarHeight, kSingleNavBarHeight, kSingleNavBarHeight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc {
    [self stopPlay];
    [self removeNotifications];
    [self removeObservers];
}

- (void)stopPlay {
    if (_player != nil) {
        _player.delegate = nil;
        [_player stop];
        
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)initializePlayer {
    _player = [[U3Player alloc] init];
    [_player setFrame:self.view.bounds];
    _player.delegate = self;
    _player.mediaFilePath = [NSURL URLWithString:_urlString];
    
    [_player prepare];
    
    [self.view addSubview:_player.playBackView];
    _player.scaleMode = kVideoRenderingScaleModeAspectFit;
    [self.view sendSubviewToBack:_player.playBackView];
}

- (void)layoutUI {
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.operateView];
    [self.view addSubview:self.closeBtn];
    
    [self.operateView prepare];
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
                [self.operateView setPlayerViewStatus:WLPlayerViewStatus_Unknown];
                break;
            case VideoPlayer_Playing:
                [self.operateView setPlayerViewStatus:WLPlayerViewStatus_Playing];
                break;
            case VideoPlayer_Ready:
                [self.operateView setPlayerViewStatus:WLPlayerViewStatus_ReadyToPlay];
                break;
            case VideoPlayer_Pause:
                [self.operateView setPlayerViewStatus:WLPlayerViewStatus_Paused];
                break;
            case VideoPlayer_Buffering:
                [self.operateView setPlayerViewStatus:WLPlayerViewStatus_CachingPaused];
                break;
            case VideoPlayer_Stop:
                [self.operateView setPlayerViewStatus:WLPlayerViewStatus_Stopped];
                break;
            case VideoPlayer_End:
                [self.operateView setPlayerViewStatus:WLPlayerViewStatus_Completed];
                break;
            case VideoPlayer_Error:
                [self.operateView setPlayerViewStatus:WLPlayerViewStatus_Failed];
                break;
        }
        
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - U3PlayerDelegate

- (void)onPrepared {
    [_player play];
}

- (void)onSeekCompleted {
    if (self.operateView.playerViewStatus != WLPlayerViewStatus_Completed) {
        [_player play];
    }
}

- (void)onEndOfStream {
    [self p_resetPlayer];
}

- (void)onStopped {
    [self p_resetPlayer];
}

- (void)onBufferingUpdate:(int)percent {
    self.operateView.cacheProgress = percent;
}

#pragma mark - WLPlayerOperateViewDelegate

- (void)playerOperateViewDidClickedPlay:(WLPlayerOperateView *)operateView {
    if (self.operateView.playerViewStatus != WLPlayerViewStatus_Playing) {
        [_player play];
    } else {
        [_player pause];
    }
}

- (void)playerOperateViewDidClickedRotate:(WLPlayerOperateView *)operateView {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    if (orientation != UIDeviceOrientationPortrait) {
        orientation = UIDeviceOrientationPortrait;
    } else {
        orientation = UIDeviceOrientationLandscapeLeft;
    }
    
    [self setOrientation:orientation];
}

- (void)playerOperateView:(WLPlayerOperateView *)operateView didSliderValueChanged:(CGFloat)changedValue {
    if (_player) {
        [_player pause];
        
        CGFloat position = changedValue * _player.duration;
        [_player seek:position];
    }
}

#pragma mark - DeviceOrientation

- (void)addNotifications {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)removeNotifications {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)deviceOrientationDidChanged:(NSNotification *)notification {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    [self setOrientation:orientation];
}

- (void)setOrientation:(UIDeviceOrientation)orientation {
    switch (orientation) {
        case UIDeviceOrientationPortrait: {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
            
            [UIView animateWithDuration:0.2f animations:^{
                self.view.transform = CGAffineTransformMakeRotation(0);
                self.view.bounds = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
            }];
            
            _player.scaleMode = kVideoRenderingScaleModeAspectFit;
        }
            break;
        case UIDeviceOrientationLandscapeLeft: {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
            
            [UIView animateWithDuration:0.2f animations:^{
                self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
                self.view.bounds = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
            }];
            
            _player.scaleMode = kVideoRenderingScaleModeAspectFill;
        }
            break;
        case UIDeviceOrientationLandscapeRight: {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
            
            [UIView animateWithDuration:0.2f animations:^{
                self.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
                self.view.bounds = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
            }];
            
            _player.scaleMode = kVideoRenderingScaleModeAspectFill;
        }
            break;
        default:
            break;
    }
}

#pragma mark - Private

- (void)p_resetPlayer {
    [_player pause];
    [_player seek:0.0];
    
    self.operateView.playSeconds = 0;
    self.operateView.duration = _player.duration;
}

#pragma mark - Event

- (void)closeBtnClicked {
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft
        || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
        [self setOrientation:UIDeviceOrientationPortrait];
    } else {
        [self stopPlay];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Getter

- (WLPlayerOperateView *)operateView {
    if (!_operateView) {
        WLPlayerOperateView *view = [[WLPlayerOperateView alloc] init];
        view.delegate = self;
        _operateView = view;
    }
    return _operateView;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[AppContext getImageForKey:@"common_close_white"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

@end
