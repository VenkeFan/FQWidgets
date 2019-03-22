//
//  WLRecordControlView.h
//  welike
//
//  Created by gyb on 2019/1/7.
//  Copyright © 2019 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>

NS_ASSUME_NONNULL_BEGIN

@class WLRecordBottomView;

@interface WLRecordControlView : UIView
{
    UIButton *flashlightBtn;
    UIButton *transformBtn;
    
 
}


@property (nonatomic, strong) WLRecordBottomView *bottomView;

@property (nonatomic,copy) void(^tapToFocus)(CGPoint clickPoint);
@property (nonatomic,copy) void(^clickFlashlightBtn)(void);
@property (nonatomic,copy) void(^clickTransformBtn)(void);
@property (nonatomic,copy) void(^tapRecordBtnDown)(void);
@property (nonatomic,copy) void(^tapRecordBtnUp)(void);
@property (nonatomic,copy) void(^tapFinishBtnDown)(void);

-(void)changeTorchBtn:(AliyunIRecorderTorchMode)status;


@end

NS_ASSUME_NONNULL_END
