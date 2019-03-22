//
//  WLTrackerDayLive.h
//  welike
//
//  Created by fan qi on 2018/10/25.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WLTrackerDayLiveOpenType) {
    WLTrackerDayLiveOpenType_Other  = 1,
    WLTrackerDayLiveOpenType_Push   = 2
};

NS_ASSUME_NONNULL_BEGIN

@interface WLTrackerDayLive : NSObject

+ (void)appendTrackWithOpenType:(WLTrackerDayLiveOpenType)openType;

@end

NS_ASSUME_NONNULL_END
