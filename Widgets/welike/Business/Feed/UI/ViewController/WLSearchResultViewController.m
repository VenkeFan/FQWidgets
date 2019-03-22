//
//  WLSearchResultViewController.m
//  welike
//
//  Created by 刘斌 on 2018/5/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchResultViewController.h"
#import "WLSearchBar.h"
#import "WLSegmentedControl.h"
#import "WLFeedCell.h"
#import "WLFollowCell.h"
#import "WLSearchLatestUserSectionCell.h"
#import "WLEmptySectionCell.h"
#import "WLSearchManager.h"
#import "WLAccountManager.h"
#import "WLSingleContentManager.h"
#import "WLUser.h"
#import "WLFeedLayout.h"
#import "WLSearchSugViewController.h"
#import "WLFeedDetailViewController.h"
#import "WLUserDetailViewController.h"
#import "WLCommentPostViewController.h"
#import "WLRepostViewController.h"
#import "WLTopicDetailViewController.h"
#import "WLReportViewController.h"
#import "WLAlertController.h"
#import "WLLocationDetailViewController.h"
#import "WLPlayerViewController.h"
#import "WLPlayerCollectionView.h"
#import "WLVideoPost.h"
#import "WLShareViewController.h"
#import "WLShareModel.h"
#import "WLPicPost.h"
#import "WLPicInfo.h"
#import "WLTrackerFeed.h"
#import "WLTrackerSearch.h"
#import "WLTrackerLogin.h"
#import "WLTrackerBlock.h"
#import "WLSingleUserManager.h"

#define kSearchResultPagerBarHeight                  44.f
#define kSearchResultSectionHeight                   13.f

static NSString *WLSearchResultFeedCellIdentifier = @"WLSearchResultFeedCell";
static NSString *WLSearchResultUserCellIdentifier = @"WLSearchResultUserCell";

@interface WLSearchResultViewController () <WLSearchBarDelegate, WLSegmentedControlDelegate, WLFeedCellDelegate, WLSearchManagerDelegate, WLSearchLatestUserSectionCellDelegate>

@property (nonatomic, strong) WLSearchBar *searchBar;
@property (nonatomic, strong) WLSegmentedControl *segmentedControl;
@property (nonatomic, strong) WLSearchManager *searchManager;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation WLSearchResultViewController {
    NSInteger userSectionCount;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.dataArray = [NSMutableArray array];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.navigationBar.hidden = YES;
    self.searchManager = [[WLSearchManager alloc] init];
    self.searchManager.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchBar = [[WLSearchBar alloc] initWithIcon:@"searchbar_icon" placeholder:nil];
    self.searchBar.content = self.keyword;
    self.searchBar.delegate = self;
    self.searchBar.showBack = YES;
    [self.view addSubview:self.searchBar];
    
    self.segmentedControl = [[WLSegmentedControl alloc] initWithFrame:CGRectMake(0, self.searchBar.bottom, self.view.width, kSearchResultPagerBarHeight)];
    self.segmentedControl.backgroundColor = [UIColor whiteColor];
    self.segmentedControl.currentIndex = 0;
    self.segmentedControl.delegate = self;
    [self.segmentedControl setItems:@[[AppContext getStringForKey:@"search_latest_tab" fileName:@"search"],
                                      [AppContext getStringForKey:@"search_user_tab" fileName:@"search"],
                                      [AppContext getStringForKey:@"search_post_tab" fileName:@"search"]]];
    [self.segmentedControl addShadow];
    [self.view addSubview:self.segmentedControl];
    
    self.tableView.frame = CGRectMake(0, self.segmentedControl.bottom, kScreenWidth, kScreenHeight - self.segmentedControl.bottom - kSafeAreaBottomY);
    
    [self addTarget:self refreshAction:@selector(refreshData) moreAction:@selector(loadMoreData)];
    [self beginRefresh];
    
    [WLTrackerSearch appendTrackerSearchResult:self.keyword];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[AppContext rootViewController] setDisableInteractivePopGestureRecognizer:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[AppContext rootViewController] setDisableInteractivePopGestureRecognizer:NO];
}

#pragma mark - WLSearchBarDelegate
- (void)onClickSearchBar:(WLSearchBar *)searchBar
{
    WLSearchSugViewController *vc = [[WLSearchSugViewController alloc] init];
    vc.keyword = self.searchBar.content;
    [[AppContext rootViewController] popViewControllerAnimated:NO];
    [[AppContext rootViewController] pushViewController:vc animated:NO];
}

- (void)onBackSearchBar:(WLSearchBar *)searchBar
{
    [[AppContext rootViewController] popViewControllerAnimated:YES];
}

#pragma mark - WLSegmentedControlDelegate
- (void)segmentedControl:(WLSegmentedControl *)control didSelectedIndex:(NSInteger)index
{
    [self.dataArray removeAllObjects];
    [self.tableView reloadData];
    
    [self beginRefresh];
}

#pragma mark - WLSearchManagerDelegate
- (void)onNewSearchResult:(NSArray *)results searchType:(WELIKE_SEARCH_TYPE)searchType last:(BOOL)last errCode:(NSInteger)errCode
{
    [self endRefresh];
    
    [self.dataArray removeAllObjects];
    
    if (errCode != ERROR_SUCCESS)
    {
        [self.tableView reloadData];
        
        self.tableView.emptyType = WLScrollEmptyType_Empty_Network;
        [self.tableView reloadEmptyData];
        return;
    }
    
    if (last == NO)
    {
        self.tableView.refreshFooterView.result = WLRefreshFooterResult_HasMore;
    }
    else
    {
        self.tableView.refreshFooterView.result = WLRefreshFooterResult_NoMore;
    }
    if (searchType == WELIKE_SEARCH_TYPE_LATEST)
    {
        NSMutableArray *userSection = [NSMutableArray array];
        NSMutableArray *postSection = [NSMutableArray array];
        for (NSInteger i = 0; i < [results count]; i++)
        {
            id obj = [results objectAtIndex:i];
            if ([obj isKindOfClass:[WLUser class]])
            {
                [userSection addObject:obj];
            }
            else if ([obj isKindOfClass:[WLFeedLayout class]])
            {
                [postSection addObject:obj];
            }
        }
        userSectionCount = 0;
        if ([userSection count] > 0)
        {
            WLSearchLatestUserSectionDataSourceItem *topSection = [[WLSearchLatestUserSectionDataSourceItem alloc] init];
            topSection.title = [AppContext getStringForKey:@"search_latest_people_title" fileName:@"search"];
            [userSection insertObject:topSection atIndex:0];
            [self.dataArray addObjectsFromArray:userSection];
            userSectionCount = userSection.count;
            WLEmptySectionDataSourceItem *emptySection = [[WLEmptySectionDataSourceItem alloc] init];
            emptySection.cellHeight = 1.0f;
            emptySection.backgroundColor = kUIColorFromRGB(0xEDF1F5);
            [self.dataArray addObject:emptySection];
        }
        if ([postSection count] > 0)
        {
            [self.dataArray addObjectsFromArray:postSection];
        }
    }
    else
    {
        [self.dataArray addObjectsFromArray:results];
    }
    if (self.dataArray.count > 0)
    {
        [self.tableView reloadData];
    }
    else
    {
        self.tableView.emptyType = WLScrollEmptyType_Empty_Data;
    }
    [self.tableView reloadEmptyData];
    
    if (searchType != WELIKE_SEARCH_TYPE_USERS) {
        [WLTrackerFeed appendTrackWithAction:WLTrackerFeedAction_Drag_Refresh
                                        type:searchType == WELIKE_SEARCH_TYPE_LATEST
                                            ? WLTrackerFeedSource_Search_Latest
                                            : (searchType == WELIKE_SEARCH_TYPE_POSTS
                                               ? WLTrackerFeedSource_Search_Posts
                                               : WLTrackerFeedSource_Unknown)
                                     subType:nil
                                  fetchCount:results.count];
    }
}

- (void)onMoreSearchResult:(NSArray *)results searchType:(WELIKE_SEARCH_TYPE)searchType last:(BOOL)last errCode:(NSInteger)errCode
{
    [self.tableView endLoadMore];
    
    if (errCode != ERROR_SUCCESS)
    {
        self.tableView.refreshFooterView.result = WLRefreshFooterResult_Error;
        return;
    }
    
    if (last == NO)
    {
        self.tableView.refreshFooterView.result = WLRefreshFooterResult_HasMore;
    }
    else
    {
        self.tableView.refreshFooterView.result = WLRefreshFooterResult_NoMore;
    }
    
    if (results.count > 0)
    {
        [self.dataArray addObjectsFromArray:results];
        [self.tableView reloadData];
    }
    
    if (searchType != WELIKE_SEARCH_TYPE_USERS) {
        [WLTrackerFeed appendTrackWithAction:WLTrackerFeedAction_More
                                        type:searchType == WELIKE_SEARCH_TYPE_LATEST
                                            ? WLTrackerFeedSource_Search_Latest
                                            : (searchType == WELIKE_SEARCH_TYPE_POSTS
                                               ? WLTrackerFeedSource_Search_Posts
                                               : WLTrackerFeedSource_Unknown)
                                     subType:nil
                                  fetchCount:results.count];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = nil;
    NSInteger row = indexPath.row;
    if ([self.dataArray count] > row)
    {
        item = [self.dataArray objectAtIndex:row];
    }
    if (item != nil)
    {
        if ([item isKindOfClass:[WLSearchLatestUserSectionDataSourceItem class]])
        {
            return ((WLSearchLatestUserSectionDataSourceItem *)item).cellHeight;
        }
        else if ([item isKindOfClass:[WLUser class]])
        {
            if (indexPath.row == userSectionCount - 1) {
                return kFollowUserCellHeight - 1.0;
            }
            return kFollowUserCellHeight;
        }
        else if ([item isKindOfClass:[WLFeedLayout class]])
        {
            return ((WLFeedLayout *)item).cellHeight;
        }
        else if ([item isKindOfClass:[WLEmptySectionDataSourceItem class]])
        {
            return ((WLEmptySectionDataSourceItem *)item).cellHeight;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    id item = nil;
    NSInteger row = indexPath.row;
    if ([self.dataArray count] > row)
    {
        item = [self.dataArray objectAtIndex:row];
    }
    if (item != nil)
    {
        if ([item isKindOfClass:[WLSearchLatestUserSectionDataSourceItem class]])
        {
            WLSearchLatestUserSectionCell *userSectionCell = [tableView dequeueReusableCellWithIdentifier:WLSearchLatestUserSectionCellIdentifier];
            if (userSectionCell == nil)
            {
                userSectionCell = [[WLSearchLatestUserSectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLSearchLatestUserSectionCellIdentifier];
                userSectionCell.delegate = self;
                [userSectionCell setDataSourceItem:item];
            }
            else
            {
                [userSectionCell setDataSourceItem:item];
            }
            cell = userSectionCell;
        }
        else if ([item isKindOfClass:[WLUser class]])
        {
            WLFollowCell *userCell = [tableView dequeueReusableCellWithIdentifier:WLSearchResultUserCellIdentifier];
            if (userCell == nil)
            {
                userCell = [[WLFollowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLSearchResultUserCellIdentifier];
                userCell.type = WELIKE_FOLLOW_CELL_TYPE_SEARCH;
                [userCell setItemModel:item];
            }
            else
            {
                userCell.type = WELIKE_FOLLOW_CELL_TYPE_SEARCH;
                [userCell setItemModel:item];
            }
            cell = userCell;
        }
        else if ([item isKindOfClass:[WLFeedLayout class]])
        {
            WLFeedCell *feedCell = [tableView dequeueReusableCellWithIdentifier:WLSearchResultFeedCellIdentifier];
            if (feedCell == nil)
            {
                feedCell = [[WLFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLSearchResultFeedCellIdentifier];
                feedCell.delegate = self;
                [feedCell setLayout:item];
            }
            else
            {
                feedCell.delegate = self;
                [feedCell setLayout:item];
            }
            cell = feedCell;
        }
        else if ([item isKindOfClass:[WLEmptySectionDataSourceItem class]])
        {
            WLEmptySectionCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:WLEmptySectionCellIdentifier];
            if (emptyCell == nil)
            {
                emptyCell = [[WLEmptySectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLEmptySectionCellIdentifier];
                [emptyCell setDataSourceItem:item];
            }
            else
            {
                [emptyCell setDataSourceItem:item];
            }
            cell = emptyCell;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    id item = nil;
    NSInteger row = indexPath.row;
    if ([self.dataArray count] > row)
    {
        item = [self.dataArray objectAtIndex:row];
    }
    if (item != nil)
    {
        if ([item isKindOfClass:[WLUser class]])
        {
            WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithUserID:((WLUser *)item).uid];
            ctr.hidesBottomBarWhenPushed = YES;
            [[AppContext rootViewController] pushViewController:ctr animated:YES];
            
            [WLTrackerSearch appendTrackerSearchDetail:self.keyword
                                                userID:((WLUser *)item).uid
                                                 index:[self objectIndex:item]];
        }
    }
}

#pragma mark - WLFeedCellDelegate

- (void)feedCell:(WLFeedCell *)cell didPolled:(WLPollPost *)polledModel {
    WLPollPost *newPollModel = polledModel;
    NSMutableArray *indices = [NSMutableArray array];
    
    for (NSInteger i = 0; i < self.dataArray.count; i++) {
        id obj = self.dataArray[i];
        if (![obj isKindOfClass:[WLFeedLayout class]]) {
            continue;
        }
        
        WLFeedLayout *newLayout = [(WLFeedLayout *)obj reLayoutWithPollModel:newPollModel];
        if (newLayout) {
            [self.dataArray replaceObjectAtIndex:i withObject:newLayout];
            [indices addObject:[NSNumber numberWithInteger:i]];
        }
    }
    
    if (indices.count == 0) {
        return;
    }
    
    NSMutableArray<NSIndexPath *> *indexPathArray = [NSMutableArray array];
    for (int i = 0; i < indices.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[indices[i] integerValue] inSection:0];
        WLFeedCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            [indexPathArray addObject:indexPath];
        }
    }
    
    [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
}

- (void)feedCell:(WLFeedCell *)cell didClickedShare:(WLFeedLayout *)layout {
    [self showShareController:layout.feedModel];
}

- (void)feedCell:(WLFeedCell *)cell didClickedFeed:(WLFeedLayout *)layout {
    WLFeedDetailViewController *ctr = [[WLFeedDetailViewController alloc] initWithOriginalFeedLayout:layout];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
    
    [WLTrackerSearch appendTrackerSearchDetail:self.keyword
                                          post:layout.feedModel
                                         index:[self objectIndex:layout]];
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
        
        [WLTrackerSearch appendTrackerSearchDetail:self.keyword
                                              post:layout.feedModel
                                             index:[self objectIndex:layout]];
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
    [self likeFeed:layout cell:cell];
}

- (void)feedCell:(WLFeedCell *)cell didClickedVideo:(WLVideoPost *)videoModel {
    WLPlayerCollectionView *playerCollectionView = [[WLPlayerCollectionView alloc] initWithPostID:videoModel.pid];
    [playerCollectionView displayWithSubView:nil videoModel:videoModel];
}

- (void)feedCell:(WLFeedCell *)cell didClickedArrow:(WLFeedLayout *)layout {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Other];
    kNeedLogin
    
    WLAlertController *alert = [WLAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"feed_share" fileName:@"feed"]
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self showShareController:layout.feedModel];
                                            }]];
    
    if ([layout.feedModel.uid isEqual:[AppContext getInstance].accountManager.myAccount.uid]) {
        [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"feed_delete_confirm" fileName:@"feed"]
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [self deleteFeed:layout cell:cell];
                                                }]];
    } else {
        [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"report" fileName:@"feed"]
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    WLReportViewController *vc = [[WLReportViewController alloc] init];
                                                    vc.post = layout.feedModel;
                                                    [[AppContext rootViewController] pushViewController:vc animated:YES];
                                                }]];
        
        NSString *blockAction = [NSString stringWithFormat:@"%@@%@", [AppContext getStringForKey:@"block" fileName:@"common"], layout.feedModel.nickName];
        [alert addAction:[UIAlertAction actionWithTitle:blockAction
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [self blockFeed:layout cell:cell];
                                                }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"common_cancel" fileName:@"common"]
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                
                                            }]];
    
    [[AppContext rootViewController] presentViewController:alert animated:YES completion:nil];
}

- (void)feedCell:(WLFeedCell *)cell didClickedLocation:(WLFeedLayout *)layout {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Other];
    kNeedLogin
    
    WLLocationDetailViewController *locationDetailViewController = [[WLLocationDetailViewController alloc] init];
    locationDetailViewController.placeId = layout.feedModel.location.placeId;
    [[AppContext rootViewController] pushViewController:locationDetailViewController animated:YES];
}

- (void)feedCellDidFollowLoadingChanged:(WLFeedLayout *)layout {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[WLFeedLayout class]] == YES)
            {
                WLFeedLayout *item = (WLFeedLayout *)obj;
                if ([item.feedModel.uid isEqualToString:layout.feedModel.uid]) {
                    item.followLoading = layout.followLoading;
                }
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[WLFeedCell class]] == YES)
                {
                    WLFeedCell *cell = (WLFeedCell *)obj;
                    cell.followLoading = cell.layout.followLoading;
                }
            }];
        });
    });
}

- (void)feedCellDidFollowLoadingFinished:(WLFeedLayout *)layout {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[WLFeedLayout class]] == YES)
            {
                WLFeedLayout *item = (WLFeedLayout *)obj;
                if ([item.feedModel.uid isEqualToString:layout.feedModel.uid]) {
                    item.feedModel.following = layout.feedModel.following;
                    item.feedModel.follower = layout.feedModel.follower;
                }
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[WLFeedCell class]] == YES)
                {
                    WLFeedCell *cell = (WLFeedCell *)obj;
                    cell.followLoading = cell.layout.followLoading;
                }
            }];
        });
    });
}

#pragma mark - UIScrollViewEmptyDelegate
- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView
{
    [self beginRefresh];
}

#pragma mark - UIScrollViewEmptyDataSource
- (NSString *)descriptionForEmptyDataSource:(UIScrollView *)scrollView
{
    if (self.tableView.emptyType == WLScrollEmptyType_Empty_Network) {
        return [AppContext getStringForKey:@"common_error_text" fileName:@"common"];
    } else {
        return [AppContext getStringForKey:@"search_no_result" fileName:@"search"];
    }
}

#pragma mark - WLSearchLatestUserSectionCellDelegate
- (void)goToAll
{
    self.segmentedControl.currentIndex = 1;
    [self.dataArray removeAllObjects];
    [self.tableView reloadData];
    
    [self beginRefresh];
}

#pragma mark - private
- (void)refreshData
{
    if (self.segmentedControl.currentIndex == 0)
    {
        [self.searchManager searchWithKeyword:self.keyword searchType:WELIKE_SEARCH_TYPE_LATEST];
    }
    else if (self.segmentedControl.currentIndex == 1)
    {
        [self.searchManager searchWithKeyword:self.keyword searchType:WELIKE_SEARCH_TYPE_USERS];
    }
    else if (self.segmentedControl.currentIndex == 2)
    {
        [self.searchManager searchWithKeyword:self.keyword searchType:WELIKE_SEARCH_TYPE_POSTS];
    }
}

- (void)loadMoreData
{
    [self.searchManager loadMore];
}

- (void)deleteFeed:(WLFeedLayout *)layout cell:(WLFeedCell *)cell
{
    NSIndexPath *deletingIndexPath = [self.tableView indexPathForCell:cell];
    if (deletingIndexPath) {
        [self.dataArray enumerateObjectsWithOptions:NSEnumerationReverse
                                         usingBlock:^(WLFeedLayout * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                             if ([layout.feedModel.pid isEqualToString:obj.feedModel.pid]) {
                                                 [self.dataArray removeObject:obj];
                                                 
                                                 *stop = YES;
                                             }
                                         }];
        [self.tableView deleteRowsAtIndexPaths:@[deletingIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [[AppContext getInstance].singleContentManager deletePost:layout.feedModel];
}

- (void)likeFeed:(WLFeedLayout *)layout cell:(WLFeedCell *)cell
{
    if (layout.feedModel.like)
    {
        [[AppContext getInstance].singleContentManager dislikePost:layout.feedModel];
    }
    else
    {
        [[AppContext getInstance].singleContentManager likePost:layout.feedModel];
    }
    
    layout.feedModel.like = !layout.feedModel.like;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath)
    {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)blockFeed:(WLFeedLayout *)layout cell:(WLFeedCell *)cell {
    [[AppContext getInstance].singleUserManager blockUserWithUid:layout.feedModel.uid];
    [WLTrackerBlock appendTrackerWithBlockType:WLTrackerBlockType_Block post:layout.feedModel];
    
    NSIndexPath *deletingIndexPath = [self.tableView indexPathForCell:cell];
    if (deletingIndexPath) {
        [self p_removeLayout:layout];
        [self.tableView deleteRowsAtIndexPaths:@[deletingIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (NSInteger)objectIndex:(NSObject *)obj {
    NSInteger index = [self.dataArray indexOfObject:obj];
    
    if (self.segmentedControl.currentIndex == 0 && userSectionCount > 0) {
        if ([obj isKindOfClass:[WLUser class]]) {
            index--;
        } else if ([obj isKindOfClass:[WLFeedLayout class]]) {
            index -= (1 + userSectionCount);
        }
    }
    
    if (index < 0) {
        index = 0;
    }
    
    if (index >= self.dataArray.count) {
        index = self.dataArray.count - 1;
    }
    
    return index;
}

- (NSInteger)p_removeLayout:(WLFeedLayout *)layout {
    __block NSInteger index = -1;
    [self.dataArray enumerateObjectsWithOptions:NSEnumerationReverse
                                     usingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                         if ([obj isKindOfClass:[WLFeedLayout class]]) {
                                             WLFeedLayout *item = (WLFeedLayout *)obj;
                                             if ([layout.feedModel.pid isEqualToString:item.feedModel.pid]) {
                                                 index = idx;
                                                 [self.dataArray removeObject:obj];
                                                 
                                                 *stop = YES;
                                             }
                                         }
                                     }];
    
    return index;
}

#pragma mark - Share

- (void)showShareController:(WLPostBase *)feedModel {
//    NSString *imgUrl = feedModel.headUrl;
//    if (feedModel.type == WELIKE_POST_TYPE_PIC) {
//        imgUrl = [(WLPicInfo *)[(WLPicPost *)feedModel picInfoList].firstObject picUrl];
//    }
    
    WLShareModel *shareModel = [WLShareModel modelWithPost:feedModel];
    
    WLShareViewController *ctr = [[WLShareViewController alloc] init];
    ctr.shareModel = shareModel;
    [[AppContext currentViewController] presentViewController:ctr animated:YES completion:nil];
}

@end
