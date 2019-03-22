//
//  WLTrackerBanner.m
//  welike
//
//  Created by fan qi on 2018/11/13.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLTrackerBanner.h"
#import "WLTracker.h"
#import "WLBannerModel.h"

#define kWLTrackerBannerEventIDKey                  @"5001019"

static WLTrackerBannerSource _source = WLTrackerBannerSource_Unknow;

@implementation WLTrackerBanner

+ (void)appendTrackerWithBannerAction:(WLTrackerBannerAction)action
                               source:(WLTrackerBannerSource)source {
    _source = source;
    
    [self appendTrackerWithBannerAction:action
                                 source:source
                            bannerModel:nil];
}

+ (void)appendTrackerWithBannerAction:(WLTrackerBannerAction)action
                               source:(WLTrackerBannerSource)source
                          bannerModel:(nullable WLBannerModel *)model {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(action) forKey:@"action"];
    
    if (model) {
        [eventInfo setObject:@(_source) forKey:@"page_name"];
    } else {
        [eventInfo setObject:@(source) forKey:@"page_name"];
    }
    
    if (model.ID) {
        [eventInfo setObject:model.ID forKey:@"banner_id"];
    }
    if (model.lang) {
        [eventInfo setObject:model.lang forKey:@"banner_la"];
    }
    
    [[WLTracker getInstance] appendEventId:kWLTrackerBannerEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

@end
