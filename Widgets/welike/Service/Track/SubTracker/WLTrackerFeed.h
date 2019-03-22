//
//  WLTrackerFeed.h
//  welike
//
//  Created by fan qi on 2018/10/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLTracker.h"

typedef NS_ENUM(NSInteger, WLTrackerFeedAction) {
    WLTrackerFeedAction_Drag_Refresh        = 1,
    WLTrackerFeedAction_More                = 2,
    WLTrackerFeedAction_Default_Refresh     = 3,
    WLTrackerFeedAction_Clicked_Refresh     = 4
};

NS_ASSUME_NONNULL_BEGIN

@interface WLTrackerFeed : NSObject

@property (class, nonatomic, assign) WLTrackerFeedSource emptyDataTrackerSource;
@property (class, nonatomic, assign, nullable) WLTrackerFeedSubType emptyDataTrackerSubType;

+ (void)appendTrackWithAction:(WLTrackerFeedAction)action
                         type:(WLTrackerFeedSource)type
                      subType:(nullable WLTrackerFeedSubType)subType
                   fetchCount:(NSUInteger)fetchCount;

@end

NS_ASSUME_NONNULL_END
