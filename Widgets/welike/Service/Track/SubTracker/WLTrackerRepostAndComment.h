//
//  WLTrackerRepostAndComment.h
//  welike
//
//  Created by fan qi on 2018/11/5.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLTracker.h"

@class WLDraftBase;

typedef NS_ENUM(NSInteger, WLTrackerReAndComAction) {
    WLTrackerReAndComAction_Comment = 1,
    WLTrackerReAndComAction_Repost  = 2
};

typedef NS_ENUM(NSInteger, WLTrackerReAndComStatus) {
    WLTrackerReAndComStatus_Failed  = 0,
    WLTrackerReAndComStatus_Succeed = 1,
    WLTrackerReAndComStatus_Draft   = 2,
    WLTrackerReAndComStatus_Discard = 3
};

NS_ASSUME_NONNULL_BEGIN

@interface WLTrackerRepostAndComment : NSObject

@property (class, nonatomic, assign) WLTrackerFeedSource feedSource;

+ (void)appendTrackerWithDraft:(WLDraftBase *)draft
                        status:(WLTrackerReAndComStatus)status;

@end

NS_ASSUME_NONNULL_END
