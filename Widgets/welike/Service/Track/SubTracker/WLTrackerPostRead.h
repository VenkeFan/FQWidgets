//
//  WLTrackerPostRead.h
//  welike
//
//  Created by fan qi on 2018/11/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTrackerPostDisplay.h"
#import "WLTracker.h"

@class WLPostBase;

typedef NS_ENUM(NSInteger, WLTrackerPostReadAction) {
    WLTrackerPostReadAction_Feed         = 1,
    WLTrackerPostReadAction_Detail       = 2,
    WLTrackerPostReadAction_Clicked      = 3
};

typedef NS_ENUM(NSInteger, WLTrackerPostClickedArea) {
    WLTrackerPostClickedArea_None       = 0,
    WLTrackerPostClickedArea_Avatar     = 1,
    WLTrackerPostClickedArea_More       = 2,
    WLTrackerPostClickedArea_Text       = 3,
    WLTrackerPostClickedArea_Picture    = 4,
    WLTrackerPostClickedArea_Video      = 5,
    WLTrackerPostClickedArea_Poll       = 6
};

NS_ASSUME_NONNULL_BEGIN

@interface WLTrackerPostRead : WLTrackerPostDisplay

+ (void)appendTrackerWithReadAction:(WLTrackerPostReadAction)action
                               post:(WLPostBase *)postModel
                           duration:(CFTimeInterval)duration;
+ (void)appendTrackerWithClickedArea:(WLTrackerPostClickedArea)area
                                post:(WLPostBase *)postModel;

@end

NS_ASSUME_NONNULL_END
