//
//  WLDiscoveryViewController.m
//  WeLike
//
//  Created by fan qi on 2018/3/28.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLDiscoveryViewController.h"
#import "WLTimelineViewModel.h"
#import "WLFeedCell.h"
#import "FQRefreshHeader.h"
#import "YYFPSLabel.h"

static NSString *reuseCellID = @"WLDiscoveryFeedCell";

@interface WLDiscoveryViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) WLTimelineViewModel *viewModel;
@property (nonatomic, strong) NSArray<WLFeedModel *> *dataArray;

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation WLDiscoveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kUIColorFromRGB(0xF6F6F6);
    
    [self.tableView.mj_header beginRefreshing];
    
    {
        YYFPSLabel *fpsLabel = [[YYFPSLabel alloc] initWithFrame:CGRectMake(10, 20, 0, 0)];
        [fpsLabel sizeToFit];
        [self.view addSubview:fpsLabel];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Network

- (void)refreshData {
    [self.viewModel fetchListWithFinished:^(BOOL succeed, BOOL hasMore) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (succeed) {
                [self.tableView reloadData];
                [self.tableView.mj_header endRefreshing];
            } else {
                [FQProgressHUDHelper showErrorWithMessage:@"刷新数据错误"];
            }
            
            self.tableView.mj_footer.hidden = !hasMore;
        });
    }];
}

- (void)loadMoreData {
    [self.viewModel fetchMoreWithFinished:^(BOOL succeed, BOOL hasMore) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (succeed) {
                [self.tableView reloadData];
                [self.tableView.mj_footer endRefreshing];
            } else {
                [FQProgressHUDHelper showErrorWithMessage:@"获取更多数据错误"];
            }
            
            self.tableView.mj_footer.hidden = !hasMore;
        });
    }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataArray[indexPath.row].layout.cellHeight; // cellPaddingTop + cellAvatarSize + cellMarginY;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WLFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCellID];
    [cell setItemModel:self.dataArray[indexPath.row]];
    
    return cell;
}

#pragma mark - Getter

- (WLTimelineViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [WLTimelineViewModel new];
    }
    return _viewModel;
}

- (NSArray *)dataArray {
    return self.viewModel.dataArray;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavBarHeight - kTabBarHeight)];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[WLFeedCell class] forCellReuseIdentifier:reuseCellID];
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

@end
