//
//  WLVideoExportSession.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/18.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLVideoExportSession.h"

NSString * const WLVideoExportSessionStatusMapping[] = {
    [AVAssetExportSessionStatusUnknown]         = @"AVAssetExportSessionStatusUnknown",
    [AVAssetExportSessionStatusWaiting]         = @"AVAssetExportSessionStatusWaiting",
    [AVAssetExportSessionStatusExporting]       = @"AVAssetExportSessionStatusExporting",
    [AVAssetExportSessionStatusCompleted]       = @"AVAssetExportSessionStatusCompleted",
    [AVAssetExportSessionStatusCancelled]       = @"AVAssetExportSessionStatusCancelled",
    [AVAssetExportSessionStatusFailed]          = @"AVAssetExportSessionStatusFailed"
};

@interface WLVideoExportSession ()

@property (nonatomic, strong) NSURL *filePath;

@end

@implementation WLVideoExportSession

#pragma mark - Public

- (void)compressWithAsset:(AVAsset *)asset {
    if (!asset) {
        return;
    }
    _asset = asset;
    
    if (![self removeFile]) {
        return;
    }
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
        exportSession.outputURL = self.filePath;
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        if ([exportSession.supportedFileTypes containsObject:AVFileTypeMPEG4]) {
            exportSession.outputFileType = AVFileTypeMPEG4;
            
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                NSLog(@"-------------------->%@", WLVideoExportSessionStatusMapping[exportSession.status]);
                
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
            
        }
    } else {
        
    }
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
