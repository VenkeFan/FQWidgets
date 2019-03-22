//
//  WLAbstractCameraViewController.h
//  welike
//
//  Created by fan qi on 2018/12/15.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "RDBaseViewController.h"
#import "WLCameraOperateView.h"

@class WLAbstractCameraViewController, PHAsset;

@protocol WLAbstractCameraViewControllerDelegate <NSObject>

- (void)cameraViewCtr:(WLAbstractCameraViewController *)viewCtr didConfirmWithImage:(UIImage *)image;
- (void)cameraViewCtr:(WLAbstractCameraViewController *)viewCtr didConfirmWithVideoAsset:(PHAsset *)videoAsset;

@end

NS_ASSUME_NONNULL_BEGIN

@interface WLAbstractCameraViewController : RDBaseViewController

+ (WLAbstractCameraViewController *)generateCameraViewCtr;

@property (nonatomic, assign) FQCameraOutputType outputType;
@property (nonatomic, weak) id<WLAbstractCameraViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
