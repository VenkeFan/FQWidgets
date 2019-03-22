//
//  WLTrackerSearch.h
//  welike
//
//  Created by fan qi on 2018/12/11.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLTracker.h"

@class WLPostBase;

NS_ASSUME_NONNULL_BEGIN

@interface WLTrackerSearch : NSObject

+ (void)appendTrackerSearchRecommend;
+ (void)appendTrackerSearchResult:(NSString *)searchKey;
+ (void)appendTrackerSearchDetail:(NSString *)searchKey userID:(NSString *)userID index:(NSInteger)index;;
+ (void)appendTrackerSearchDetail:(NSString *)searchKey post:(WLPostBase *)post index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
