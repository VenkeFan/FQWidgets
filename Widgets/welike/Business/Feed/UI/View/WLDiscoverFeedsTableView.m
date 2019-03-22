//
//  WLDiscoverFeedsTableView.m
//  welike
//
//  Created by fan qi on 2018/6/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLDiscoverFeedsTableView.h"

@interface WLDiscoverFeedsTableView () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation WLDiscoverFeedsTableView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.showsVerticalScrollIndicator = YES;
        self.tableView.disableHeaderRefresh = NO;
        
        self.displayRefreshHeaderView = NO;
    }
    return self;
}

#pragma mark - Public

- (void)setDisplayRefreshHeaderView:(BOOL)displayRefreshHeaderView {
    _displayRefreshHeaderView = displayRefreshHeaderView;
    
    self.tableView.refreshHeaderView.hidden = !displayRefreshHeaderView;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableView tableView:tableView numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableView tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableView tableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.tableView scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.tableView scrollViewDidScroll:scrollView];
    
    if (self.superCell.superScrollViewScrolling) {
        scrollView.contentOffset = CGPointZero;
        return;
    }
    
    if (scrollView.contentOffset.y <= 0) {
        self.superCell.subScrollViewScrolling = NO;
    } else {
        self.superCell.subScrollViewScrolling = YES;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.tableView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.tableView scrollViewDidEndDecelerating:scrollView];
}

@end
