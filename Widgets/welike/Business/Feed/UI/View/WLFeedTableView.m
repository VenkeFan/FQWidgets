//
//  WLFeedTableView.m
//  welike
//
//  Created by fan qi on 2018/5/17.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFeedTableView.h"

#import "WLRecommendUserArrayCell.h"
#import "WLFeedLayout.h"
#import "WLPicPost.h"
#import "WLPicInfo.h"
#import "WLForwardPost.h"
#import "WLVideoPost.h"
#import "WLPollPost.h"

#import "WLFeedsManager.h"
#import "WLSingleContentManager.h"
#import "WLAccountManager.h"
#import "WLSingleUserManager.h"
#import "WLUsersManager.h"
#import "WLShareManager.h"

#import "WLHomeFeedsProvider.h"
#import "WLLatestFeedsProvider.h"
#import "WLHotFeedsProvider.h"
#import "WLRecommendUsersProvider.h"

#import "WLAlertController.h"
#import "WLUserDetailViewController.h"
#import "WLFeedDetailViewController.h"
#import "WLCommentPostViewController.h"
#import "WLRepostViewController.h"
#import "WLTopicDetailViewController.h"
#import "WLReportViewController.h"
#import "WLShareViewController.h"
#import "WLLocationDetailViewController.h"
#import "WLPlayerViewController.h"

#import "WLMixedPlayerViewManager.h"
#import "WLPlayerCollectionView.h"
#import "AFNetworkManager.h"
#import <objc/runtime.h>
#import "WLTrackerBlock.h"
#import "WLTrackerLogin.h"

#import "WLArticalPostModel.h"
#import "WLArticalController.h"

static NSString * const reuseFeedCellID = @"WLFeedTableViewCellID";
static NSString * const reuseRecommendUserCellID = @"WLRecommendUserArrayCellID";

@interface WLFeedTableView () <WLFeedsManagerDelegate, WLSingleContentManagerDelegate, WLFeedDetailViewControllerDelegate, WLUsersManagerDelegate>

@property (nonatomic, strong, readwrite) WLFeedsManager *feedManager;
@property (nonatomic, strong) WLSingleContentManager *deleteManager;
@property (nonatomic, strong) WLUsersManager *userManager;
@property (nonatomic, strong) WLShareManager *shareManager;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray<WLUser *> *recommendUserArray;
@property (nonatomic, assign) BOOL hasData;

@end

@implementation WLFeedTableView {
    WLFeedCell *_displayVideoCell;
    BOOL _isDragToRefresh;
    dispatch_group_t _taskGroup;
}

@synthesize mixedPlayerView;

#pragma mark - LifeCycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _hasData = NO;
        _isDragToRefresh = NO;
        
        self.backgroundColor = kTableViewBgColor;
        self.showsVerticalScrollIndicator = YES;
        [self registerClass:[WLFeedCell class] forCellReuseIdentifier:reuseFeedCellID];
        [self registerClass:[WLRecommendUserArrayCell class] forCellReuseIdentifier:reuseRecommendUserCellID];
        [self addTarget:self refreshAction:@selector(refreshData) moreAction:@selector(loadMoreData)];
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    
    if (!newWindow) {
        if (self.mixedPlayerView.playerView.windowMode == WLPlayerViewWindowMode_Widget) {
            [self destroyMixedPlayerView];
        }
    }
}

- (void)dealloc {
    [_deleteManager unregister:self];
    
    [self destroyMixedPlayerView];
}

#pragma mark - Public

- (void)setDataSourceProvider:(id<WLFeedsProvider>)provider uid:(NSString *)uid {
    [self.feedManager setDataSourceProvider:provider uid:uid];
}

#pragma mark - Network

- (void)refreshData {
    if (_taskGroup) {
        return;
    }
    
    _taskGroup = dispatch_group_create();
    
    dispatch_group_enter(_taskGroup);
    [self.feedManager tryRefreshFeeds];
    
    if (self.feedManager.sourceType == WLFeedSourceType_Home
        && [AppContext getInstance].accountManager.isLogin) {
        dispatch_group_enter(_taskGroup);
        [self.userManager tryRefreshUsersWithKeyId:nil];
    }
    
    dispatch_group_notify(_taskGroup, dispatch_get_main_queue(), ^{
        [self endRefresh];
        
        if (self->_recommendUserArray.count > 0) {
            [self.dataArray removeObject:self.recommendUserArray];
            
            if (self.dataArray.count >= 7) {
                [self.dataArray insertObject:self.recommendUserArray atIndex:7];
            } else {
                [self.dataArray addObject:self.recommendUserArray];
            }
        }
        
        if (self.dataArray.count > 0) {
            self.emptyType = WLScrollEmptyType_None;
        } else if (self.dataArray.count == 0) {
            if (self.emptyType != WLScrollEmptyType_Empty_Network) {
                self.emptyType = WLScrollEmptyType_Empty_Data;
            }
        }
        [self reloadData];
        [self reloadEmptyData];
        
        self->_taskGroup = nil;
    });
}

- (void)loadMoreData {
    [self.feedManager tryHisFeeds];
}

- (void)deleteFeed:(WLFeedLayout *)layout cell:(WLFeedCell *)cell {
    NSIndexPath *deletingIndexPath = [self indexPathForCell:cell];
    if (deletingIndexPath) {
        [self p_removeLayout:layout];
        [self deleteRowsAtIndexPaths:@[deletingIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [self.deleteManager deletePost:layout.feedModel];
}

- (void)likeFeed:(WLFeedLayout *)layout cell:(WLFeedCell *)cell {
    if (layout.feedModel.like) {
        [self.deleteManager dislikePost:layout.feedModel];
    } else {
        [self.deleteManager likePost:layout.feedModel];
    }
    
    layout.feedModel.like = !layout.feedModel.like;
    
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath) {
        [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)blockFeed:(WLFeedLayout *)layout cell:(WLFeedCell *)cell {
    [[AppContext getInstance].singleUserManager blockUserWithUid:layout.feedModel.uid];
    [WLTrackerBlock appendTrackerWithBlockType:WLTrackerBlockType_Block post:layout.feedModel];
    
    NSIndexPath *deletingIndexPath = [self indexPathForCell:cell];
    if (deletingIndexPath) {
        [self p_removeLayout:layout];
        [self deleteRowsAtIndexPaths:@[deletingIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)pinToTopWithLayout:(WLFeedLayout *)layout cell:(WLFeedCell *)cell {
    [[AppContext currentViewController] showLoading];
    
    [self.userManager pinPost:layout.feedModel.pid complete:^(BOOL isSuccess, NSInteger errCode) {
        [[AppContext currentViewController] hideLoading];
        
        if (isSuccess) {
            layout.feedModel.isTop = YES;
            
            NSIndexPath *indexPath = [self indexPathForCell:cell];
            if (indexPath) {
                NSInteger i = 0;
                for ( ; i < self.dataArray.count; i++) {
                    if (![self.dataArray[i] isKindOfClass:[WLFeedLayout class]]) {
                        continue;
                    }
                    WLFeedLayout *itemLayout = (WLFeedLayout *)self.dataArray[i];
                    if (!itemLayout.feedModel.isTop) {
                        break;
                    }
                }
                
                if (i >= 0 && i < self.dataArray.count) {
                    [self.dataArray removeObject:layout];
                    [self.dataArray insertObject:layout atIndex:i];
                    
                    NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [self moveRowAtIndexPath:indexPath toIndexPath:toIndexPath];
                    [self reloadRowsAtIndexPaths:@[toIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
            
        } else {
            [[AppContext currentViewController] showToastWithNetworkErr:errCode];
        }
    }];
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

#pragma mark - WLFeedsManagerDelegate

- (void)onRefreshManager:(WLFeedsManager *)manager
                   feeds:(NSArray *)feeds
                newCount:(NSInteger)newCount
                    last:(BOOL)last
                 errCode:(NSInteger)errCode {
    dispatch_group_leave(_taskGroup);
    
    self.hasData = feeds.count > 0;
    
    if (feeds.count > 0) {
        [self.dataArray removeAllObjects];
    }
    
    if (errCode != ERROR_SUCCESS) {
//        [self reloadData];
        
        self.emptyType = WLScrollEmptyType_Empty_Network;
//        [self reloadEmptyData];
        return;
    }
    
    self.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
    
    [self.dataArray addObjectsFromArray:feeds];
//    [self reloadData];
    
//    if (self.dataArray.count == 0) {
//        self.emptyType = WLScrollEmptyType_Empty_Data;
//    }
//    [self reloadEmptyData];
    
    [self appendRefreshTrackerWithFetchCount:feeds.count];
}

- (void)onReceiveHisManager:(WLFeedsManager *)manager
                      feeds:(NSArray *)feeds
                       last:(BOOL)last
                    errCode:(NSInteger)errCode {
    [self endLoadMore];
    
    if (errCode != ERROR_SUCCESS) {
        self.refreshFooterView.result = WLRefreshFooterResult_Error;
        return;
    }
    
    self.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
    
    if (feeds.count > 0) {
        [self.dataArray addObjectsFromArray:feeds];
        [self reloadData];
    }
    
    [self appendMoreTrackerWithFetchCount:feeds.count];
}

#pragma mark - WLUsersManagerDelegate

- (void)onRefreshManager:(WLUsersManager *)manager
                   users:(NSArray *)users
                     kid:(NSString *)kid
                newCount:(NSInteger)newCount
                    last:(BOOL)last
                 errCode:(NSInteger)errCode {
    [self.recommendUserArray removeAllObjects];
    [self.recommendUserArray addObjectsFromArray:users];
    
    dispatch_group_leave(_taskGroup);
}

- (void)onReceiveHisManager:(WLUsersManager *)manager
                      users:(NSArray *)users
                        kid:(NSString *)kid
                       last:(BOOL)last
                    errCode:(NSInteger)errCode {
    
}

#pragma mark - WLSingleContentManagerDelegate

- (void)onPostDeleted:(NSString *)pid {
    
}

- (void)onPostDeleted:(NSString *)pid error:(NSInteger)errCode {
    
}

#pragma mark - WLFeedDetailViewControllerDelegate

- (void)feedDetailViewController:(WLFeedDetailViewController *)ctr didDeleted:(WLFeedLayout *)layout {
    NSInteger index = [self p_removeLayout:layout];
    if (index < 0 || index >= self.dataArray.count) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    WLFeedCell *cell = [self cellForRowAtIndexPath:indexPath];
    if (cell) {
        [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)feedDetailViewController:(WLFeedDetailViewController *)ctr didPolled:(WLPollPost *)polledModel {
    [self p_reloadWithPolledModel:polledModel];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataArray.count) {
        return 0;
    }
    
    id obj = self.dataArray[indexPath.row];
    if ([obj isKindOfClass:[WLFeedLayout class]]) {
        return [(WLFeedLayout *)obj cellHeight];
    }
    
    return kWLRecommendUserArrayCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataArray.count) {
        return [UITableViewCell new];
    }
    
    id obj = self.dataArray[indexPath.row];
    if ([obj isKindOfClass:[WLFeedLayout class]]) {
        WLFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseFeedCellID];
        cell.delegate = self;
        [cell setLayout:(WLFeedLayout *)obj];
        return cell;
        
    } else if ([obj isKindOfClass:[NSArray class]]) {
        WLRecommendUserArrayCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseRecommendUserCellID];
        [cell setCellDataArray:(NSMutableArray *)obj];
        return cell;
    }
    
    return [UITableViewCell new];
}

#pragma mark - WLFeedCellDelegate

- (void)feedCell:(WLFeedCell *)cell didClickedFeed:(WLFeedLayout *)layout {
    WLFeedDetailViewController *ctr = [[WLFeedDetailViewController alloc] initWithOriginalFeedLayout:layout];
    ctr.delegate = self;
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

- (void)feedCell:(WLFeedCell *)cell didClickedArtical:(WLFeedLayout *)layout
{
    if ([layout.feedModel isKindOfClass:[WLArticalPostModel class]])
    {
        WLArticalController *ctr = [[WLArticalController alloc] initWithOriginalFeedLayout:layout.feedModel];
        [[AppContext rootViewController] pushViewController:ctr animated:YES];
    }
   
     if ([layout.feedModel isKindOfClass:[WLForwardPost class]])
    {
        WLForwardPost *post = (WLForwardPost *)layout.feedModel;
        
        if ([post.rootPost isKindOfClass:[WLArticalPostModel class]])
        {
            WLArticalController *ctr = [[WLArticalController alloc] initWithOriginalFeedLayout:post.rootPost];
            [[AppContext rootViewController] pushViewController:ctr animated:YES];
        }
    }
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
        ctr.delegate = self;
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
    [self destroyMixedPlayerView];
    
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
        if (self.feedManager.sourceType == WLFeedSourceType_UserDetail_Posts) {
            if (layout.feedModel.isTop) {
                [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"un_feed_top" fileName:@"user"]
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [[AppContext currentViewController] showLoading];
                                                            [self.userManager unPinPost:layout.feedModel.pid complete:^(BOOL isSuccess, NSInteger errCode) {
                                                                [[AppContext currentViewController] hideLoading];
                                                                
                                                                if (isSuccess) {
                                                                    layout.feedModel.isTop = NO;
                                                                    [self refreshData];
                                                                }
                                                            }];
                                                        }]];
            } else {
                [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"feed_top" fileName:@"user"]
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [self pinToTopWithLayout:layout cell:cell];
                                                        }]];
            }
        }
        
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

- (void)feedCell:(WLFeedCell *)cell didClickedShare:(WLFeedLayout *)layout {
    WLShareModel *shareModel = [WLShareModel modelWithPost:layout.feedModel];
    [self.shareManager whatsAppShareWithShareModel:shareModel];
}

- (void)feedCell:(WLFeedCell *)cell didPolled:(WLPollPost *)polledModel {
    [self p_reloadWithPolledModel:polledModel];
}

- (void)feedCellDidFollowLoadingChanged:(WLFeedLayout *)layout {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.dataArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[WLFeedLayout class]]) {
                WLFeedLayout *item = (WLFeedLayout *)obj;
                if ([item.feedModel.uid isEqualToString:layout.feedModel.uid]) {
                    item.followLoading = layout.followLoading;
                }
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[WLFeedCell class]]) {
                    WLFeedCell *cell = (WLFeedCell *)obj;
                    cell.followLoading = cell.layout.followLoading;
                }
            }];
        });
    });
}

- (void)feedCellDidFollowLoadingFinished:(WLFeedLayout *)layout {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.dataArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[WLFeedLayout class]]) {
                WLFeedLayout *item = (WLFeedLayout *)obj;
                if ([item.feedModel.uid isEqualToString:layout.feedModel.uid]) {
                    item.feedModel.following = layout.feedModel.following;
                    item.feedModel.follower = layout.feedModel.follower;
                }
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[WLFeedCell class]]) {
                    WLFeedCell *cell = (WLFeedCell *)obj;
                    cell.followLoading = cell.layout.followLoading;
                }
            }];
        });
    });
}

#pragma mark - UIScrollViewEmptyDelegate

- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView {
    [self beginRefresh];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    
    if (self.mixedPlayerView) {
        CGRect frame = [_displayVideoCell.feedView.videoView convertRect:_displayVideoCell.feedView.videoView.bounds
                                                         toView:kCurrentWindow];
        
        if (CGRectGetMinY(frame) <= -(CGRectGetHeight(frame) - kNavBarHeight)
            || CGRectGetMinY(frame) > (CGRectGetHeight(scrollView.frame) + kNavBarHeight)) {
            [self destroyMixedPlayerView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [super scrollViewDidEndDecelerating:scrollView];
    
    [self mixedPlayerViewAutoPlay];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    
    _isDragToRefresh = YES;
    
    if (!decelerate) {
        [self mixedPlayerViewAutoPlay];
    }
}

#pragma mark - WLMixedPlayerViewProtocol

- (void)mixedPlayerViewAutoPlay {
    if ([AFNetworkManager getInstance].reachabilityStatus != HLNetWorkStatusWiFi) {
        [self destroyMixedPlayerView];
        return;
    }
    
    if (nil == (_displayVideoCell = [self p_questDisplayingCell])) {
        [self destroyMixedPlayerView];
        return;
    }
    
    WLFeedLayout *layout = _displayVideoCell.layout;
    WLPostBase *feedModel = layout.feedModel;
    if (layout.feedModel.type == WELIKE_POST_TYPE_FORWARD) {
        feedModel = [(WLForwardPost *)layout.feedModel rootPost];
    }
    
    if (feedModel.type != WELIKE_POST_TYPE_VIDEO) {
        [self destroyMixedPlayerView];
        return;
    }
    
    [WLTrackerPlayer setForwardPost:layout.feedModel];
    
    WLVideoPost *videoPost = (WLVideoPost *)feedModel;
    
    if ([self.mixedPlayerView.urlString isEqualToString:videoPost.videoUrl]
        && (self.mixedPlayerView.playerView.playerViewStatus == WLPlayerViewStatus_Playing
            || self.mixedPlayerView.playerView.playerViewStatus == WLPlayerViewStatus_CachingPaused)) {
            return;
        }
    
    [self destroyMixedPlayerView];
    self.mixedPlayerView = [[WLMixedPlayerViewManager instance] generateMixedPlayerView];
    self.mixedPlayerView.videoModel = videoPost;
    self.mixedPlayerView.playerView.operateView.playerOrientation = WLPlayerViewOrientation_Vertical;
    self.mixedPlayerView.playerView.windowMode = WLPlayerViewWindowMode_Widget;
    
    self.mixedPlayerView.frame = _displayVideoCell.feedView.videoView.bounds;
    [_displayVideoCell.feedView.videoView addSubview:self.mixedPlayerView];
    
    [self.mixedPlayerView.playerView play];
}

- (void)destroyMixedPlayerView {
    if (self.mixedPlayerView) {
        self.mixedPlayerView.playerView.operateView.cacheProgress = 0.0;
        [self.mixedPlayerView.playerView stop];
        [self.mixedPlayerView removeFromSuperview];
        self.mixedPlayerView = nil;
    }
}

#pragma mark - Private

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

- (WLFeedCell *)p_questDisplayingCell {
    __block WLFeedCell *displayingCell = nil;
    [self.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[WLFeedCell class]]) {
            WLFeedCell *feedCell = (WLFeedCell *)obj;
            
            CGRect frame = [feedCell.feedView.videoView convertRect:feedCell.feedView.videoView.bounds
                                                             toView:kCurrentWindow];
            if (CGRectGetMinY(frame) > kNavBarHeight && CGRectGetMaxY(frame) <= (CGRectGetHeight(self.frame) + kNavBarHeight)) {
                displayingCell = feedCell;
                *stop = YES;
            }
        }
    }];
    
    return displayingCell;
}

- (void)p_reloadWithPolledModel:(WLPollPost *)polledModel {
    WLPollPost *newPollModel = polledModel;
    NSMutableArray *indices = [NSMutableArray array];
    
    for (NSInteger i = 0; i < self.dataArray.count; i++) {
        if ([self.dataArray[i] isKindOfClass:[WLFeedLayout class]]) {
            WLFeedLayout *obj = (WLFeedLayout *)self.dataArray[i];
            WLFeedLayout *newLayout = [obj reLayoutWithPollModel:newPollModel];
            if (newLayout) {
                [self.dataArray replaceObjectAtIndex:i withObject:newLayout];
                [indices addObject:[NSNumber numberWithInteger:i]];
            }
        }
    }
    
    if (indices.count == 0) {
        return;
    }
    
    NSMutableArray<NSIndexPath *> *indexPathArray = [NSMutableArray array];
    for (int i = 0; i < indices.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[indices[i] integerValue] inSection:0];
        WLFeedCell *cell = [self cellForRowAtIndexPath:indexPath];
        if (cell) {
            [indexPathArray addObject:indexPath];
        }
    }
    
    [self reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Getter

- (WLFeedsManager *)feedManager {
    if (!_feedManager) {
        _feedManager = [[WLFeedsManager alloc] init];
        [_feedManager setDataSourceProvider:[[WLHomeFeedsProvider alloc] init] uid:nil];
        _feedManager.delegate = self;
    }
    return _feedManager;
}

- (WLSingleContentManager *)deleteManager {
    if (!_deleteManager) {
        _deleteManager = [AppContext getInstance].singleContentManager;
        [_deleteManager registerDelegate:self];
    }
    return _deleteManager;
}

- (WLUsersManager *)userManager {
    if (!_userManager) {
        _userManager = [[WLUsersManager alloc] init];
        [_userManager setDataSourceProvider:[WLRecommendUsersProvider new]];
        _userManager.delegate = self;
    }
    return _userManager;
}

- (WLShareManager *)shareManager {
    if (!_shareManager) {
        _shareManager = [[WLShareManager alloc] init];
    }
    return _shareManager;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray<WLUser *> *)recommendUserArray {
    if (!_recommendUserArray) {
        _recommendUserArray = [NSMutableArray array];
    }
    return _recommendUserArray;
}

@end


@implementation WLFeedTableView (WLTracker)

- (void)setTrackerAction:(WLTrackerFeedAction)trackerAction {
    objc_setAssociatedObject(self, @selector(trackerAction), @(trackerAction), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (WLTrackerFeedAction)trackerAction {
    return (WLTrackerFeedAction)[objc_getAssociatedObject(self, @selector(trackerAction)) integerValue];
}

- (void)appendRefreshTrackerWithFetchCount:(NSUInteger)fetchCount {
    self.trackerAction = self.dataArray.count == 0 ? WLTrackerFeedAction_Default_Refresh :
    (_isDragToRefresh ? WLTrackerFeedAction_Drag_Refresh : WLTrackerFeedAction_Clicked_Refresh);
    
    WLFeedLayout *layout = nil;
    if ([self.dataArray.firstObject isKindOfClass:[WLFeedLayout class]]) {
        layout = (WLFeedLayout *)self.dataArray.firstObject;
    }
    
    [WLTrackerFeed appendTrackWithAction:self.trackerAction
                                    type:layout ? layout.feedModel.trackerSource : [WLTrackerFeed emptyDataTrackerSource]
                                 subType:layout ? layout.feedModel.trackerSubType : [WLTrackerFeed emptyDataTrackerSubType]
                              fetchCount:fetchCount];
    _isDragToRefresh = NO;
}

- (void)appendMoreTrackerWithFetchCount:(NSUInteger)fetchCount {
    self.trackerAction = WLTrackerFeedAction_More;
    
    WLFeedLayout *layout = nil;
    if ([self.dataArray.firstObject isKindOfClass:[WLFeedLayout class]]) {
        layout = (WLFeedLayout *)self.dataArray.firstObject;
    }
    
    [WLTrackerFeed appendTrackWithAction:self.trackerAction
                                    type:layout ? layout.feedModel.trackerSource : [WLTrackerFeed emptyDataTrackerSource]
                                 subType:layout ? layout.feedModel.trackerSubType : [WLTrackerFeed emptyDataTrackerSubType]
                              fetchCount:fetchCount];
    _isDragToRefresh = NO;
}

@end
