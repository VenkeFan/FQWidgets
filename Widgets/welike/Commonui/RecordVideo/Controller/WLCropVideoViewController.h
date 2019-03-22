//
//  WLCropVideoViewController.h
//  welike
//
//  Created by gyb on 2019/1/7.
//  Copyright © 2019 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class  WLCropVideoViewController,PHAsset;
@protocol WLCropVideoViewControllerDelegate <NSObject>

- (void)shortVideoCtr:(WLCropVideoViewController *)viewCtr didConfirmWithVideoAsset:(PHAsset *)videoAsset;

@end


@interface WLCropVideoViewController : RDBaseViewController
{
  Float64 seconds;
}

@property (nonatomic, strong) NSString *urlStr;



@property (nonatomic, weak) id<WLCropVideoViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
