//
//  WLCameraViewController.h
//  WeLike
//
//  Created by fan qi on 2018/4/2.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLCameraOperateView.h"

@class WLCameraViewController, PHAsset;

@protocol WLCameraViewControllerDelegate <NSObject>

- (void)cameraViewCtr:(WLCameraViewController *)viewCtr didConfirmWithImage:(UIImage *)image;
- (void)cameraViewCtr:(WLCameraViewController *)viewCtr didConfirmWithVideoAsset:(PHAsset *)videoAsset;

@end

@interface WLCameraViewController : RDBaseViewController

@property (nonatomic, assign) FQCameraOutputType outputType;
@property (nonatomic, weak) id<WLCameraViewControllerDelegate> delegate;

@end
