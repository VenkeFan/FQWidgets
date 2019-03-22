//
//  WLTrackerActivity.h
//  welike
//
//  Created by fan qi on 2018/11/12.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLTracker.h"

typedef NS_ENUM(NSInteger, WLTrackerActivityType) {
    WLTrackerActivityType_Appear        = 1,
    WLTrackerActivityType_Transition    = 2
};

NS_ASSUME_NONNULL_BEGIN

@interface WLTrackerActivity : NSObject

+ (void)appendTrackerWithActivityType:(WLTrackerActivityType)type
                                  cls:(Class)cls
                             duration:(NSTimeInterval)duration;

+ (void)appendTrackerWithActivityType:(WLTrackerActivityType)type
                                  obj:(NSObject *)obj
                             duration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
