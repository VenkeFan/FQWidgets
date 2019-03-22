//
//  WLTopicSearchViewController.h
//  welike
//
//  Created by gyb on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNavBarBaseViewController.h"


@class WLTopicInfoModel;
@interface WLTopicSearchViewController : WLNavBarBaseViewController

@property (nonatomic,copy) void(^select)(WLTopicInfoModel *topic);

@property (nonatomic,copy) void(^hasIput)(void);


@end
