//
//  FQVideoExportSession.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/18.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQVideoExportSession.h"
#import <VideoToolbox/VideoToolbox.h>

NSString * const FQVideoExportSessionStatusMapping[] = {
    [AVAssetExportSessionStatusUnknown]         = @"未知的转码状态",
    [AVAssetExportSessionStatusWaiting]         = @"准备转码",
    [AVAssetExportSessionStatusExporting]       = @"正在转码",
    [AVAssetExportSessionStatusCompleted]       = @"完成转码",
    [AVAssetExportSessionStatusCancelled]       = @"取消转码",
    [AVAssetExportSessionStatusFailed]          = @"转码失败"
};

@interface FQVideoExportSession ()

@property (nonatomic, strong) NSURL *filePath;

@property (nonatomic, strong) dispatch_queue_t mainSerializationQueue;
@property (nonatomic, strong) dispatch_queue_t rwAudioSerializationQueue;
@property (nonatomic, strong) dispatch_queue_t rwVideoSerializationQueue;
@property (nonatomic, assign) BOOL cancelled;
@property (nonatomic, strong) AVAssetReader *assetReader;
@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetReaderTrackOutput *assetReaderAudioOutput;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterAudioInput;
@property (nonatomic, strong) AVAssetReaderTrackOutput *assetReaderVideoOutput;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterVideoInput;
@property (nonatomic, strong) dispatch_group_t dispatchGroup;
@property (nonatomic, assign) BOOL audioFinished;
@property (nonatomic, assign) BOOL videoFinished;

@end

@implementation FQVideoExportSession

#pragma mark - Public

- (void)compressWithAsset:(AVAsset *)asset {
    if (!asset) {
        return;
    }
    _asset = asset;
    
    if (![self removeFile]) {
        NSLog(@"路径文件已存在且删除该文件失败");
        return;
    }
    
//    [self sessionCompress:asset];
    [self readerCompress:asset];
}

#pragma mark - AVAssetExportSession

- (void)sessionCompress:(AVAsset *)asset {
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
        exportSession.outputURL = self.filePath;
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        if ([exportSession.supportedFileTypes containsObject:AVFileTypeMPEG4]) {
            exportSession.outputFileType = AVFileTypeMPEG4;
            
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                NSLog(@"AVAssetExportSession: %@", FQVideoExportSessionStatusMapping[exportSession.status]);
                
                switch (exportSession.status) {
                    case AVAssetExportSessionStatusUnknown:
                        break;
                    case AVAssetExportSessionStatusWaiting:
                        break;
                    case AVAssetExportSessionStatusExporting:
                        break;
                    case AVAssetExportSessionStatusCompleted:
                        break;
                    case AVAssetExportSessionStatusCancelled:
                        break;
                    case AVAssetExportSessionStatusFailed:
                        break;
                }
            }];
        } else {
            NSLog(@"不支持 AVFileTypeMPEG4 转码格式");
        }
    } else {
        NSLog(@"不支持 AVAssetExportPresetMediumQuality 分辨率");
    }
}

#pragma mark - AVAssetReader & AVAssetWriter

- (void)readerCompress:(AVAsset *)asset {
    NSString *serializationQueueDescription = [NSString stringWithFormat:@"%@ serialization queue", self];
    
    // Create the main serialization queue.
    self.mainSerializationQueue = dispatch_queue_create([serializationQueueDescription UTF8String], NULL);
    NSString *rwAudioSerializationQueueDescription = [NSString stringWithFormat:@"%@ rw audio serialization queue", self];
    
    // Create the serialization queue to use for reading and writing the audio data.
    self.rwAudioSerializationQueue = dispatch_queue_create([rwAudioSerializationQueueDescription UTF8String], NULL);
    NSString *rwVideoSerializationQueueDescription = [NSString stringWithFormat:@"%@ rw video serialization queue", self];
    
    // Create the serialization queue to use for reading and writing the video data.
    self.rwVideoSerializationQueue = dispatch_queue_create([rwVideoSerializationQueueDescription UTF8String], NULL);
    
    if (!asset) {
        return;
    }
    _asset = asset;
    _cancelled = NO;
    
    if (![self removeFile]) {
        NSLog(@"路径文件已存在且删除该文件失败");
        return;
    }
    
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        NSLog(@"loadValuesAsynchronouslyForKeys: %@", [NSThread currentThread]);
        dispatch_async(self.mainSerializationQueue, ^{
            if (self.cancelled) {
                return;
            }
            BOOL success = YES;
            NSError *localError = nil;
            // Check for success of loading the assets tracks.
            success = ([self.asset statusOfValueForKey:@"tracks" error:&localError] == AVKeyValueStatusLoaded);

            if (success) {
                success = [self setupAssetReaderAndAssetWriter:&localError];
            }

            if (success) {
                success = [self startAssetReaderAndWriter:&localError];
            }

            if (!success) {
                [self readingAndWritingDidFinishSuccessfully:success withError:localError];
            }
        });
    }];
    
    {
//        dispatch_async(self.mainSerializationQueue, ^{
//            if (self.cancelled) {
//                return;
//            }
//            BOOL success = YES;
//            NSError *localError = nil;
//            // Check for success of loading the assets tracks.
//            success = [self setupAssetReaderAndAssetWriter:&localError];
//
//            if (success) {
//                success = [self startAssetReaderAndWriter:&localError];
//            }
//
//            if (!success) {
//                [self readingAndWritingDidFinishSuccessfully:success withError:localError];
//            }
//        });
    }
}

- (BOOL)setupAssetReaderAndAssetWriter:(NSError **)outError {
    // Create and initialize the asset reader.
    self.assetReader = [[AVAssetReader alloc] initWithAsset:self.asset error:outError];
    BOOL success = (self.assetReader != nil);
    if (success)
    {
        // If the asset reader was successfully initialized, do the same for the asset writer.
        self.assetWriter = [[AVAssetWriter alloc] initWithURL:self.filePath fileType:AVFileTypeQuickTimeMovie error:outError];
        success = (self.assetWriter != nil);
    }
    
    if (success)
    {
        // If the reader and writer were successfully initialized, grab the audio and video asset tracks that will be used.
        AVAssetTrack *assetAudioTrack = nil, *assetVideoTrack = nil;
        NSArray *audioTracks = [self.asset tracksWithMediaType:AVMediaTypeAudio];
        if ([audioTracks count] > 0)
            assetAudioTrack = [audioTracks objectAtIndex:0];
        NSArray *videoTracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
        if ([videoTracks count] > 0)
            assetVideoTrack = [videoTracks objectAtIndex:0];
        
        if (assetAudioTrack)
        {
            // If there is an audio track to read, set the decompression settings to Linear PCM and create the asset reader output.
            NSDictionary *decompressionAudioSettings = @{ AVFormatIDKey : [NSNumber numberWithUnsignedInt:kAudioFormatLinearPCM] };
            self.assetReaderAudioOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:assetAudioTrack outputSettings:decompressionAudioSettings];
            self.assetReaderAudioOutput.alwaysCopiesSampleData = NO;
            [self.assetReader addOutput:self.assetReaderAudioOutput];
            
            
            // Then, set the compression settings to 128kbps AAC and create the asset writer input.
//            AudioChannelLayout stereoChannelLayout = {
//                .mChannelLayoutTag = kAudioChannelLayoutTag_Stereo,
//                .mChannelBitmap = 0,
//                .mNumberChannelDescriptions = 0
//            };
//            NSData *channelLayoutAsData = [NSData dataWithBytes:&stereoChannelLayout length:offsetof(AudioChannelLayout, mChannelDescriptions)];
//            NSDictionary *compressionAudioSettings = @{
//                                                       AVFormatIDKey         : [NSNumber numberWithUnsignedInt:kAudioFormatMPEG4AAC],
//                                                       AVEncoderBitRateKey   : [NSNumber numberWithInteger:128000],
//                                                       AVSampleRateKey       : [NSNumber numberWithInteger:44100],
//                                                       AVChannelLayoutKey    : channelLayoutAsData,
//                                                       AVNumberOfChannelsKey : [NSNumber numberWithUnsignedInteger:2]
//                                                       };
            size_t aclSize = 0;
            CMFormatDescriptionRef currentFormatDescription = (__bridge CMFormatDescriptionRef)assetAudioTrack.formatDescriptions.firstObject;
            const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(currentFormatDescription);
            const AudioChannelLayout *currentChannelLayout = CMAudioFormatDescriptionGetChannelLayout(currentFormatDescription, &aclSize);
            
            NSData *currentChannelLayoutData = nil;
            if (currentChannelLayout && aclSize > 0 ) {
                currentChannelLayoutData = [NSData dataWithBytes:currentChannelLayout length:aclSize];
            } else {
                currentChannelLayoutData = [NSData data];
            }
            
            NSDictionary *compressionAudioSettings = @{AVFormatIDKey : [NSNumber numberWithInteger:kAudioFormatMPEG4AAC],
                                                       AVSampleRateKey : [NSNumber numberWithFloat:currentASBD->mSampleRate],
                                                       AVEncoderBitRatePerChannelKey : [NSNumber numberWithInt:64000],
                                                       AVNumberOfChannelsKey : [NSNumber numberWithInteger:currentASBD->mChannelsPerFrame],
                                                       AVChannelLayoutKey : currentChannelLayoutData};
            
            
            self.assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:[assetAudioTrack mediaType] outputSettings:compressionAudioSettings];
            self.assetWriterAudioInput.expectsMediaDataInRealTime = NO;
            [self.assetWriter addInput:self.assetWriterAudioInput];
        }
        
        if (assetVideoTrack)
        {
            // If there is a video track to read, set the decompression settings for YUV and create the asset reader output.
            NSDictionary *decompressionVideoSettings = @{
                                                         (id)kCVPixelBufferPixelFormatTypeKey     : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_422YpCbCr8],
                                                         (id)kCVPixelBufferIOSurfacePropertiesKey : [NSDictionary dictionary]
                                                         };
            self.assetReaderVideoOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:assetVideoTrack outputSettings:decompressionVideoSettings];
            self.assetReaderVideoOutput.alwaysCopiesSampleData = NO;
            [self.assetReader addOutput:self.assetReaderVideoOutput];
            
            
//            CMFormatDescriptionRef formatDescription = NULL;
//            // Grab the video format descriptions from the video track and grab the first one if it exists.
//            NSArray *videoFormatDescriptions = [assetVideoTrack formatDescriptions];
//            if ([videoFormatDescriptions count] > 0)
//                formatDescription = (__bridge CMFormatDescriptionRef)[videoFormatDescriptions objectAtIndex:0];
//            CGSize trackDimensions = {
//                .width = 0.0,
//                .height = 0.0,
//            };
//            // If the video track had a format description, grab the track dimensions from there. Otherwise, grab them direcly from the track itself.
//            if (formatDescription)
//                trackDimensions = CMVideoFormatDescriptionGetPresentationDimensions(formatDescription, false, false);
//            else
//                trackDimensions = [assetVideoTrack naturalSize];
//            NSDictionary *compressionSettings = nil;
//            // If the video track had a format description, attempt to grab the clean aperture settings and pixel aspect ratio used by the video.
//            if (formatDescription)
//            {
//                NSDictionary *cleanAperture = nil;
//                NSDictionary *pixelAspectRatio = nil;
//                CFDictionaryRef cleanApertureFromCMFormatDescription = CMFormatDescriptionGetExtension(formatDescription, kCMFormatDescriptionExtension_CleanAperture);
//                if (cleanApertureFromCMFormatDescription)
//                {
//                    cleanAperture = @{
//                                      AVVideoCleanApertureWidthKey            : (id)CFDictionaryGetValue(cleanApertureFromCMFormatDescription, kCMFormatDescriptionKey_CleanApertureWidth),
//                                      AVVideoCleanApertureHeightKey           : (id)CFDictionaryGetValue(cleanApertureFromCMFormatDescription, kCMFormatDescriptionKey_CleanApertureHeight),
//                                      AVVideoCleanApertureHorizontalOffsetKey : (id)CFDictionaryGetValue(cleanApertureFromCMFormatDescription, kCMFormatDescriptionKey_CleanApertureHorizontalOffset),
//                                      AVVideoCleanApertureVerticalOffsetKey   : (id)CFDictionaryGetValue(cleanApertureFromCMFormatDescription, kCMFormatDescriptionKey_CleanApertureVerticalOffset)
//                                      };
//                }
//                CFDictionaryRef pixelAspectRatioFromCMFormatDescription = CMFormatDescriptionGetExtension(formatDescription, kCMFormatDescriptionExtension_PixelAspectRatio);
//                if (pixelAspectRatioFromCMFormatDescription)
//                {
//                    pixelAspectRatio = @{
//                                         AVVideoPixelAspectRatioHorizontalSpacingKey : (id)CFDictionaryGetValue(pixelAspectRatioFromCMFormatDescription, kCMFormatDescriptionKey_PixelAspectRatioHorizontalSpacing),
//                                         AVVideoPixelAspectRatioVerticalSpacingKey   : (id)CFDictionaryGetValue(pixelAspectRatioFromCMFormatDescription, kCMFormatDescriptionKey_PixelAspectRatioVerticalSpacing)
//                                         };
//                }
//                // Add whichever settings we could grab from the format description to the compression settings dictionary.
//                if (cleanAperture || pixelAspectRatio)
//                {
//                    NSMutableDictionary *mutableCompressionSettings = [NSMutableDictionary dictionary];
//                    if (cleanAperture)
//                        [mutableCompressionSettings setObject:cleanAperture forKey:AVVideoCleanApertureKey];
//                    if (pixelAspectRatio)
//                        [mutableCompressionSettings setObject:pixelAspectRatio forKey:AVVideoPixelAspectRatioKey];
//                    compressionSettings = mutableCompressionSettings;
//                }
//            }
//            // Create the video settings dictionary for H.264.
//            NSMutableDictionary *videoSettings = (NSMutableDictionary *) @{
//                                                                           AVVideoCodecKey  : AVVideoCodecH264,
//                                                                           AVVideoWidthKey  : [NSNumber numberWithDouble:trackDimensions.width],
//                                                                           AVVideoHeightKey : [NSNumber numberWithDouble:trackDimensions.height]
//                                                                           };
//            // Put the compression settings into the video settings dictionary if we were able to grab them.
//            if (compressionSettings)
//                [videoSettings setObject:compressionSettings forKey:AVVideoCompressionPropertiesKey];
            
            // 压缩的更小
            CGFloat bitsPerPixel;
            CMVideoDimensions dimensions = {assetVideoTrack.naturalSize.width, assetVideoTrack.naturalSize.height};
            NSUInteger numPixels = dimensions.width * dimensions.height;
            NSUInteger bitsPerSecond;
            
            if (numPixels < (640 * 480)) {
                bitsPerPixel = 4.05;
            } else {
                bitsPerPixel = 11.4;
            }
            
            bitsPerSecond = numPixels * bitsPerPixel; // 该数值和视频的清晰度及质量成正比
            NSDictionary *videoSettings = @{AVVideoCodecKey: AVVideoCodecH264,
                                            AVVideoWidthKey: [NSNumber numberWithInteger:dimensions.width],
                                            AVVideoHeightKey: [NSNumber numberWithInteger:dimensions.height],
                                            AVVideoCompressionPropertiesKey:@{AVVideoAverageBitRateKey:[NSNumber numberWithInteger:bitsPerSecond],
                                                                              AVVideoMaxKeyFrameIntervalKey:[NSNumber numberWithInteger:30]}};
            
            
            // Create the asset writer input and add it to the asset writer.
            self.assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:[assetVideoTrack mediaType] outputSettings:videoSettings];
            self.assetWriterVideoInput.expectsMediaDataInRealTime = NO;
            [self.assetWriter addInput:self.assetWriterVideoInput];
        }
    }
    return success;
}

- (BOOL)startAssetReaderAndWriter:(NSError **)outError {
    BOOL success = YES;
    // Attempt to start the asset reader.
    success = [self.assetReader startReading];
    if (!success)
        *outError = [self.assetReader error];
    if (success)
    {
        // If the reader started successfully, attempt to start the asset writer.
        success = [self.assetWriter startWriting];
        if (!success)
            *outError = [self.assetWriter error];
    }
    
    if (success)
    {
        // If the asset reader and writer both started successfully, create the dispatch group where the reencoding will take place and start a sample-writing session.
        self.dispatchGroup = dispatch_group_create();
        [self.assetWriter startSessionAtSourceTime:kCMTimeZero];
        self.audioFinished = NO;
        self.videoFinished = NO;
        
        if (self.assetWriterAudioInput)
        {
            // If there is audio to reencode, enter the dispatch group before beginning the work.
            dispatch_group_enter(self.dispatchGroup);
            // Specify the block to execute when the asset writer is ready for audio media data, and specify the queue to call it on.
            [self.assetWriterAudioInput requestMediaDataWhenReadyOnQueue:self.rwAudioSerializationQueue usingBlock:^{
                // Because the block is called asynchronously, check to see whether its task is complete.
                if (self.audioFinished)
                    return;
                BOOL completedOrFailed = NO;
                // If the task isn't complete yet, make sure that the input is actually ready for more media data.
                while ([self.assetWriterAudioInput isReadyForMoreMediaData] && !completedOrFailed)
                {
                    // Get the next audio sample buffer, and append it to the output file.
                    CMSampleBufferRef sampleBuffer = [self.assetReaderAudioOutput copyNextSampleBuffer];
                    if (sampleBuffer != NULL)
                    {
                        BOOL success = [self.assetWriterAudioInput appendSampleBuffer:sampleBuffer];
//                        CMSampleBufferInvalidate(sampleBuffer);
                        CFRelease(sampleBuffer);
                        sampleBuffer = NULL;
                        completedOrFailed = !success;
                    }
                    else
                    {
                        completedOrFailed = YES;
                    }
                }
                if (completedOrFailed)
                {
                    // Mark the input as finished, but only if we haven't already done so, and then leave the dispatch group (since the audio work has finished).
                    BOOL oldFinished = self.audioFinished;
                    self.audioFinished = YES;
                    if (oldFinished == NO)
                    {
                        [self.assetWriterAudioInput markAsFinished];
                    }
                    dispatch_group_leave(self.dispatchGroup);
                }
            }];
        }
        
        if (self.assetWriterVideoInput)
        {
            // If we had video to reencode, enter the dispatch group before beginning the work.
            dispatch_group_enter(self.dispatchGroup);
            // Specify the block to execute when the asset writer is ready for video media data, and specify the queue to call it on.
            [self.assetWriterVideoInput requestMediaDataWhenReadyOnQueue:self.rwVideoSerializationQueue usingBlock:^{
                NSLog(@"===============>requestMediaDataWhenReadyOnQueue %@...", [NSThread currentThread]);
                // Because the block is called asynchronously, check to see whether its task is complete.
                if (self.videoFinished) {
                    return;
                }
                BOOL completedOrFailed = NO;
                // If the task isn't complete yet, make sure that the input is actually ready for more media data.
                while ([self.assetWriterVideoInput isReadyForMoreMediaData] && !completedOrFailed)
                {
                    NSLog(@"--------->reencoding video %@...", [NSThread currentThread]);
                    // Get the next video sample buffer, and append it to the output file.
                    CMSampleBufferRef sampleBuffer = [self.assetReaderVideoOutput copyNextSampleBuffer];
                    if (sampleBuffer != NULL)
                    {
                        BOOL success = [self.assetWriterVideoInput appendSampleBuffer:sampleBuffer];
//                        CMSampleBufferInvalidate(sampleBuffer);
                        CFRelease(sampleBuffer);
                        sampleBuffer = NULL;
                        completedOrFailed = !success;
                    }
                    else
                    {
                        completedOrFailed = YES;
                    }
                }
                if (completedOrFailed)
                {
                    // Mark the input as finished, but only if we haven't already done so, and then leave the dispatch group (since the video work has finished).
                    BOOL oldFinished = self.videoFinished;
                    self.videoFinished = YES;
                    if (oldFinished == NO)
                    {
                        [self.assetWriterVideoInput markAsFinished];
                    }
                    dispatch_group_leave(self.dispatchGroup);
                }
            }];
        }
        // Set up the notification that the dispatch group will send when the audio and video work have both finished.
        dispatch_group_notify(self.dispatchGroup, self.mainSerializationQueue, ^{
            BOOL finalSuccess = YES;
            NSError *finalError = nil;
            // Check to see if the work has finished due to cancellation.
            if (self.cancelled)
            {
                // If so, cancel the reader and writer.
                [self.assetReader cancelReading];
                [self.assetWriter cancelWriting];
            }
            else
            {
                // If cancellation didn't occur, first make sure that the asset reader didn't fail.
                if ([self.assetReader status] == AVAssetReaderStatusFailed)
                {
                    finalSuccess = NO;
                    finalError = [self.assetReader error];
                }
                // If the asset reader didn't fail, attempt to stop the asset writer and check for any errors.
                if (finalSuccess)
                {
//                    finalSuccess = [self.assetWriter finishWriting];
//                    if (!finalSuccess)
//                        finalError = [self.assetWriter error];
                    [self.assetWriter finishWritingWithCompletionHandler:^{
                        NSLog(@"----->finishWriting error: %@ - %@", self.assetWriter.error, [NSThread currentThread]);
                        [self readingAndWritingDidFinishSuccessfully:finalSuccess withError:self.assetWriter.error];
                    }];
                }
            }
            // Call the method to handle completion, and pass in the appropriate parameters to indicate whether reencoding was successful.
//            [self readingAndWritingDidFinishSuccessfully:finalSuccess withError:finalError];
        });
    }
    // Return success here to indicate whether the asset reader and writer were started successfully.
    return success;
}

- (void)readingAndWritingDidFinishSuccessfully:(BOOL)success withError:(NSError *)error {
    if (!success)
    {
        // If the reencoding process failed, we need to cancel the asset reader and writer.
        [self.assetReader cancelReading];
        [self.assetWriter cancelWriting];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Handle any UI tasks here related to failure.
        });
    }
    else
    {
        // Reencoding was successful, reset booleans.
        self.cancelled = NO;
        self.videoFinished = NO;
        self.audioFinished = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            // Handle any UI tasks here related to success.
        });
    }
}

- (void)cancel
{
    // Handle cancellation asynchronously, but serialize it with the main queue.
    dispatch_async(self.mainSerializationQueue, ^{
        // If we had audio data to reencode, we need to cancel the audio work.
        if (self.assetWriterAudioInput)
        {
            // Handle cancellation asynchronously again, but this time serialize it with the audio queue.
            dispatch_async(self.rwAudioSerializationQueue, ^{
                // Update the Boolean property indicating the task is complete and mark the input as finished if it hasn't already been marked as such.
                BOOL oldFinished = self.audioFinished;
                self.audioFinished = YES;
                if (oldFinished == NO)
                {
                    [self.assetWriterAudioInput markAsFinished];
                }
                // Leave the dispatch group since the audio work is finished now.
                dispatch_group_leave(self.dispatchGroup);
            });
        }
        
        if (self.assetWriterVideoInput)
        {
            // Handle cancellation asynchronously again, but this time serialize it with the video queue.
            dispatch_async(self.rwVideoSerializationQueue, ^{
                // Update the Boolean property indicating the task is complete and mark the input as finished if it hasn't already been marked as such.
                BOOL oldFinished = self.videoFinished;
                self.videoFinished = YES;
                if (oldFinished == NO)
                {
                    [self.assetWriterVideoInput markAsFinished];
                }
                // Leave the dispatch group, since the video work is finished now.
                dispatch_group_leave(self.dispatchGroup);
            });
        }
        // Set the cancelled Boolean property to YES to cancel any work on the main queue as well.
        self.cancelled = YES;
    });
}

#pragma mark - Private

- (BOOL)removeFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.filePath.path]){
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:self.filePath.path error:&error];
        return success;
    }
    return YES;
}

#pragma mark - Getter

- (NSURL *)filePath {
    if (!_filePath) {
        _filePath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"movie_fq_export.mp4"]];
    }
    return _filePath;
}

@end
