//
//  FQAssetWriter.m
//  WeLike
//
//  Created by fan qi on 2018/4/7.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQAssetWriter.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface FQAssetWriter ()

@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *assetVideoInput;
@property (nonatomic, strong) AVAssetWriterInput *assetAudioInput;

@property (nonatomic, strong, readwrite) NSURL *filePath;
@property (nonatomic, assign, readwrite) BOOL readyToRecordVideo;
@property (nonatomic, assign, readwrite) BOOL readyToRecordAudio;

@end

@implementation FQAssetWriter

- (instancetype)init {
    if (self = [super init]) {
        _writingQueue = dispatch_queue_create("com.welike.assetwriter.fq", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc {
    NSLog(@"FQAssetWriter dealloc");
    [_assetWriter cancelWriting];
    _assetWriter = nil;
}

#pragma mark - Public

- (void)startRecording {
    [self removeFile];
    dispatch_async(_writingQueue, ^{
        if (!_assetWriter) {
            NSError *error;
            _assetWriter = [[AVAssetWriter alloc] initWithURL:self.filePath fileType:AVFileTypeMPEG4 error:&error];
            if (error) {
                NSLog(@"FQAssetWriter 初始化失败: %@", error);
            }
        }
    });
}

- (void)stopRecordingWithFinished:(void (^)(void))finished {
    NSLog(@"正在停止写入");
    dispatch_async(_writingQueue, ^{
        [_assetWriter finishWritingWithCompletionHandler:^{
            NSLog(@"停止写入");
            switch (_assetWriter.status) {
                case AVAssetWriterStatusCompleted: {
                    _readyToRecordVideo = NO;
                    _readyToRecordAudio = NO;
                    _assetWriter = nil;
                    break;
                }
                case AVAssetWriterStatusFailed: {
                    NSLog(@"%@", _assetWriter.error);
                    break;
                }
                case AVAssetWriterStatusCancelled: {
                    
                }
                case AVAssetWriterStatusWriting: {
                    
                }
                default:
                    break;
            }
            
            AVURLAsset *urlAsset = [AVURLAsset assetWithURL:self.filePath];
            NSNumber *size;
            [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
            NSLog(@"录制的视频大小: %f M.", size.floatValue / (1024 * 1024.0));
            
            if (finished) {
                finished();
            }
        }];
    });
}

- (void)cancelRecording {
    [_assetWriter cancelWriting];
}

- (void)writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType {
    if (_assetWriter.status == AVAssetWriterStatusUnknown){
        if ([_assetWriter startWriting]){
            NSLog(@"开始写入");
            [_assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        } else {
            NSLog(@"开始写入就错误: %@", _assetWriter.error);
        }
    }
    
    if (_assetWriter.status == AVAssetWriterStatusWriting){
        if (mediaType == AVMediaTypeVideo){
            if (!_assetVideoInput.readyForMoreMediaData){
                return;
            }
            if (![_assetVideoInput appendSampleBuffer:sampleBuffer]){
                NSLog(@"写入中途错误: %@", _assetWriter.error);
            }
        } else if (mediaType == AVMediaTypeAudio){
            if (!_assetAudioInput.readyForMoreMediaData){
                return;
            }
            if (![_assetAudioInput appendSampleBuffer:sampleBuffer]){
                NSLog(@"写入中途错误: %@", _assetWriter.error);
            }
        }
    } else {
        NSLog(@"写入失败");
    }
}

- (void)setupAssetWriterVideoInput:(CMFormatDescriptionRef)currentFormatDescription {
    CGFloat bitsPerPixel;
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(currentFormatDescription);
    NSUInteger numPixels = dimensions.width * dimensions.height;
    NSUInteger bitsPerSecond;
    
    if (numPixels < (640 * 480)){
        bitsPerPixel = 4.05;
    } else{
        bitsPerPixel = 11.4;
    }
    
    bitsPerSecond = numPixels * bitsPerPixel;
    NSDictionary *videoCompressionSettings = @{AVVideoCodecKey: AVVideoCodecH264,
                                               AVVideoWidthKey: [NSNumber numberWithInteger:dimensions.width],
                                               AVVideoHeightKey: [NSNumber numberWithInteger:dimensions.height],
                                               AVVideoCompressionPropertiesKey:@{AVVideoAverageBitRateKey:[NSNumber numberWithInteger:bitsPerSecond],
                                                                                 AVVideoMaxKeyFrameIntervalKey:[NSNumber numberWithInteger:30]}
                                               };
    if ([_assetWriter canApplyOutputSettings:videoCompressionSettings forMediaType:AVMediaTypeVideo]) {
        _assetVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
        _assetVideoInput.expectsMediaDataInRealTime = YES;
//        _assetVideoInput.transform = [self transformFromCurrentVideoOrientationToOrientation:_referenceOrientation];
        
        if ([_assetWriter canAddInput:_assetVideoInput]) {
            [_assetWriter addInput:_assetVideoInput];
        } else {
            _readyToRecordVideo = NO;
            NSLog(@"AssetWriter add VideoInput error");
        }
        _readyToRecordVideo = YES;
    } else {
        _readyToRecordVideo = NO;
        NSLog(@"AssetWriter add VideoInput error");
    }
}

- (void)setupAssetWriterAudioInput:(CMFormatDescriptionRef)currentFormatDescription {
    size_t aclSize = 0;
    const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(currentFormatDescription);
    const AudioChannelLayout *currentChannelLayout = CMAudioFormatDescriptionGetChannelLayout(currentFormatDescription, &aclSize);
    
    NSData *currentChannelLayoutData = nil;
    if (currentChannelLayout && aclSize > 0 ){
        currentChannelLayoutData = [NSData dataWithBytes:currentChannelLayout length:aclSize];
    }
    else{
        currentChannelLayoutData = [NSData data];
    }
    
    NSDictionary *audioCompressionSettings = @{AVFormatIDKey : [NSNumber numberWithInteger:kAudioFormatMPEG4AAC],
                                               AVSampleRateKey : [NSNumber numberWithFloat:currentASBD->mSampleRate],
                                               AVEncoderBitRatePerChannelKey : [NSNumber numberWithInt:64000],
                                               AVNumberOfChannelsKey : [NSNumber numberWithInteger:currentASBD->mChannelsPerFrame],
                                               AVChannelLayoutKey : currentChannelLayoutData};
    
    if ([_assetWriter canApplyOutputSettings:audioCompressionSettings forMediaType:AVMediaTypeAudio]) {
        _assetAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioCompressionSettings];
        _assetAudioInput.expectsMediaDataInRealTime = YES;
        
        if ([_assetWriter canAddInput:_assetAudioInput]){
            [_assetWriter addInput:_assetAudioInput];
        } else{
            _readyToRecordAudio = NO;
            NSLog(@"AssetWriter add AudioInput error");
        }
        _readyToRecordAudio = YES;
    } else {
        _readyToRecordAudio = NO;
        NSLog(@"AssetWriter add AudioInput error");
    }
}

- (void)removeFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.filePath.path]){
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:self.filePath.path error:&error];
        if (!success){
            NSLog(@"%@", error);
        } else {
            NSLog(@"删除视频文件成功");
        }
    }
}

- (void)saveToCameraRoll {
    if (!self.filePath) {
        NSLog(@"文件路径错误");
        return;
    }
    NSLog(@"开始存入相册");
    
    if (kiOS9Later) {
        [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
            if (status != PHAuthorizationStatusAuthorized) {
                return;
            }
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCreationRequest *videoRequest = [PHAssetCreationRequest creationRequestForAsset];
                [videoRequest addResourceWithType:PHAssetResourceTypeVideo fileURL:self.filePath options:nil];
            } completionHandler:^( BOOL success, NSError * _Nullable error ) {
                if (error) {
                    NSLog(@"存入相册错误: %@", error);
                } else {
                    [FQProgressHUDHelper showWithMessage:@"存入相册成功"];
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                });
            }];
        }];
    } else {
        ALAssetsLibrary *lab = [[ALAssetsLibrary alloc] init];
        [lab writeVideoAtPathToSavedPhotosAlbum:self.filePath
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    if (error) {
                                        NSLog(@"存入相册错误: %@", error);
                                    } else {
                                        [FQProgressHUDHelper showWithMessage:@"存入相册成功"];
                                    }
                                    dispatch_sync(dispatch_get_main_queue(), ^{
                                        
                                    });
                                }];
    }
}

#pragma mark - Private

// 旋转视频方向函数实现
//-  (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation {
//    CGFloat orientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:orientation];
//    CGFloat videoOrientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:self.motionManager.videoOrientation];
//    CGFloat angleOffset;
//        if (_activeCamera.position == AVCaptureDevicePositionBack) {
//            angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
//        } else {
//            angleOffset = videoOrientationAngleOffset - orientationAngleOffset + M_PI_2;
//        }
//    CGAffineTransform transform = CGAffineTransformMakeRotation(angleOffset);
//    return transform;
//}

- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation {
    CGFloat angle = 0.0;
    switch (orientation) {
        case AVCaptureVideoOrientationPortrait:
            angle = 0.0;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        default:
            break;
    }
    return angle;
}

#pragma mark - Getter

- (NSURL *)filePath {
    if (!_filePath) {
        _filePath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"movie_fq.mp4"]];
    }
    return _filePath;
}

@end
