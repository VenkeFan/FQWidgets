//
//  FQCameraOperateView.m
//  WeLike
//
//  Created by fan qi on 2018/4/7.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQCameraOperateView.h"
#import "FQPlayerView.h"

#define OperateViewHeight           kSizeScale(210)
#define PhotoButtonWidth            kSizeScale(70)
#define ButtonSideColor             kUIColorFromRGB(0xE3E5EA)

@interface FQCameraOperateView () <FQPlayerViewDelegate> {
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

@property (nonatomic, weak) FQPlayerView *playerView;

@end

@implementation FQCameraOperateView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _outputType = FQCameraOutputType_Photo;
    }
    return self;
}

- (void)layoutSubviews {
    [self.photoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.operateContentView);
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.photoBtn);
        make.right.mas_equalTo(self.photoBtn.mas_left).offset(-kSizeScale(60));
    }];
    
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.photoBtn);
        make.left.mas_equalTo(self.photoBtn.mas_right).offset(kSizeScale(60));
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
        make.right.mas_equalTo(self).offset(-kSizeScale(15));
        make.bottom.mas_equalTo(self.operateContentView.mas_top).offset(-kSizeScale(20));
    }];
    
    [self.flashlightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.transformBtn);
        make.bottom.mas_equalTo(self.transformBtn.mas_top).offset(-kSizeScale(15));
    }];
}

- (void)dealloc {
    NSLog(@"FQCameraOperateView dealloc");
    
    [self invalidateTimer];
}

#pragma mark - Private

- (void)setCancelAndConfirmHidden:(BOOL)hidden {
    self.cancelBtn.hidden = self.confirmBtn.hidden = hidden;
}

- (void)startCountDown {
    self.countDownView.hidden = NO;
    NSLog(@"开始录制");
    
    __block NSInteger duration = kMaxVideoRecordDuration;
    __weak typeof(self) weakSelf = self;
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        if (duration <= 0) {
            [weakSelf invalidateTimer];
        } else {
            NSMutableAttributedString *mutAttr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"00:%.2zd", duration]];
            [mutAttr setAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                     NSFontAttributeName: [UIFont systemFontOfSize:20]}
                             range:NSMakeRange(0, mutAttr.length)];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.countLabel.attributedText = mutAttr;
                [weakSelf.progressView setProgress:(kMaxVideoRecordDuration - duration) / kMaxVideoRecordDuration animated:YES];
                NSLog(@"正在录制: %@", mutAttr.string);
            });
            
            duration--;
        }
    });
    
    dispatch_source_set_cancel_handler(_timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"停止录制");
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
    
    [self.playerView playWithAsset:[AVAsset assetWithURL:self.recordFilePath]];
}

- (void)confirmBtnClicked {
    if ([self.delegate respondsToSelector:@selector(cameraOperateView:didConfirmedWithOutputType:)]) {
        [self.delegate cameraOperateView:self didConfirmedWithOutputType:self.outputType];
    }
}

- (void)cancelBtnClicked {
    [self setCancelAndConfirmHidden:YES];
    
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
                                                                [self.flashlightBtn setImage:[UIImage imageNamed:@"camera_flashlight_on"]
                                                                                    forState:UIControlStateNormal];
                                                                break;
                                                            case AVCaptureFlashModeOff:
                                                                [self.flashlightBtn setImage:[UIImage imageNamed:@"camera_flashlight_off"]
                                                                                    forState:UIControlStateNormal];
                                                                break;
                                                            case AVCaptureFlashModeAuto:
                                                                [self.flashlightBtn setImage:[UIImage imageNamed:@"camera_flashlight_auto"]
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

#pragma mark - FQPlayerViewDelegate

- (void)playerView:(FQPlayerView *)playerView statusDidChanged:(FQPlayerViewStatus)status {
    if (status == FQPlayerViewStatus_Stopped || status == FQPlayerViewStatus_Completed) {
        self.playerView.hidden = YES;
    }
    
    
    switch (status) {
        case FQPlayerViewStatus_ReadyToPlay:
        case FQPlayerViewStatus_Playing:
            self.playerView.hidden = NO;
            [self.playBtn setBackgroundImage:[UIImage imageNamed:@"camera_video_pause"] forState:UIControlStateNormal];
            break;
        case FQPlayerViewStatus_Paused:
            self.playerView.hidden = NO;
            [self.playBtn setBackgroundImage:[UIImage imageNamed:@"camera_video_play"] forState:UIControlStateNormal];
            break;
        case FQPlayerViewStatus_Stopped:
        case FQPlayerViewStatus_Completed:
            self.playerView.hidden = YES;
            break;
        default:
            
            break;
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
            [self.recordBtn setBackgroundImage:[UIImage imageNamed:@"camera_recorder"] forState:UIControlStateNormal];
            
            self.countLabel.attributedText = nil;
            self.countDownView.hidden = YES;
            
            self.playBtn.hidden = YES;
            [self setCancelAndConfirmHidden:YES];
            
            break;
        case FQCameraVideoStatus_Recording:
            self.progressView.hidden = NO;
            
            self.recordBtn.hidden = NO;
            [self.recordBtn setBackgroundImage:[UIImage imageNamed:@"camera_recorder_stop"] forState:UIControlStateNormal];
            
            [self startCountDown];
            
            self.playBtn.hidden = YES;
            [self setCancelAndConfirmHidden:YES];
            
            break;
        case FQCameraVideoStatus_Stop:
        case FQCameraVideoStatus_Completed:
            self.progressView.progress = 0;
            self.progressView.hidden = YES;
            
            self.recordBtn.hidden = YES;
            
            self.countLabel.attributedText = nil;
            self.countDownView.hidden = YES;
            
            self.playBtn.hidden = NO;
            [self setCancelAndConfirmHidden:NO];
            
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
    [btn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
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
            make.left.right.bottom.mas_equalTo(self.operateContentView);
        }];
    }
    return _progressView;
}

- (UIView *)countDownView {
    if (!_countDownView) {
        UIView *view = [[UIView alloc] init];
        view.hidden = YES;
        [self addSubview:view];
        _countDownView = view;
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).offset(kMarginY);
            make.centerX.mas_equalTo(self);
        }];

        UIView *flickerView = [[UIView alloc] init];
        flickerView.backgroundColor = kMainColor;
        flickerView.layer.cornerRadius = 4;
        flickerView.layer.masksToBounds = YES;
        flickerView.layer.opacity = 0;
        [view addSubview:flickerView];
        [flickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(8);
            make.left.mas_equalTo(view);
            make.centerY.mas_equalTo(view);
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


        UILabel *countLab = [[UILabel alloc] init];
        [view addSubview:countLab];
        self.countLabel = countLab;
        [countLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(flickerView.mas_right).offset(kSizeScale(10));
            make.top.bottom.mas_equalTo(view);
            make.right.mas_equalTo(view);
        }];
    }
    return _countDownView;
}

- (UIButton *)flashlightBtn {
    if (!_flashlightBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.hidden = YES;
        btn.selected = NO;
        [btn setImage:[UIImage imageNamed:@"camera_flashlight_off"] forState:UIControlStateNormal];
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
        [btn setImage:[UIImage imageNamed:@"camera_transform"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"camera_transform_highlight"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(transformBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn sizeToFit];
        [self addSubview:btn];
        _transformBtn = btn;
    }
    return _transformBtn;
}

- (FQPlayerView *)playerView {
    if (!_playerView) {
        FQPlayerView *view = [[FQPlayerView alloc] initWithFrame:self.bounds];
        view.delegate = self;
        view.hidden = YES;
        [self insertSubview:view belowSubview:self.operateContentView];
        _playerView = view;
    }
    return _playerView;
}

@end
