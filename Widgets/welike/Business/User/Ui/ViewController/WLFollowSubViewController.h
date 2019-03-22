//
//  WLFollowSubViewController.h
//  welike
//
//  Created by fan qi on 2018/5/13.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTableViewController.h"

typedef NS_ENUM(NSInteger, WLFollowType) {
    WLFollowType_Followed,
    WLFollowType_Following
};

@interface WLFollowSubViewController : WLTableViewController

- (instancetype)initWithUserID:(NSString *)userID followType:(WLFollowType)followType;

- (void)display;

@end
