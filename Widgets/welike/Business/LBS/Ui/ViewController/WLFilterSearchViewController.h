//
//  WLFilterSearchViewController.h
//  welike
//
//  Created by gyb on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTableViewController.h"
#import <CoreLocation/CoreLocation.h>

@class RDLocation;
@interface WLFilterSearchViewController : WLTableViewController


@property (copy,nonatomic) NSString *searchStr;
@property (assign,nonatomic) CLLocationCoordinate2D coordinate;


@property (nonatomic,copy) void(^select)(RDLocation *loction);


-(void)research;

@end
