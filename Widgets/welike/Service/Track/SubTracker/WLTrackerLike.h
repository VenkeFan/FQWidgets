//
//  WLTrackerLike.h
//  welike
//
//  Created by fan qi on 2018/11/6.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLTracker.h"

@class WLPostBase;

NS_ASSUME_NONNULL_BEGIN

@interface WLTrackerLike : NSObject

@property (class, nonatomic, assign) WLTrackerFeedSource feedSource;

+ (void)appendTrackerLikePost:(WLPostBase *)post;
+ (void)appendTrackerLikeCommentOrReplay:(NSString *)comOrReplyID;

@end

NS_ASSUME_NONNULL_END
