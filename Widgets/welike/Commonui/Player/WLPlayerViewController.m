//
//  WLPlayerViewController.m
//  welike
//
//  Created by fan qi on 2018/6/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPlayerViewController.h"
#import "WLAVPlayerView.h"
#import "WLYoutubePlayerView.h"
#import "WLApoloPlayerView.h"

NSString * const kWLPlayerVideoSite = @"YOUTUBE";

@interface WLPlayerViewController () <WLPlayerViewDelegate>

@property (nonatomic, strong) WLAbstractPlayerView *playerView;
@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, copy) NSString *videoID;

@end

@implementation WLPlayerViewController {
    UIDeviceOrientation _orientation;
}

- (instancetype)initWithURLString:(NSString *)urlString videoSite:(NSString *)videoSite {
    if (self = [super init]) {
        _urlString = [urlString copy];
        
        if (videoSite.length > 0) {
            _videoID = [[urlString componentsSeparatedByString:@"/"].lastObject copy];
        }
    }
    return self;
}

- (instancetype)initWithURLString:(NSString *)urlString {
    if (self = [self initWithURLString:urlString videoSite:nil]) {
        
    }
    return self;
}

- (instancetype)initWithAsset:(AVAsset *)asset {
    if (self = [super init]) {
        _asset = asset;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self addNotifications];
    [self initializePlayer];
    [self layoutUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.playerView play];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.playerView.frame = self.view.bounds;
    
    self.closeBtn.transform = CGAffineTransformIdentity;
    CGFloat statusBarHeight = kIsiPhoneX ? 44 : 20; // [UIApplication sharedApplication].statusBarFrame.size.height;
    self.closeBtn.frame = CGRectMake(0, statusBarHeight, kSingleNavBarHeight, kSingleNavBarHeight);
    
//    [self playerView:self.playerView didDiaplayToolsChanged:self.playerView.operateView.isDisplayTools];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc {
    [self removeNotifications];
}

- (void)initializePlayer {
    if (_videoID.length > 0) {
        _playerView = [[WLYoutubePlayerView alloc] init];
        [(WLYoutubePlayerView *)_playerView setVideoID:_videoID];
    } else if (_urlString.length > 0) {
        _playerView = [[WLApoloPlayerView alloc] init];
        [(WLApoloPlayerView *)_playerView setUrlString:_urlString];
    } else if (_asset) {
        _playerView = [[WLAVPlayerView alloc] init];
        [(WLAVPlayerView *)_playerView setAsset:_asset];
    }
    
    _playerView.delegate = self;
    [_playerView setVideoGravity:WLPlayerViewGravity_ResizeAspect];
    _playerView.operateView.windowMode = WLPlayerViewWindowMode_Screen;
}

- (void)layoutUI {
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.playerView];
    [self.view addSubview:self.closeBtn];
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
    _orientation = orientation;
    
    switch (orientation) {
        case UIDeviceOrientationPortrait: {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
            
            [UIView animateWithDuration:0.35 animations:^{
                self.view.transform = CGAffineTransformMakeRotation(0);
                self.view.bounds = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
            }];
            
            [self.playerView setVideoGravity:WLPlayerViewGravity_ResizeAspect];
        }
            break;
        case UIDeviceOrientationLandscapeLeft: {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
            
            [UIView animateWithDuration:0.35 animations:^{
                self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
                self.view.bounds = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
            }];
            
            [self.playerView setVideoGravity:WLPlayerViewGravity_ResizeAspect];
        }
            break;
        case UIDeviceOrientationLandscapeRight: {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
            
            [UIView animateWithDuration:0.35 animations:^{
                self.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
                self.view.bounds = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
            }];
            
            [self.playerView setVideoGravity:WLPlayerViewGravity_ResizeAspect];
        }
            break;
        default:
            break;
    }
}

#pragma mark - WLPlayerViewDelegate

- (void)playerViewOrientationDidChanged:(WLAVPlayerView *)playerView {
    if (_orientation != UIDeviceOrientationPortrait) {
        _orientation = UIDeviceOrientationPortrait;
    } else {
        if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
            _orientation = UIDeviceOrientationLandscapeRight;
        } else {
            _orientation = UIDeviceOrientationLandscapeLeft;
        }
    }
    
    [self setOrientation:_orientation];
}

- (void)playerView:(WLAbstractPlayerView *)playerView didDiaplayToolsChanged:(BOOL)displayTools {
    if (displayTools) {
        self.closeBtn.transform = CGAffineTransformIdentity;
    } else {
        self.closeBtn.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(self.closeBtn.frame));
    }
}

#pragma mark - Event

- (void)closeBtnClicked {
    if (_orientation != UIDeviceOrientationPortrait) {
        [self setOrientation:UIDeviceOrientationPortrait];
    }
    
    [self.playerView stop];
    
    if (self.navigationController.childViewControllers.count == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Getter

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[AppContext getImageForKey:@"common_close_white"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

@end
