//
//  WLRecordConfig.h
//  welike
//
//  Created by gyb on 2019/1/5.
//  Copyright © 2019 redefine. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
//#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>

/**
 清晰度
 
 - AliyunMediaQualityVeryHight: 超高清
 - AliyunMediaQualityHight: 高清
 - AliyunMediaQualityMedium: 普通
 - AliyunMediaQualityLow: 低
 - AliyunMediaQualityPoor: 很低
 - AliyunMediaQualityExtraPoor: 差
 */
typedef NS_ENUM(NSInteger, AliyunMediaQuality) {
    AliyunMediaQualityVeryHight,
    AliyunMediaQualityHight,
    AliyunMediaQualityMedium,
    AliyunMediaQualityLow,
    AliyunMediaQualityPoor,
    AliyunMediaQualityExtraPoor
};


/**
 裁剪模式
 
 - AliyunMediaCutModeScaleAspectFill: 填充
 - AliyunMediaCutModeScaleAspectCut: 裁剪
 */
typedef NS_ENUM(NSInteger, AliyunMediaCutMode) {
    AliyunMediaCutModeScaleAspectFill = 0,
    AliyunMediaCutModeScaleAspectCut = 1
};

/**
 编码格式
 
 - AliyunEncodeModeSoftH264: 软编：提升质量、牺牲速度
 - AliyunEncodeModeHardH264: 硬编：提升速度、牺牲视频质量
 */
typedef NS_ENUM(NSInteger, AliyunEncodeMode) {
    AliyunEncodeModeHardH264,
    AliyunEncodeModeSoftH264
};

/**
 视频比例
 
 - AliyunMediaRatio9To16: 9：16
 - AliyunMediaRatio3To4: 3：4
 - AliyunMediaRatio1To1: 1：1
 - AliyunMediaRatio4To3: 4：3
 - AliyunMediaRatio16To9: 16：9
 */
typedef NS_ENUM(NSInteger, AliyunMediaRatio) {
    AliyunMediaRatio9To16,
    AliyunMediaRatio3To4,
    AliyunMediaRatio1To1,
    AliyunMediaRatio4To3,
    AliyunMediaRatio16To9,
};


/**
 媒体资源类型
 
 - kPhotoMediaTypeVideo: 视频
 - kPhotoMediaTypePhoto: 图片
 */
typedef NS_ENUM(NSInteger, kPhotoMediaType) {
    kPhotoMediaTypeVideo,
    kPhotoMediaTypePhoto,
};


@class AVAsset;
@interface WLRecordConfig : NSObject


@property (nonatomic, strong) NSString *taskPath;//

/**
 输出路径
 */
@property (nonatomic, strong) NSString *outputPath;//


/**
 编辑剪辑输出路径
 */
@property (nonatomic, strong) NSString *cropOutputPath;//1-11新加


/**
 输出大小
 */
@property (nonatomic, assign) CGSize outputSize;//


//@property (nonatomic, assign) AliyunIRecorderVideoOutputPixelFormatType outputType;

//是否开启人脸识别
@property (nonatomic, assign) BOOL useFaceDetect;

//人脸贴合,6以上开启
@property (nonatomic, assign) BOOL faceDectectSync;

//是否美颜
@property (nonatomic, assign) BOOL beautifyStatus;

//美颜参数
@property (nonatomic, assign) int beautifyValue;


/**
 最小时长
 */
@property (nonatomic, assign) CGFloat minDuration;//

/**
 最大时长
 */
@property (nonatomic, assign) CGFloat maxDuration;//


/**
 视频录制清晰度
 */
@property (nonatomic, assign) AliyunMediaQuality videoQuality;//

/**
 编码格式
 */
@property (nonatomic, assign) AliyunEncodeMode encodeMode;//

/**
 帧率
 */
@property (nonatomic, assign) int fps;//

/**
 关键帧间隔
 */
@property (nonatomic, assign) int gop;//

/**
 码率
 */
@property (nonatomic, assign) int bitrate;//

/**
 裁剪模式
 */
@property (nonatomic, assign) AliyunMediaCutMode cutMode;


/**
 视频角度，以第一段为准 0/90/180/270
 */
@property (nonatomic, assign) int videoRotate;//


/**
 前置摄像头采集分辨率
 
 */
@property (nonatomic, copy) NSString *frontCaptureSessionPreset;//

/**
 后置摄像头采集分辨率
 
 */
@property (nonatomic, copy) NSString *backCaptureSessionPreset;//



/**
 获取一个默认属性的config
 
 @return 默认属性的config,我们已经设置好了参数
 */
+ (instancetype)defaultConfig;


@end


/**
 原视频路径
 */
//@property (nonatomic, strong) NSString *sourcePath;

/**
 原视频时长
 */
//@property (nonatomic, assign) CGFloat sourceDuration;

/**
 开始时间
 */
//@property (nonatomic, assign) CGFloat startTime;

/**
 结束时间
 */
//@property (nonatomic, assign) CGFloat endTime;



/**
 系统音视频信息类
 */
//@property (nonatomic, strong) AVAsset *avAsset;

/**
 系统相册图片信息类
 */
//@property (nonatomic, strong) PHAsset *phAsset;

//@property (nonatomic, strong) UIImage *phImage;

/**
 是否仅展示视频
 */
//@property (nonatomic, assign) BOOL videoOnly;
