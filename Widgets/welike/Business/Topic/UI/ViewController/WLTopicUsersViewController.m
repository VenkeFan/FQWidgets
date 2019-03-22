//
//  WLTopicUsersViewController.m
//  welike
//
//  Created by fan qi on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTopicUsersViewController.h"
#import "WLUsersManager.h"
#import "WLTopicUsersProvider.h"
#import "WLTopicUserCell.h"
#import "WLUserDetailViewController.h"
#import "WLTrackerFollow.h"

static NSString * const reuseCellID = @"WLTopicUserCellID";

@interface WLTopicUsersViewController () <WLUsersManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSString *topicID;
@property (nonatomic, strong) WLUsersManager *userManager;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation WLTopicUsersViewController

- (instancetype)initWithTopicID:(NSString *)topicID {
    if (self = [super init]) {
        _topicID = [topicID copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [AppContext getStringForKey:@"topic_user_title" fileName:@"topic"];
    
    self.tableView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight - kNavBarHeight);
    [self.tableView registerClass:[WLTopicUserCell class] forCellReuseIdentifier:reuseCellID];
    self.tableView.rowHeight = kTopicUserCellHeight;
    [self addTarget:self refreshAction:@selector(refreshData) moreAction:@selector(loadMoreData)];
    [self beginRefresh];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [WLTrackerFollow setFeedSource:WLTrackerFeedSource_Topic_Top];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Network

- (void)refreshData {
    [self.userManager tryRefreshUsersWithKeyId:self.topicID];
}

- (void)loadMoreData {
    [self.userManager tryHisUsersWithKeyId:self.topicID];
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
    WLTopicUserCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCellID];
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
        [_userManager setDataSourceProvider:[WLTopicUsersProvider new]];
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
