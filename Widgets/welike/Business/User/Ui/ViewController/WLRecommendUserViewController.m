//
//  WLRecommendUserViewController.m
//  welike
//
//  Created by fan qi on 2018/12/13.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLRecommendUserViewController.h"
#import "WLUsersManager.h"
#import "WLRecommendUsersProvider.h"
#import "WLUserDetailViewController.h"
#import "WLFollowCell.h"

static NSString * const reuseCellID = @"WLFollowCellID";

@interface WLRecommendUserViewController () <WLUsersManagerDelegate>

@property (nonatomic, strong) WLUsersManager *userManager;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation WLRecommendUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [AppContext getStringForKey:@"feed_recommend_user" fileName:@"feed"];
    
    [self.tableView registerClass:[WLFollowCell class] forCellReuseIdentifier:reuseCellID];
    self.tableView.rowHeight = kFollowUserCellHeight;
    [self addTarget:self refreshAction:@selector(refreshData) moreAction:@selector(loadMoreData)];
    
    [self beginRefresh];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.tableView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight - kNavBarHeight);
}

#pragma mark - Network

- (void)refreshData {
    [self.userManager tryRefreshUsersWithKeyId:nil];
}

- (void)loadMoreData {
    [self.userManager tryHisUsersWithKeyId:nil];
}

#pragma mark - WLUsersManagerDelegate

- (void)onRefreshManager:(WLUsersManager *)manager
                   users:(NSArray *)users
                     kid:(NSString *)kid
                newCount:(NSInteger)newCount
                    last:(BOOL)last
                 errCode:(NSInteger)errCode {
    [self endRefresh];
    
    if (users.count > 0) {
        [self.dataArray removeAllObjects];
    }
    
    if (errCode != ERROR_SUCCESS) {
        self.tableView.emptyType = WLScrollEmptyType_Empty_Network;
        [self.tableView reloadData];
        [self.tableView reloadEmptyData];
        return;
    }
    
    self.tableView.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
    
    [self.dataArray addObjectsFromArray:users];
    
    if (self.dataArray.count == 0) {
        self.tableView.emptyType = WLScrollEmptyType_Empty_Data;
    }
    
    [self.tableView reloadData];
    [self.tableView reloadEmptyData];
}

- (void)onReceiveHisManager:(WLUsersManager *)manager
                      users:(NSArray *)users
                        kid:(NSString *)kid
                       last:(BOOL)last
                    errCode:(NSInteger)errCode {
    [self.tableView endLoadMore];
    
    if (errCode != ERROR_SUCCESS) {
        self.tableView.refreshFooterView.result = WLRefreshFooterResult_Error;
        return;
    }
    
    self.tableView.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
    
    if (users.count > 0) {
        [self.dataArray addObjectsFromArray:users];
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WLFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCellID];
    if (self.dataArray.count > indexPath.row) {
        [cell setItemModel:self.dataArray[indexPath.row]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithOriginalUserInfo:self.dataArray[indexPath.row]];
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark - Getter

- (WLUsersManager *)userManager {
    if (!_userManager) {
        _userManager = [[WLUsersManager alloc] init];
        [_userManager setDataSourceProvider:[WLRecommendUsersProvider new]];
        _userManager.delegate = self;
    }
    return _userManager;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
