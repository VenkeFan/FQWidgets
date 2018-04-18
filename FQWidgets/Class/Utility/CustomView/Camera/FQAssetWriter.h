//
//  FQAssetWriter.h
//  WeLike
//
//  Created by fan qi on 2018/4/7.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface FQAssetWriter : NSObject

@property (nonatomic) dispatch_queue_t writingQueue;
@property (nonatomic, strong, readonly) NSURL *filePath;
@property (nonatomic, assign, readonly, getter=isReadyToRecordVideo) BOOL readyToRecordVideo;
@property (nonatomic, assign, readonly, getter=isReadyToRecordAudio) BOOL readyToRecordAudio;

- (void)setupAssetWriterVideoInput:(CMFormatDescriptionRef)currentFormatDescription;
- (void)setupAssetWriterAudioInput:(CMFormatDescriptionRef)currentFormatDescription;

- (void)startRecording;
- (void)stopRecordingWithFinished:(void(^)(void))finished;
- (void)cancelRecording;
- (void)writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType;

- (void)removeFile;
- (void)saveToCameraRoll;

@end
