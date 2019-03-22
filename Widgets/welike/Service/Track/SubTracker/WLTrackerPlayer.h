//
//  WLTrackerPlayer.h
//  welike
//
//  Created by fan qi on 2018/11/8.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLTracker.h"

@class WLPostBase, WLVideoPost;

typedef NS_ENUM(NSInteger, WLTrackerPlayerAction) {
    WLTrackerPlayerAction_Widget    = 5,
    WLTrackerPlayerAction_Screen    = 7
};

typedef NS_ENUM(NSInteger, WLTrackerPlayerOpenType) {
    WLTrackerPlayerOpenType_Clicked     = 1,
    WLTrackerPlayerOpenType_SlideUp     = 2,
    WLTrackerPlayerOpenType_SlideDown   = 3,
    WLTrackerPlayerOpenType_Detail      = 4
};

typedef NS_ENUM(NSInteger, WLTrackerPlayerOperateType) {
    WLTrackerPlayerOperateType_Play_Pause   = 1,
    WLTrackerPlayerOperateType_Download     = 2,
    WLTrackerPlayerOperateType_FullScreen   = 3,
    WLTrackerPlayerOperateType_Mute         = 4,
    WLTrackerPlayerOperateType_Avatar       = 5,
    WLTrackerPlayerOperateType_Text         = 6,
    WLTrackerPlayerOperateType_Rotate       = 7,
    WLTrackerPlayerOperateType_Close        = 8
};

typedef NS_ENUM(NSInteger, WLTrackerPlayerMuteType) {
    WLTrackerPlayerMuteType_Closed      = 1,
    WLTrackerPlayerMuteType_Opened      = 2
};

NS_ASSUME_NONNULL_BEGIN

@interface WLTrackerPlayer : NSObject

@property (class, nonatomic, weak) WLPostBase *forwardPost;
@property (class, nonatomic, assign) WLTrackerPlayerOpenType openType;

+ (void)appendTrackerWithPlayerAction:(WLTrackerPlayerAction)action
                            videoPost:(WLVideoPost *)videoPost
                             playTime:(CGFloat)playTime
                             duration:(CGFloat)duration
                             muteType:(WLTrackerPlayerMuteType)muteType;

+ (void)appendTrackerWithPlayerOperateType:(WLTrackerPlayerOperateType)operateType;
+ (void)appendTrackerWithPlayerOperateType:(WLTrackerPlayerOperateType)operateType
                                  muteType:(WLTrackerPlayerMuteType)muteType;

@end

NS_ASSUME_NONNULL_END
