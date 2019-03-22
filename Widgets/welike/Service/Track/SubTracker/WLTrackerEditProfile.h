//
//  WLTrackerEditProfile.h
//  welike
//
//  Created by fan qi on 2018/11/12.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WLTrackerEditProfileAction) {
    WLTrackerEditProfileAction_Display          = 1,
    WLTrackerEditProfileAction_Avatar           = 2,
    WLTrackerEditProfileAction_Name             = 3,
    WLTrackerEditProfileAction_Gender           = 4,
    WLTrackerEditProfileAction_Intro            = 5,
    WLTrackerEditProfileAction_Interest         = 6,
    WLTrackerEditProfileAction_Icon             = 7,
    WLTrackerEditProfileAction_SnakeDisplay     = 8,
    WLTrackerEditProfileAction_SnakeApply       = 9,
    WLTrackerEditProfileAction_Link             = 10,
    WLTrackerEditProfileAction_Submit           = 11,
    WLTrackerEditProfileAction_Response         = 12
};

typedef NS_ENUM(NSInteger, WLTrackerEditProfileResult) {
    WLTrackerEditProfileResult_Succeed      = 1,
    WLTrackerEditProfileResult_Failed       = 2
};

NS_ASSUME_NONNULL_BEGIN

@interface WLTrackerEditProfile : NSObject

+ (void)appendTrackerWithEditAction:(WLTrackerEditProfileAction)action;
+ (void)appendTrackerWithEditResult:(WLTrackerEditProfileResult)result;

@end

NS_ASSUME_NONNULL_END
