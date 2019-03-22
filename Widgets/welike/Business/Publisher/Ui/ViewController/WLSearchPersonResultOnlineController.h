//
//  WLSearchPersonResultOnlineController.h
//  welike
//
//  Created by gyb on 2018/5/5.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNavBarBaseViewController.h"
#import "WLTableViewController.h"

@class WLContact;
@interface WLSearchPersonResultOnlineController : WLTableViewController


@property (copy,nonatomic) NSString *searchStr;

@property (nonatomic,copy) void(^select)(WLContact *contact);

@end
