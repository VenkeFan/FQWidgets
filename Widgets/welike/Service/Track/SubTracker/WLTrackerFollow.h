//
//  WLTrackerFollow.h
//  welike
//
//  Created by fan qi on 2018/11/7.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLTracker.h"

@class WLPostBase;

typedef NS_ENUM(NSInteger, WLTrackerFollowAction) {
    WLTrackerFollowAction_Follow        = 1,
    WLTrackerFollowAction_UnFollow      = 2
};

NS_ASSUME_NONNULL_BEGIN

@interface WLTrackerFollow : NSObject

@property (class, nonatomic, assign) WLTrackerFeedSource feedSource;

+ (void)appendTrackerWithFollowAction:(WLTrackerFollowAction)action
                                 post:(nullable WLPostBase *)post
                               userID:(NSString *)userID;

@end

NS_ASSUME_NONNULL_END
