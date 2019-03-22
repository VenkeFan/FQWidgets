//
//  WLTrackerMe.m
//  welike
//
//  Created by fan qi on 2018/11/12.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLTrackerMe.h"
#import "WLTracker.h"

#define kWLTrackerMeEventIDKey                  @"5001016"

@implementation WLTrackerMe

+ (void)appendTrackerWithMeAction:(WLTrackerMeActionType)action {
    [[WLTracker getInstance] appendEventId:kWLTrackerMeEventIDKey
                                 eventInfo:@{@"action": @(action)}];
    [[WLTracker getInstance] synchronize];
}

@end
