//
//  WLSearchLocationViewController.h
//  welike
//
//  Created by gyb on 2018/5/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNavBarBaseViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "WLTableViewController.h"



@class RDLocation;
@interface WLSearchLocationViewController : WLTableViewController


@property (weak,nonatomic) id delegate;



@property (nonatomic,copy) void(^select)(RDLocation *locationInfo);


@end
