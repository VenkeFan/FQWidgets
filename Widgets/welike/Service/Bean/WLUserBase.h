//
//  WLUserBase.h
//  welike
//
//  Created by 刘斌 on 2018/4/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLUserHonorModel;

typedef NS_ENUM(NSInteger, WELIKE_USER_GENDER)
{
    WELIKE_USER_GENDER_UNKNOWN = -1,
    WELIKE_USER_GENDER_MALE = 0,
    WELIKE_USER_GENDER_FEMALE
};

typedef NS_ENUM(NSInteger, WLUserLinkType) {
    WLUserLinkType_Facebook,
    WLUserLinkType_Instagram,
    WLUserLinkType_YouTube
};

typedef NS_ENUM(NSInteger, WLUserLevel) {
    WLUserLevel_Normal          = 0,
    WLUserLevel_Star            = 1,
    WLUserLevel_Influencer      = 2
};

#define kUserNoneVIP                (1)
#define kUserVIPStarMinimum         (1000000)
#define kUserVIPStarMaximum         (1999999)

#define USER_JSON_KEY_UID                            @"id"
#define USER_JSON_KEY_NICK_NAME                      @"nickName"
#define USER_JSON_KEY_HEAD                           @"avatarUrl"
#define USER_JSON_KEY_GENDER                         @"sex"
#define USER_JSON_KEY_POSTS_COUNT                    @"postsCount"
#define USER_JSON_KEY_FOLLOW_USERS_COUNT             @"followUsersCount"
#define USER_JSON_KEY_FOLLOWED_USERS_COUNT           @"followedUsersCount"
#define USER_JSON_KEY_LIKE_MY_POSTS_COUNT            @"likedCount"
#define USER_JSON_KEY_MY_LIKED_POSTS_COUNT           @"likePostsCount"
#define USER_JSON_KEY_VIP                            @"vip"
#define USER_JSON_KEY_INTRO                          @"introduction"
#define USER_JSON_KEY_INTERESTS                      @"interests"
#define USER_JSON_KEY_LINKS                          @"links"
#define USER_JSON_KEY_LEVEL                          @"curLevel"

@interface WLUserBase : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *headUrl;
@property (nonatomic, assign) WELIKE_USER_GENDER gender;
@property (nonatomic, copy) NSString *introduction;
@property (nonatomic, assign) NSInteger postsCount;
@property (nonatomic, assign) NSInteger followUsersCount;
@property (nonatomic, assign) NSInteger followedUsersCount;
@property (nonatomic, assign) NSInteger likedMyPostsCount;
@property (nonatomic, assign) NSInteger myLikedPostsCount;
@property (nonatomic, assign) NSInteger vip;
@property (nonatomic, strong) NSArray *interests;
@property (nonatomic, strong) NSArray *links;
@property (nonatomic, assign) WLUserLevel curLevel;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, assign) BOOL canChangeCover;
@property (nonatomic, strong) NSArray<WLUserHonorModel *> *honors;

@end

@interface WLUserLinkModel : NSObject

@property (nonatomic, copy) NSString *linkId;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, assign) WLUserLinkType linkType;

+ (instancetype)parseWithNetworkJson:(NSDictionary *)json;

@end

@interface WLUserHonorModel : NSObject

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *picUrl;
@property (nonatomic, copy) NSString *forwardUrl;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger type;

+ (instancetype)parseWithNetworkJson:(NSDictionary *)json;
+ (NSArray<WLUserHonorModel *> *)honorsFromNetworkJSON:(NSArray *)honorJsons;

@end
