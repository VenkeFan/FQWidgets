//
//  WLTableViewController.h
//  welike
//
//  Created by fan qi on 2018/4/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLBasicTableView.h"

@interface WLTableViewController : WLNavBarBaseViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewEmptyDelegate, UIScrollViewEmptyDataSource>

@property (nonatomic, strong, readonly) WLBasicTableView *tableView;

- (void)addTarget:(id)target refreshAction:(SEL)refreshAction moreAction:(SEL)moreAction;

- (void)beginRefresh;
- (void)endRefresh;


@end
