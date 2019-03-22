//
//  WLPushSetting.h
//  welike
//
//  Created by luxing on 2018/5/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kRepostNotificationKey          @"RepostNotificationKey"
#define kCommentNotificationKey         @"CommentNotificationKey"
#define kLikeNotificationKey            @"LikeNotificationKey"
#define kFriendNotificationKey          @"FriendNotificationKey"
#define kFollowingNotificationKey       @"FollowingNotificationKey"
#define kDisturbNotificationKey         @"DisturbNotificationKey"
#define kTimeNotificationKey            @"TimeNotificationKey"

typedef NS_ENUM(NSInteger, WLPushSettingType) {
    WLPushSettingTypePost = 1,
    WLPushSettingTypeComment,
    WLPushSettingTypeLike,
    WLPushSettingTypeFriend,
    WLPushSettingTypeFollowing = 6,
    WLPushSettingTypeDisturb = 7,
};

@class WLPushSetting;

typedef void (^refreshPushSetting)(WLPushSetting *);

@interface WLPushSetting : NSObject

@property (nonatomic, assign) BOOL repostSwitch;
@property (nonatomic, assign) BOOL commentSwitch;
@property (nonatomic, assign) BOOL likeSwitch;
@property (nonatomic, assign) BOOL friendSwitch;
@property (nonatomic, assign) BOOL followingSwitch;
@property (nonatomic, assign) BOOL disturbSwitch;

@property (nonatomic, assign) NSUInteger fromHours;
@property (nonatomic, assign) NSUInteger fromMinute;
@property (nonatomic, assign) NSUInteger toHours;
@property (nonatomic, assign) NSUInteger toMinute;

+ (WLPushSetting *)defaultPushSetting;

- (NSMutableDictionary *)toNetworkJSON;

+ (WLPushSetting *)parseFromNetworkJSON:(NSDictionary *)result;

@end
