//
//  WLRecordShortVideoController.m
//  welike
//
//  Created by gyb on 2019/1/5.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLRecordShortVideoController.h"
#import "WLAuthorizationHelper.h"
#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>
#import "WLRecordControlView.h"
#import "WLAssetsManager.h"
#import "WLCropVideoViewController.h"

@interface WLRecordShortVideoController () <AliyunIRecorderDelegate, UIGestureRecognizerDelegate>
{
    UIView *previewView;
    AliyunEffectPaster *currentPaster;
    
    UIButton *closeBtn;
    
    
    
    
}

@property (nonatomic, strong) AliyunIRecorder *recorder;

@property (nonatomic, strong) WLRecordControlView *recordControlView;

@end


@implementation WLRecordShortVideoController


- (void)dealloc
{
    [self closeAndClear];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.hidden = YES;
    
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.view.backgroundColor = [UIColor blackColor];
   
     _recordConfig = [WLRecordConfig defaultConfig];
    //清除之前的路径
//    [self p_removeFile:_recordConfig.taskPath];
    [LuuUtils removeFilesInPath:_recordConfig.taskPath];
 
    [self setUI];
    
    [WLAuthorizationHelper requestCameraAuthorizationWithFinished:^(BOOL granted){
        if (granted)
        {
            [WLAuthorizationHelper requestMicrophoneAuthorizationWithFinished:^(BOOL granted){
                if (granted)
                {
                    [self initializeCapture];
                }
                else
                {
                    [self closeBtnClicked];
                }
            }];
        }
        else
        {
            [self closeBtnClicked];
        }
    }];
}

#pragma mark - UI
- (void)setUI
{
     __weak typeof(self) weakSelf = self;
    
    previewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.view addSubview:previewView];
 
    _recordControlView = [[WLRecordControlView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _recordControlView.tapToFocus = ^(CGPoint clickPoint) {
        weakSelf.recorder.focusPoint = clickPoint;
        //TODO:需要关闭美颜
    };
    _recordControlView.clickTransformBtn = ^{
        [weakSelf.recorder switchCameraPosition];
    };
    _recordControlView.clickFlashlightBtn = ^{
        
        AliyunIRecorderTorchMode torchMode = weakSelf.recorder.torchMode;
        if (torchMode == AliyunIRecorderTorchModeOff)
        {
            [weakSelf.recorder switchTorchWithMode:AliyunIRecorderTorchModeOn];
            [weakSelf.recordControlView changeTorchBtn:AliyunIRecorderTorchModeOn];
        }
        else
        {
            [weakSelf.recorder switchTorchWithMode:AliyunIRecorderTorchModeOff];
            [weakSelf.recordControlView changeTorchBtn:AliyunIRecorderTorchModeOff];
        }
    };
    
    _recordControlView.tapRecordBtnUp = ^{
        
        if (!weakSelf.recorder.isRecording) {
            return;
        }
        
        [weakSelf endRecord];
    };
    
    _recordControlView.tapRecordBtnDown = ^{
        
        if (weakSelf.recorder.isRecording)
        {
            return;
        }
        
        int code =  [weakSelf.recorder startRecording];
        if (code == 0)
        {
            //TODO:隐藏界面按钮
            
        }
        else
        {
            //界面按钮不隐藏
            
        }
    };
    
    _recordControlView.tapFinishBtnDown = ^{
      
        NSLog(@"=====完成拍摄");
        
        if ([weakSelf.recorder.clipManager partCount]) {
            //        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [weakSelf.recorder finishRecording];
        }
    };
    
    
    [self.view addSubview:_recordControlView];
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(0, kSystemStatusBarHeight, 44, 44);
    [closeBtn setImage:[AppContext getImageForKey:@"common_close_white"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
}

#pragma mark - record related
- (void)initializeCapture
{
    _recorder = [[AliyunIRecorder alloc] initWithDelegate:self videoSize:_recordConfig.outputSize];
    _recorder.taskPath = _recordConfig.taskPath;
    _recorder.outputPath = _recordConfig.outputPath;
    _recorder.outputType = AliyunIRecorderVideoOutputPixelFormatType420f;
    _recorder.useFaceDetect = _recordConfig.useFaceDetect;
    _recorder.faceDectectSync = _recordConfig.faceDectectSync;
    _recorder.beautifyStatus = _recordConfig.beautifyStatus;
    _recorder.beautifyValue = _recordConfig.beautifyValue;
    _recorder.clipManager.maxDuration = _recordConfig.maxDuration;
    _recorder.clipManager.minDuration = _recordConfig.minDuration;//TODO:最小时间段判断
    _recorder.encodeMode = _recordConfig.encodeMode;
    _recorder.bitrate = _recordConfig.bitrate;
    
    _recorder.cameraRotate = _recordConfig.videoRotate;
    _recorder.backCaptureSessionPreset = _recordConfig.backCaptureSessionPreset;//TODO:分辨率设备区分
    _recorder.frontCaptureSessionPreset = _recordConfig.frontCaptureSessionPreset;//TODO:分辨率设备区分
    _recorder.preview = previewView;
    [_recorder startPreview];
}

- (void)endRecord{  //TODO:结束录制
    if (!_recorder.isRecording) {
        return;
    }
//    _startTime = 0;
 
   [_recorder stopRecording];
    
    //    _progressView.showBlink = NO;
   // _dele .enabled = YES;
    
    
    //   self.countdownButton.enabled = YES;
    //    if (self.progressView.videoCount) {
    //        self.deleteButton.hidden = NO;
    //    }
}

#pragma mark - Event
- (void)closeBtnClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 关闭和清理
- (void)closeAndClear {
    [LuuUtils removeFilesInPath:_recordConfig.taskPath];
    [_recorder stopRecording];
    [_recorder stopPreview];
    [_recorder destroyRecorder];
    _recorder = nil;
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

//- (void)p_removeFile:(NSString *)filePath {
//
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if ([fileManager fileExistsAtPath:filePath]){
//        BOOL result = [fileManager removeItemAtPath:filePath error:nil];
//        if (result)
//        {
//             //NSLog(@"移除文件成功1");
//             [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
//        }
//    }
//}

#pragma mark - AliyunIRecorderDelegate
- (void)recorderDeviceAuthorization:(AliyunIRecorderDeviceAuthor)status {
    
}

- (void)recorderDidStopRecording {
    
    NSLog(@"停止录制了");
   
}

- (void)recorderDidFinishRecording {
    NSLog(@"完成录制了");
    //将视频存入相册,等待发布或者编辑
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __weak typeof(self) weakSelf = self;
        // [self p_removeFile:weakSelf.recordConfig.outputPath];
        //跳转页面
        WLCropVideoViewController *cut = [[WLCropVideoViewController alloc] init];
        cut.urlStr = weakSelf.recordConfig.outputPath;
        cut.isLightStatusBar = YES;
        cut.delegate = self->_target;
//        cut.seconds = CMTimeGetSeconds(_av);
        [weakSelf.navigationController pushViewController:cut animated:YES];
        
    });
    
    
//    [WLAssetsManager saveVideoToCameraRollWithFilePath:_recordConfig.outputPath
//                                              finished:^(PHAsset *asset) {
//
//                                                    dispatch_async(dispatch_get_main_queue(), ^{
//
//                                                        __weak typeof(self) weakSelf = self;
//                                                        // [self p_removeFile:weakSelf.recordConfig.outputPath];
//                                                        //跳转页面
//                                                        WLCropVideoViewController *cut = [[WLCropVideoViewController alloc] init];
//                                                        cut.urlStr = weakSelf.recordConfig.outputPath;
//                                                        cut.isLightStatusBar = YES;
//                                                        [weakSelf.navigationController pushViewController:cut animated:YES];
//
//                                                      });
//                                              }];
}

- (void)recorderVideoDuration:(CGFloat)duration {
     NSLog(@"录了%f秒",duration);
    dispatch_async(dispatch_get_main_queue(), ^{
         //__weak typeof(self) weakSelf = self;
        //NSLog(@"录了%f秒",duration);
        //CGFloat percent = duration / weakSelf.recorder.clipManager.maxDuration;
       // [self.operateView recordingPercent:percent];
       // self.recordingDuration = duration;
    });
}


@end
