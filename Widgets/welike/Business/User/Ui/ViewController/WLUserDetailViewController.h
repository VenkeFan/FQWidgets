//
//  WLUserDetailViewController.h
//  welike
//
//  Created by fan qi on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNavBarBaseViewController.h"

@class WLUserBase;

@interface WLUserDetailViewController : WLNavBarBaseViewController

- (instancetype)initWithUserID:(NSString *)userID;
- (instancetype)initWithOriginalUserInfo:(WLUserBase *)originalUserInfo;

@end
