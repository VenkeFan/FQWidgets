//
//  WLAVCameraViewController.m
//  WeLike
//
//  Created by fan qi on 2018/4/2.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLAVCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "WLAssetWriter.h"
#import "WLAuthorizationHelper.h"
#import "WLPlayerViewController.h"

static char * const VideoOutputQueueKey = "com.welike.videoOutputQueue.fq";
static char * const AudioOutputQueueKey = "com.welike.audioOutputQueue.fq";

@interface WLAVCameraViewController () <WLCameraOperateViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate> {
    AVCaptureSession *_session;
    
    AVCaptureDeviceInput *_videoInput;
    AVCaptureDeviceInput *_audioInput;
    
    AVCaptureVideoDataOutput *_videoOutput;
    AVCaptureAudioDataOutput *_audioOutput;
//    AVCapturePhotoOutput *_photoOutput; // iOS 10.0
    AVCaptureStillImageOutput *_imageOutput;
    
    AVCaptureConnection *_videoConnection;
    AVCaptureConnection *_audioConnection;
    
    WLAssetWriter *_assetWriter;
    
    AVCaptureVideoPreviewLayer *_previewLayer;
    
    AVCaptureVideoOrientation _referenceOrientation;
    AVCaptureFlashMode _currentFlashMode;
    
    UIImage *_stillImage;
}

@property (nonatomic, strong) WLCameraOperateView *operateView;
@property (nonatomic, strong) UIButton *leftBtn;

@property (nonatomic, weak) AVCaptureDevice *activeCamera;
@property (nonatomic, assign) BOOL isReadyToWrite;
@property (nonatomic, strong) CABasicAnimation *transformCameraAnimation;

@end

@implementation WLAVCameraViewController

#pragma mark - LifeCycle

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
    [_session stopRunning];
    _session = nil;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - InitializeAVCapture

- (void)initializeCapture {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVCaptureDevice *videoDevice = [self deviceWithMediaType:AVMediaTypeVideo];
        self->_videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        self->_currentFlashMode = videoDevice.flashMode;
        
        self->_videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        self->_videoOutput.alwaysDiscardsLateVideoFrames = YES;
        [self->_videoOutput setSampleBufferDelegate:self queue:dispatch_queue_create(VideoOutputQueueKey, NULL)];
        [self->_videoOutput setVideoSettings:@{(NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)}];
        
        self->_imageOutput = [[AVCaptureStillImageOutput alloc] init];
        [self->_imageOutput setOutputSettings:@{AVVideoCodecKey: AVVideoCodecJPEG}];
        
        self->_session = [[AVCaptureSession alloc] init];
        switch (self.outputType) {
            case FQCameraOutputType_Photo: {
                if ([self->_session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
                    [self->_session setSessionPreset:AVCaptureSessionPresetHigh];
                }
            }
                break;
            case FQCameraOutputType_Video: {
                AVCaptureDevice *audioDevice = [self deviceWithMediaType:AVMediaTypeAudio];
                self->_audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
                
                self->_audioOutput = [[AVCaptureAudioDataOutput alloc] init];
                [self->_audioOutput setSampleBufferDelegate:self queue:dispatch_queue_create(AudioOutputQueueKey, NULL)];
                
                if ([self->_session canSetSessionPreset:AVCaptureSessionPresetMedium]) {
                    [self->_session setSessionPreset:AVCaptureSessionPresetMedium];
                }
            }
                break;
        }
        if ([self->_session canAddInput:self->_videoInput]) {
            [self->_session addInput:self->_videoInput];
        }
        if ([self->_session canAddOutput:self->_videoOutput]) {
            [self->_session addOutput:self->_videoOutput];
        }
        if ([self->_session canAddOutput:self->_imageOutput]) {
            [self->_session addOutput:self->_imageOutput];
        }
        
        if ([self->_session canAddInput:self->_audioInput]) {
            [self->_session addInput:self->_audioInput];
        }
        if ([self->_session canAddOutput:self->_audioOutput]) {
            [self->_session addOutput:self->_audioOutput];
        }
        
        self->_referenceOrientation = AVCaptureVideoOrientationPortrait;
        self->_videoConnection = [self->_videoOutput connectionWithMediaType:AVMediaTypeVideo];
        self->_videoConnection.videoOrientation = self->_referenceOrientation;
        self->_audioConnection = [self->_audioOutput connectionWithMediaType:AVMediaTypeAudio];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self->_session];
            self->_previewLayer.frame = self.view.bounds;
            self->_previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//            self->_previewLayer.doubleSided = YES;
//            CATransform3D transform = self->_previewLayer.transform;
//            transform.m34 = -1.0 / 500;
            [self.view.layer addSublayer:self->_previewLayer];
            
            [self.view addSubview:self.operateView];
            [self.view addSubview:self.leftBtn];
            
            [self->_session startRunning];
        });
    });
}

- (AVCaptureDevice *)deviceWithMediaType:(AVMediaType)mediaType {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    
    if (mediaType == AVMediaTypeVideo) {
        for (AVCaptureDevice *device in devices) {
            if (device.position == AVCaptureDevicePositionBack) {
                return device;
            }
        }
    } else if (mediaType == AVMediaTypeAudio) {
        return devices.firstObject;
    }
    
    return devices.firstObject;
}

#pragma mark - WLCameraOperateViewDelegate

- (void)cameraOperateViewDidTakePhotoClicked:(WLCameraOperateView *)operateView succeed:(SucceedBlock)succeed {
    AVCaptureConnection *imgConnection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (imgConnection.isVideoOrientationSupported) {
        imgConnection.videoOrientation = [self currentVideoOrientation];
    }
    [_imageOutput captureStillImageAsynchronouslyFromConnection:imgConnection
                                              completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
                                                  if (!imageDataSampleBuffer) {
                                                      return;
                                                  }
                                                  
                                                  NSData *imgData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                  UIImage *image = [[UIImage alloc] initWithData:imgData];
                                                  self->_stillImage = [image fixOrientation];
                                                  
                                                  [self->_session stopRunning];
                                                  
                                                  if (succeed) {
                                                      succeed();
                                                  }
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
            [_assetWriter saveToCameraRollWithFinished:^(PHAsset *asset) {
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
        [_assetWriter removeFile];
    } else {
        _stillImage = nil;
    }
    [_session startRunning];
}

- (void)cameraOperateView:(WLCameraOperateView *)operateView
    didVideoStatusChanged:(FQCameraVideoStatus)newStatus
                oldStatus:(FQCameraVideoStatus)oldStatus {
    switch (newStatus) {
        case FQCameraVideoStatus_Prepare:
            break;
        case FQCameraVideoStatus_Recording:
            [self p_startRecording];
            break;
        case FQCameraVideoStatus_Completed:
            [self p_stopRecording];
            break;
        default:
            break;
    }
}

- (void)cameraOperateViewDidChangeFlashlight:(WLCameraOperateView *)operateView succeed:(void (^)(AVCaptureFlashMode))succeed {
    if (!self.activeCamera) {
        return;
    }
    if (!self.activeCamera.hasFlash) {
        return;
    }
    if(!self.activeCamera.flashAvailable) {
        return;
    }
    
    AVCaptureFlashMode currentMode = self.activeCamera.flashMode;
    
    AVCaptureFlashMode newMode = AVCaptureFlashModeOn;
    if (currentMode == AVCaptureFlashModeOff) {
        newMode = AVCaptureFlashModeOn;
    } else if (currentMode == AVCaptureFlashModeOn) {
        newMode = AVCaptureFlashModeAuto;
    } else {
        newMode = AVCaptureFlashModeOff;
    }
    
    [self p_changeFlashMode:newMode succeed:succeed];
}

- (void)cameraOperateViewDidTransformCamera:(WLCameraOperateView *)operateView {
    NSArray<AVCaptureDevice *> *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    if (devices.count <= 1) {
        return;
    }
    
    __block AVCaptureDevice *inactiveDevice = nil;
    [devices enumerateObjectsUsingBlock:^(AVCaptureDevice * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj != self.activeCamera) {
            inactiveDevice = obj;
        }
    }];
    
    if (!inactiveDevice) {
        return;
    }
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:inactiveDevice error:nil];
    if (videoInput) {
        
//        [_previewLayer removeAnimationForKey:@"transformCameraAnimation"];
//        [_previewLayer addAnimation:self.transformCameraAnimation forKey:@"transformCameraAnimation"];
        
        [_session beginConfiguration];

        [_session removeInput:_videoInput];
        if ([_session canAddInput:videoInput]) {
            [_session addInput:videoInput];
            _videoInput = videoInput;
        }

        [_session removeOutput:_videoOutput];
        AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        videoOutput.alwaysDiscardsLateVideoFrames = YES;
        [videoOutput setSampleBufferDelegate:self queue:dispatch_queue_create(VideoOutputQueueKey, NULL)];
        [videoOutput setVideoSettings:@{(NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)}];
        if ([_session canAddOutput:videoOutput]) {
            [_session addOutput:videoOutput];
            _videoOutput = videoOutput;

            _videoConnection = [videoOutput connectionWithMediaType:AVMediaTypeVideo];
            _videoConnection.videoOrientation = _referenceOrientation;
        }

        [_session commitConfiguration];

        [self p_changeFlashMode:_currentFlashMode succeed:nil];
    }
}

- (void)cameraOperateView:(WLCameraOperateView *)operateView disPlayVideo:(NSURL *)fileUrl {
    AVAsset *asset = [AVAsset assetWithURL:fileUrl];
    
    WLPlayerViewController *ctr = [[WLPlayerViewController alloc] initWithAsset:asset];
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (self.operateView.videoStatus == FQCameraVideoStatus_Recording) {
        if (_assetWriter) {
            CFRetain(sampleBuffer);
            dispatch_async(_assetWriter.writingQueue, ^{
                if (connection == self->_videoConnection) {
                    if (!self->_assetWriter.readyToRecordVideo){
                        [self->_assetWriter setupAssetWriterVideoInput:CMSampleBufferGetFormatDescription(sampleBuffer)];
                    }
                    if (self.isReadyToWrite){
                        [self->_assetWriter writeSampleBuffer:sampleBuffer ofType:AVMediaTypeVideo];
                    }
                } else if (connection == self->_audioConnection) {
                    if (!self->_assetWriter.readyToRecordAudio){
                        [self->_assetWriter setupAssetWriterAudioInput:CMSampleBufferGetFormatDescription(sampleBuffer)];
                    }
                    if (self.isReadyToWrite){
                        [self->_assetWriter writeSampleBuffer:sampleBuffer ofType:AVMediaTypeAudio];
                    }
                }
                CFRelease(sampleBuffer);
            });
        }
    }
}

#pragma mark - Private

- (AVCaptureVideoOrientation)currentVideoOrientation {
    AVCaptureVideoOrientation videoOrientation = AVCaptureVideoOrientationPortrait;
    
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationFaceUp:
            
            break;
        case UIDeviceOrientationFaceDown:
            
            break;
        case UIDeviceOrientationUnknown:
            
            break;
        case UIDeviceOrientationLandscapeLeft:
            videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortrait:
            videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
    }
    
    return videoOrientation;
}

- (void)p_startRecording {
    if (!_assetWriter) {
        _assetWriter = [[WLAssetWriter alloc] init];
        _assetWriter.referenceOrientation = _referenceOrientation;
        _assetWriter.devicePostion = self.activeCamera.position;
    }
    
    [_assetWriter startRecording];
}

- (void)p_stopRecording {
    [_assetWriter stopRecordingWithFinished:^() {
        self.operateView.recordFilePath = self->_assetWriter.filePath;
    }];
    [_session stopRunning];
}

- (void)p_changeFlashMode:(AVCaptureFlashMode)flashMode succeed:(void (^)(AVCaptureFlashMode))succeed {
    if ([self.activeCamera isFlashModeSupported:flashMode]) {
        NSError *error;
        
        if ([self.activeCamera lockForConfiguration:&error]) {
            self.activeCamera.flashMode = flashMode;
            [self.activeCamera unlockForConfiguration];
            _currentFlashMode = flashMode;
            
            if (succeed) {
                succeed(flashMode);
            }
        } else {
            
        }
    }
}

- (void)p_setFrameRate {
    BOOL isSupport = NO;
    CMTime perferTimescale = CMTimeMake(1, 15);
    for (AVFrameRateRange *supportFrame in self.activeCamera.activeFormat.videoSupportedFrameRateRanges) {
        int32_t min = CMTimeCompare(perferTimescale, supportFrame.minFrameDuration);
        int32_t max = CMTimeCompare(perferTimescale, supportFrame.maxFrameDuration);
        
        if (max <= 0 && min >= 0) {
            isSupport = YES;
            break;
        }
    }
    
    if (isSupport) {
        [self.activeCamera lockForConfiguration:nil];
        self.activeCamera.activeVideoMaxFrameDuration = perferTimescale;
        self.activeCamera.activeVideoMinFrameDuration = perferTimescale;
        [self.activeCamera unlockForConfiguration];
    }
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
        WLCameraOperateView *view = [[WLCameraOperateView alloc] initWithFrame:self.view.bounds];
        view.cameraType = WLCameraType_AVCapture;
        view.outputType = self.outputType;
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

- (AVCaptureDevice *)activeCamera {
    return _videoInput.device;
}

- (BOOL)isReadyToWrite {
    return _assetWriter.isReadyToRecordVideo && _assetWriter.isReadyToRecordAudio;
}

- (CABasicAnimation *)transformCameraAnimation {
    if (!_transformCameraAnimation) {
        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.keyPath = @"transform";
        animation.valueFunction = [CAValueFunction functionWithName:kCAValueFunctionRotateY];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.duration = 0.75;
        animation.toValue = @(M_PI);
        _transformCameraAnimation = animation;
    }
    return _transformCameraAnimation;
}

@end
