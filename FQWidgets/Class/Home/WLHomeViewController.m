//
//  WLHomeViewController.m
//  WeLike
//
//  Created by fan qi on 2018/3/27.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLHomeViewController.h"
#import "FQRefreshHeader.h"
#import "UIScrollView+FQExtension.h"

static NSString * const reuseCellID = @"WLFeedCell";

@interface WLHomeViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewEmptyDelegate, UIScrollViewEmptyDataSource> {
    NSInteger _random;
}

@property (nonatomic, copy) NSArray *dataArray;
@property (nonatomic, weak) UITableView *tableView;

@end

@implementation WLHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor purpleColor];

    [self.tableView.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Network

- (void)refreshData {
    _random = [self randomNumber];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.tableView reloadEmptyData];
        [self.tableView.mj_header endRefreshing];
    });
}

- (void)loadMoreData {
    
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCellID];
    
    return cell;
}

#pragma mark - UIScrollViewEmptyDelegate & UIScrollViewEmptyDataSource

- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView {
    [self.tableView.mj_header beginRefreshing];
}

- (UIImage *)imageForEmptyDataSource:(UIScrollView *)scrollView {
    return _random == 0 ? [UIImage imageNamed:@"network_error"] : [UIImage imageNamed:@"empty_data"];
}

- (NSString *)descriptionForEmptyDataSource:(UIScrollView *)scrollView {
    return _random == 0 ? @"Network connection error please refresh and try again" : @"";
}

- (NSString *)buttonTitleForEmptyDataSource:(UITableView *)tableView {
    return _random == 0 ? @"Refresh" : @"";
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavBarHeight - kTabBarHeight)];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.emptyDelegate = self;
        tableView.emptyDataSource = self;
        tableView.rowHeight = 50;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseCellID];
        [self.view addSubview:tableView];
        _tableView = tableView;
        
        tableView.mj_header = [FQRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
        
        MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self
                                                                                 refreshingAction:@selector(loadMoreData)];
        [footer setTitle:@"上拉加载更多" forState:MJRefreshStateIdle];
        [footer setTitle:@"上拉加载更多" forState:MJRefreshStatePulling];
        [footer setTitle:@"正在加载" forState:MJRefreshStateRefreshing];
        tableView.mj_footer = footer;
    }
    return _tableView;
}

- (NSInteger)randomNumber {
    return arc4random() % 2;
}

@end
