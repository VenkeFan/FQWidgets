//
//  WLFollowSubViewController.m
//  welike
//
//  Created by fan qi on 2018/5/13.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFollowSubViewController.h"
#import "WLUsersManager.h"
#import "WLFollowedUsersProvider.h"
#import "WLFollowingUsersProvider.h"
#import "WLUserDetailViewController.h"
#import "WLFollowCell.h"

static NSString * const reuseCellID = @"WLFollowCellID";

@interface WLFollowSubViewController () <WLUsersManagerDelegate> {
    BOOL _isLoaded;
}

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, assign) WLFollowType followType;

@property (nonatomic, strong) WLUsersManager *userManager;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation WLFollowSubViewController

- (instancetype)initWithUserID:(NSString *)userID followType:(WLFollowType)followType {
    if (self = [super init]) {
        _userID = [userID copy];
        _followType = followType;
        
        _isLoaded = NO;
        
        if (followType == WLFollowType_Followed) {
            [self.userManager setDataSourceProvider:[WLFollowedUsersProvider new]];
        } else {
            [self.userManager setDataSourceProvider:[WLFollowingUsersProvider new]];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.hidden = YES;
    
    [self.tableView registerClass:[WLFollowCell class] forCellReuseIdentifier:reuseCellID];
    self.tableView.rowHeight = kFollowUserCellHeight;
    [self addTarget:self refreshAction:@selector(refreshData) moreAction:@selector(loadMoreData)];
}

- (void)viewDidLayoutSubviews {
    self.tableView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Public

- (void)display {
    if (!_isLoaded) {
        _isLoaded = YES;
        
        [self beginRefresh];
    }
}

#pragma mark - Network

- (void)refreshData {
    [self.userManager tryRefreshUsersWithKeyId:self.userID];
}

- (void)loadMoreData {
    [self.userManager tryHisUsersWithKeyId:self.userID];
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
        self.tableView.emptyType = WLScrollEmptyType_Empty_Relationship;
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

#pragma mark - UIScrollViewEmptyDelegate

- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView {
    [self beginRefresh];
}

- (NSString *)descriptionForEmptyDataSource:(UIScrollView *)scrollView {
    if (self.followType == WLFollowType_Followed) {
        if (self.tableView.emptyType == WLScrollEmptyType_Empty_Relationship) {
            return [AppContext getStringForKey:@"user_follower_page_empty" fileName:@"user"];
        } else {
            return nil;
        }
        
    } else {
        if (self.tableView.emptyType == WLScrollEmptyType_Empty_Relationship) {
            return [AppContext getStringForKey:@"user_following_page_empty" fileName:@"user"];
        } else {
            return nil;
        }
    }
}

#pragma mark - Getter

- (WLUsersManager *)userManager {
    if (!_userManager) {
        _userManager = [[WLUsersManager alloc] init];
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
