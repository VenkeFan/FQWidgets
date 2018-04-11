//
//  FQCameraOperateView.m
//  WeLike
//
//  Created by fan qi on 2018/4/7.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQCameraOperateView.h"
//#import "FQRadioButton.h"

#define OperateViewHeight           kSizeScale(210)
#define PhotoButtonWidth            kSizeScale(78)
#define ButtonSideColor             kUIColorFromRGB(0xE3E5EA)
#define MaxVideoRecordDuration      10.0

@interface FQCameraOperateView ()

@property (nonatomic, weak) UIView *switchBgView;

//@property (nonatomic, weak) UIView *segmentedView;

@property (nonatomic, weak) UIButton *confirmBtn;
@property (nonatomic, weak) UIButton *cancelBtn;

@property (nonatomic, weak) UIImageView *photoBtn;

@property (nonatomic, weak) UIView *videoBtn;
@property (nonatomic, weak) CAShapeLayer *progressLayer;
@property (nonatomic, weak) CALayer *videoStatusLayer;

@property (nonatomic, weak) UIView *countDownView;
@property (nonatomic, weak) UILabel *countLabel;

@property (nonatomic, weak) UIButton *flashlightBtn;
@property (nonatomic, weak) UIButton *transformBtn;

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
//    [self.segmentedView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.switchBgView);
//        make.centerX.mas_equalTo(self.switchBgView);
//    }];
    
    [self.photoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.switchBgView);
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.photoBtn);
        make.right.mas_equalTo(self.photoBtn.mas_left).offset(-kSizeScale(60));
    }];
    
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.photoBtn);
        make.left.mas_equalTo(self.photoBtn.mas_right).offset(kSizeScale(60));
    }];
    
    [self.videoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.photoBtn);
        make.size.mas_equalTo(self.photoBtn);
    }];
    
    [self.transformBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-kSizeScale(15));
        make.bottom.mas_equalTo(self.switchBgView.mas_top).offset(-kSizeScale(20));
    }];
    
    [self.flashlightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.transformBtn);
        make.bottom.mas_equalTo(self.transformBtn.mas_top).offset(-kSizeScale(15));
    }];
}

- (void)dealloc {
//    [FQRadioButton clearRadioGroup];
}

#pragma mark - Private

- (void)setCancelAndConfirmHidden:(BOOL)hidden {
    self.cancelBtn.hidden = self.confirmBtn.hidden = hidden;
}

- (void)setCountDownRemainder:(NSInteger)remainder {
    if (remainder <= 0) {
        self.countLabel.attributedText = nil;
        self.countDownView.hidden = YES;
        return;
    }
    
    if (self.countDownView.hidden) {
        self.countDownView.hidden = NO;
    }
    
    NSMutableAttributedString *mutAttr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"00:%.2zd",
                                                                                            remainder]];
    [mutAttr setAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                             NSFontAttributeName: [UIFont systemFontOfSize:20]}
                     range:NSMakeRange(0, mutAttr.length)];
    
    self.countLabel.attributedText = mutAttr;
}

- (void)startCountDown {
    self.countDownView.hidden = NO;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:MaxVideoRecordDuration];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    _progressLayer.strokeEnd = 1.0;
    [CATransaction commit];
    
    NSLog(@"开始录制");
    
    __block NSInteger duration = 0;
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (duration >= MaxVideoRecordDuration) {
            dispatch_source_cancel(timer);
        } else {
            
            NSMutableAttributedString *mutAttr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"00:%.2zd",
                                                                                                    duration]];
            [mutAttr setAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                     NSFontAttributeName: [UIFont systemFontOfSize:20]}
                             range:NSMakeRange(0, mutAttr.length)];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.countLabel.attributedText = mutAttr;
                NSLog(@"正在录制: %@", mutAttr.string);
            });
            
            duration++;
        }
    });
    
    dispatch_source_set_cancel_handler(timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"停止录制");
            [self setVideoStatus:FQCameraVideoStatus_Completed];
        });
    });
    
    dispatch_resume(timer);
}

#pragma mark - Event

- (void)photoBtnTapped:(UIGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(cameraOperateViewDidPhotoClicked:succeed:)]) {
        [self.delegate cameraOperateViewDidPhotoClicked:self succeed:^{
            [self setCancelAndConfirmHidden:NO];
            gesture.view.hidden = YES;
        }];
    }
}

- (void)videoBtnTapped {
    switch (self.videoStatus) {
        case FQCameraVideoStatus_Prepare: {
            [self setVideoStatus:FQCameraVideoStatus_Recording];
        }
            break;
        case FQCameraVideoStatus_Recording: {
//            [self setVideoStatus:FQCameraVideoStatus_Pause];
        }
            break;
        case FQCameraVideoStatus_Pause: {
//            [self setVideoStatus:FQCameraVideoStatus_Recording];
        }
            break;
        case FQCameraVideoStatus_Completed:
            break;
    }
}

- (void)confirmBtnClicked {
    if ([self.delegate respondsToSelector:@selector(cameraOperateView:didConfirmedWithOutputType:)]) {
        [self.delegate cameraOperateView:self didConfirmedWithOutputType:self.outputType];
    }
}

- (void)cancelBtnClicked {
    [self setCancelAndConfirmHidden:YES];
    
    if (_outputType == FQCameraOutputType_Video) {
        _progressLayer.strokeEnd = 0.0;
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

//- (void)radioClicked:(UIButton *)sender {
//    NSInteger tag = sender.tag;
//
//    if (tag == 0) {
//        self.videoBtn.hidden = NO;
//        self.photoBtn.hidden = YES;
//        _outputType = FQCameraOutputType_Video;
//    } else {
//        self.videoBtn.hidden = YES;
//        self.photoBtn.hidden = NO;
//        _outputType = FQCameraOutputType_Photo;
//    }
//}

#pragma mark - Setter

- (void)setVideoStatus:(FQCameraVideoStatus)videoStatus {
    FQCameraVideoStatus oldStatus = _videoStatus;
    _videoStatus = videoStatus;
    
    switch (videoStatus) {
        case FQCameraVideoStatus_Prepare:
            _videoStatusLayer.contents = (__bridge id)[UIImage imageNamed:@"camera_video_prepare"].CGImage;
            break;
        case FQCameraVideoStatus_Recording:
            _videoStatusLayer.contents = (__bridge id)[UIImage imageNamed:@"camera_video_pause"].CGImage;
            if (oldStatus != FQCameraVideoStatus_Pause) {
                [self startCountDown];
            }
            break;
        case FQCameraVideoStatus_Pause:
            _videoStatusLayer.contents = (__bridge id)[UIImage imageNamed:@"camera_video_play"].CGImage;
            break;
        case FQCameraVideoStatus_Completed:
            _videoStatusLayer.contents = (__bridge id)[UIImage imageNamed:@"camera_video_prepare"].CGImage;
            [self setCountDownRemainder:0];
            [self setCancelAndConfirmHidden:NO];
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
        self.videoBtn.hidden = NO;
    }
}

#pragma mark - Getter

- (CGFloat)switchBgViewHeight {
    return self.switchBgView.frame.size.height;
}

- (UIView *)switchBgView {
    if (!_switchBgView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - OperateViewHeight, kScreenWidth, OperateViewHeight)];
        view.backgroundColor = [UIColor clearColor];
        [self addSubview:view];
        _switchBgView = view;
    }
    return _switchBgView;
}

//- (UIView *)segmentedView {
//    if (!_segmentedView) {
//        UIView *view = [[UIView alloc] init];
//        [self.switchBgView addSubview:view];
//        _segmentedView = view;
//
//        CGFloat padding = kSizeScale(3);
//
//        FQRadioButton *videoRadio = [self radioBtnWithTitle:@"Video"];
//        videoRadio.tag = 0;
//        [view addSubview:videoRadio];
//        [videoRadio mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(view);
//            make.top.mas_equalTo(view).offset(padding);
//            make.bottom.mas_equalTo(view).offset(-padding);
//            make.width.mas_equalTo(kSizeScale(50));
//        }];
//
//        FQRadioButton *photoRadio = [self radioBtnWithTitle:@"Photo"];
//        photoRadio.tag = 1;
//        photoRadio.selected = YES;
//        [view addSubview:photoRadio];
//        [photoRadio mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(videoRadio.mas_right).offset(kSizeScale(30));
//            make.right.mas_equalTo(view);
//            make.size.mas_equalTo(videoRadio);
//            make.centerY.mas_equalTo(videoRadio);
//        }];
//
//        _outputType = FQCameraOutputType_Photo;
//    }
//    return _segmentedView;
//}
//
//- (FQRadioButton *)radioBtnWithTitle:(NSString *)title {
//    FQRadioButton *btn = [[FQRadioButton alloc] initWithGroupName:@"Camera_Radio"];
//    [btn setTitle:title forState:UIControlStateNormal];
//    [btn setTitleColor:kBodyFontColor forState:UIControlStateSelected];
//    [btn setTitleColor:kLightFontColor forState:UIControlStateNormal];
//    btn.titleLabel.font = [UIFont systemFontOfSize:kSizeScale(16)];
//    [btn addTarget:self action:@selector(radioClicked:) forControlEvents:UIControlEventTouchUpInside];
//
//    return btn;
//}

- (UIButton *)confirmBtn {
    if (!_confirmBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.hidden = YES;
        [btn setBackgroundImage:[UIImage imageNamed:@"camera_confirm"] forState:UIControlStateNormal];
        [btn sizeToFit];
        [btn addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.switchBgView addSubview:btn];
        _confirmBtn = btn;
    }
    return _confirmBtn;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.hidden = YES;
        [btn setBackgroundImage:[UIImage imageNamed:@"camera_cancel"] forState:UIControlStateNormal];
        [btn sizeToFit];
        [btn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.switchBgView addSubview:btn];
        _cancelBtn = btn;
    }
    return _cancelBtn;
}

- (UIImageView *)photoBtn {
    if (!_photoBtn) {
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, PhotoButtonWidth, PhotoButtonWidth)];
        view.hidden = YES;
        view.image = [UIImage imageNamed:@"camera_takePhoto"];
        view.contentMode = UIViewContentModeScaleAspectFit;
        [self.switchBgView addSubview:view];
        _photoBtn = view;

        view.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoBtnTapped:)];
        [view addGestureRecognizer:tap];
    }
    return _photoBtn;
}

- (UIView *)videoBtn {
    if (!_videoBtn) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PhotoButtonWidth, PhotoButtonWidth)];
        view.hidden = YES;
        [self.switchBgView addSubview:view];
        _videoBtn = view;

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoBtnTapped)];
        [view addGestureRecognizer:tap];

        CGFloat lineWidth = kSizeScale(6);

        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds))
                                                            radius:(CGRectGetWidth(view.bounds) - lineWidth) * 0.5
                                                        startAngle:-M_PI_2
                                                          endAngle:M_PI_2 * 3
                                                         clockwise:YES];

        CAShapeLayer *traceLayer = [CAShapeLayer layer];
        traceLayer.frame = view.bounds;
        traceLayer.fillColor = [UIColor clearColor].CGColor;
        traceLayer.strokeColor = kUIColorFromRGB(0xE3E5EA).CGColor;
        traceLayer.lineWidth = lineWidth;
        traceLayer.path = path.CGPath;
        [view.layer addSublayer:traceLayer];

        CAShapeLayer *progressLayer = [CAShapeLayer layer];
        progressLayer.frame = traceLayer.bounds;
        progressLayer.fillColor = [UIColor clearColor].CGColor;
        progressLayer.strokeColor = kMainColor.CGColor;
        progressLayer.lineWidth = lineWidth;
        progressLayer.path = path.CGPath;
        progressLayer.lineCap = kCALineCapRound;
        progressLayer.strokeStart = 0;
        progressLayer.strokeEnd = 0;
        [view.layer addSublayer:progressLayer];
        _progressLayer = progressLayer;

        CALayer *statusLayer = [CALayer layer];
        statusLayer.bounds = CGRectMake(0, 0, kSizeScale(38), kSizeScale(38));
        statusLayer.position = traceLayer.position;
        statusLayer.contents = (__bridge id)[UIImage imageNamed:@"camera_video_prepare"].CGImage;
        statusLayer.contentsGravity = kCAGravityResizeAspect;
        [view.layer addSublayer:statusLayer];
        _videoStatusLayer = statusLayer;
    }
    return _videoBtn;
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

@end
