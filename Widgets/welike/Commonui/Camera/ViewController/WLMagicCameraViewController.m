//
//  WLMagicCameraViewController.m
//  welike
//
//  Created by fan qi on 2018/11/26.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLMagicCameraViewController.h"
#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>
#import "WLAssetsManager.h"
#import "WLAuthorizationHelper.h"
#import "WLPlayerViewController.h"
#import "WLMagicContentView.h"
#import "WLMagicBasicModel.h"

@interface WLMagicCameraViewController () <WLCameraOperateViewDelegate, AliyunIRecorderDelegate, UIGestureRecognizerDelegate> {
    AliyunIRecorder *_recorder;
    UIView *_previewView;
    NSString *_outputFilePath;
    
    UIImage *_stillImage;
    
    AliyunEffectPaster *_currentPaster;
}

@property (nonatomic, strong) WLCameraOperateView *operateView;
@property (nonatomic, strong) UIButton *leftBtn;

/**
 是否是从后台进入前台这种场景录制
 */
@property (nonatomic, assign) BOOL backToFrontRecord;

/**
 开始录制时间
 */
@property (nonatomic, assign) double downTime;

/**
 结束录制时间
 */
@property (nonatomic, assign) double upTime;

/**
 开始录制视频段数
 */
@property (nonatomic, assign) NSInteger downVideoCount;

/**
 结束录制视频段数
 */
@property (nonatomic, assign) NSInteger upVideoCount;

/**
 录制时间
 */
@property (nonatomic, assign) CFTimeInterval recordingDuration;

/**
 APP是否处于悬挂状态
 */
@property (nonatomic, assign) BOOL suspend;


@end

@implementation WLMagicCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.view.backgroundColor = [UIColor blackColor];
    
    [WLAuthorizationHelper requestCameraAuthorizationWithFinished:^(BOOL granted) {
        if (granted) {
            if (self.outputType == FQCameraOutputType_Video) {
                [WLAuthorizationHelper requestMicrophoneAuthorizationWithFinished:^(BOOL granted) {
                    if (granted) {
                        [self initializeCapture];
                    } else {
                        [self leftBtnClicked];
                    }
                }];
            } else {
                [self initializeCapture];
            }
            
        } else {
            [self leftBtnClicked];
        }
    }];
}

- (void)dealloc {
    [self p_clear];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _previewView.frame = self.view.bounds;
}

- (void)initializeCapture {
    _previewView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    CGFloat viewWidth = 0, viewHeight = 0;
    
    NSString *videoSessionPreset;
    NSString *photoSessionPreset;
    
    if (kScreenHeight > 480)
    {
        viewWidth = 720;
        viewHeight = 1280;
        
        videoSessionPreset = AVCaptureSessionPreset1280x720;
        photoSessionPreset = AVCaptureSessionPresetHigh;
    }
    else
    {
        viewWidth = 480;
        viewHeight = 848;
        
        videoSessionPreset = AVCaptureSessionPreset640x480;
        photoSessionPreset = AVCaptureSessionPresetHigh;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *taskPath = NSTemporaryDirectory();
        self->_outputFilePath = [[taskPath stringByAppendingPathComponent:@"movie_wl"] stringByAppendingPathExtension:@"mp4"];
        
        self->_recorder = [[AliyunIRecorder alloc] initWithDelegate:self videoSize:CGSizeMake(viewWidth, viewHeight)];
        self->_recorder.outputPath = self->_outputFilePath;
        self->_recorder.taskPath = taskPath;
        self->_recorder.useFaceDetect = NO;
        self->_recorder.outputType = AliyunIRecorderVideoOutputPixelFormatType420f;
        self->_recorder.beautifyStatus = NO;
        self->_recorder.beautifyValue = 50;
        self->_recorder.clipManager.maxDuration = MAX_VIDEO_RECORD_DURATION;
        self->_recorder.encodeMode = 1;
        self->_recorder.videoQuality = AliyunVideoQualityMedium;
        self->_recorder.bitrate = viewWidth * viewHeight * 1.4;
        
        switch (self.outputType) {
            case FQCameraOutputType_Photo: {
                self->_recorder.cameraRotate = 0;
                self->_recorder.backCaptureSessionPreset = AVCaptureSessionPresetHigh;
                self->_recorder.frontCaptureSessionPreset = AVCaptureSessionPresetHigh;
            }
                break;
            case FQCameraOutputType_Video: {
                self->_recorder.cameraRotate = 0;
                self->_recorder.backCaptureSessionPreset = videoSessionPreset;
                self->_recorder.frontCaptureSessionPreset = videoSessionPreset;
            }
                break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_recorder.preview = self->_previewView;
            [self.view addSubview:self->_previewView];
            [self.view addSubview:self.operateView];
            [self.view addSubview:self.leftBtn];
            
            [self->_recorder startPreview];
            
            [self addGesture];
        });
    });
}

#pragma mark - AliyunIRecorderDelegate

- (void)recorderDeviceAuthorization:(AliyunIRecorderDeviceAuthor)status {
    
}

- (void)recorderDidStopRecording {
   
    NSLog(@"停止录制了");
    // 录制时间小于0.2秒，并且录制结束后的视频段大于录制开始时的视频段，回删最后一段视频。
//    if (((self.upTime - self.downTime)<0.2)&&(self.upVideoCount>self.downVideoCount)) {
//
//        NSInteger code = [_recorder.clipManager partCount];
//        [self deleteButtonClicked];
//        [_clipManager partCount];
//        NSInteger code2 = [_clipManager partCount];
//        NSLog(@"录制参数：%zd--%zd",code,code2);
//    }else if((self.upVideoCount == self.downVideoCount)){
//        self.magicCameraView.progressView.videoCount--;
//        CGFloat percent = _clipManager.duration / _clipManager.maxDuration;
//        [self.magicCameraView recordingPercent:percent];
//        _recordingDuration = _clipManager.duration;
//        // 当录制结束后的视频段=录制开始时的视频=0时，恢复默认UI
//        if ((self.downVideoCount==0)&&(self.upVideoCount == 0)) {
//            self.magicCameraView.bottomHide = NO;
//        }
//    }
//
}

- (void)recorderDidFinishRecording {
    if (_suspend == NO)
    {
       
        [self.operateView recordButtonTouchUp];
        
        self.operateView.hidden = NO;
        //跳转处理
        NSString *outputPath = _recorder.outputPath;
//        if (self.finishBlock) {
//            self.finishBlock(outputPath);
//        }
//        else
//        {
//            [[AlivcShortVideoRoute shared]registerEditVideoPath:outputPath];
//            [[AlivcShortVideoRoute shared]registerEditMediasPath:nil];
//            UIViewController *editVC = [[AlivcShortVideoRoute shared]alivcViewControllerWithType:AlivcViewControlCrop];
//            [self.navigationController pushViewController:editVC animated:YES];
//        }
    }
}

#pragma mark - WLCameraOperateViewDelegate

- (void)cameraOperateViewDidTakePhotoClicked:(WLCameraOperateView *)operateView succeed:(SucceedBlock)succeed {
    [_recorder takePhoto:^(UIImage *image, UIImage *rawImage) {
        UIImage *fixedImg = [image fixOrientation];
        self->_stillImage = fixedImg;
        
        [self->_recorder stopPreview];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (succeed) {
                succeed();
            }
        });
    }];
}

- (void)cameraOperateView:(WLCameraOperateView *)operateView didConfirmedWithOutputType:(FQCameraOutputType)outputType {
    switch (outputType) {
        case FQCameraOutputType_Photo: {
            if (_stillImage && [self.delegate respondsToSelector:@selector(cameraViewCtr:didConfirmWithImage:)]) {
                [self.delegate cameraViewCtr:self didConfirmWithImage:_stillImage];
            }
        }
            break;
        case FQCameraOutputType_Video: {
            [WLAssetsManager saveVideoToCameraRollWithFilePath:_outputFilePath
                                                      finished:^(PHAsset *asset) {
                                                          [self p_removeFile:self->_outputFilePath];
                                                          
                                                          if ([self.delegate respondsToSelector:@selector(cameraViewCtr:didConfirmWithVideoAsset:)]) {
                                                              [self.delegate cameraViewCtr:self didConfirmWithVideoAsset:asset];
                                                          }
                                                      }];
        }
            break;
    }
}

- (void)cameraOperateView:(WLCameraOperateView *)operateView didCanceledWithOutputType:(FQCameraOutputType)outputType {
    if (outputType == FQCameraOutputType_Video) {
        [self p_removeFile:_outputFilePath];
    } else {
        _stillImage = nil;
    }
    [_recorder startPreview];
}

- (void)cameraOperateView:(WLCameraOperateView *)operateView
    didVideoStatusChanged:(FQCameraVideoStatus)newStatus
                oldStatus:(FQCameraVideoStatus)oldStatus {
    switch (newStatus) {
        case FQCameraVideoStatus_Prepare:
            break;
        case FQCameraVideoStatus_Recording:
            [self p_removeFile:_outputFilePath];
            [_recorder startRecording];
            break;
        case FQCameraVideoStatus_Completed:
            [_recorder stopRecording];
            [_recorder stopPreview];
            self.operateView.recordFilePath = [NSURL fileURLWithPath:_outputFilePath];
            break;
        default:
            break;
    }
}

- (void)cameraOperateViewDidChangeFlashlight:(WLCameraOperateView *)operateView succeed:(void (^)(AVCaptureFlashMode))succeed {
    [_recorder switchTorchMode];
    
    AVCaptureFlashMode flashMode = AVCaptureFlashModeOff;
    switch (_recorder.torchMode) {
        case AliyunIRecorderTorchModeOff:
            flashMode = AVCaptureFlashModeOff;
            break;
        case AliyunIRecorderTorchModeOn:
            flashMode = AVCaptureFlashModeOn;
            break;
        case AliyunIRecorderTorchModeAuto:
            flashMode = AVCaptureFlashModeAuto;
            break;
    }
    
    if (succeed) {
        succeed(flashMode);
    }
}

- (void)cameraOperateViewDidTransformCamera:(WLCameraOperateView *)operateView {
    [_recorder switchCameraPosition];
}

- (void)cameraOperateView:(WLCameraOperateView *)operateView disPlayVideo:(NSURL *)fileUrl {
    AVAsset *asset = [AVAsset assetWithURL:fileUrl];
    
    WLPlayerViewController *ctr = [[WLPlayerViewController alloc] initWithAsset:asset];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (void)cameraOperateViewDidSelectedModel:(WLMagicBasicModel *)selectedModel {
    if (selectedModel.type == WLMagicBasicModelType_Filter) {
        if (!selectedModel.localPath) {
            [_recorder deleteFilter];
            
        } else {
            AliyunEffectFilter *filter = [[AliyunEffectFilter alloc] initWithFile:selectedModel.localPath];
            [_recorder applyFilter:filter];
        }
    } else if (selectedModel.type == WLMagicBasicModelType_Paster) {
        if (_currentPaster) {
            [_recorder deletePaster:_currentPaster];
        }
        
        if (!selectedModel.localPath) {
            [_recorder deletePaster:_currentPaster];
            return;
        }
        
        _recorder.useFaceDetect = YES;
        _recorder.faceDetectCount = 3;
        
        AliyunEffectPaster *paster = [[AliyunEffectPaster alloc] initWithFile:selectedModel.localPath];
        [_recorder applyPaster:paster];
        
        _currentPaster = paster;
    }
}

//video
-(void)cameraOperateViewDidTapRecordBtn
{
    NSLog(@"====开始拍摄");
    int code =  [_recorder startRecording];
    
    if (code == 0) {
       // self.operateView.hidden = YES;
    }else{
      //  self.operateView.hidden = NO;
       // self.magicCameraView.progressView.videoCount--;
       // [self.magicCameraView resetRecordButtonUI];
      //  self.magicCameraView.recording = NO;
      //  _magicCameraView.realVideoCount = [_clipManager partCount];
    }
}

-(void)cameraOperateVieDidPauseRecording
{
     NSLog(@"====暂停拍摄");
    [_recorder stopRecording];
    self.upTime = CFAbsoluteTimeGetCurrent();
    self.operateView.hidden = NO;
    
    self.operateView.videoStatus = FQCameraVideoStatus_Stop;
    
}

-(void)cameraOperateVieDidFinishRecording
{
     NSLog(@"=====完成拍摄");
    
    if ([_recorder.clipManager partCount]) {
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [_recorder finishRecording];
    }
    
    //    [_recorder stopPreview];
//    //_quVideo.videoRotate = [_clipManager firstClipVideoRotation];
//    [_recorder finishRecording];
//    self.operateView.hidden = NO;
}

#pragma mark - AliyunIRecorderDelegate

- (void)recorderVideoDuration:(CGFloat)duration {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGFloat percent = duration / self->_recorder.clipManager.maxDuration;
        [self.operateView recordingPercent:percent];
        self.recordingDuration = duration;
    });
}


#pragma mark - Gesture
- (void)addGesture
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToFocusPoint:)];
    [_recorder.preview addGestureRecognizer:tapGesture];
}


- (void)tapToFocusPoint:(UITapGestureRecognizer *)tapGesture {
    UIView *tapView = tapGesture.view;
    CGPoint point = [tapGesture locationInView:tapView];
    _recorder.focusPoint = point;
    
    if (!_recorder.isRecording) {
     //   [self.magicCameraView cancelRecordBeautyView];//关闭美颜
    }
}

#pragma mark - Private

- (void)p_clear {
    [self p_removeFile:_outputFilePath];
    [_recorder stopRecording];
    [_recorder stopPreview];
    [_recorder destroyRecorder];
    _recorder = nil;
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)p_removeFile:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]){
        [fileManager removeItemAtPath:filePath error:nil];
    }
    
    [_recorder.clipManager.videoAbsolutePaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([fileManager fileExistsAtPath:obj]){
            [fileManager removeItemAtPath:obj error:nil];
        }
    }];
    
    [_recorder.clipManager deleteAllPart];
}

#pragma mark - Event

- (void)leftBtnClicked {
    if (self.navigationController.childViewControllers.count == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Getter

- (WLCameraOperateView *)operateView {
    if (!_operateView) {
        WLCameraOperateView *view = [[WLCameraOperateView alloc] initWithFrame:self.view.bounds type:self.outputType];
        view.cameraType = WLCameraType_Magic;
//        view.outputType = self.outputType;
        view.delegate = self;
        _operateView = view;
    }
    return _operateView;
}

- (UIButton *)leftBtn {
    if (!_leftBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, kSystemStatusBarHeight, kSingleNavBarHeight, kSingleNavBarHeight);
        [btn setImage:[AppContext getImageForKey:@"common_close_white"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(leftBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        _leftBtn = btn;
    }
    return _leftBtn;
}

@end
