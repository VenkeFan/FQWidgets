//
//  WLAssetWriter.m
//  WeLike
//
//  Created by fan qi on 2018/4/7.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLAssetWriter.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreMotion/CoreMotion.h>

@interface WLAssetWriter ()

@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *assetVideoInput;
@property (nonatomic, strong) AVAssetWriterInput *assetAudioInput;

@property (nonatomic, strong) CMMotionManager *motionManager;
@property(nonatomic, assign) UIDeviceOrientation deviceOrientation;
@property(nonatomic, assign) AVCaptureVideoOrientation videoOrientation;

@property (nonatomic, strong, readwrite) NSURL *filePath;
@property (nonatomic, assign, readwrite) BOOL readyToRecordVideo;
@property (nonatomic, assign, readwrite) BOOL readyToRecordAudio;

@end

@implementation WLAssetWriter

- (instancetype)init {
    if (self = [super init]) {
        _writingQueue = dispatch_queue_create("com.welike.assetwriter.fq", DISPATCH_QUEUE_SERIAL);
        
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 1 / 15.0;
        if (_motionManager.deviceMotionAvailable) {
            __weak typeof(self) weakSelf = self;
            [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                                withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
                                                    [weakSelf performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
                                                }];
        } else {
            _motionManager = nil;
        }
    }
    return self;
}

- (void)dealloc {
    [_motionManager stopDeviceMotionUpdates];
    
    [_assetWriter cancelWriting];
    _assetWriter = nil;
}

#pragma mark - Public

- (void)startRecording {
    [self removeFile];
    dispatch_async(_writingQueue, ^{
        if (!self->_assetWriter) {
            NSError *error;
            self->_assetWriter = [[AVAssetWriter alloc] initWithURL:self.filePath fileType:AVFileTypeMPEG4 error:&error];
            if (error) {
                
            }
        }
    });
}

- (void)stopRecordingWithFinished:(void (^)(void))finished {
    dispatch_async(_writingQueue, ^{
        [self->_assetVideoInput markAsFinished];
        [self->_assetAudioInput markAsFinished];
        [self->_assetWriter finishWritingWithCompletionHandler:^{
            switch (self->_assetWriter.status) {
                case AVAssetWriterStatusCompleted: {
                    self->_readyToRecordVideo = NO;
                    self->_readyToRecordAudio = NO;
                    self->_assetWriter = nil;
                    break;
                }
                case AVAssetWriterStatusFailed: {
                    break;
                }
                case AVAssetWriterStatusCancelled: {
                    
                }
                case AVAssetWriterStatusWriting: {
                    
                }
                default:
                    break;
            }
            
#if DEBUG
            AVURLAsset *urlAsset = [AVURLAsset assetWithURL:self.filePath];
            NSNumber *size;
            [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
            NSLog(@"video size: %f M.", size.floatValue / (1024 * 1024.0));
#endif
            
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
    if (_assetWriter.status == AVAssetWriterStatusUnknown) {
        if ([_assetWriter startWriting]) {
            [_assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        } else {
            
        }
    }
    
    if (_assetWriter.status == AVAssetWriterStatusWriting) {
        if (mediaType == AVMediaTypeVideo) {
            if (!_assetVideoInput.readyForMoreMediaData) {
                return;
            }
            if (![_assetVideoInput appendSampleBuffer:sampleBuffer]) {
            }
        } else if (mediaType == AVMediaTypeAudio) {
            if (!_assetAudioInput.readyForMoreMediaData) {
                return;
            }
            if (![_assetAudioInput appendSampleBuffer:sampleBuffer]) {
            }
        }
    } else {
        
    }
}

- (void)setupAssetWriterVideoInput:(CMFormatDescriptionRef)currentFormatDescription {
    CGFloat bitsPerPixel;
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(currentFormatDescription);
    NSUInteger numPixels = dimensions.width * dimensions.height;
    NSUInteger bitsPerSecond;
    
    if (numPixels < (640 * 480)) {
        bitsPerPixel = 4.05;
    } else {
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
        _assetVideoInput.transform = [self transformFromCurrentVideoOrientationToOrientation:self.referenceOrientation];
        
        if ([_assetWriter canAddInput:_assetVideoInput]) {
            [_assetWriter addInput:_assetVideoInput];
        } else {
            _readyToRecordVideo = NO;
        }
        _readyToRecordVideo = YES;
    } else {
        _readyToRecordVideo = NO;
    }
}

- (void)setupAssetWriterAudioInput:(CMFormatDescriptionRef)currentFormatDescription {
    size_t aclSize = 0;
    const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(currentFormatDescription);
    const AudioChannelLayout *currentChannelLayout = CMAudioFormatDescriptionGetChannelLayout(currentFormatDescription, &aclSize);
    
    NSData *currentChannelLayoutData = nil;
    if (currentChannelLayout && aclSize > 0 ) {
        currentChannelLayoutData = [NSData dataWithBytes:currentChannelLayout length:aclSize];
    } else {
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
        
        if ([_assetWriter canAddInput:_assetAudioInput]) {
            [_assetWriter addInput:_assetAudioInput];
        } else {
            _readyToRecordAudio = NO;
        }
        _readyToRecordAudio = YES;
    } else {
        _readyToRecordAudio = NO;
    }
}

- (void)removeFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.filePath.path]){
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:self.filePath.path error:&error];
        if (!success) {
            
        } else {
            
        }
    }
}

- (void)saveToCameraRollWithFinished:(void (^)(PHAsset *asset))finished {
    if (!self.filePath) {
        return;
    }
    
    if (@available(iOS 9.0, *)) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status ) {
            if (status != PHAuthorizationStatusAuthorized) {
                return;
            }
            
            __block NSString *assetIdentifier = nil;
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCreationRequest *videoRequest = [PHAssetCreationRequest creationRequestForAsset];
                [videoRequest addResourceWithType:PHAssetResourceTypeVideo fileURL:self.filePath options:nil];
                assetIdentifier = videoRequest.placeholderForCreatedAsset.localIdentifier;
                
            } completionHandler:^( BOOL success, NSError * _Nullable error ) {
                if (error) {
                    return;
                }
                if (!assetIdentifier) {
                    return;
                }
                
                PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetIdentifier] options:nil].firstObject;
                if (finished) {
                    finished(asset);
                }
                
            }];
        }];
    } else {
        ALAssetsLibrary *lab = [[ALAssetsLibrary alloc] init];
        [lab writeVideoAtPathToSavedPhotosAlbum:self.filePath
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    if (error) {
                                        return;
                                    }
                                    
                                    if (!assetURL) {
                                        return;
                                    }
                                    
                                    PHAsset *asset = [PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil].firstObject;
                                    if (finished) {
                                        finished(asset);
                                    }
                                }];
    }
}

#pragma mark - Private

- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation {
    CGFloat orientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:orientation];
    CGFloat videoOrientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:self.videoOrientation];
    CGFloat angleOffset;
    if (self.devicePostion == AVCaptureDevicePositionBack) {
        angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
    } else {
        angleOffset = videoOrientationAngleOffset - orientationAngleOffset + M_PI_2;
    }
    CGAffineTransform transform = CGAffineTransformMakeRotation(angleOffset);
    return transform;
}

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

- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    if (fabs(y) >= fabs(x)) {
        if (y >= 0) {
            _deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
            _videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
        } else {
            _deviceOrientation = UIDeviceOrientationPortrait;
            _videoOrientation = AVCaptureVideoOrientationPortrait;
        }
    } else {
        if (x >= 0) {
            _deviceOrientation = UIDeviceOrientationLandscapeRight;
            _videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        } else {
            _deviceOrientation = UIDeviceOrientationLandscapeLeft;
            _videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        }
    }
}

#pragma mark - Getter

- (NSURL *)filePath {
    if (!_filePath) {
        _filePath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"movie_fq.mp4"]];
    }
    return _filePath;
}

@end
