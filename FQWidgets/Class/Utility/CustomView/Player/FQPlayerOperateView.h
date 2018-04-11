//
//  FQPlayerOperateView.h
//  WeLike
//
//  Created by fan qi on 2018/4/10.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FQPlayerViewStatus) {
    FQPlayerViewStatus_Unknown,
    FQPlayerViewStatus_ReadyToPlay,
    FQPlayerViewStatus_Playing,
    FQPlayerViewStatus_Paused,
    FQPlayerViewStatus_CachingPaused,
    FQPlayerViewStatus_Stopped,
    FQPlayerViewStatus_Completed,
    FQPlayerViewStatus_Failed
};

@class FQPlayerOperateView;

@protocol FQPlayerOperateViewDelegate <NSObject>

- (void)playerOperateViewDidClickedPlay:(FQPlayerOperateView *)operateView;
- (void)playerOperateViewDidClickedStop:(FQPlayerOperateView *)operateView;
- (void)playerOperateView:(FQPlayerOperateView *)operateView didSliderValueChanged:(CGFloat)changedValue;

@end

@interface FQPlayerOperateView : UIView

@property (nonatomic, assign) CGFloat playProgress;
@property (nonatomic, assign) CGFloat cacheProgress;
@property (nonatomic, assign) CGFloat playSeconds;
@property (nonatomic, assign) CGFloat restSeconds;

@property (nonatomic, assign, getter=isCaching) BOOL caching;
@property (nonatomic, assign) FQPlayerViewStatus playerViewStatus;
@property (nonatomic, weak) id<FQPlayerOperateViewDelegate> delegate;

@end
