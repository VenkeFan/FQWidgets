//
//  WLAssetReader.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/19.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLAssetReader.h"

@interface WLAssetReader () {
    dispatch_queue_t _readingQueue;
}

//@property (nonatomic, strong) AVAssetReader *assetReader;
//@property (nonatomic, strong) AVAssetReaderTrackOutput *assetVideoOutput;

@end

@implementation WLAssetReader

- (void)dealloc {
    
}

#pragma mark - Public

- (void)startReadingWithAsset:(AVAsset *)asset {
    if (!asset) {
        return;
    }
    
    NSError *error;
    AVAssetReader *assetReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    if (error) {
        return;
    }
    
    AVAssetTrack *videoTrack = [assetReader.asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    
#if DEBUG
    // 打印Track信息
//    CMFormatDescriptionRef desc = (__bridge CMFormatDescriptionRef)videoTrack.formatDescriptions.firstObject;
//    NSLog(@"CMFormatDescriptionRef: %@", desc);
//    NSLog(@"resolution ratio: %f x %f", videoTrack.naturalSize.width ,videoTrack.naturalSize.height);
//    NSLog(@"frame rate: %f",videoTrack.nominalFrameRate);
//    NSLog(@"bit rate: %f",videoTrack.estimatedDataRate);
#endif
    
    NSDictionary *outputSetting = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
                                    (id)kCVPixelBufferIOSurfacePropertiesKey: [NSDictionary dictionary]};
    
    AVAssetReaderTrackOutput *assetVideoOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack
                                                                                  outputSettings:outputSetting];
    assetVideoOutput.alwaysCopiesSampleData = NO;
    if (![assetReader canAddOutput:assetVideoOutput]) {
        return;
    }
    [assetReader addOutput:assetVideoOutput];
    
    BOOL success = [assetReader startReading];
    if (!success) {
        return;
    }
    
    BOOL done = NO;
    while (!done) {
        CMSampleBufferRef sampleBuffer = [assetVideoOutput copyNextSampleBuffer];
        if (sampleBuffer) {
            if ([self.delegate respondsToSelector:@selector(assetReader:didReadingBuffer:)]) {
                [self.delegate assetReader:self didReadingBuffer:sampleBuffer];
            }
            CMSampleBufferInvalidate(sampleBuffer);
            CFRelease(sampleBuffer);
            sampleBuffer = NULL;
        } else {
            if (assetReader.status == AVAssetReaderStatusFailed) {
                
            } else {
                done = YES;
            }
        }
    }
    
    [assetReader cancelReading];
    assetReader = nil;
    if ([self.delegate respondsToSelector:@selector(assetReaderDidCompleted:)]) {
        [self.delegate assetReaderDidCompleted:self];
    }
}

@end
