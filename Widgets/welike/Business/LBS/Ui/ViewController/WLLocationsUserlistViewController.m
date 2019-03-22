//
//  WLLocationsUserlistViewController.m
//  welike
//
//  Created by gyb on 2018/6/1.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLocationsUserlistViewController.h"
#import "WLUsersManager.h"
#import "WLLocationUserProvider.h"
#import "WLTopicUserCell.h"
#import "WLUserDetailViewController.h"

@interface WLLocationsUserlistViewController () <WLUsersManagerDelegate, UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, strong) WLUsersManager *userManager;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation WLLocationsUserlistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [AppContext getStringForKey:@"topic_user_title" fileName:@"topic"];
    
    self.tableView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight - kNavBarHeight);
    self.tableView.rowHeight = kTopicUserCellHeight;
    [self addTarget:self refreshAction:@selector(refreshData) moreAction:@selector(loadMoreData)];
    [self beginRefresh];
}

#pragma mark - Network

- (void)refreshData {
    [self.userManager tryRefreshUsersWithKeyId:self.placeId];
}

- (void)loadMoreData {
    [self.userManager tryHisUsersWithKeyId:self.placeId];
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
        [self.tableView reloadData];
        
        self.tableView.emptyType = WLScrollEmptyType_Empty_Network;
        [self.tableView reloadEmptyData];
        return;
    }
    
    self.tableView.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
    
    [self.dataArray addObjectsFromArray:users];
    [self.tableView reloadData];
    
    if (self.dataArray.count == 0) {
        self.tableView.emptyType = WLScrollEmptyType_Empty_Data;
    }
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
    static NSString *RootCellIdentifier = @"WLLocationUserCell";
    WLTopicUserCell *cell = (WLTopicUserCell *)[tableView dequeueReusableCellWithIdentifier:RootCellIdentifier];
    if (cell == nil)
    {
        cell = [[WLTopicUserCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:RootCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
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
        _userManager.delegate = self;
        [_userManager setDataSourceProvider:[WLLocationUserProvider new]];
    }
    return _userManager;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
