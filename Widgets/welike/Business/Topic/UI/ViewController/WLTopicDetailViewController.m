//
//  WLTopicDetailViewController.m
//  welike
//
//  Created by fan qi on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTopicDetailViewController.h"
#import "WLTopicUsersViewController.h"
#import "WLFeedDetailViewController.h"
#import "WLUserDetailViewController.h"
#import "WLRepostViewController.h"
#import "WLCommentPostViewController.h"
#import "WLLocationDetailViewController.h"
#import "WLAlertController.h"
#import "WLShareViewController.h"
#import "WLPostViewController.h"
#import "WLPlayerViewController.h"

#import "WLTopicManager.h"
#import "WLTopicHotProvider.h"
#import "WLTopicLatestProvider.h"
#import "WLUsersManager.h"
#import "WLSingleContentManager.h"
#import "WLTopicUsersProvider.h"
#import "WLTopicInfoModel.h"
#import "WLPublishTaskManager.h"

#import "WLMainTableView.h"
#import "WLSegmentedControl.h"
#import "GBRefreshTableHeaderView.h"
#import "WLTopicInfoCell.h"
#import "WLFeedCell.h"
#import "WLScrollViewCell.h"
#import "WLUserFeedsTableView.h"
#import "WLPlayerCollectionView.h"
#import "WLVideoPost.h"
#import "WLTrackerLogin.h"

#define kTopicTableDataObserveKey       @"tableView.hasData"

static NSString * const reuseTopicInfoCellID = @"resueTopicInfoCellID";
static NSString * const reuseTopicTopFeedCellID = @"reuseTopicTopFeedCellID";

@interface WLTopicDetailViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewEmptyDelegate, UIScrollViewEmptyDataSource, WLUsersManagerDelegate, WLTopicInfoCellDelegate, WLSegmentedControlDelegate, WLScrollViewCellDelegate, GBRefreshTableHeaderViewDelegate, WLPublishTaskManagerDelegate, WLFeedCellDelegate>

@property (nonatomic, copy) NSString *topicID;
@property (nonatomic, strong) WLTopicManager *topicManager;
@property (nonatomic, strong) WLTopicInfoModel *topicModel;
@property (nonatomic, strong) WLFeedLayout *topFeedLayout;

@property (nonatomic, strong) WLUsersManager *userManager;
@property (nonatomic, strong) NSMutableArray *userArray;

@property (nonatomic, strong) WLSingleContentManager *deleteManager;

@property (nonatomic, strong) WLMainTableView *containerTableView;
@property (nonatomic, strong) WLSegmentedControl *segmentedCtr;
@property (nonatomic, strong) GBRefreshTableHeaderView *refreshHeaderView;

@property (nonatomic, strong) WLScrollViewCell *scrollViewCell;
@property (nonatomic, strong) WLUserFeedsTableView *hotTableView;
@property (nonatomic, strong) WLUserFeedsTableView *latestTableView;
@property (nonatomic, assign) BOOL hasHotData;

@property (nonatomic, weak) UIButton *postBtn;

@end

@implementation WLTopicDetailViewController {
    BOOL _hasRefreshed;
}

- (instancetype)initWithTopicID:(NSString *)topicID {
    if (self = [super init]) {
        _topicID = [topicID copy]; //不带#
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [AppContext getStringForKey:@"topic" fileName:@"common"];
    
    [self layoutUI];
    
    [[AppContext getInstance].publishTaskManager registerDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)layoutUI {
    [self.navigationBar.rightBtn setImage:[AppContext getImageForKey:@"common_share"] forState:UIControlStateNormal];
    [self.navigationBar.rightBtn addTarget:self action:@selector(navRightBtnOnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[AppContext getImageForKey:@"post_on_this_topic"] forState:UIControlStateNormal];
    [btn sizeToFit];
    btn.center = CGPointMake(CGRectGetWidth(self.view.bounds) - CGRectGetWidth(btn.bounds) * 0.5 - 12,
                             CGRectGetHeight(self.view.bounds) - CGRectGetHeight(btn.bounds) * 0.5 - 24);
    [btn addTarget:self action:@selector(bottomBtnOnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    self.postBtn = btn;
    
    self.containerTableView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight - kNavBarHeight);
    [self.view addSubview:self.containerTableView];
    [self.view sendSubviewToBack:self.containerTableView];
    
    {
        self.hotTableView.superCell = self.scrollViewCell;
        self.latestTableView.superCell = self.scrollViewCell;
        
        [self.hotTableView addObserver:self
                            forKeyPath:kTopicTableDataObserveKey
                               options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                               context:nil];
    }
    
    {
        _refreshHeaderView = [[GBRefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -kScreenHeight, kScreenWidth, kScreenHeight) type:Normal];
        _refreshHeaderView.delegate = self;
        [self.containerTableView addSubview:_refreshHeaderView];

        [self beginRefresh];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.containerTableView.emptyType == WLScrollEmptyType_Empty_Topic) {
        [self refreshData];
    }
}

- (void)dealloc {
    [[AppContext getInstance].publishTaskManager unregister:self];
    [self.hotTableView removeObserver:self forKeyPath:kTopicTableDataObserveKey];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kTopicTableDataObserveKey]) {
        if ([object isEqual:self.hotTableView]) {
            if (change[NSKeyValueChangeNewKey]) {
                self.hasHotData = [change[NSKeyValueChangeNewKey] boolValue];
                
                self.hotTableView.height = self.latestTableView.height = [self p_scrollCellHeight];
                
                if (self.hasHotData) {
                    [self.scrollViewCell setSubViews:@[self.hotTableView, self.latestTableView]];
                } else {
                    [self.scrollViewCell setSubViews:@[self.latestTableView]];
                }
                
                [self.containerTableView reloadData];
            }
        }
    }
}

#pragma mark - Network

- (void)beginRefresh {
    [_refreshHeaderView manualFresh:self.containerTableView];
}

- (void)endRefresh {
    [_refreshHeaderView GBRefreshScrollViewStopLoading:self.containerTableView];
}

- (void)refreshData {
    [self fetchTopicInfo];
    [self fetchUserArray];
    
    [self.hotTableView forceRefresh];
    [self.latestTableView forceRefresh];
}

- (void)fetchTopicInfo {
    _hasRefreshed = NO;
    [self.topicManager loadTopicInfo:self.topicID
                        succeed:^(WLTopicInfoModel *topic, WLFeedLayout *topFeedLayout) {
                            [self endRefresh];
                            self->_hasRefreshed = YES;
                            
                            if ([self p_isEmptyTopic:topic]) {
                                self.containerTableView.emptyType = WLScrollEmptyType_Empty_Topic;
                                self.postBtn.hidden = YES;
                                self.navigationBar.rightBtn.hidden = YES;
                            } else {
                                self.containerTableView.emptyType = WLScrollEmptyType_None;
                                self.postBtn.hidden = NO;
                                self.navigationBar.rightBtn.hidden = NO;
                            }
                            
                            self.topicModel = topic;
                            self.topFeedLayout = topFeedLayout;
                            
                            [self.containerTableView reloadData];
                            [self.containerTableView reloadEmptyData];
                            
                        } failed:^(NSString *topicID, NSInteger errorCode) {
                            [self endRefresh];
                            self->_hasRefreshed = YES;
                            
                            self.topicModel = nil;
                            self.topFeedLayout = nil;
                            
                            self.containerTableView.emptyType = WLScrollEmptyType_Empty_Network;
                            [self.containerTableView reloadData];
                            [self.containerTableView reloadEmptyData];
                        }];
}

- (void)fetchUserArray {
    [self.userManager tryRefreshUsersWithKeyId:self.topicID];
}

- (void)likeFeed:(WLFeedLayout *)layout cell:(WLFeedCell *)cell {
    if (layout.feedModel.like) {
        [self.deleteManager dislikePost:layout.feedModel];
    } else {
        [self.deleteManager likePost:layout.feedModel];
    }
    
    layout.feedModel.like = !layout.feedModel.like;
    
    NSIndexPath *indexPath = [self.containerTableView indexPathForCell:cell];
    if (indexPath) {
        [self.containerTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - Share

- (void)showShareController:(WLTopicInfoModel *)topicModel {
    WLShareModel *shareModel = [WLShareModel modelWithID:topicModel.topicID
                                                    type:WLShareModelType_Topic
                                                   title:topicModel.topicName
                                                    desc:nil];
    
    WLShareViewController *ctr = [[WLShareViewController alloc] init];
    ctr.shareModel = shareModel;
    [self presentViewController:ctr animated:YES completion:nil];
}

#pragma mark - WLUsersManagerDelegate

- (void)onRefreshManager:(WLUsersManager *)manager
                   users:(NSArray *)users
                     kid:(NSString *)kid
                newCount:(NSInteger)newCount
                    last:(BOOL)last
                 errCode:(NSInteger)errCode {
    _userArray = [NSMutableArray array];
    [_userArray addObjectsFromArray:users];
    [self.containerTableView reloadData];
}

- (void)onReceiveHisManager:(WLUsersManager *)manager
                      users:(NSArray *)users
                        kid:(NSString *)kid
                       last:(BOOL)last
                    errCode:(NSInteger)errCode {
    
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self p_sectionCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.hasHotData) {
        if (section == [self p_sectionCount] - 1) {
            return kSegmentHeight;
        }
        
        return 0;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.hasHotData) {
        if (section == [self p_sectionCount] - 1) {
            return self.segmentedCtr;
        }
        
        return nil;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return kWLTopicInfoCellHeight;
    } else if (indexPath.section == [self p_sectionCount] - 1) {
        return [self p_scrollCellHeight];
    } else {
        return self.topFeedLayout.cellHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        WLTopicInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseTopicInfoCellID];
        [cell setItemModel:self.topicModel];
        [cell setUserArray:_userArray];
        cell.delegate = self;
        return cell;
    } else if (indexPath.section == [self p_sectionCount] - 1) {
        return self.scrollViewCell;
    } else {
        WLFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseTopicTopFeedCellID];
        [cell setLayout:self.topFeedLayout];
        cell.delegate = self;
        return cell;
    }
}

#pragma mark - WLFeedCellDelegate

- (void)feedCell:(WLFeedCell *)cell didClickedFeed:(WLFeedLayout *)layout {
    WLFeedDetailViewController *ctr = [[WLFeedDetailViewController alloc] initWithOriginalFeedLayout:layout];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
}

- (void)feedCell:(WLFeedCell *)cell didClickedUser:(NSString *)userID {
    WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithUserID:userID];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
}

- (void)feedCell:(WLFeedCell *)cell didClickedTopic:(NSString *)topicID {
    WLTopicDetailViewController *ctr = [[WLTopicDetailViewController alloc] initWithTopicID:topicID];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
}

- (void)feedCell:(WLFeedCell *)cell didClickedTranspond:(WLFeedLayout *)layout {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Repost];
    kNeedLogin
    
    WLRepostViewController *repostViewController = [[WLRepostViewController alloc] init];
    repostViewController.type = WELIKE_DRAFT_TYPE_FORWARD_POST;
    repostViewController.postBase = layout.feedModel;
    RDRootViewController *navController = [[RDRootViewController alloc] initWithRootViewController:repostViewController];
    
    [[AppContext rootViewController] presentViewController:navController animated:YES completion:^{
        
    }];
}

- (void)feedCell:(WLFeedCell *)cell didClickedComment:(WLFeedLayout *)layout {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Comment];
    kNeedLogin
    
    if (layout.feedModel.commentCount > 0) {
        WLFeedDetailViewController *ctr = [[WLFeedDetailViewController alloc] initWithOriginalFeedLayout:layout];
        ctr.scrollToSegment = YES;
        [[AppContext rootViewController] pushViewController:ctr animated:YES];
        return;
    }
    
    WLCommentPostViewController *commentPostViewController = [[WLCommentPostViewController alloc] init];
    commentPostViewController.type = WELIKE_DRAFT_TYPE_COMMENT;
    commentPostViewController.postBase = layout.feedModel;
    RDRootViewController *navController = [[RDRootViewController alloc] initWithRootViewController:commentPostViewController];
    
    [[AppContext rootViewController] presentViewController:navController animated:YES completion:^{
        
    }];
}

- (void)feedCell:(WLFeedCell *)cell didClickedLike:(WLFeedLayout *)layout {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Like];
    kNeedLogin
    
    [self likeFeed:layout cell:cell];
}

- (void)feedCell:(WLFeedCell *)cell didClickedVideo:(WLVideoPost *)videoModel {
    [self.scrollViewCell.subViews enumerateObjectsUsingBlock:^(id<WLScrollContentViewProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[WLUserFeedsTableView class]]) {
            WLUserFeedsTableView *feedsTableView = (WLUserFeedsTableView *)obj;
            [feedsTableView.tableView destroyMixedPlayerView];
        }
    }];
    
    WLPlayerCollectionView *playerCollectionView = [[WLPlayerCollectionView alloc] initWithPostID:videoModel.pid];
    [playerCollectionView displayWithSubView:nil videoModel:videoModel];
}

- (void)feedCell:(WLFeedCell *)cell didClickedLocation:(WLFeedLayout *)layout {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Other];
    kNeedLogin
    
    WLLocationDetailViewController *locationDetailViewController = [[WLLocationDetailViewController alloc] init];
    locationDetailViewController.placeId = layout.feedModel.location.placeId;
    [[AppContext rootViewController] pushViewController:locationDetailViewController animated:YES];
}

- (void)feedCell:(WLFeedCell *)cell didClickedShare:(WLFeedLayout *)layout {
    WLShareModel *shareModel = [WLShareModel modelWithPost:layout.feedModel];
    
    WLShareViewController *ctr = [[WLShareViewController alloc] init];
    ctr.shareModel = shareModel;
    [self presentViewController:ctr animated:YES completion:nil];
}

- (void)feedCell:(WLFeedCell *)cell didPolled:(WLPollPost *)polledModel {
    WLFeedLayout *newLayout = [self.topFeedLayout reLayoutWithPollModel:polledModel];
    if (newLayout) {
        self.topFeedLayout = newLayout;
        
        NSIndexPath *indexPath = [self.containerTableView indexPathForCell:cell];
        if (indexPath) {
            [self.containerTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (void)feedCellDidFollowLoadingFinished:(WLFeedLayout *)layout {
    [self.containerTableView.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[WLFeedCell class]]) {
            WLFeedCell *cell = (WLFeedCell *)obj;
            cell.followLoading = cell.layout.followLoading;
            
            *stop = YES;
        }
    }];
}

#pragma mark - UIScrollViewEmptyDelegate & UIScrollViewEmptyDataSource

- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView {
    [self bottomBtnOnClicked];
}

- (NSString *)descriptionForEmptyDataSource:(UIScrollView *)scrollView {
    if (self.containerTableView.emptyType == WLScrollEmptyType_Empty_Topic) {
        return [AppContext getStringForKey:@"topic_empty_text" fileName:@"topic"];
    }
    return nil;
}

- (NSString *)buttonTitleForEmptyDataSource:(UIScrollView *)scrollView {
    return [AppContext getStringForKey:@"post" fileName:@"common"];
}

#pragma mark - WLTopicInfoCellDelegate

- (void)topicInfoCellDidClickedUsers:(WLTopicInfoCell *)cell {
    WLTopicUsersViewController *ctr = [[WLTopicUsersViewController alloc] initWithTopicID:self.topicID];
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark - WLSegmentedControlDelegate

- (void)segmentedControl:(WLSegmentedControl *)control didSelectedIndex:(NSInteger)index preIndex:(NSInteger)preIndex {
    if (preIndex < self.scrollViewCell.subViews.count) {
        [[(WLUserFeedsTableView *)self.scrollViewCell.subViews[preIndex] tableView] destroyMixedPlayerView];
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.scrollViewCell.currentIndex = index;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark - WLScrollViewCellDelegate

- (void)userDetailCellHorizontalScrollViewDidScroll:(UIScrollView *)scrollView {
    [self.segmentedCtr setLineOffsetX:scrollView.contentOffset.x];
}

- (void)userDetailCellHorizontalScrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat x = scrollView.contentOffset.x;
    NSInteger index = x / kScreenWidth;
    
    self.segmentedCtr.currentIndex = index;
}

#pragma mark - GBRefreshTableHeaderViewDelegate

- (void)GBRefreshScrollViewStartLoading {
    [self refreshData];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_refreshHeaderView GBRefreshScrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_refreshHeaderView GBRefreshScrollViewDidScroll:scrollView];
    
    if (self.scrollViewCell.subScrollViewScrolling) {
        self.containerTableView.contentOffset = CGPointMake(0, [self p_topCellHeight]);
        return;
    }
    
    if (scrollView.contentOffset.y >= [self p_topCellHeight]) {
        self.containerTableView.contentOffset = CGPointMake(0, [self p_topCellHeight]);
        self.scrollViewCell.superScrollViewScrolling = NO;
        
        [self.segmentedCtr addShadow];
    } else {
        self.scrollViewCell.superScrollViewScrolling = YES;
        
        [self.segmentedCtr clearShadow];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_refreshHeaderView GBRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - WLPublishTaskManagerDelegate

- (void)onPublishTask:(NSString *)taskId end:(NSInteger)errCode {
    if (errCode == 0) {
        [self showToast:[AppContext getStringForKey:@"editor_send_successed" fileName:@"publish"]];
    } else {
        [self showToastWithNetworkErr:errCode];
    }
}

#pragma mark - Event

- (void)bottomBtnOnClicked {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Publish];
    kNeedLogin
    
    WLPostViewController *postViewController = [[WLPostViewController alloc] init];
    postViewController.topicInfo = self.topicModel;
    RDRootViewController *nav = [[RDRootViewController alloc] initWithRootViewController:postViewController];
    
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

- (void)navRightBtnOnClicked {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Other];
    kNeedLogin
    
    [self showShareController:self.topicModel];
    
//    WLAlertController *alert = [WLAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//
//    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"feed_share" fileName:@"feed"]
//                                              style:UIAlertActionStyleDefault
//                                            handler:^(UIAlertAction * _Nonnull action) {
//                                                [self showShareController:self.topicModel];
//                                            }]];
//    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"common_cancel" fileName:@"common"]
//                                              style:UIAlertActionStyleCancel
//                                            handler:^(UIAlertAction * _Nonnull action) {
//
//                                            }]];
//
//    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Private

- (CGFloat)p_topCellHeight {
    return kWLTopicInfoCellHeight + self.topFeedLayout.cellHeight;
}

- (CGFloat)p_scrollCellHeight {
    return self.hasHotData
    ? CGRectGetHeight(self.view.bounds) - kNavBarHeight - kSegmentHeight
    : CGRectGetHeight(self.view.bounds) - kNavBarHeight;
}

- (NSInteger)p_sectionCount {
    return [self p_isEmptyTopic:self.topicModel] ? 1 : (self.topFeedLayout ? 3 : 2);
}

- (BOOL)p_isEmptyTopic:(WLTopicInfoModel *)topicModel {
    return topicModel.topicName.length == 0;
}

#pragma mark - Getter

- (WLTopicManager *)topicManager {
    if (!_topicManager) {
        _topicManager = [WLTopicManager new];
    }
    return _topicManager;
}

- (WLUsersManager *)userManager {
    if (!_userManager) {
        _userManager = [[WLUsersManager alloc] init];
        _userManager.delegate = self;
        [_userManager setDataSourceProvider:[WLTopicUsersProvider new]];
    }
    return _userManager;
}

- (WLSingleContentManager *)deleteManager {
    if (!_deleteManager) {
        _deleteManager = [AppContext getInstance].singleContentManager;
    }
    return _deleteManager;
}

- (WLMainTableView *)containerTableView {
    if (!_containerTableView) {
        WLMainTableView *tableView = [[WLMainTableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight - kNavBarHeight)
                                                                      style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.emptyDelegate = self;
        tableView.emptyDataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.sectionHeaderHeight = kSegmentHeight;
        [tableView registerClass:[WLTopicInfoCell class] forCellReuseIdentifier:reuseTopicInfoCellID];
        [tableView registerClass:[WLFeedCell class] forCellReuseIdentifier:reuseTopicTopFeedCellID];
        _containerTableView = tableView;
    }
    return _containerTableView;
}

- (WLSegmentedControl *)segmentedCtr {
    if (!_segmentedCtr) {
        WLSegmentedControl *segmentCtr = [[WLSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kSegmentHeight)];
        segmentCtr.backgroundColor = [UIColor whiteColor];
        segmentCtr.currentIndex = 0;
        segmentCtr.delegate = self;
        segmentCtr.items = @[[AppContext getStringForKey:@"sort_trending_text" fileName:@"common"],
                             [AppContext getStringForKey:@"sort_created_text" fileName:@"common"]];
        _segmentedCtr = segmentCtr;
    }
    return _segmentedCtr;
}

- (WLUserFeedsTableView *)hotTableView {
    if (!_hotTableView) {
        _hotTableView = [[WLUserFeedsTableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, [self p_scrollCellHeight])];
        WLTopicHotProvider *hotProvider = [WLTopicHotProvider new];
        [hotProvider loadTopicID:self.topicID];
        [_hotTableView setProvider:hotProvider userID:nil];
        _hotTableView.tableView.contentInset = UIEdgeInsetsMake(0, 0, kScreenHeight - CGRectGetMinY(self.postBtn.frame) + CGRectGetHeight(_hotTableView.tableView.refreshFooterView.bounds), 0);
    }
    return _hotTableView;
}

- (WLUserFeedsTableView *)latestTableView {
    if (!_latestTableView) {
        _latestTableView = [[WLUserFeedsTableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, [self p_scrollCellHeight])];
        WLTopicLatestProvider *latestProvider = [WLTopicLatestProvider new];
        [latestProvider loadTopicID:self.topicID];
        [_latestTableView setProvider:latestProvider userID:nil];
        _latestTableView.tableView.contentInset = UIEdgeInsetsMake(0, 0, kScreenHeight - CGRectGetMinY(self.postBtn.frame) + CGRectGetHeight(_hotTableView.tableView.refreshFooterView.bounds), 0);
    }
    return _latestTableView;
}

- (WLScrollViewCell *)scrollViewCell {
    if (!_scrollViewCell) {
        _scrollViewCell = [[WLScrollViewCell alloc] init];
        _scrollViewCell.delegate = self;
    }
    return _scrollViewCell;
}

@end
