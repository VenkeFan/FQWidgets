//
//  WLFeedRepostTableView.m
//  welike
//
//  Created by fan qi on 2018/6/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFeedRepostTableView.h"
#import "WLFeedRepostCell.h"

#import "WLFeedsManager.h"
#import "WLForwardPostsProvider.h"

#import "WLFeedDetailViewController.h"
#import "WLUserDetailViewController.h"
#import "WLTopicDetailViewController.h"

static NSString *reuseRepostCellID = @"WLFeedRepostCellID";

@interface WLFeedRepostTableView () <WLFeedsManagerDelegate, WLFeedRepostCellDelegate, WLFeedDetailViewControllerDelegate>

@property (nonatomic, strong) WLFeedsManager *feedManager;
@property (nonatomic, strong) NSMutableArray<WLFeedRepostLayout *> *dataArray;

@end

@implementation WLFeedRepostTableView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.tableView registerClass:[WLFeedRepostCell class] forCellReuseIdentifier:reuseRepostCellID];
        [self.tableView addTarget:self refreshAction:nil moreAction:@selector(loadMoreData)];
    }
    return self;
}

#pragma mark - Public

- (void)setPid:(NSString *)pid {
    _pid = [pid copy];
    
    WLForwardPostsProvider *provider = [WLForwardPostsProvider new];
    [provider loadPid:pid];
    [self.feedManager setDataSourceProvider:provider uid:nil];
}

#pragma mark - Network

- (void)refreshData {
    if (!self.hasRefreshed) {
        [super refreshData];
        
        self.hasRefreshed = YES;
        [self.feedManager tryRefreshFeeds];
    }
}

- (void)loadMoreData {
    [self.feedManager tryHisFeeds];
}

#pragma mark - WLFeedsManagerDelegate

- (void)onRefreshManager:(WLFeedsManager *)manager
                   feeds:(NSArray *)feeds
                newCount:(NSInteger)newCount
                    last:(BOOL)last
                 errCode:(NSInteger)errCode {
    [self.tableView endRefresh];
    
    if (feeds.count > 0) {
        [self.dataArray removeAllObjects];
    }
    
    if (errCode != ERROR_SUCCESS) {
        self.tableView.emptyType = WLScrollEmptyType_Empty_Network;
        [self reloadMyData];
        return;
    }
    
    self.tableView.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
    
    [self.dataArray addObjectsFromArray:feeds];
    
    if (self.dataArray.count == 0) {
        self.tableView.emptyType = WLScrollEmptyType_Empty_Data;
    }
    [self reloadMyData];
}

- (void)onReceiveHisManager:(WLFeedsManager *)manager
                      feeds:(NSArray *)feeds
                       last:(BOOL)last
                    errCode:(NSInteger)errCode {
    [self.tableView endLoadMore];
    
    if (errCode != ERROR_SUCCESS) {
        self.tableView.refreshFooterView.result = WLRefreshFooterResult_Error;
        return;
    }
    
    self.tableView.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
    
    if (feeds.count > 0) {
        [self.dataArray addObjectsFromArray:feeds];
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataArray.count > indexPath.row ? [self.dataArray[indexPath.row] cellHeight] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WLFeedRepostCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseRepostCellID];
    cell.delegate = self;
    if (self.dataArray.count > indexPath.row) {
        [cell setLayout:self.dataArray[indexPath.row]];
    }
    return cell;
}

#pragma mark - WLFeedRepostCellDelegate

- (void)feedRepostCell:(WLFeedRepostCell *)cell didClickedFeed:(WLFeedRepostLayout *)layout {
    WLFeedDetailViewController *ctr = [[WLFeedDetailViewController alloc] initWithID:layout.feedModel.pid];
    ctr.delegate = self;
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
}

- (void)feedRepostCell:(WLFeedRepostCell *)cell didClickedUser:(NSString *)userID {
    WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithUserID:userID];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
}

- (void)feedRepostCell:(WLFeedRepostCell *)cell didClickedTopic:(NSString *)topicID {
    WLTopicDetailViewController *ctr = [[WLTopicDetailViewController alloc] initWithTopicID:topicID];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
}

#pragma mark - WLFeedDetailViewControllerDelegate

- (void)feedDetailViewController:(WLFeedDetailViewController *)ctr didDeleted:(WLFeedLayout *)layout {
    NSInteger index = [self p_removeLayoutWithPid:layout.feedModel.pid];
    if (index < 0) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    WLFeedRepostCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Private

- (NSInteger)p_removeLayoutWithPid:(NSString *)pid {
    __block NSInteger index = -1;
    [self.dataArray enumerateObjectsWithOptions:NSEnumerationReverse
                                     usingBlock:^(WLFeedRepostLayout * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                         if ([pid isEqualToString:obj.feedModel.pid]) {
                                             index = idx;
                                             [self.dataArray removeObject:obj];
                                             
                                             *stop = YES;
                                         }
                                     }];
    
    return index;
}

#pragma mark - Getter

- (WLFeedsManager *)feedManager {
    if (!_feedManager) {
        _feedManager = [[WLFeedsManager alloc] init];
        _feedManager.delegate = self;
    }
    return _feedManager;
}

- (NSMutableArray<WLFeedRepostLayout *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
