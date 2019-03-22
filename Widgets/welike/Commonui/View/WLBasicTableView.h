//
//  WLBasicTableView.h
//  welike
//
//  Created by fan qi on 2018/5/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+FQEmptyData.h"
#import "WLRefreshFooterView.h"
#import "GBRefreshTableHeaderView.h"

@interface WLBasicTableView : UITableView <UITableViewDelegate, UITableViewDataSource, UIScrollViewEmptyDelegate, UIScrollViewEmptyDataSource>

@property (nonatomic, strong, readonly) GBRefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, strong, readonly) WLRefreshFooterView *refreshFooterView;

- (void)addTarget:(id)target refreshAction:(SEL)refreshAction moreAction:(SEL)moreAction;

- (void)beginRefresh;
- (void)endRefresh;

- (void)endLoadMore;

@property (nonatomic, assign) BOOL disableHeaderRefresh;
@property (nonatomic, assign, readonly, getter=isHeaderRefreshing) BOOL headerRefreshing;
@property (nonatomic, assign, readonly, getter=isFooterRefreshing) BOOL footerRefreshing;

@end
