//
//  WLUserFeedsTableView.m
//  welike
//
//  Created by fan qi on 2018/5/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUserFeedsTableView.h"

@interface WLUserFeedsTableView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong, readwrite) WLFeedTableView *tableView;

@end

@implementation WLUserFeedsTableView

@synthesize hasRefreshed;
@synthesize superCell;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.tableView = [[WLFeedTableView alloc] initWithFrame:frame];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.emptyTop = kDefaultEmptyTop;
        self.tableView.disableHeaderRefresh = YES;
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.tableView.frame = self.bounds;
}

#pragma mark - Public

- (void)setProvider:(id<WLFeedsProvider>)provider userID:(NSString *)userID {
    [self.tableView setDataSourceProvider:provider uid:userID];
}

#pragma mark - WLScrollContentViewProtocol

- (void)refreshData {
    if (!self.hasRefreshed) {
        self.hasRefreshed = YES;
        [self.tableView beginRefresh];
    }
}

- (void)forceRefresh {
    self.hasRefreshed = NO;
    [self refreshData];
}

- (void)reloadMyData {
//    [self.tableView reloadData];
//    [self.tableView reloadEmptyData];
}

- (void)setContentOffset:(CGPoint)offset {
    [self.tableView setContentOffset:offset animated:YES];
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
        scrollView.contentOffset = CGPointZero;
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
