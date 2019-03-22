//
//  WLFollowViewController.h
//  welike
//
//  Created by fan qi on 2018/5/13.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNavBarBaseViewController.h"
#import "WLFollowSubViewController.h"

@interface WLFollowViewController : WLNavBarBaseViewController

- (instancetype)initWithUserID:(NSString *)userID followType:(WLFollowType)followType;

@end
