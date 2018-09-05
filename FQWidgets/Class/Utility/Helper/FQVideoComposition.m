//
//  FQVideoComposition.m
//  FQWidgets
//
//  Created by fan qi on 2018/8/29.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQVideoComposition.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation FQVideoComposition

- (void)composeVideo:(AVAsset *)firstVideoAsset secondVideoAsset:(AVAsset *)secondVideoAsset {
    if (!firstVideoAsset) {
        return;
    }
    if (!secondVideoAsset) {
        return;
    }
    
    // ----------- Creating the Composition
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // ----------- Adding the Assets
    AVAssetTrack *firstVideoAssetTrack = [[firstVideoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVAssetTrack *secondVideoAssetTrack = [[secondVideoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVAssetTrack *audioTrack = [[secondVideoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration)
                                   ofTrack:firstVideoAssetTrack
                                    atTime:kCMTimeZero
                                     error:nil];
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondVideoAssetTrack.timeRange.duration)
                                   ofTrack:secondVideoAssetTrack
                                    atTime:firstVideoAssetTrack.timeRange.duration
                                     error:nil];
    [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstVideoAssetTrack.timeRange.duration, secondVideoAssetTrack.timeRange.duration))
                                   ofTrack:audioTrack
                                    atTime:kCMTimeZero
                                     error:nil];
    
    // ----------- Checking the Video Orientations
    BOOL isFirstVideoAssetPortrait = NO;
    CGAffineTransform firstTransform = firstVideoAssetTrack.preferredTransform;
    if (firstTransform.a == 0 && firstTransform.d == 0 && (firstTransform.b == 1.0 || firstTransform.b == -1.0) && (firstTransform.c == 1.0 || firstTransform.c == -1.0)) {
        isFirstVideoAssetPortrait = YES;
    }
    
    BOOL isSecondVideoAssetPortrait = NO;
    CGAffineTransform secondTransform = secondVideoAssetTrack.preferredTransform;
    if (secondTransform.a == 0 && secondTransform.d == 0 && (secondTransform.b == 1.0 || secondTransform.b == -1.0) && (secondTransform.c == 1.0 || secondTransform.c == -1.0)) {
        isSecondVideoAssetPortrait = YES;
    }
    
    if ((isFirstVideoAssetPortrait && !isSecondVideoAssetPortrait)
        || (!isFirstVideoAssetPortrait && isSecondVideoAssetPortrait)) {
        UIAlertView *incompatibleVideoOrientationAlert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Cannot combine a video shot in portrait mode with a video shot in landscape mode." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [incompatibleVideoOrientationAlert show];
        return;
    }
    
    // ----------- Applying the Video Composition Layer Instructions
    AVMutableVideoCompositionInstruction *firstVideoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    // Set the time range of the first instruction to span the duration of the first video track.
    firstVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration);
    
    AVMutableVideoCompositionInstruction * secondVideoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    // Set the time range of the second instruction to span the duration of the second video track.
    secondVideoCompositionInstruction.timeRange = CMTimeRangeMake(firstVideoAssetTrack.timeRange.duration, CMTimeAdd(firstVideoAssetTrack.timeRange.duration, secondVideoAssetTrack.timeRange.duration));
    
    AVMutableVideoCompositionLayerInstruction *firstVideoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    // Set the transform of the first layer instruction to the preferred transform of the first video track.
    [firstVideoLayerInstruction setTransform:firstTransform atTime:kCMTimeZero];
    
    AVMutableVideoCompositionLayerInstruction *secondVideoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    // Set the transform of the second layer instruction to the preferred transform of the second video track.
    [secondVideoLayerInstruction setTransform:secondTransform atTime:firstVideoAssetTrack.timeRange.duration];
    
    firstVideoCompositionInstruction.layerInstructions = @[firstVideoLayerInstruction];
    secondVideoCompositionInstruction.layerInstructions = @[secondVideoLayerInstruction];
    
    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
    mutableVideoComposition.instructions = @[firstVideoCompositionInstruction, secondVideoCompositionInstruction];
    
    // ----------- Setting the Render Size and Frame Duration
    CGSize naturalSizeFirst, naturalSizeSecond;
    // If the first video asset was shot in portrait mode, then so was the second one if we made it here.
    if (isFirstVideoAssetPortrait) {
        // Invert the width and height for the video tracks to ensure that they display properly.
        naturalSizeFirst = CGSizeMake(firstVideoAssetTrack.naturalSize.height, firstVideoAssetTrack.naturalSize.width);
        naturalSizeSecond = CGSizeMake(secondVideoAssetTrack.naturalSize.height, secondVideoAssetTrack.naturalSize.width);
    } else {
        // If the videos weren't shot in portrait mode, we can just use their natural sizes.
        naturalSizeFirst = firstVideoAssetTrack.naturalSize;
        naturalSizeSecond = secondVideoAssetTrack.naturalSize;
    }
    float renderWidth, renderHeight;
    // Set the renderWidth and renderHeight to the max of the two videos widths and heights.
    if (naturalSizeFirst.width > naturalSizeSecond.width) {
        renderWidth = naturalSizeFirst.width;
    } else {
        renderWidth = naturalSizeSecond.width;
    }
    if (naturalSizeFirst.height > naturalSizeSecond.height) {
        renderHeight = naturalSizeFirst.height;
    } else {
        renderHeight = naturalSizeSecond.height;
    }
    mutableVideoComposition.renderSize = CGSizeMake(renderWidth, renderHeight);
    // Set the frame duration to an appropriate value (i.e. 30 frames per second for video).
    mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
    
    // ----------- Exporting the Composition and Saving it to the Camera Roll
    [self exportComposition:mutableComposition
           videoComposition:mutableVideoComposition];
}

- (void)composeVideo:(AVAsset *)videoAsset audio:(AVAsset *)audioAsset {
    if (!videoAsset) {
        return;
    }
    if (!audioAsset) {
        return;
    }
    
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVAssetTrack *videoTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    AVAssetTrack *audioTrack = [audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration)
                                   ofTrack:videoTrack
                                    atTime:kCMTimeZero
                                     error:nil];
    [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration)
                                   ofTrack:audioTrack
                                    atTime:kCMTimeZero
                                     error:nil];
    
    AVMutableVideoCompositionInstruction *videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    videoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration);
    
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    [videoLayerInstruction setTransform:videoTrack.preferredTransform atTime:kCMTimeZero];
    [videoLayerInstruction setOpacityRampFromStartOpacity:1.0 toEndOpacity:0.0 timeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration)];
    
    videoCompositionInstruction.layerInstructions = @[videoLayerInstruction];
    
    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
    mutableVideoComposition.instructions = @[videoCompositionInstruction];
    mutableVideoComposition.renderSize = videoTrack.naturalSize;
    mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
    
    [self exportComposition:mutableComposition
           videoComposition:mutableVideoComposition];
}

- (void)composeVideo:(AVAsset *)videoAsset image:(UIImage *)image {
    if (!videoAsset) {
        return;
    }
    if (!image) {
        return;
    }
    
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVAssetTrack *videoTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    AVAssetTrack *audioTrack = [videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration)
                                   ofTrack:videoTrack
                                    atTime:kCMTimeZero
                                     error:nil];
    [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration)
                                   ofTrack:audioTrack
                                    atTime:kCMTimeZero
                                     error:nil];
    
    AVMutableVideoCompositionInstruction *videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    videoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration);
    
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    [videoLayerInstruction setTransform:videoTrack.preferredTransform atTime:kCMTimeZero];
    
    videoCompositionInstruction.layerInstructions = @[videoLayerInstruction];
    
    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
    mutableVideoComposition.instructions = @[videoCompositionInstruction];
    mutableVideoComposition.renderSize = videoTrack.naturalSize;
    mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
    
    {
        // add watermark
        CALayer *waterLayer = [CALayer layer];
        waterLayer.frame = CGRectMake(0, 0, 50, 50);
        waterLayer.contents = (__bridge id)image.CGImage;
        
        {
            CABasicAnimation *animation = [CABasicAnimation animation];
            animation.keyPath = @"opacity";
            animation.duration = 0.7;
            animation.fromValue = @(0.0);
            animation.toValue = @(1.0);
            animation.autoreverses = YES;
            animation.repeatCount = HUGE_VALF;
            animation.removedOnCompletion = NO;
            animation.beginTime = AVCoreAnimationBeginTimeAtZero;
            [waterLayer addAnimation:animation forKey:nil];
        }
        
        CALayer *parentLayer = [CALayer layer];
        CALayer *videoLayer = [CALayer layer];
        
        parentLayer.frame = CGRectMake(0, 0, mutableVideoComposition.renderSize.width, mutableVideoComposition.renderSize.height);
        videoLayer.frame = CGRectMake(0, 0, mutableVideoComposition.renderSize.width, mutableVideoComposition.renderSize.height);
        [parentLayer addSublayer:videoLayer];
        
        waterLayer.position = CGPointMake(mutableVideoComposition.renderSize.width/2, mutableVideoComposition.renderSize.height/4);
        [parentLayer addSublayer:waterLayer];
        
        mutableVideoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    }
    
    [self exportComposition:mutableComposition
           videoComposition:mutableVideoComposition];
}

- (void)composeVideo:(AVAsset *)videoAsset gifPath:(NSString *)gifPath {
    if (!videoAsset) {
        return;
    }
    if (gifPath.length == 0) {
        return;
    }
    
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVAssetTrack *videoTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    AVAssetTrack *audioTrack = [videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration)
                                   ofTrack:videoTrack
                                    atTime:kCMTimeZero
                                     error:nil];
    [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration)
                                   ofTrack:audioTrack
                                    atTime:kCMTimeZero
                                     error:nil];
    
    AVMutableVideoCompositionInstruction *videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    videoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration);
    
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    [videoLayerInstruction setTransform:videoTrack.preferredTransform atTime:kCMTimeZero];
    
    videoCompositionInstruction.layerInstructions = @[videoLayerInstruction];
    
    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
    mutableVideoComposition.instructions = @[videoCompositionInstruction];
    mutableVideoComposition.renderSize = videoTrack.naturalSize;
    mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
    
    // add gif watermark
    [self applyVideoEffectsToComposition:mutableVideoComposition
                                filePath:gifPath
                                    size:mutableVideoComposition.renderSize];
    
    [self exportComposition:mutableComposition
           videoComposition:mutableVideoComposition];
}

- (void)composeVideo:(AVAsset *)videoAsset filterName:(NSString *)filterName {
    if (!videoAsset) {
        return;
    }
    CIFilter *filter = [CIFilter filterWithName:filterName];
    if (!filter) {
        return;
    }
    
    // 这种加滤镜的方法cpu高，而且视频过长时（1分钟左右）就会导出失败
    TODO("-----------考虑下其他的方式?");
    AVMutableVideoComposition *mutableVideoComposition =
    [AVMutableVideoComposition videoCompositionWithAsset:videoAsset applyingCIFiltersWithHandler:^(AVAsynchronousCIImageFilteringRequest * _Nonnull request) {
        CIImage *image = request.sourceImage.imageByClampingToExtent;
        [filter setValue:image forKey:kCIInputImageKey];
        [filter setValue:@(0.8) forKey:kCIInputIntensityKey];
        
        CIImage *output = [filter.outputImage imageByCroppingToRect:request.sourceImage.extent];
        
        [request finishWithImage:output context:nil];
    }];
    
    [self exportComposition:videoAsset
           videoComposition:mutableVideoComposition];
}

- (void)composeAudio:(AVAsset *)firstAudioAsset secondAudioAsset:(AVAsset *)secondAudioAsset {
    
}

#pragma mark - Private

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition
                              filePath:(NSString *)filePath
                                  size:(CGSize)size {
    
    // - set up the parent layer
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    
    size.width = 100;
    size.height = 100;
    
    // - set up the overlay
    CALayer *waterLayer = [CALayer layer];
    waterLayer.frame = CGRectMake(0, 100, size.width, size.height);
    
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    [self startGifAnimationWithURL:fileUrl inLayer:waterLayer];
    
    [parentLayer addSublayer:waterLayer];
    
    // - apply magic
    composition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
}

- (void)startGifAnimationWithURL:(NSURL *)url inLayer:(CALayer *)layer {
    CAKeyframeAnimation * animation = [self animationForGifWithURL:url];
    [layer addAnimation:animation forKey:@"contents"];
}

- (CAKeyframeAnimation *)animationForGifWithURL:(NSURL *)url {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    
    NSMutableArray * frames = [NSMutableArray new];
    NSMutableArray *delayTimes = [NSMutableArray new];
    
    CGFloat totalTime = 0.0;
    CGFloat gifWidth;
    CGFloat gifHeight;
    
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    
    // get frame count
    size_t frameCount = CGImageSourceGetCount(gifSource);
    for (size_t i = 0; i < frameCount; ++i) {
        // get each frame
        CGImageRef frame = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        [frames addObject:(__bridge id)frame];
        CGImageRelease(frame);
        
        // get gif info with each frame
        NSDictionary *dict = (NSDictionary*)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(gifSource, i, NULL));
        NSLog(@"kCGImagePropertyGIFDictionary %@", [dict valueForKey:(NSString*)kCGImagePropertyGIFDictionary]);
        
        // get gif size
        gifWidth = [[dict valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
        gifHeight = [[dict valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
        
        // kCGImagePropertyGIFDictionary中kCGImagePropertyGIFDelayTime，kCGImagePropertyGIFUnclampedDelayTime值是一样的
        NSDictionary *gifDict = [dict valueForKey:(NSString*)kCGImagePropertyGIFDictionary];
        [delayTimes addObject:[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime]];
        
        totalTime = totalTime + [[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime] floatValue];
    }
    
    if (gifSource) {
        CFRelease(gifSource);
    }
    
    NSMutableArray *times = [NSMutableArray arrayWithCapacity:3];
    CGFloat currentTime = 0;
    NSInteger count = delayTimes.count;
    for (int i = 0; i < count; ++i) {
        [times addObject:[NSNumber numberWithFloat:(currentTime / totalTime)]];
        currentTime += [[delayTimes objectAtIndex:i] floatValue];
    }
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i < count; ++i) {
        [images addObject:[frames objectAtIndex:i]];
    }
    
    animation.keyTimes = times;
    animation.values = images;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = totalTime;
    animation.repeatCount = HUGE_VALF;
    animation.beginTime = AVCoreAnimationBeginTimeAtZero;
    animation.removedOnCompletion = NO;
    
    return animation;
}

- (void)exportComposition:(AVAsset *)mutableComposition
         videoComposition:(AVMutableVideoComposition *)videoComposition {
    if (!mutableComposition) {
        return;
    }
    if (!videoComposition) {
        return;
    }
    
    // Create a static date formatter so we only have to initialize it once.
    static NSDateFormatter *kDateFormatter;
    if (!kDateFormatter) {
        kDateFormatter = [[NSDateFormatter alloc] init];
        kDateFormatter.dateStyle = NSDateFormatterMediumStyle;
        kDateFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    // Create the export session with the composition and set the preset to the highest quality.
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mutableComposition presetName:AVAssetExportPresetHighestQuality];
    // Set the desired output URL for the file created by the export process.
    exporter.outputURL = [[[[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:@YES error:nil] URLByAppendingPathComponent:[kDateFormatter stringFromDate:[NSDate date]]] URLByAppendingPathExtension:CFBridgingRelease(UTTypeCopyPreferredTagWithClass((CFStringRef)AVFileTypeQuickTimeMovie, kUTTagClassFilenameExtension))];
    // Set the output file type to be a QuickTime movie.
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = videoComposition;
    // Asynchronously export the composition to a video file and save this file to the camera roll once export completes.
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (exporter.status == AVAssetExportSessionStatusCompleted) {
                ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
                if ([assetsLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:exporter.outputURL]) {
                    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:exporter.outputURL
                                                      completionBlock:^(NSURL *assetURL, NSError *error) {
                                                          if (error) {
                                                              UIAlertView *incompatibleVideoOrientationAlert = [[UIAlertView alloc] initWithTitle:@"Error!" message:[NSString stringWithFormat:@"%@", exporter.error] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                                                              [incompatibleVideoOrientationAlert show];
                                                          } else {
                                                              UIAlertView *incompatibleVideoOrientationAlert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                                                              [incompatibleVideoOrientationAlert show];
                                                          }
                                                      }];
                }
            } else if (exporter.status == AVAssetExportSessionStatusFailed) {
                UIAlertView *incompatibleVideoOrientationAlert = [[UIAlertView alloc] initWithTitle:@"Error!" message:[NSString stringWithFormat:@"%@ \n %@ \n %@", exporter.error, exporter.outputURL, mutableComposition] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [incompatibleVideoOrientationAlert show];
            }
        });
    }];
}

@end
