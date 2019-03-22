//
//  WLPlayerOperateView.h
//  WeLike
//
//  Created by fan qi on 2018/4/10.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLVideoPost, WLAbstractPlayerView;

typedef NS_ENUM(NSInteger, WLPlayerViewStatus) {
    WLPlayerViewStatus_Unknown,
    WLPlayerViewStatus_ReadyToPlay,
    WLPlayerViewStatus_Playing,
    WLPlayerViewStatus_Paused,
    WLPlayerViewStatus_CachingPaused,
    WLPlayerViewStatus_Stopped,
    WLPlayerViewStatus_Completed,
    WLPlayerViewStatus_Failed
};

typedef NS_ENUM(NSInteger, WLPlayerViewWindowMode) {
    WLPlayerViewWindowMode_Screen,
    WLPlayerViewWindowMode_Widget
};

typedef NS_ENUM(NSInteger, WLPlayerViewType) {
    WLPlayerViewType_Welike,
    WLPlayerViewType_YouTube,
    WLPlayerViewType_Local
};

typedef NS_ENUM(NSInteger, WLPlayerViewOrientation) {
    WLPlayerViewOrientation_Vertical,
    WLPlayerViewOrientation_Horizontal
};

@class WLPlayerOperateView;

@protocol WLPlayerOperateViewDelegate <NSObject>

@optional
- (void)playerOperateViewDidClickedPlay:(WLPlayerOperateView *)operateView;
- (void)playerOperateViewDidClickedRotate:(WLPlayerOperateView *)operateView;
- (void)playerOperateView:(WLPlayerOperateView *)operateView didVolumeChanged:(BOOL)mute;
- (void)playerOperateViewDidClickedDownload:(WLPlayerOperateView *)operateView;
- (void)playerOperateView:(WLPlayerOperateView *)operateView didSliderValueChanged:(CGFloat)changedValue;
- (void)playerOperateView:(WLPlayerOperateView *)operateView didDiaplayToolsChanged:(BOOL)displayTools;

@end

@interface WLPlayerOperateView : UIView

@property (class, nonatomic, assign, getter=isMute) BOOL mute;

@property (nonatomic, strong) WLVideoPost *videoModel;
@property (nonatomic, weak) WLAbstractPlayerView *playerView;

@property (nonatomic, assign) CGFloat playProgress;
@property (nonatomic, assign) CGFloat cacheProgress;
@property (nonatomic, assign) CGFloat playSeconds;
@property (nonatomic, assign) CGFloat duration;

@property (nonatomic, assign, getter=isCaching) BOOL caching;
@property (nonatomic, assign) WLPlayerViewStatus playerViewStatus;
@property (nonatomic, weak) id<WLPlayerOperateViewDelegate> delegate;

@property (nonatomic, assign) WLPlayerViewWindowMode windowMode;
@property (nonatomic, assign) WLPlayerViewType playerViewType;
@property (nonatomic, assign) WLPlayerViewOrientation playerOrientation;

@property (nonatomic, assign, readonly, getter=isDisplayTools) BOOL displayToos;

@property (nonatomic, strong, readonly) CAShapeLayer *downloadProgressLayer;
@property (nonatomic, assign) BOOL downloading;
@property (nonatomic, assign) BOOL downloaded;

- (void)prepare;

@end
