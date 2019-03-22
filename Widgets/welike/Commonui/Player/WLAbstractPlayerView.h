//
//  WLAbstractPlayerView.h
//  welike
//
//  Created by fan qi on 2018/6/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLPlayerOperateView.h"

typedef NS_ENUM(NSInteger, WLPlayerViewGravity) {
    WLPlayerViewGravity_ResizeAspectFill,
    WLPlayerViewGravity_ResizeAspect
};

@protocol WLBasicPlayerProtocol <NSObject>

@optional
- (void)play;
- (void)pause;
- (void)stop;
- (void)seekToPosition:(CGFloat)position;

@end

@class WLAbstractPlayerView;

@protocol WLPlayerViewDelegate <NSObject>

@optional
- (void)playerView:(WLAbstractPlayerView *)playerView statusDidChanged:(WLPlayerViewStatus)status;
- (void)playerViewOrientationDidChanged:(WLAbstractPlayerView *)playerView;
- (void)playerView:(WLAbstractPlayerView *)playerView didDiaplayToolsChanged:(BOOL)displayTools;

@end

@interface WLAbstractPlayerView : UIView <WLBasicPlayerProtocol>

@property (nonatomic, strong) WLPlayerOperateView *operateView;

@property (nonatomic, assign) WLPlayerViewStatus playerViewStatus;
@property (nonatomic, assign) WLPlayerViewGravity videoGravity;
@property (nonatomic, assign) WLPlayerViewWindowMode windowMode;

@property (nonatomic, assign, readonly) CGFloat position;

@property (nonatomic, weak) id<WLPlayerViewDelegate> delegate;

@property (nonatomic, assign, getter=isLoop) BOOL loop;

- (BOOL)checkNetworkReachable;

@end
