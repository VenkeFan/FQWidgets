//
//  WLTrackerProfile.h
//  welike
//
//  Created by fan qi on 2018/11/12.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WLTrackerProfileActionType) {
    WLTrackerProfileActionType_Display          = 1,
    WLTrackerProfileActionType_Icon             = 2,
    WLTrackerProfileActionType_Authentication   = 3,
    WLTrackerProfileActionType_Interest         = 4,
    WLTrackerProfileActionType_Following        = 5,
    WLTrackerProfileActionType_Followers        = 6,
    WLTrackerProfileActionType_EditProfile      = 7,
    WLTrackerProfileActionType_More             = 8,
    WLTrackerProfileActionType_Follow           = 9,
    WLTrackerProfileActionType_Message          = 10,
    WLTrackerProfileActionType_SnakeDisplay     = 11,
    WLTrackerProfileActionType_SnakeApply       = 12,
    WLTrackerProfileActionType_Posts            = 13,
    WLTrackerProfileActionType_Likes            = 14,
    WLTrackerProfileActionType_Pictures         = 15,
    WLTrackerProfileActionType_Pic_Tran         = 16
};

typedef NS_ENUM(NSInteger, WLTrackerProfileIconType) {
    WLTrackerProfileIconType_Facebook       = 1,
    WLTrackerProfileIconType_Instagram      = 2,
    WLTrackerProfileIconType_YouTube        = 3
};

typedef NS_ENUM(NSInteger, WLTrackerProfileSource) {
    WLTrackerProfileSource_None     = -1,
    WLTrackerProfileSource_Me       = 1,
    WLTrackerProfileSource_Other    = 2
};

typedef NS_ENUM(NSInteger, WLTrackerProfileMoreType) {
    WLTrackerProfileMoreType_None       = -1,
    WLTrackerProfileMoreType_Share      = 1,
    WLTrackerProfileMoreType_Other      = 2
};

typedef NS_ENUM(NSInteger, WLTrackerProfileUserType) {
    WLTrackerProfileUserType_None       = -1,
    WLTrackerProfileUserType_Master     = 1,
    WLTrackerProfileUserType_Visitor    = 2
};

NS_ASSUME_NONNULL_BEGIN

@interface WLTrackerProfile : NSObject

+ (void)appendTrackerWithProfileAction:(WLTrackerProfileActionType)action
                            pageSource:(WLTrackerProfileSource)pageSource
                              moreType:(WLTrackerProfileMoreType)moreType
                                userID:(NSString *)userID;

@end

NS_ASSUME_NONNULL_END
