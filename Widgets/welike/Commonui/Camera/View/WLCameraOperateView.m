//
//  WLCameraOperateView.m
//  WeLike
//
//  Created by fan qi on 2018/4/7.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLCameraOperateView.h"
#import "WLAVPlayerView.h"

#define OperateViewHeight           210.0
#define PhotoButtonWidth            70.0
#define ButtonSideColor             kUIColorFromRGB(0xE3E5EA)

@interface WLCameraOperateView () <WLPlayerViewDelegate> {
    dispatch_source_t _timer;
}

@property (nonatomic, weak) UIView *operateContentView;

@property (nonatomic, weak) UIButton *confirmBtn;
@property (nonatomic, weak) UIButton *cancelBtn;

@property (nonatomic, weak) UIButton *photoBtn;

@property (nonatomic, weak) UIButton *recordBtn;
@property (nonatomic, weak) UIButton *playBtn;

@property (nonatomic, weak) UIProgressView *progressView;
@property (nonatomic, weak) UIView *countDownView;
@property (nonatomic, weak) UILabel *countLabel;

@property (nonatomic, weak) UIButton *flashlightBtn;
@property (nonatomic, weak) UIButton *transformBtn;

@property (nonatomic, weak) WLAVPlayerView *playerView;

@end

@implementation WLCameraOperateView

#pragma mark - LifeCycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _outputType = FQCameraOutputType_Photo;
        
        [self addNotifications];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.photoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.operateContentView);
    }];
    
    CGFloat x = 60;
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.photoBtn);
        make.right.mas_equalTo(self.photoBtn.mas_left).offset(-x);
    }];
    
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.photoBtn);
        make.left.mas_equalTo(self.photoBtn.mas_right).offset((x));
    }];
    
    [self.recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.photoBtn);
        make.size.mas_equalTo(self.photoBtn);
    }];
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.recordBtn);
        make.size.mas_equalTo(self.recordBtn);
    }];
    
    [self.transformBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self);
        make.top.mas_equalTo(self).offset(kSystemStatusBarHeight);
        make.size.mas_equalTo(kSingleNavBarHeight);
    }];
    
    [self.flashlightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.transformBtn);
        make.right.mas_equalTo(self.transformBtn.mas_left);
        make.size.mas_equalTo(kSingleNavBarHeight);
    }];
}

- (void)dealloc {
    [self invalidateTimer];
    
    [self removeNotifications];
}

#pragma mark - Notifications

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:kWLAppWillResignActiveNotificationName
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:kWLAppDidBecomeActiveNotificationName
                                               object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    if (self.videoStatus == FQCameraVideoStatus_Recording) {
        [self setVideoStatus:FQCameraVideoStatus_Stop];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    
}

#pragma mark - WLPlayerViewDelegate

- (void)playerView:(WLAVPlayerView *)playerView statusDidChanged:(WLPlayerViewStatus)status {
    if (status == WLPlayerViewStatus_Stopped || status == WLPlayerViewStatus_Completed) {
        self.playerView.hidden = YES;
    }
    
    switch (status) {
        case WLPlayerViewStatus_ReadyToPlay:
        case WLPlayerViewStatus_Playing:
            self.playerView.hidden = NO;
            [self.playBtn setBackgroundImage:[AppContext getImageForKey:@"camera_video_pause"] forState:UIControlStateNormal];
            break;
        case WLPlayerViewStatus_Paused:
            self.playerView.hidden = NO;
            [self.playBtn setBackgroundImage:[AppContext getImageForKey:@"camera_video_play"] forState:UIControlStateNormal];
            break;
        case WLPlayerViewStatus_Stopped:
        case WLPlayerViewStatus_Completed:
            self.playerView.hidden = YES;
            break;
        default:
            
            break;
    }
}

#pragma mark - Private

- (void)setCancelAndConfirmHidden:(BOOL)hidden {
    self.cancelBtn.hidden = self.confirmBtn.hidden = hidden;
}

- (void)startCountDown {
    self.countDownView.hidden = NO;
    
    __block NSInteger duration = MAX_VIDEO_RECORD_DURATION;
    __weak typeof(self) weakSelf = self;
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        if (duration <= 0) {
            [weakSelf invalidateTimer];
        } else {
            NSMutableAttributedString *mutAttr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"00:%.2ld", (long)duration]];
            [mutAttr setAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                     NSFontAttributeName: [UIFont systemFontOfSize:10]}
                             range:NSMakeRange(0, mutAttr.length)];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.countLabel.attributedText = mutAttr;
                [weakSelf.progressView setProgress:(MAX_VIDEO_RECORD_DURATION - duration) / MAX_VIDEO_RECORD_DURATION animated:YES];
            });
            
            duration--;
        }
    });
    
    dispatch_source_set_cancel_handler(_timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf setVideoStatus:FQCameraVideoStatus_Completed];
        });
    });
    
    dispatch_resume(_timer);
}

- (void)invalidateTimer {
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

#pragma mark - Event

- (void)photoBtnClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(cameraOperateViewDidTakePhotoClicked:succeed:)]) {
        [self.delegate cameraOperateViewDidTakePhotoClicked:self succeed:^{
            [self setCancelAndConfirmHidden:NO];
            self.flashlightBtn.hidden = self.transformBtn.hidden = YES;
            sender.hidden = YES;
        }];
    }
}

- (void)recordBtnClicked:(UIButton *)sender {
    if (self.videoStatus == FQCameraVideoStatus_Prepare) {
        [self setVideoStatus:FQCameraVideoStatus_Recording];
    } else if (self.videoStatus == FQCameraVideoStatus_Recording) {
        [self setVideoStatus:FQCameraVideoStatus_Stop];
    }
}

- (void)playBtnClicked:(UIButton *)sender {
    if (!self.recordFilePath) {
        return;
    }
    
    //    self.playerView.asset = [AVAsset assetWithURL:self.recordFilePath];
    //    if (self.playerView.playerViewStatus != WLPlayerViewStatus_Playing) {
    //        [self.playerView play];
    //    } else {
    //        [self.playerView pause];
    //    }
    
    if ([self.delegate respondsToSelector:@selector(cameraOperateView:disPlayVideo:)]) {
        [self.delegate cameraOperateView:self disPlayVideo:self.recordFilePath];
    }
}

- (void)confirmBtnClicked {
    if (self.playerView.playerViewStatus == WLPlayerViewStatus_Playing) {
        [self.playerView stop];
    }
    
    if ([self.delegate respondsToSelector:@selector(cameraOperateView:didConfirmedWithOutputType:)]) {
        [self.delegate cameraOperateView:self didConfirmedWithOutputType:self.outputType];
    }
}

- (void)cancelBtnClicked {
    if (self.playerView.playerViewStatus == WLPlayerViewStatus_Playing) {
        [self.playerView stop];
    }
    
    [self setCancelAndConfirmHidden:YES];
    
    if (self.outputType == FQCameraOutputType_Photo) {
        self.flashlightBtn.hidden = self.transformBtn.hidden = NO;
    }
    
    if (_outputType == FQCameraOutputType_Video) {
        [self setVideoStatus:FQCameraVideoStatus_Prepare];
    } else {
        self.photoBtn.hidden = NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(cameraOperateView:didCanceledWithOutputType:)]) {
        [self.delegate cameraOperateView:self didCanceledWithOutputType:_outputType];
    }
}

- (void)flashlightBtnClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(cameraOperateViewDidChangeFlashlight:succeed:)]) {
        [self.delegate cameraOperateViewDidChangeFlashlight:self
                                                    succeed:^(AVCaptureFlashMode flashMode) {
                                                        switch (flashMode) {
                                                            case AVCaptureFlashModeOn:
                                                                [self.flashlightBtn setImage:[AppContext getImageForKey:@"camera_flashlight_on"]
                                                                                    forState:UIControlStateNormal];
                                                                break;
                                                            case AVCaptureFlashModeOff:
                                                                [self.flashlightBtn setImage:[AppContext getImageForKey:@"camera_flashlight_off"]
                                                                                    forState:UIControlStateNormal];
                                                                break;
                                                            case AVCaptureFlashModeAuto:
                                                                [self.flashlightBtn setImage:[AppContext getImageForKey:@"camera_flashlight_auto"]
                                                                                    forState:UIControlStateNormal];
                                                                break;
                                                        }
                                                    }];
    }
}

- (void)transformBtnClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(cameraOperateViewDidTransformCamera:)]) {
        [self.delegate cameraOperateViewDidTransformCamera:self];
    }
}

#pragma mark - Setter

- (void)setVideoStatus:(FQCameraVideoStatus)videoStatus {
    FQCameraVideoStatus oldStatus = _videoStatus;
    _videoStatus = videoStatus;
    
    switch (videoStatus) {
        case FQCameraVideoStatus_Prepare:
            self.progressView.progress = 0;
            self.progressView.hidden = YES;
            
            self.recordBtn.hidden = NO;
            [self.recordBtn setBackgroundImage:[AppContext getImageForKey:@"camera_recorder"] forState:UIControlStateNormal];
            
            self.countLabel.attributedText = nil;
            self.countDownView.hidden = YES;
            
            self.playBtn.hidden = YES;
            [self setCancelAndConfirmHidden:YES];
            
            self.transformBtn.hidden = NO;
            
            break;
        case FQCameraVideoStatus_Recording:
            self.progressView.hidden = NO;
            
            self.recordBtn.hidden = NO;
            [self.recordBtn setBackgroundImage:[AppContext getImageForKey:@"camera_recorder_stop"] forState:UIControlStateNormal];
            
            [self startCountDown];
            
            self.playBtn.hidden = YES;
            [self setCancelAndConfirmHidden:YES];
            
            self.transformBtn.hidden = NO;
            
            break;
        case FQCameraVideoStatus_Stop:
        case FQCameraVideoStatus_Completed:
            self.progressView.progress = 0;
            self.progressView.hidden = YES;
            
            self.recordBtn.hidden = YES;
            
            self.countLabel.attributedText = nil;
            self.countDownView.hidden = YES;
            if (videoStatus == FQCameraVideoStatus_Stop) {
                [self invalidateTimer];
            }
            
            self.playBtn.hidden = NO;
            [self setCancelAndConfirmHidden:NO];
            
            self.transformBtn.hidden = YES;
            
            break;
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(cameraOperateView:didVideoStatusChanged:oldStatus:)]) {
        [self.delegate cameraOperateView:self didVideoStatusChanged:videoStatus oldStatus:oldStatus];
    }
}

- (void)setOutputType:(FQCameraOutputType)outputType {
    _outputType = outputType;
    
    if (outputType == FQCameraOutputType_Photo) {
        self.photoBtn.hidden = NO;
        self.flashlightBtn.hidden = NO;
        self.transformBtn.hidden = NO;
    } else {
        self.recordBtn.hidden = NO;
        self.transformBtn.hidden = NO;
    }
}

#pragma mark - Getter

- (UIView *)operateContentView {
    if (!_operateContentView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - OperateViewHeight, kScreenWidth, OperateViewHeight)];
        view.backgroundColor = [UIColor clearColor];
        [self addSubview:view];
        _operateContentView = view;
    }
    return _operateContentView;
}

- (UIButton *)buttonWithImageName:(NSString *)imageName action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.hidden = YES;
    [btn setBackgroundImage:[AppContext getImageForKey:imageName] forState:UIControlStateNormal];
    [btn sizeToFit];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (UIButton *)confirmBtn {
    if (!_confirmBtn) {
        UIButton *btn = [self buttonWithImageName:@"camera_confirm" action:@selector(confirmBtnClicked)];
        [self.operateContentView addSubview:btn];
        _confirmBtn = btn;
    }
    return _confirmBtn;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        UIButton *btn = [self buttonWithImageName:@"camera_cancel" action:@selector(cancelBtnClicked)];
        [self.operateContentView addSubview:btn];
        _cancelBtn = btn;
    }
    return _cancelBtn;
}

- (UIButton *)photoBtn {
    if (!_photoBtn) {
        UIButton *view = [self buttonWithImageName:@"camera_takePhoto" action:@selector(photoBtnClicked:)];
        [self.operateContentView addSubview:view];
        _photoBtn = view;
    }
    return _photoBtn;
}

- (UIButton *)recordBtn {
    if (!_recordBtn) {
        UIButton *view = [self buttonWithImageName:@"camera_recorder" action:@selector(recordBtnClicked:)];
        [self.operateContentView addSubview:view];
        _recordBtn = view;
    }
    return _recordBtn;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        UIButton *view = [self buttonWithImageName:@"camera_video_play" action:@selector(playBtnClicked:)];
        [self.operateContentView addSubview:view];
        _playBtn = view;
    }
    return _playBtn;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        UIProgressView *view = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        view.hidden = YES;
        view.progress = 0.0;
        view.trackTintColor = kLightFontColor;
        view.progressTintColor = kMainColor;
        [self.operateContentView addSubview:view];
        _progressView = view;
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.operateContentView);
            make.bottom.mas_equalTo(self.operateContentView);
        }];
    }
    return _progressView;
}

- (UIView *)countDownView {
    if (!_countDownView) {
        CGFloat padding = 4;
        
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.46];
        view.hidden = YES;
        [self addSubview:view];
        _countDownView = view;
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self);
            make.centerX.mas_equalTo(self);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(kSystemStatusBarHeight + 10);
        }];
        
        UIView *subView = ({
            UIView *contentView = [[UIView alloc] init];
            
            UILabel *countLab = [[UILabel alloc] init];
            [contentView addSubview:countLab];
            self.countLabel = countLab;
            [countLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(contentView);
                make.top.mas_equalTo(contentView);
                make.bottom.mas_equalTo(contentView);
            }];
            
            CGFloat size = 6.0;
            UIView *flickerView = [[UIView alloc] init];
            flickerView.backgroundColor = kUIColorFromRGB(0xFF3C3C);
            flickerView.layer.cornerRadius = size * 0.5;
            flickerView.layer.masksToBounds = YES;
            flickerView.layer.opacity = 0;
            [contentView addSubview:flickerView];
            [flickerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(size);
                make.right.mas_equalTo(countLab.mas_left).offset(-padding);
                make.left.mas_equalTo(contentView);
                make.centerY.mas_equalTo(countLab);
            }];
            
            CABasicAnimation *animation = [CABasicAnimation animation];
            animation.keyPath = @"opacity";
            animation.duration = 0.7;
            animation.fromValue = @(0);
            animation.toValue = @(1);
            animation.autoreverses = YES;
            animation.repeatCount = INFINITY;
            animation.removedOnCompletion = NO;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            [flickerView.layer addAnimation:animation forKey:nil];
            
            contentView;
        });
        [view addSubview:subView];
        [subView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(view);
            make.centerX.mas_equalTo(view);
        }];
    }
    return _countDownView;
}

- (UIButton *)flashlightBtn {
    if (!_flashlightBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.hidden = YES;
        btn.selected = NO;
        [btn setImage:[AppContext getImageForKey:@"camera_flashlight_off"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(flashlightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn sizeToFit];
        [self addSubview:btn];
        _flashlightBtn = btn;
    }
    return _flashlightBtn;
}

- (UIButton *)transformBtn {
    if (!_transformBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.hidden = YES;
        btn.selected = NO;
        [btn setImage:[AppContext getImageForKey:@"camera_transform"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(transformBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn sizeToFit];
        [self addSubview:btn];
        _transformBtn = btn;
    }
    return _transformBtn;
}

- (WLAVPlayerView *)playerView {
    if (!_playerView) {
        WLAVPlayerView *view = [[WLAVPlayerView alloc] initWithFrame:self.bounds];
        view.delegate = self;
        view.hidden = YES;
        [self insertSubview:view belowSubview:self.operateContentView];
        _playerView = view;
    }
    return _playerView;
}

@end
