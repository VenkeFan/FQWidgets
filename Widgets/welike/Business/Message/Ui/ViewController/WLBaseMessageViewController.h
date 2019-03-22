//
//  WLBaseMessageViewController.h
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTableViewController.h"
#import "WLMessageTableViewCell.h"
#import "WLUser.h"

#define kMessageTableBottomPading               10.f
#define kMessageSectionHeadHeight               37.f

@interface WLBaseMessageViewController : WLNavBarBaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong, readonly) WLBasicTableView *tableView;

- (instancetype)initWithChat:(WLIMSession *)session;
- (instancetype)initWithUser:(WLUser *)user;

@end
