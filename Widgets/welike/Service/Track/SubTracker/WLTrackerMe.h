//
//  WLTrackerMe.h
//  welike
//
//  Created by fan qi on 2018/11/12.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WLTrackerMeActionType) {
    WLTrackerMeActionType_Profile               = 1,
    WLTrackerMeActionType_Following             = 2,
    WLTrackerMeActionType_Followers             = 3,
    WLTrackerMeActionType_Posts                 = 4,
    WLTrackerMeActionType_Mission               = 5,
    WLTrackerMeActionType_Authentication        = 6,
    WLTrackerMeActionType_NewFriends            = 7,
    WLTrackerMeActionType_MyLikes               = 8,
    WLTrackerMeActionType_ShareApp              = 9,
    WLTrackerMeActionType_Feedback              = 10,
    WLTrackerMeActionType_Setting               = 11,
    WLTrackerMeActionType_Draftbox              = 12,
    WLTrackerMeActionType_Display               = 13
};

NS_ASSUME_NONNULL_BEGIN

@interface WLTrackerMe : NSObject

+ (void)appendTrackerWithMeAction:(WLTrackerMeActionType)action;

@end

NS_ASSUME_NONNULL_END
