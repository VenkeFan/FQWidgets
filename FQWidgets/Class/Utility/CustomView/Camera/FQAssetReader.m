//
//  FQAssetReader.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/19.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQAssetReader.h"

@interface FQAssetReader () {
    dispatch_queue_t _readingQueue;
}

//@property (nonatomic, strong) AVAssetReader *assetReader;
//@property (nonatomic, strong) AVAssetReaderTrackOutput *assetVideoOutput;

@end

@implementation FQAssetReader

- (void)dealloc {
    NSLog(@"FQAssetReader dealloc");
}

#pragma mark - Public

- (void)startReadingWithAsset:(AVAsset *)asset {
    if (!asset) {
        return;
    }
    
    NSError *error;
    AVAssetReader *assetReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    if (error) {
        NSLog(@"FQAssetReader 初始化失败: %@", error);
        return;
    }
    
    AVAssetTrack *videoTrack = [assetReader.asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    
    // 打印Track信息
    CMFormatDescriptionRef desc = (__bridge CMFormatDescriptionRef)videoTrack.formatDescriptions.firstObject;
    NSLog(@"CMFormatDescriptionRef: %@", desc);
    NSLog(@"分辨率: %f x %f", videoTrack.naturalSize.width ,videoTrack.naturalSize.height);
    NSLog(@"帧率: %f",videoTrack.nominalFrameRate);
    NSLog(@"比特率: %f",videoTrack.estimatedDataRate);
    
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
        NSLog(@"视频解码开始失败: %@", assetReader.error);
        return;
    }
    NSLog(@"开始视频解码");
    
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
                NSLog(@"视频解码中出错: %@", assetReader.error);
            } else {
                done = YES;
            }
        }
    }
    
    NSLog(@"视频解码完成");
    [assetReader cancelReading];
    assetReader = nil;
    if ([self.delegate respondsToSelector:@selector(assetReaderDidCompleted:)]) {
        [self.delegate assetReaderDidCompleted:self];
    }
}

@end
