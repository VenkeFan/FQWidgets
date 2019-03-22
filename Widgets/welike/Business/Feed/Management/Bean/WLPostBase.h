//
//  WLPostBase.h
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLRichContent.h"
#import "RDLocation.h"
#import "WLUser.h"
#import "WLTrackerFeed.h"
#import "WLUserBase.h"

typedef NS_ENUM(NSInteger, WELIKE_POST_TYPE)
{
    WELIKE_POST_TYPE_TEXT = 1,
    WELIKE_POST_TYPE_PIC = 2,
    WELIKE_POST_TYPE_VIDEO = 3,
    WELIKE_POST_TYPE_LINK = 4,
    WELIKE_POST_TYPE_FORWARD = 5,
    WELIKE_POST_TYPE_POLL = 6,
    WELIKE_POST_TYPE_ARTICAL = 7
};

@interface WLPostBase : NSObject

@property (nonatomic, copy) NSString *pid;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, assign) WELIKE_POST_TYPE type;
@property (nonatomic, assign) long long time;
@property (nonatomic, copy) NSString *headUrl;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, assign) long long userCreateTime;
@property (nonatomic, assign) WELIKE_USER_GENDER gender;
@property (nonatomic, assign) BOOL following;
@property (nonatomic, assign) BOOL follower;
@property (nonatomic, copy) NSString *from;
@property (nonatomic, strong) RDLocation *location;
@property (nonatomic, assign) long long likeCount;
@property (nonatomic, assign) BOOL like;
@property (nonatomic, assign) long long superLikeExp;
@property (nonatomic, assign) BOOL deleted;
@property (nonatomic, assign) BOOL hot;
@property (nonatomic, assign) BOOL isTop;
@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, assign) NSInteger forwardCount;
@property (nonatomic, assign) NSInteger readCount;
@property (nonatomic, assign) NSInteger vip;
@property (nonatomic, strong) WLRichContent *richContent;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, copy) NSString *sequenceId;
@property (nonatomic, strong) NSArray<WLUserHonorModel *> *userHonors;

- (NSString *)encodeToJSONString;
+ (WLPostBase *)decodeFromJSONString:(NSString *)string;
+ (WLPostBase *)parseFromNetworkJSON:(NSDictionary *)json;

@end

@interface WLPostBase (WLTracker)

@property (nonatomic, assign) WLTrackerFeedSource trackerSource;
@property (nonatomic, assign) WLTrackerFeedSubType trackerSubType;

@end
