//
//  WLTrackerEditProfile.m
//  welike
//
//  Created by fan qi on 2018/11/12.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLTrackerEditProfile.h"
#import "WLTracker.h"

#define kWLTrackerEditProfileEventIDKey                  @"5001017"

@implementation WLTrackerEditProfile

+ (void)appendTrackerWithEditAction:(WLTrackerEditProfileAction)action {
    [self p_appendTrackerWithEventInfo:@{@"action": @(action)}];
}

+ (void)appendTrackerWithEditResult:(WLTrackerEditProfileResult)result {
    [self p_appendTrackerWithEventInfo:@{@"action": @(WLTrackerEditProfileAction_Response),
                                         @"result": @(result)}];
}

+ (void)p_appendTrackerWithEventInfo:(NSDictionary *)eventInfo {
    [[WLTracker getInstance] appendEventId:kWLTrackerEditProfileEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

@end
