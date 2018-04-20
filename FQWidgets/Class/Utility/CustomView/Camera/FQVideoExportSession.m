//
//  FQVideoExportSession.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/18.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQVideoExportSession.h"

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
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
        exportSession.outputURL = self.filePath;
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        if ([exportSession.supportedFileTypes containsObject:AVFileTypeMPEG4]) {
            exportSession.outputFileType = AVFileTypeMPEG4;
            
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                NSLog(@"-------------------->%@", FQVideoExportSessionStatusMapping[exportSession.status]);
                
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
