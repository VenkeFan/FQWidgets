//
//  WLRecordConfig.m
//  welike
//
//  Created by gyb on 2019/1/5.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLRecordConfig.h"


@implementation WLRecordConfig


+ (instancetype)defaultConfig{
   
    NSString *taskPath = NSTemporaryDirectory();
    
    WLRecordConfig *config = [[WLRecordConfig alloc] init];
    config.taskPath = taskPath;
    
    
    config.outputPath = [[[taskPath stringByAppendingPathComponent:@"video"] stringByAppendingPathComponent:@"movie_wl"] stringByAppendingPathExtension:@"mp4"];
    config.outputSize = CGSizeMake(720, 1280);
    config.cropOutputPath =  [[[taskPath stringByAppendingPathComponent:@"video"] stringByAppendingPathComponent:@"movie_wl_f"] stringByAppendingPathExtension:@"mp4"];
    
    
    config.outputType = AliyunIRecorderVideoOutputPixelFormatType420f;
    config.minDuration = 2.0;
    config.maxDuration = 60.0;
    config.videoQuality = AliyunMediaQualityMedium;
    config.encodeMode = AliyunEncodeModeHardH264;
    config.fps = 25;
    config.gop = 5;
    config.bitrate = config.outputSize.width * config.outputSize.height * 1.8;
    config.videoRotate = 0;
    config.backCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    config.frontCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    config.useFaceDetect = YES;
    config.beautifyStatus = NO;
    config.beautifyValue = 50;
    config.cutMode = AliyunMediaCutModeScaleAspectFill;
    
    if (kScreenWidth != 320)
    {
          config.faceDectectSync = YES;
    }
    else
    {
          config.faceDectectSync = NO;
    }
    
    return config;
}


@end
