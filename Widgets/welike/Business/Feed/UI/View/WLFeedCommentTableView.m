//
//  WLFeedCommentTableView.m
//  welike
//
//  Created by fan qi on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFeedCommentTableView.h"
#import "WLCommentsManager.h"
#import "WLSingleContentManager.h"
#import "WLCreatedCommentsProvider.h"
#import "WLHotCommentsProvider.h"
#import "WLCommentLayout.h"
#import "WLFeedCommentCell.h"
#import "WLTrackerLike.h"
#import "WLTrackerLogin.h"

static NSString *reuseCommentCellID = @"WLFeedCommentCellID";

@interface WLFeedCommentTableView () <WLCommentsManagerDelegate, WLFeedCommentCellDelegate, WLSingleContentManagerDelegate>

@property (nonatomic, strong) WLSingleContentManager *deleteManager;
@property (nonatomic, strong) WLCommentsManager *commentsManager;
@property (nonatomic, strong) NSMutableArray<WLCommentLayout *> *dataArray;

@end

@implementation WLFeedCommentTableView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.tableView registerClass:[WLFeedCommentCell class] forCellReuseIdentifier:reuseCommentCellID];
        [self.tableView addTarget:self refreshAction:nil moreAction:@selector(loadMoreData)];
    }
    return self;
}

- (void)dealloc {
    [_deleteManager unregister:self];
}

#pragma mark - Network

- (void)refreshData {
    if (!self.hasRefreshed) {
        [super refreshData];
        
        self.hasRefreshed = YES;
        [self.commentsManager tryRefreshCommentsForPid:self.pid];
    }
}

- (void)loadMoreData {
    [self.commentsManager tryHisCommentsForPid:self.pid];
}

- (void)deleteComment:(WLCommentLayout *)layout cell:(WLFeedCommentCell *)cell {
    NSIndexPath *deletingIndexPath = [self.tableView indexPathForCell:cell];
    if (deletingIndexPath) {
        [self.dataArray enumerateObjectsWithOptions:NSEnumerationReverse
                                         usingBlock:^(WLCommentLayout * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                             if ([layout.commentModel.cid isEqualToString:obj.commentModel.cid]) {
                                                 [self.dataArray removeObject:obj];
                                                 
                                                 *stop = YES;
                                             }
                                         }];
        
        [self.tableView deleteRowsAtIndexPaths:@[deletingIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [self.deleteManager deleteComment:layout.commentModel];
}

- (void)likeComment:(WLCommentLayout *)layout cell:(WLFeedCommentCell *)cell {
    if (layout.commentModel.like) {
        [self.deleteManager dislikeComment:layout.commentModel.cid];
        layout.commentModel.likeCount--;
    } else {
        [self.deleteManager likeComment:layout.commentModel.cid];
        layout.commentModel.likeCount++;
    }
    
    layout.commentModel.like = !layout.commentModel.like;
    layout.commentModel.likeCount = layout.commentModel.likeCount > 0 ?: 0;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - WLCommentsManagerDelegate

- (void)onRefreshManager:(WLCommentsManager *)manager
                comments:(NSArray *)comments
                    last:(BOOL)last
                 errCode:(NSInteger)errCode {
    if (comments.count > 0) {
        [self.dataArray removeAllObjects];
    }
    
    if (errCode != ERROR_SUCCESS) {
        self.tableView.emptyType = WLScrollEmptyType_Empty_Network;
        [self reloadMyData];
        return;
    }
    
    self.tableView.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
    
    [self.dataArray addObjectsFromArray:comments];
    
    if (self.dataArray.count == 0) {
        self.tableView.emptyType = WLScrollEmptyType_Empty_Data;
    }
    [self reloadMyData];
}

- (void)onReceiveHisManager:(WLCommentsManager *)manager
                   comments:(NSArray *)comments
                       last:(BOOL)last
                    errCode:(NSInteger)errCode {
    [self.tableView endLoadMore];
    
    if (errCode != ERROR_SUCCESS) {
        self.tableView.refreshFooterView.result = WLRefreshFooterResult_Error;
        return;
    }
    
    self.tableView.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
    
    if (comments.count > 0) {
        [self.dataArray addObjectsFromArray:comments];
        [self.tableView reloadData];
    }
}

#pragma mark - WLSingleContentManagerDelegate

- (void)onCommentDeleted:(NSString *)cid {
    
}

- (void)onCommentDeleted:(NSString *)cid error:(NSInteger)errCode {
    
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [(WLCommentLayout *)self.dataArray[indexPath.row] cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WLFeedCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCommentCellID];
    [cell setLayout:self.dataArray[indexPath.row]];
    cell.delegate = self;
    return cell;
}

#pragma mark - WLFeedCommentCellDelegate

- (void)feedCommentCell:(WLFeedCommentCell *)cell didClickedSelf:(WLCommentLayout *)layout {
    if ([self.delegate respondsToSelector:@selector(feedCommentTableView:didClickedCell:layout:)]) {
        [self.delegate feedCommentTableView:self didClickedCell:cell layout:layout];
    }
}

- (void)feedCommentCell:(WLFeedCommentCell *)cell didClickedUser:(NSString *)userID {
    if ([self.delegate respondsToSelector:@selector(feedCommentTableView:didClickedUser:)]) {
        [self.delegate feedCommentTableView:self didClickedUser:userID];
    }
}

- (void)feedCommentCell:(WLFeedCommentCell *)cell didClickedTopic:(NSString *)topicID {
    if ([self.delegate respondsToSelector:@selector(feedCommentTableView:didClickedTopic:)]) {
        [self.delegate feedCommentTableView:self didClickedTopic:topicID];
    }
}

- (void)feedCommentCell:(WLFeedCommentCell *)cell didClickedTranspond:(WLCommentLayout *)layout {
    if ([self.delegate respondsToSelector:@selector(feedCommentTableView:didClickedTranspond:)]) {
        [self.delegate feedCommentTableView:self didClickedTranspond:layout];
    }
}

- (void)feedCommentCell:(WLFeedCommentCell *)cell didClickedComment:(WLCommentLayout *)layout {
    if ([self.delegate respondsToSelector:@selector(feedCommentTableView:didClickedComment:)]) {
        [self.delegate feedCommentTableView:self didClickedComment:layout];
    }
}

- (void)feedCommentCell:(WLFeedCommentCell *)cell didClickedLike:(WLCommentLayout *)layout {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Like];
    kNeedLogin
    
    [WLTrackerLike setFeedSource:WLTrackerFeedSource_FeedDetail_Comments];
    
    [self likeComment:layout cell:cell];
}

- (void)feedCommentCell:(WLFeedCommentCell *)cell didClickedChild:(WLCommentLayout *)layout {
    if ([self.delegate respondsToSelector:@selector(feedCommentTableView:didClickedChild:)]) {
        [self.delegate feedCommentTableView:self didClickedChild:layout];
    }
}

#pragma mark - Setter

- (void)setSortType:(WLFeedCommentSortType)sortType {
    switch (sortType) {
        case WLFeedCommentSortType_Top:
            [self.commentsManager setDataSourceProvider:[WLHotCommentsProvider new]];
            break;
        case WLFeedCommentSortType_Latest:
            [self.commentsManager setDataSourceProvider:[WLCreatedCommentsProvider new]];
            break;
    }
    
    if (_sortType != sortType) {
        [self forceRefresh];
    }
    
    _sortType = sortType;
}

#pragma mark - Getter

- (WLCommentsManager *)commentsManager {
    if (!_commentsManager) {
        _commentsManager = [[WLCommentsManager alloc] init];
        _commentsManager.delegate = self;
    }
    return _commentsManager;
}

- (WLSingleContentManager *)deleteManager {
    if (!_deleteManager) {
        _deleteManager = [AppContext getInstance].singleContentManager;
        [_deleteManager registerDelegate:self];
    }
    return _deleteManager;
}

- (NSMutableArray<WLCommentLayout *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
