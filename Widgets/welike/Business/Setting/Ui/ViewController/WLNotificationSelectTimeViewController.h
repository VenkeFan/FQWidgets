//
//  WLNotificationSelectTimeViewController.h
//  welike
//
//  Created by luxing on 2018/5/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNavBarBaseViewController.h"
#import "WLTimeSelectViewModel.h"

@protocol WLNotificationSelectTimeViewDelegate<NSObject>

- (void)refreshNotificationSelectTime:(WLTimeSelectViewModel *)model;

@end

@interface WLNotificationSelectTimeViewController : WLNavBarBaseViewController

@property (nonatomic, weak) id<WLNotificationSelectTimeViewDelegate> delegate;

- (instancetype)initWithTimeSelectModel:(WLTimeSelectViewModel *)model;

@end
