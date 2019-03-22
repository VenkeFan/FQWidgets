//
//  WLCameraOperateView.h
//  WeLike
//
//  Created by fan qi on 2018/4/7.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class WLCameraOperateView;

typedef NS_ENUM(NSInteger, FQCameraOutputType) {
    FQCameraOutputType_Photo,
    FQCameraOutputType_Video
};

typedef NS_ENUM(NSInteger, FQCameraVideoStatus) {
    // Record Video
    FQCameraVideoStatus_Prepare,
    FQCameraVideoStatus_Recording,
    FQCameraVideoStatus_Stop,
    FQCameraVideoStatus_Completed,
    
    // Play Video
    FQCameraVideoStatus_Play,
    FQCameraVideoStatus_Pause,
    FQCameraVideoStatus_PlayToEnd,
};

typedef void(^SucceedBlock)(void);
typedef void(^FailedBlock)(void);

@protocol WLCameraOperateViewDelegate <NSObject>

- (void)cameraOperateView:(WLCameraOperateView *)operateView didCanceledWithOutputType:(FQCameraOutputType)outputType;
- (void)cameraOperateView:(WLCameraOperateView *)operateView didConfirmedWithOutputType:(FQCameraOutputType)outputType;
- (void)cameraOperateViewDidTakePhotoClicked:(WLCameraOperateView *)operateView succeed:(SucceedBlock)succeed;
- (void)cameraOperateView:(WLCameraOperateView *)operateView didVideoStatusChanged:(FQCameraVideoStatus)newStatus oldStatus:(FQCameraVideoStatus)oldStatus;
- (void)cameraOperateViewDidChangeFlashlight:(WLCameraOperateView *)operateView succeed:(void(^)(AVCaptureFlashMode flashMode))succeed;
- (void)cameraOperateViewDidTransformCamera:(WLCameraOperateView *)operateView;
- (void)cameraOperateView:(WLCameraOperateView *)operateView disPlayVideo:(NSURL *)fileUrl;

@end

@interface WLCameraOperateView : UIView

@property (nonatomic, assign) FQCameraOutputType outputType;
@property (nonatomic, assign) FQCameraVideoStatus videoStatus;
@property (nonatomic, weak) id<WLCameraOperateViewDelegate> delegate;

@property (nonatomic, strong) NSURL *recordFilePath;

@end

