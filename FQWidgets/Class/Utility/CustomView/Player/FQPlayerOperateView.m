//
//  FQPlayerOperateView.m
//  WeLike
//
//  Created by fan qi on 2018/4/10.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQPlayerOperateView.h"

@interface FQPlayerOperateView ()

@property (nonatomic, weak) UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) UIButton *playBtn;
@property (nonatomic, weak) UIView *progressView;
@property (nonatomic, strong) UILabel *leftLab;
@property (nonatomic, strong) UILabel *rightLab;
@property (nonatomic, strong) UISlider *cacheProgressBar;
@property (nonatomic, strong) UISlider *playProgressBar;

@end

@implementation FQPlayerOperateView

#pragma mark - LifeCycle

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        
        _playProgress = 0.0;
        _cacheProgress = 0.0;
    }
    return self;
}

- (void)layoutSubviews {
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
        make.height.mas_equalTo(kSizeScale(35));
    }];
    
    CGPoint centerPoint = CGPointMake(CGRectGetWidth(self.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5);
    self.indicatorView.center = centerPoint;
    self.playBtn.center = centerPoint;
}

#pragma mark - Event

- (void)playBtnClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(playerOperateViewDidClickedPlay:)]) {
        [self.delegate playerOperateViewDidClickedPlay:self];
    }
}

- (void)stopBtnClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(playerOperateViewDidClickedStop:)]) {
        [self.delegate playerOperateViewDidClickedStop:self];
    }
}

- (void)sliderUpInside:(UISlider *)slider {
    if ([self.delegate respondsToSelector:@selector(playerOperateView:didSliderValueChanged:)]) {
        [self.delegate playerOperateView:self didSliderValueChanged:slider.value];
    }
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

#pragma mark - Private

- (NSString *)p_translateTotalSeconds:(NSInteger)totalSeconds {
    NSInteger hours = totalSeconds / 3600;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger seconds = totalSeconds % 60;
    
    if (hours > 0) {
        return [NSString stringWithFormat:@"%.2zd:%.2zd:%.2zd", hours, minutes, seconds];
    } else {
        return[NSString stringWithFormat:@"%.2zd:%.2zd", minutes, seconds];
    }
}

#pragma mark - Setter

- (void)setPlayerViewStatus:(FQPlayerViewStatus)playerViewStatus {
    if (playerViewStatus == _playerViewStatus) {
        return;
    }
    _playerViewStatus = playerViewStatus;
    [self setCaching:NO];
    
    switch (playerViewStatus) {
        case FQPlayerViewStatus_ReadyToPlay:
            break;
        case FQPlayerViewStatus_Playing:
            self.playBtn.hidden = YES;
            break;
        case FQPlayerViewStatus_Paused:
            self.playBtn.hidden = NO;
            break;
        case FQPlayerViewStatus_CachingPaused:
            [self setCaching:YES];
            break;
        case FQPlayerViewStatus_Stopped:
            self.playBtn.hidden = NO;
            break;
        case FQPlayerViewStatus_Completed:
            self.playBtn.hidden = NO;
            break;
        default:
            
            break;
    }
}

- (void)setPlayProgress:(CGFloat)playProgress {
    _playProgress = playProgress;
    [self.playProgressBar setValue:playProgress animated:YES];
}

- (void)setCacheProgress:(CGFloat)cacheProgress {
    _cacheProgress = cacheProgress;
    [self.cacheProgressBar setValue:cacheProgress animated:YES];
}

- (void)setPlaySeconds:(CGFloat)playSeconds {
    _playSeconds = playSeconds;
    if (playSeconds <= 0) {
        self.leftLab.text = @"00:00";
    } else {
        self.leftLab.text = [self p_translateTotalSeconds:(int)floorf(playSeconds)];
    }
}

- (void)setRestSeconds:(CGFloat)restSeconds {
    _restSeconds = restSeconds;
    if (restSeconds <= 0) {
        self.rightLab.text = @"00:00";
    } else {
        self.rightLab.text = [self p_translateTotalSeconds:(int)ceilf(restSeconds)];
    }
}

- (void)setCaching:(BOOL)caching {
    _caching = caching;
    
    if (caching && !self.indicatorView.isAnimating) {
        [self.indicatorView startAnimating];
    } else {
        [self.indicatorView stopAnimating];
    }
}

#pragma mark - Getter

#pragma mark ProgressView

- (UIView *)progressView {
    if (!_progressView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        [self addSubview:view];
        _progressView = view;
        
        [view addSubview:self.leftLab];
        [self.leftLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(view).offset(kSizeScale(30));
            make.centerY.mas_equalTo(view);
            make.height.mas_equalTo(view);
            make.width.mas_equalTo(kSizeScale(40));
        }];
        
        [view addSubview:self.rightLab];
        [self.rightLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(view).offset(-kSizeScale(30));
            make.centerY.mas_equalTo(self.leftLab);
            make.height.mas_equalTo(self.leftLab);
            make.width.mas_equalTo(self.leftLab);
        }];
        
//        [view addSubview:self.cacheProgressBar];
//        [self.cacheProgressBar mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerY.mas_equalTo(self.leftLab);
//            make.left.mas_equalTo(self.leftLab.mas_right).offset(kSizeScale(10));
//            make.right.mas_equalTo(self.rightLab.mas_left).offset(-kSizeScale(10));
//        }];
        
        [view addSubview:self.playProgressBar];
        [self.playProgressBar mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.mas_equalTo(self.cacheProgressBar);
            
            make.centerY.mas_equalTo(self.leftLab);
            make.left.mas_equalTo(self.leftLab.mas_right).offset(kSizeScale(10));
            make.right.mas_equalTo(self.rightLab.mas_left).offset(-kSizeScale(10));
        }];
    }
    return _progressView;
}

- (UILabel *)leftLab {
    if (!_leftLab) {
        UILabel *lab = [[UILabel alloc] init];
        lab.text = @"00:00";
        lab.textColor = kLightFontColor;
        lab.font = [UIFont systemFontOfSize:kSizeScale(14)];
        _leftLab = lab;
    }
    return _leftLab;
}

- (UILabel *)rightLab {
    if (!_rightLab) {
        UILabel *lab = [[UILabel alloc] init];
        lab.text = @"00:00";
        lab.textColor = kLightFontColor;
        lab.font = [UIFont systemFontOfSize:kSizeScale(14)];
        _rightLab = lab;
    }
    return _rightLab;
}

- (UISlider *)cacheProgressBar {
    if (!_cacheProgressBar) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0.0;
        slider.maximumValue = 1.0;
        slider.minimumTrackTintColor = [UIColor greenColor];
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
        slider.maximumTrackTintColor = kLightFontColor;
        [slider addTarget:self action:@selector(sliderUpInside:) forControlEvents:UIControlEventTouchUpInside];
        _playProgressBar = slider;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)];
        [slider addGestureRecognizer:tap];
    }
    return _playProgressBar;
}

#pragma mark ControlView

- (UIButton *)playBtn {
    if (!_playBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"camera_video_icon"] forState:UIControlStateNormal];
        [btn sizeToFit];
        [btn addTarget:self action:@selector(playBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        _playBtn = btn;
    }
    return _playBtn;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self addSubview:indicator];
        _indicatorView = indicator;
    }
    return _indicatorView;
}

@end
