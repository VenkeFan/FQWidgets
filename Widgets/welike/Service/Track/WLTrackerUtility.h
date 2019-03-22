//
//  WLTrackerUtility.h
//  welike
//
//  Created by fan qi on 2018/11/1.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLPostBase;

#define kWLTrackerPostReadDuration            1.0

typedef NSString* WLTrackerFeedSubType;

typedef NS_ENUM(NSInteger, WLTrackerFeedSource) {
    WLTrackerFeedSource_Unknown,
    
    WLTrackerFeedSource_Home                        = 1, ///< Following
    
    WLTrackerFeedSource_Discover_Hot                = 2, ///< Trending
    WLTrackerFeedSource_Discover_Latest             = 3, ///< Rising
    
    WLTrackerFeedSource_Search_Latest               = 4,
    WLTrackerFeedSource_Search_Posts                = 5,
    
    WLTrackerFeedSource_Location_Hot                = 6,
    WLTrackerFeedSource_Location_Latest             = 7,
    
    WLTrackerFeedSource_Topic_Hot                   = 8,
    WLTrackerFeedSource_Topic_Latest                = 9,
    
    WLTrackerFeedSource_User_Detail                 = 10,
    
    WLTrackerFeedSource_User_Likes                  = 11,
    WLTrackerFeedSource_User_Posts                  = 12,
    
    WLTrackerFeedSource_Topic_Top                   = 17,
    
    WLTrackerFeedSource_UnLogin                     = 18,
    
    WLTrackerFeedSource_FeedDetail                  = 50,
    WLTrackerFeedSource_FeedDetail_Comments         = 51,
    WLTrackerFeedSource_CommentDetail_Comments      = 52,
    
    WLTrackerFeedSource_VideoPlayer                 = 53,
    WLTrackerFeedSource_Notification                = 54,
    
    WLTrackerFeedSource_FeedDetail_Bottom           = 55,
    WLTrackerFeedSource_CommentDetail_Bottom        = 56,
    
    WLTrackerFeedSource_Advice_Home                 = 57,
    WLTrackerFeedSource_Advice_FullScreen           = 58,
    WLTrackerFeedSource_Advice_Discovery            = 59,
    
    WLTrackerFeedSource_Contact                     = 60,
    WLTrackerFeedSource_User_Following              = 61,
    WLTrackerFeedSource_User_Follow                 = 62,
    WLTrackerFeedSource_Advice_More                 = 63,
    WLTrackerFeedSource_Me                          = 64,
    WLTrackerFeedSource_Setting_Report              = 65,
    WLTrackerFeedSource_IM_Message                  = 66,
};

#define kWLTrackerFeedSubType_InterestVideo          @"a"
#define kWLTrackerFeedSubType_InterestForyou         @"0"
#define kWLTrackerFeedSubType_VideoSimilar           @"b"


typedef NS_ENUM(NSInteger, WLTrackerRepostType) {
    WLTrackerRepostType_Text        = 1,
    WLTrackerRepostType_Picture     = 2,
    WLTrackerRepostType_Video       = 3,
    WLTrackerRepostType_PostStatus  = 5,
    WLTrackerRepostType_Poll        = 6,
    WLTrackerRepostType_Other       = 7,
    WLTrackerRepostType_Long        = 9,
    WLTrackerRepostType_Comment     = 10
};

NS_ASSUME_NONNULL_BEGIN

extern NSString * trackerFeedSource(WLTrackerFeedSource source, __nullable WLTrackerFeedSubType subType);
extern WLTrackerRepostType trackerPostType(WLPostBase *postModel);
extern BOOL swizzleInstanceMethod(Class cls, SEL originalSel, SEL swizzledSel);
extern BOOL swizzleClassMethod(Class cls, SEL originalSel, SEL swizzledSel);
extern NSString *activityNameWithClass(Class cls);
extern NSString *activityNameWithObject(NSObject *obj);

NS_ASSUME_NONNULL_END
