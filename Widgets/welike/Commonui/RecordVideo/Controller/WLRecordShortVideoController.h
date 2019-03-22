//
//  WLRecordShortVideoController.h
//  welike
//
//  Created by gyb on 2019/1/5.
//  Copyright © 2019 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLRecordConfig.h"


@class WLRecordShortVideoController,PHAsset;
//
//@protocol WLRecordShortVideoControllerDelegate <NSObject>
//
//- (void)shortVideoCtr:(WLRecordShortVideoController *)viewCtr didConfirmWithVideoAsset:(PHAsset *)videoAsset;
//
//@end

@interface WLRecordShortVideoController : WLNavBarBaseViewController

/**
 视频参数配置
 */
@property (nonatomic, strong) WLRecordConfig *recordConfig;

@property (nonatomic, weak) id target;

@end
