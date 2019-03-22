//
//  WLBasicTableView.m
//  welike
//
//  Created by fan qi on 2018/5/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLBasicTableView.h"

@interface WLBasicTableView () <GBRefreshTableHeaderViewDelegate>

@property (nonatomic, strong, readwrite) GBRefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, strong, readwrite) WLRefreshFooterView *refreshFooterView;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL refreshAction;
@property (nonatomic, assign) SEL moreAction;

@property (nonatomic, assign) CGPoint preOffset;

@end

@implementation WLBasicTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.backgroundColor = [UIColor whiteColor];
        self.estimatedRowHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        self.estimatedSectionFooterHeight = 0;
        self.delegate = self;
        self.dataSource = self;
        self.emptyDelegate = self;
        self.emptyDataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        if (@available(iOS 11.0, *)){
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } 
    }
    return self;
}

- (void)dealloc {
    
}

#pragma mark - Public

- (void)addTarget:(id)target refreshAction:(SEL)refreshAction moreAction:(SEL)moreAction {
    _target = target;
    
    if (refreshAction) {
        _refreshAction = refreshAction;
        [self p_addHeader];
    }
    
    if (moreAction) {
        _moreAction = moreAction;
        [self p_addFooter];
    }
}

- (void)beginRefresh {    
    if (self.disableHeaderRefresh || self.refreshHeaderView.hidden) {
        self.loading = YES;
        [self p_executeAction];
    } else {
        _headerRefreshing = YES;
        [self.refreshHeaderView manualFresh:self];
    }
}

- (void)endRefresh {
    self.loading = _headerRefreshing = NO;
    [self.refreshHeaderView GBRefreshScrollViewStopLoading:self];
}

- (void)endLoadMore {
    self.refreshFooterView.status = WLRefreshFooterStatus_Idle;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UITableViewCell new];
}

#pragma mark - UIScrollViewEmptyDelegate

- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView {
    [self beginRefresh];
}

#pragma mark - GBRefreshTableHeaderViewDelegate

- (void)GBRefreshScrollViewStartLoading {
    [self p_executeAction];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.refreshHeaderView GBRefreshScrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.refreshHeaderView GBRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.refreshHeaderView GBRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_headerRefreshing) {
        return;
    }
    
    if (self.refreshFooterView.result == WLRefreshFooterResult_NoMore) {
        return;
    }
    
    if (self.refreshFooterView.status == WLRefreshFooterStatus_Refreshing) {
        return;
    }
    
    if (scrollView.contentSize.height > CGRectGetHeight(scrollView.bounds)) {
        if (scrollView.contentOffset.y > scrollView.contentSize.height - CGRectGetHeight(scrollView.bounds) - CGRectGetHeight(self.refreshFooterView.frame)) {
            self.refreshFooterView.status = WLRefreshFooterStatus_Refreshing;
        }
    } else if (scrollView.contentOffset.y >= 0) {
        self.refreshFooterView.status = WLRefreshFooterStatus_Refreshing;
    }
}

#pragma mark - Private

- (void)p_executeAction {
    if (_target && [_target respondsToSelector:_refreshAction]) {
        IMP imp = [_target methodForSelector:_refreshAction];
        void (*fun)(id, SEL) = (void *)imp;
        fun(_target, _refreshAction);
    }
}

- (void)p_addHeader {
    if (self.disableHeaderRefresh) {
        return;
    }
    
    if (_refreshHeaderView) {
        [_refreshHeaderView removeFromSuperview];
    }
    
    _refreshHeaderView = [[GBRefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) type:Normal];
    _refreshHeaderView.delegate = self;
    [self addSubview:_refreshHeaderView];
}

- (void)p_addFooter {
    if (_refreshFooterView) {
        [_refreshFooterView removeFromSuperview];
    }

    _refreshFooterView = [[WLRefreshFooterView alloc] init];
    [_refreshFooterView addTarget:_target refreshAction:_moreAction];
    [self addSubview:_refreshFooterView];
}

#pragma mark - Setter

- (void)setDisableHeaderRefresh:(BOOL)disableHeaderRefresh {
    _disableHeaderRefresh = disableHeaderRefresh;
    
    if (disableHeaderRefresh) {
        [_refreshHeaderView removeFromSuperview];
        _refreshHeaderView = nil;
    } else {
        if (_refreshAction) {
            [self p_addHeader];
        }
    }
}

@end
