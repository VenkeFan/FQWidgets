//
//  FQCameraOperateView.h
//  WeLike
//
//  Created by fan qi on 2018/4/7.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class FQCameraOperateView;

typedef NS_ENUM(NSInteger, FQCameraOutputType) {
    FQCameraOutputType_Photo,
    FQCameraOutputType_Video
};

typedef NS_ENUM(NSInteger, FQCameraVideoStatus) {
    FQCameraVideoStatus_Prepare,
    FQCameraVideoStatus_Recording,
    FQCameraVideoStatus_Pause,
    FQCameraVideoStatus_Completed
};

typedef void(^SucceedBlock)(void);
typedef void(^FailedBlock)(void);

@protocol FQCameraOperateViewDelegate <NSObject>

- (void)cameraOperateView:(FQCameraOperateView *)operateView didCanceledWithOutputType:(FQCameraOutputType)outputType;
- (void)cameraOperateView:(FQCameraOperateView *)operateView didConfirmedWithOutputType:(FQCameraOutputType)outputType;
- (void)cameraOperateViewDidPhotoClicked:(FQCameraOperateView *)operateView succeed:(SucceedBlock)succeed;
- (void)cameraOperateView:(FQCameraOperateView *)operateView
    didVideoStatusChanged:(FQCameraVideoStatus)newStatus
                oldStatus:(FQCameraVideoStatus)oldStatus;
- (void)cameraOperateViewDidChangeFlashlight:(FQCameraOperateView *)operateView succeed:(void(^)(AVCaptureFlashMode flashMode))succeed;
- (void)cameraOperateViewDidTransformCamera:(FQCameraOperateView *)operateView;

@end

@interface FQCameraOperateView : UIView

@property (nonatomic, assign) FQCameraOutputType outputType;
@property (nonatomic, assign) FQCameraVideoStatus videoStatus;
@property (nonatomic, weak) id<FQCameraOperateViewDelegate> delegate;

@property (nonatomic, assign, readonly) CGFloat switchBgViewHeight;

@end
