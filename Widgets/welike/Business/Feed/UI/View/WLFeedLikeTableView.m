//
//  WLFeedLikeTableView.m
//  welike
//
//  Created by fan qi on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFeedLikeTableView.h"
#import "WLUsersManager.h"
#import "WLPostLikeUsersProvider.h"
#import "WLFeedLikeUserCell.h"
#import "WLUser.h"

#define kRowHeight           48.0

static NSString *reuseFeedCellID = @"WLFeedLikeUserCellID";

@interface WLFeedLikeTableView () <WLUsersManagerDelegate>

@property (nonatomic, strong) WLUsersManager *manager;
@property (nonatomic, strong) NSMutableArray<WLUser *> *dataArray;

@end

@implementation WLFeedLikeTableView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.tableView.rowHeight = kRowHeight;
        [self.tableView registerClass:[WLFeedLikeUserCell class] forCellReuseIdentifier:reuseFeedCellID];
        [self.tableView addTarget:self refreshAction:nil moreAction:@selector(loadMoreData)];
    }
    return self;
}

#pragma mark - Network

- (void)refreshData {
    if (!self.hasRefreshed) {
        [super refreshData];
        
        self.hasRefreshed = YES;
        [self.manager tryRefreshUsersWithKeyId:self.pid];
    }
}

- (void)loadMoreData {
    [self.manager tryHisUsersWithKeyId:self.pid];
}

#pragma mark - WLUsersManagerDelegate

- (void)onRefreshManager:(WLUsersManager *)manager
                   users:(NSArray *)users
                     kid:(NSString *)kid
                newCount:(NSInteger)newCount
                    last:(BOOL)last
                 errCode:(NSInteger)errCode {
    if (errCode != ERROR_SUCCESS) {
        self.tableView.emptyType = WLScrollEmptyType_Empty_Network;
        [self reloadMyData];
        return;
    }
    
    self.tableView.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
    
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:users];
    
    if (self.dataArray.count == 0) {
        self.tableView.emptyType = WLScrollEmptyType_Empty_Data;
    }
    [self reloadMyData];
}

- (void)onReceiveHisManager:(WLUsersManager *)manager
                      users:(NSArray *)users
                        kid:(NSString *)kid
                       last:(BOOL)last
                    errCode:(NSInteger)errCode {
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
    WLFeedLikeUserCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseFeedCellID];
    [cell setItemModel:self.dataArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(feedLikeTableView:didSelectedWithUserID:)]) {
        [self.delegate feedLikeTableView:self didSelectedWithUserID:self.dataArray[indexPath.row].uid];
    }
}

#pragma mark - Getter

- (WLUsersManager *)manager {
    if (!_manager) {
        _manager = [WLUsersManager new];
        _manager.delegate = self;
        
        [_manager setDataSourceProvider:[WLPostLikeUsersProvider new]];
    }
    return _manager;
}

- (NSMutableArray<WLUser *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
