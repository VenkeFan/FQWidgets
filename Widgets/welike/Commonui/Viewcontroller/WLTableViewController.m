//
//  WLTableViewController.m
//  welike
//
//  Created by fan qi on 2018/4/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTableViewController.h"

@interface WLTableViewController ()

@end

@implementation WLTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[WLBasicTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.emptyDelegate = self;
    _tableView.emptyDataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    _tableView.backgroundColor = kLightBackgroundViewColor;
    [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Public

- (void)addTarget:(id)target refreshAction:(SEL)refreshAction moreAction:(SEL)moreAction {
    [self.tableView addTarget:target refreshAction:refreshAction moreAction:moreAction];
}

- (void)beginRefresh {
    [self.tableView beginRefresh];
}

- (void)endRefresh {
    [self.tableView endRefresh];
}


#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UITableViewCell new];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.tableView scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.tableView scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.tableView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.tableView scrollViewDidEndDecelerating:scrollView];
}

@end
