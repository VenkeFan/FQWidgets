//
//  WLDiscoveryViewController.m
//  WeLike
//
//  Created by fan qi on 2018/3/28.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLDiscoveryViewController.h"
#import "FQRefreshHeader.h"
#import "FQImageButton.h"

@interface WLDiscoveryViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation WLDiscoveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    [self.tableView.mj_header beginRefreshing];
    
    
    
    {
        FQImageButton *imgBtn = [FQImageButton buttonWithType:UIButtonTypeCustom];
        imgBtn.layer.borderWidth = 1;
        imgBtn.layer.borderColor = [UIColor blackColor].CGColor;
        imgBtn.titleLabel.backgroundColor = [UIColor redColor];
        imgBtn.imageView.backgroundColor = [UIColor greenColor];
        
        imgBtn.frame = CGRectMake(20, kNavBarHeight * 0.5, 0, 0);
        imgBtn.imageOrientation = FQImageButtonOrientation_Right;
        imgBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [imgBtn setImage:[UIImage imageNamed:@"camera_photo_selected"] forState:UIControlStateSelected];
        [imgBtn setImage:[UIImage imageNamed:@"camera_photo_unselected"] forState:UIControlStateNormal];
        [imgBtn setTitleColor:kBodyFontColor forState:UIControlStateNormal];
        imgBtn.titleLabel.font = [UIFont systemFontOfSize:kSizeScale(11)];
        imgBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [imgBtn setTitle:@"9" forState:UIControlStateNormal];
        [imgBtn sizeToFit];
        
        [self.view addSubview:imgBtn];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Network

- (void)refreshData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.mj_header endRefreshing];
    });
}

- (void)loadMoreData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.mj_footer endRefreshing];
    });
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    return cell;
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavBarHeight - kTabBarHeight)];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.rowHeight = 50;
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

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
