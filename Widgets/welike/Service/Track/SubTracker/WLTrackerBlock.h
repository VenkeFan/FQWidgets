//
//  WLTrackerBlock.h
//  welike
//
//  Created by fan qi on 2018/12/11.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLTracker.h"

@class WLPostBase;

typedef NS_ENUM(NSInteger, WLTrackerBlockType) {
    WLTrackerBlockType_Block    = 1,
    WLTrackerBlockType_Unblock  = 2
};

NS_ASSUME_NONNULL_BEGIN

@interface WLTrackerBlock : NSObject

+ (void)appendTrackerWithBlockType:(WLTrackerBlockType)type
                              post:(WLPostBase *)post;

+ (void)appendTrackerWithBlockType:(WLTrackerBlockType)type
                            userID:(NSString *)userID
                            source:(WLTrackerFeedSource)source;

@end

NS_ASSUME_NONNULL_END
