//
//  WLTracker.h
//  welike
//
//  Created by 刘斌 on 2018/6/5.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLTrackerUtility.h"

typedef NS_ENUM(NSInteger, WELIKE_APP_ENTRANCE)
{
    WELIKE_APP_ENTRANCE_NORMAL = 0,
    WELIKE_APP_ENTRANCE_SCHEME = 1,
    WELIKE_APP_ENTRANCE_MSG_PUSH = 2,
    WELIKE_APP_ENTRANCE_IM_PUSH = 3,
    WELIKE_APP_ENTRANCE_OFFICIAL_PUSH = 4
};

@interface WLTracker : NSObject

@property (nonatomic, assign) WELIKE_APP_ENTRANCE entrance;

+ (WLTracker *)getInstance;

- (void)appendEventId:(NSString *)eventId eventInfo:(NSDictionary *)eventInfo;
- (void)synchronize;

@end
