//
//  WLTrackerPostDisplay.h
//  welike
//
//  Created by fan qi on 2018/11/1.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLTracker.h"

@class WLPostBase;

#define kWLTrackerPostDisplayActionKey                  @"action"
#define kWLTrackerPostDisplayViewerIDKey                @"uid"
#define kWLTrackerPostDisplayPostUIDKey                 @"post_uid"
#define kWLTrackerPostDisplayRootPostUIDKey             @"rootpost_uid"
#define kWLTrackerPostDisplayPostIDKey                  @"post_id"
#define kWLTrackerPostDisplayRootPostIDKey              @"rootpost_id"
#define kWLTrackerPostDisplayTypeKey                    @"post_type"
#define kWLTrackerPostDisplaySourceKey                  @"view_source"
#define kWLTrackerPostDisplayClickedAreaKey             @"click_area"

typedef NS_ENUM(NSInteger, WLTrackerPostDisplayAction) {
    WLTrackerPostDisplayAction_Feed         = 1,
    WLTrackerPostDisplayAction_Detail       = 2
};

NS_ASSUME_NONNULL_BEGIN

@interface WLTrackerPostDisplay : NSObject

+ (void)appendTrackerWithDisplayAction:(WLTrackerPostDisplayAction)action;
+ (void)addDisplayedPost:(WLPostBase *)post;

+ (NSMutableDictionary *)eventInfoWithPost:(WLPostBase *)post;

@end

NS_ASSUME_NONNULL_END
