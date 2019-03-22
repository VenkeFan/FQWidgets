//
//  WLTrackerBanner.h
//  welike
//
//  Created by fan qi on 2018/11/13.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLBannerModel;

typedef NS_ENUM(NSInteger, WLTrackerBannerAction) {
    WLTrackerBannerAction_Display   = 1,
    WLTrackerBannerAction_Click     = 2
};

typedef NS_ENUM(NSInteger, WLTrackerBannerSource) {
    WLTrackerBannerSource_Unknow    = -1,
    WLTrackerBannerSource_Home      = 1,
    WLTrackerBannerSource_Discover  = 2
};

NS_ASSUME_NONNULL_BEGIN

@interface WLTrackerBanner : NSObject

+ (void)appendTrackerWithBannerAction:(WLTrackerBannerAction)action
                               source:(WLTrackerBannerSource)source;

+ (void)appendTrackerWithBannerAction:(WLTrackerBannerAction)action
                               source:(WLTrackerBannerSource)source
                          bannerModel:(nullable WLBannerModel *)model;

@end

NS_ASSUME_NONNULL_END
