//
//  WLRecordControlView.m
//  welike
//
//  Created by gyb on 2019/1/7.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLRecordControlView.h"
#import "WLRecordBottomView.h"
#import "QUProgressView.h"

@implementation WLRecordControlView

#pragma mark - UI
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        flashlightBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 48, kSystemStatusBarHeight, 48, 48)];
//        flashlightBtn.selected = NO;
        [flashlightBtn setImage:[AppContext getImageForKey:@"camera_flashlight_off"] forState:UIControlStateNormal];
        [flashlightBtn addTarget:self action:@selector(flashlightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:flashlightBtn];
        
        transformBtn = [[UIButton alloc] initWithFrame:CGRectMake(flashlightBtn.left - 48, kSystemStatusBarHeight, 48, 48)];
//        transformBtn.selected = NO;
        [transformBtn setImage:[AppContext getImageForKey:@"camera_transform"] forState:UIControlStateNormal];
        [transformBtn addTarget:self action:@selector(transformBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:transformBtn];
        
        
        CGFloat y = kIsiPhoneX? kScreenHeight - 160 - 34:kScreenHeight - 160;
        
        _bottomView = [[WLRecordBottomView alloc] initWithFrame:CGRectMake(0, y, kScreenWidth, 160)];
        [self addSubview:_bottomView];
        
        [self addGesture];
        
    }
    return self;
}

-(void)changeTorchBtn:(AliyunIRecorderTorchMode)status
{
    if (status == AliyunIRecorderTorchModeOn)
    {
        [flashlightBtn setImage:[AppContext getImageForKey:@"camera_flashlight_on"]
                            forState:UIControlStateNormal];
    }
    
    if (status == AliyunIRecorderTorchModeOff)
    {
        [flashlightBtn setImage:[AppContext getImageForKey:@"camera_flashlight_off"]
                      forState:UIControlStateNormal];
    }
    
}

#pragma mark - Event
- (void)flashlightBtnClicked:(id)sender
{
    if ([self clickFlashlightBtn])
    {
        self.clickFlashlightBtn();
    }
}

- (void)transformBtnClicked:(id)sender
{
    if ([self clickTransformBtn])
    {
        self.clickTransformBtn();
    }
}

#pragma mark - Gesture
- (void)addGesture
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToFocusPoint:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)tapToFocusPoint:(UITapGestureRecognizer *)tapGesture {
    UIView *tapView = tapGesture.view;
    CGPoint point = [tapGesture locationInView:tapView];
    
    if ([self tapToFocus])
    {
        self.tapToFocus(point);
    }
}


@end
