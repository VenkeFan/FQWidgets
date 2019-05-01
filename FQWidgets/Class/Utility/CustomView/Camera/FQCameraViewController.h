//
//  FQCameraViewController.h
//  WeLike
//
//  Created by fan qi on 2018/4/2.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FQCameraOperateView.h"

@class FQCameraViewController, PHAsset;

@protocol FQCameraViewControllerDelegate <NSObject>

- (void)cameraViewCtr:(FQCameraViewController *)viewCtr didConfirmWithImage:(UIImage *)image;
- (void)cameraViewCtr:(FQCameraViewController *)viewCtr didConfirmWithVideoAsset:(PHAsset *)videoAsset;

@end

@interface FQCameraViewController : UIViewController

@property (nonatomic, assign) FQCameraOutputType outputType;
@property (nonatomic, weak) id<FQCameraViewControllerDelegate> delegate;

@end
