//
//  FQCameraViewController.m
//  WeLike
//
//  Created by fan qi on 2018/4/2.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQCameraViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "FQAssetWriter.h"

@interface FQCameraViewController () <FQCameraOperateViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate> {
    AVCaptureSession *_session;
    
    AVCaptureDeviceInput *_videoInput;
    AVCaptureDeviceInput *_audioInput;
    
    AVCaptureVideoDataOutput *_videoOutput;
    AVCaptureAudioDataOutput *_audioOutput;
//    AVCapturePhotoOutput *_photoOutput; // iOS 10.0
    AVCaptureStillImageOutput *_imageOutput;
    
    AVCaptureConnection *_videoConnection;
    AVCaptureConnection *_audioConnection;
    
    FQAssetWriter *_assetWriter;
    
    AVCaptureVideoPreviewLayer *_previewLayer;
    
    AVCaptureVideoOrientation _referenceOrientation;
    AVCaptureFlashMode _currentFlashMode;
    
    UIImage *_stillImage;
}

@property (nonatomic, strong) FQCameraOperateView *operateView;

@property (nonatomic, weak) AVCaptureDevice *activeCamera;
@property (nonatomic, assign) BOOL isReadyToWrite;
@property (nonatomic, strong) CABasicAnimation *transformCameraAnimation;

@end

@implementation FQCameraViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self initializeCapture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc {
    NSLog(@"FQCameraViewController dealloc");
    [_session stopRunning];
    _session = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - InitializeAVCapture

- (void)initializeCapture {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVCaptureDevice *videoDevice = [self deviceWithMediaType:AVMediaTypeVideo];
        _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        _currentFlashMode = videoDevice.flashMode;
        
        AVCaptureDevice *audioDevice = [self deviceWithMediaType:AVMediaTypeAudio];
        _audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
        
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        _videoOutput.alwaysDiscardsLateVideoFrames = YES;
        [_videoOutput setSampleBufferDelegate:self queue:dispatch_queue_create("VideoOutputQueue", NULL)];
        [_videoOutput setVideoSettings:@{(NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)}];
        
        _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
        [_audioOutput setSampleBufferDelegate:self queue:dispatch_queue_create("AudioOutputQueue", NULL)];
        
        _imageOutput = [[AVCaptureStillImageOutput alloc] init];
        [_imageOutput setOutputSettings:@{AVVideoCodecKey: AVVideoCodecJPEG}];
        
        _session = [[AVCaptureSession alloc] init];
        if ([_session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            [_session setSessionPreset:AVCaptureSessionPresetHigh];
        }
        if ([_session canAddInput:_videoInput]) {
            [_session addInput:_videoInput];
        }
        if ([_session canAddInput:_audioInput]) {
            [_session addInput:_audioInput];
        }
        
        if ([_session canAddOutput:_videoOutput]) {
            [_session addOutput:_videoOutput];
        }
        if ([_session canAddOutput:_audioOutput]) {
            [_session addOutput:_audioOutput];
        }
        if ([_session canAddOutput:_imageOutput]) {
            [_session addOutput:_imageOutput];
        }
        
        _referenceOrientation = AVCaptureVideoOrientationPortrait;
        _videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
        _videoConnection.videoOrientation = _referenceOrientation;
        _audioConnection = [_audioOutput connectionWithMediaType:AVMediaTypeAudio];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
            _previewLayer.frame = self.view.bounds;
            _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//            _previewLayer.doubleSided = YES;
//            CATransform3D transform = _previewLayer.transform;
//            transform.m34 = -1.0 / 500;
            [self.view.layer addSublayer:_previewLayer];
            
            [self.view addSubview:self.operateView];
            
            [_session startRunning];
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

#pragma mark - FQCameraOperateViewDelegate

- (void)cameraOperateViewDidTakePhotoClicked:(FQCameraOperateView *)operateView succeed:(SucceedBlock)succeed {
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
                                                  _stillImage = image;
                                                  
                                                  [_session stopRunning];
                                                  
                                                  if (succeed) {
                                                      succeed();
                                                  }
                                              }];

}

- (void)cameraOperateView:(FQCameraOperateView *)operateView didConfirmedWithOutputType:(FQCameraOutputType)outputType {
    switch (outputType) {
        case FQCameraOutputType_Photo: {
            if (_stillImage && [self.delegate respondsToSelector:@selector(cameraViewCtr:didConfirmWithOutputType:image:)]) {
                [self.delegate cameraViewCtr:self didConfirmWithOutputType:outputType image:_stillImage];
            }
        }
            break;
        case FQCameraOutputType_Video: {
            [_assetWriter saveToCameraRoll];
        }
            break;
    }
}

- (void)cameraOperateView:(FQCameraOperateView *)operateView didCanceledWithOutputType:(FQCameraOutputType)outputType {
    if (outputType == FQCameraOutputType_Video) {
        [_assetWriter removeFile];
    } else {
        _stillImage = nil;
    }
    [_session startRunning];
}

- (void)cameraOperateView:(FQCameraOperateView *)operateView
    didVideoStatusChanged:(FQCameraVideoStatus)newStatus
                oldStatus:(FQCameraVideoStatus)oldStatus {
    switch (newStatus) {
        case FQCameraVideoStatus_Prepare:
            break;
        case FQCameraVideoStatus_Recording:
            [self p_startRecording];
            break;
        case FQCameraVideoStatus_Stop:
        case FQCameraVideoStatus_Completed:
            [self p_stopRecording];
            break;
        default:
            break;
    }
}

- (void)cameraOperateViewDidChangeFlashlight:(FQCameraOperateView *)operateView succeed:(void (^)(AVCaptureFlashMode))succeed {
    if (!self.activeCamera) {
        return;
    }
    if (!self.activeCamera.hasFlash) {
        NSLog(@"不支持闪光灯");
        return;
    }
    if(!self.activeCamera.flashAvailable) {
        NSLog(@"闪光灯不可用");
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

- (void)cameraOperateViewDidTransformCamera:(FQCameraOperateView *)operateView {
    NSArray<AVCaptureDevice *> *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    if (devices.count <= 1) {
        NSLog(@"当前设备只有一个摄像头");
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
        [videoOutput setSampleBufferDelegate:self queue:dispatch_queue_create("VideoOutputQueue", NULL)];
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

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (self.operateView.videoStatus == FQCameraVideoStatus_Recording) {
        if (_assetWriter) {
            CFRetain(sampleBuffer);
            dispatch_async(_assetWriter.writingQueue, ^{
                if (connection == _videoConnection) {
                    if (!_assetWriter.readyToRecordVideo){
                        [_assetWriter setupAssetWriterVideoInput:CMSampleBufferGetFormatDescription(sampleBuffer)];
                    }
                    if (self.isReadyToWrite){
                        [_assetWriter writeSampleBuffer:sampleBuffer ofType:AVMediaTypeVideo];
                    }
                } else if (connection == _audioConnection) {
                    if (!_assetWriter.readyToRecordAudio){
                        [_assetWriter setupAssetWriterAudioInput:CMSampleBufferGetFormatDescription(sampleBuffer)];
                    }
                    if (self.isReadyToWrite){
                        [_assetWriter writeSampleBuffer:sampleBuffer ofType:AVMediaTypeAudio];
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
            NSLog(@"屏幕朝上平躺");
            break;
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕朝下平躺");
            break;
        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"屏幕向左橫置");
            videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"屏幕向右橫置");
            videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortrait:
            NSLog(@"屏幕直立");
            videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
    }
    
    return videoOrientation;
}

- (void)p_startRecording {
    if (!_assetWriter) {
        _assetWriter = [[FQAssetWriter alloc] init];
    }
    
    [_assetWriter startRecording];
}

- (void)p_stopRecording {
    [_assetWriter stopRecordingWithFinished:^() {
        self.operateView.recordFilePath = _assetWriter.filePath;
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
            NSLog(@"闪光灯模式 %zd 失败: %@", flashMode, error);
        }
    }
}

#pragma mark - Getter

- (FQCameraOperateView *)operateView {
    if (!_operateView) {
        FQCameraOperateView *view = [[FQCameraOperateView alloc] initWithFrame:self.view.bounds];
        view.outputType = self.outputType;
        view.delegate = self;
        _operateView = view;
    }
    return _operateView;
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
