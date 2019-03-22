//
//  WLFeedDetailViewController.m
//  welike
//
//  Created by fan qi on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFeedDetailViewController.h"
#import "WLPostDetailManager.h"
#import "WLFeedLayout.h"
#import "WLForwardPost.h"
#import "WLFeedCell.h"
#import "WLFeedCommentCell.h"
#import "GBRefreshTableHeaderView.h"

#import "WLMainTableView.h"
#import "WLComboxView.h"
#import "WLScrollViewCell.h"
#import "WLFeedRepostTableView.h"
#import "WLFeedCommentTableView.h"
#import "WLFeedLikeTableView.h"
#import "WLUserDetailViewController.h"
#import "WLCommentPostViewController.h"
#import "WLRepostViewController.h"
#import "WLCommentLayout.h"
#import "WLCommentDetailViewController.h"
#import "WLTopicDetailViewController.h"
#import "WLReportViewController.h"
#import "WLSingleUserManager.h"
#import "WLAlertController.h"
#import "WLAccountManager.h"
#import "WLSingleContentManager.h"
#import "WLPublishTaskManager.h"
#import "WLCommentOperateView.h"
#import "WLPlayerViewController.h"
#import "WLShareViewController.h"
#import "WLPicPost.h"
#import "WLPicInfo.h"
#import "WLLocationDetailViewController.h"
#import "WLVideoPost.h"
#import "WLShareManager.h"

#import "WLMixedPlayerViewManager.h"
#import "WLPlayerCollectionView.h"
#import "AFNetworkManager.h"

#import "WLTrackerRepostAndComment.h"
#import "WLTrackerLike.h"
#import "WLTrackerBlock.h"
#import "WLTrackerLogin.h"

#import "WLArticalController.h"
#import "WLArticalPostModel.h"

static NSString *reuseDetailCellID = @"WLFeedDetailCellID";

@interface WLFeedDetailViewController () <WLFeedCommentTableViewDelegate, WLFeedCellDelegate, WLFeedLikeTableViewDelegate, WLCommentOperateViewDelegate, UIScrollViewEmptyDelegate, UIScrollViewEmptyDataSource, UITableViewDelegate, UITableViewDataSource, GBRefreshTableHeaderViewDelegate, WLPublishTaskManagerDelegate, WLMixedPlayerViewProtocol, WLComboxViewDelegate> {
    WLFeedCell *_displayVideoCell;
}

@property (nonatomic, assign) BOOL hasRefreshed;

@property (nonatomic, strong) WLFeedLayout *detailLayout;
@property (nonatomic, copy) NSString *feedID;

@property (nonatomic, strong) WLPostDetailManager *detailManager;
@property (nonatomic, strong) WLSingleContentManager *deleteManager;
@property (nonatomic, strong) WLShareManager *shareManager;

@property (nonatomic, weak) WLMainTableView *containerTableView;
@property (nonatomic, strong) UIView *sectionHeaderView;
@property (nonatomic, strong) WLComboxView *combox;
@property (nonatomic, strong) WLScrollViewCell *scrollViewCell;
@property (nonatomic, strong) WLFeedCommentTableView *commentView;

@property (nonatomic, weak) WLCommentOperateView *operateView;

@property (nonatomic, strong) GBRefreshTableHeaderView *refreshHeaderView;

@end

@implementation WLFeedDetailViewController

@synthesize mixedPlayerView;

#pragma mark - LifeCycle

- (instancetype)initWithID:(NSString *)ID {
    if (self = [super init]) {
        _feedID = [ID copy];
    }
    return self;
}

- (instancetype)initWithOriginalFeedLayout:(WLFeedLayout *)originalFeedLayout {
    if (self = [self initWithID:originalFeedLayout.feedModel.pid]) {
        [self setDetailLayout:[WLFeedLayout layoutWithFeedModel:originalFeedLayout.feedModel layoutType:WLFeedLayoutType_FeedDetail]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kLightBackgroundViewColor;
    self.title = [AppContext getStringForKey:@"feed_detail" fileName:@"feed"];
    
    [self layoutUI];
    
    if (self.scrollToSegment) {
        [self.containerTableView reloadData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.containerTableView setContentOffset:CGPointMake(0, [self p_topCellHeight])];
        });
        [self fetchFeedDetail];
    } else {
        [self beginRefresh];
    }
    
    [[AppContext getInstance].publishTaskManager registerDelegate:self];
}

- (void)layoutUI {
    WLMainTableView *tableView = [[WLMainTableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight,
                                                                                   CGRectGetWidth(self.view.bounds),
                                                                                   CGRectGetHeight(self.view.bounds) - kNavBarHeight - kCommentOperateHeight)
                                                                  style:UITableViewStylePlain];
    tableView.backgroundColor = kLightBackgroundViewColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.emptyDelegate = self;
    tableView.emptyDataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[WLFeedCell class] forCellReuseIdentifier:reuseDetailCellID];
    [self.view addSubview:tableView];
    _containerTableView = tableView;
    
    _refreshHeaderView = [[GBRefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -kScreenHeight, kScreenWidth, kScreenHeight) type:Normal];
    _refreshHeaderView.delegate = self;
    [tableView addSubview:_refreshHeaderView];
    
    WLCommentOperateView *operateView = [[WLCommentOperateView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kCommentOperateHeight, kScreenWidth, kCommentOperateHeight)];
    operateView.delegate = self;
    [self.view addSubview:operateView];
    self.operateView = operateView;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect frame = self.operateView.frame;
    frame.origin.y = self.view.frame.size.height - kCommentOperateHeight;
    self.operateView.frame = frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.mixedPlayerView.playerView play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.mixedPlayerView.playerView pause];
}

- (void)dealloc {
    [[AppContext getInstance].publishTaskManager unregister:self];
    
    [self destroyMixedPlayerView];
}

#pragma mark - Network

- (void)beginRefresh {
    [_refreshHeaderView manualFresh:self.containerTableView];
}

- (void)endRefresh {
    [_refreshHeaderView GBRefreshScrollViewStopLoading:self.containerTableView];
}

- (void)fetchFeedDetail {
    if (self.detailLayout.feedModel.deleted) {
        [self endRefresh];
        return;
    }
    
    _hasRefreshed = NO;
    
    __weak typeof(self) weakSelf = self;
    [self.detailManager reqPostDetailWithPid:weakSelf.feedID
                                   successed:^(WLFeedLayout *postLayout) {
                                       [weakSelf endRefresh];
                                       weakSelf.hasRefreshed = YES;
                                       
                                       if (postLayout.feedModel.deleted) {
                                           weakSelf.containerTableView.emptyType = WLScrollEmptyType_Empty_Deleted;
                                           weakSelf.operateView.hidden = YES;
                                           
                                       } else {
                                           weakSelf.containerTableView.emptyType = WLScrollEmptyType_None;
                                           weakSelf.operateView.hidden = NO;
                                       }
                                       
                                       [weakSelf setDetailLayout:postLayout];
                                       self.operateView.liked = self.detailLayout.feedModel.like;
                                       
                                       [weakSelf.containerTableView reloadData];
                                       [weakSelf.containerTableView reloadEmptyData];
                                       
                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                           [weakSelf mixedPlayerViewAutoPlay];
                                       });
                                       
                                       [WLTrackerPostDisplay addDisplayedPost:postLayout.feedModel];
                                       [WLTrackerPostDisplay appendTrackerWithDisplayAction:WLTrackerPostDisplayAction_Detail];
                                   }
                                       error:^(NSInteger errCode) {
                                           [weakSelf endRefresh];
                                           weakSelf.hasRefreshed = YES;
                                           
                                           [weakSelf.containerTableView reloadData];
                                       }];
}

- (void)likeFeed:(WLFeedLayout *)layout {
    if (layout.feedModel.like) {
        [self.deleteManager dislikePost:layout.feedModel];
    } else {
        [self.deleteManager likePost:layout.feedModel];
    }
    
    layout.feedModel.like = !layout.feedModel.like;
    
    self.operateView.liked = layout.feedModel.like;
}

- (void)deleteFeed:(WLFeedLayout *)layout {
    [self.deleteManager deletePost:layout.feedModel];
    
    if ([self.delegate respondsToSelector:@selector(feedDetailViewController:didDeleted:)]) {
        [self.delegate feedDetailViewController:self didDeleted:self.detailLayout];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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
    [self presentViewController:ctr animated:YES completion:nil];
}

#pragma mark - WLPublishTaskManagerDelegate

- (void)onPublishTask:(NSString *)taskId end:(NSInteger)errCode
{
    if (errCode == 0)
    {
        [self showToast:[AppContext getStringForKey:@"editor_send_successed" fileName:@"publish"]];
    }
    else
    {
        [self showToastWithNetworkErr:errCode];
    }
}

#pragma mark - GBRefreshTableHeaderViewDelegate

- (void)GBRefreshScrollViewStartLoading {
    [self fetchFeedDetail];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_refreshHeaderView GBRefreshScrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_refreshHeaderView GBRefreshScrollViewDidScroll:scrollView];
    
    CGFloat ratio = 1.0 - (scrollView.contentOffset.y) / fabs([self p_topCellHeight]);
    self.navigationBar.navLine.alpha = ratio;
    
    if (self.scrollViewCell.subScrollViewScrolling) {
        self.containerTableView.contentOffset = CGPointMake(0, [self p_topCellHeight]);
        return;
    }
    
    if (scrollView.contentOffset.y >= [self p_topCellHeight]) {
        self.containerTableView.contentOffset = CGPointMake(0, [self p_topCellHeight]);
        self.scrollViewCell.superScrollViewScrolling = NO;
        
        [self p_addSectionHeaderShadow];
    } else {
        self.scrollViewCell.superScrollViewScrolling = YES;
        
        [self p_clearSectionHeaderShadow];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_refreshHeaderView GBRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.detailLayout || self.detailLayout.feedModel.deleted) {
        return 0;
    }
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.detailLayout || self.detailLayout.feedModel.deleted) {
        return 0;
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return CGRectGetHeight(self.sectionHeaderView.bounds);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [self p_topCellHeight];
    }
    
    return [self p_scrollCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        WLFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseDetailCellID];
        [cell setLayout:self.detailLayout];
        cell.delegate = self;
        _displayVideoCell = cell;
        return cell;
    } else {
        if (!_hasRefreshed) {
            return [UITableViewCell new];
        }
        
        if (_scrollViewCell) {
            [_scrollViewCell forceRefresh];
        }
        
        if (!_scrollViewCell) {
            _scrollViewCell = [[WLScrollViewCell alloc] init];
            
            CGFloat height = [self p_scrollCellHeight];
            CGRect frame = CGRectMake(0, 0, kScreenWidth, height);
            
            _commentView = [[WLFeedCommentTableView alloc] initWithFrame:frame];
            _commentView.pid = self.feedID;
            _commentView.superCell = _scrollViewCell;
            _commentView.delegate = self;
            if (_combox.currentIndex == 0) {
                _commentView.sortType = WLFeedCommentSortType_Top;
            } else {
                _commentView.sortType = WLFeedCommentSortType_Latest;
            }
            
            [_scrollViewCell setSubViews:@[_commentView]];
            [_scrollViewCell setCurrentIndex:0];
        }
        return _scrollViewCell;
    }
}

#pragma mark - WLFeedCellDelegate

- (void)feedCell:(WLFeedCell *)cell didClickedFeed:(WLFeedLayout *)layout {
    if ([layout.feedModel.pid isEqualToString:self.detailLayout.feedModel.pid]) {
        return;
    }
    
    WLFeedDetailViewController *ctr = [[WLFeedDetailViewController alloc] initWithOriginalFeedLayout:layout];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
}

- (void)feedCell:(WLFeedCell *)cell didClickedUser:(NSString *)userID {
    WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithUserID:userID];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (void)feedCell:(WLFeedCell *)cell didClickedTopic:(NSString *)topicID {
    WLTopicDetailViewController *ctr = [[WLTopicDetailViewController alloc] initWithTopicID:topicID];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
}

- (void)feedCell:(WLFeedCell *)cell didClickedVideo:(WLVideoPost *)videoModel {
    WLPlayerCollectionView *playerCollectionView = [[WLPlayerCollectionView alloc] initWithPostID:videoModel.pid];
    [playerCollectionView displayWithSubView:nil videoModel:videoModel];
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

- (void)feedCell:(WLFeedCell *)cell didClickedLocation:(WLFeedLayout *)layout {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Other];
    kNeedLogin
    
    WLLocationDetailViewController *locationDetailViewController = [[WLLocationDetailViewController alloc] init];
    locationDetailViewController.placeId = layout.feedModel.location.placeId;
    [[AppContext rootViewController] pushViewController:locationDetailViewController animated:YES];
}

- (void)feedCell:(WLFeedCell *)cell didPolled:(WLPollPost *)polledModel {
    WLFeedLayout *newLayout = [self.detailLayout reLayoutWithPollModel:polledModel];
    if (newLayout) {
        self.detailLayout = newLayout;
        
        NSIndexPath *indexPath = [self.containerTableView indexPathForCell:cell];
        if (indexPath) {
            [self.containerTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(feedDetailViewController:didPolled:)]) {
        [self.delegate feedDetailViewController:self didPolled:polledModel];
    }
}

- (void)feedCellDidFollowLoadingChanged:(WLFeedLayout *)layout {
    _displayVideoCell.followLoading = layout.followLoading;
}

- (void)feedCellDidFollowLoadingFinished:(WLFeedLayout *)layout {
    _displayVideoCell.followLoading = layout.followLoading;
}

#pragma mark - WLFeedCommentTableViewDelegate

- (void)feedCommentTableView:(WLFeedCommentTableView *)commentView didClickedCell:(WLFeedCommentCell *)cell layout:(WLCommentLayout*)layout {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Other];
    kNeedLogin
    
    WLComment *comment = layout.commentModel;
    if (!comment) {
        return;
    }
    
    WLAlertController *alert = [WLAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@: %@", comment.nickName, comment.content.text]
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"comment_menu_reply" fileName:@"feed"]
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                  WLCommentPostViewController *commentPostViewController = [[WLCommentPostViewController alloc] init];
                    
                                                  commentPostViewController.type = WELIKE_DRAFT_TYPE_REPLY;
                                                  commentPostViewController.comment = layout.commentModel;
                                                  commentPostViewController.postBase = self.detailLayout.feedModel;
                                                  RDRootViewController *navController = [[RDRootViewController alloc] initWithRootViewController:commentPostViewController];
                                                  
                                                  [self presentViewController:navController animated:YES completion:^{
                                                      
                                                  }];
                                              }]];
    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"comment_menu_forward" fileName:@"feed"]
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                  
                                                  WLRepostViewController *repostViewController = [[WLRepostViewController alloc] init];
                                                 
                                                  repostViewController.type = WELIKE_DRAFT_TYPE_FORWARD_COMMENT;
                                                  repostViewController.comment = layout.commentModel;
                                                  repostViewController.postBase = self.detailLayout.feedModel;
                                                  RDRootViewController *navController = [[RDRootViewController alloc] initWithRootViewController:repostViewController];
                                                  
                                                  [self presentViewController:navController animated:YES completion:^{
                                                      
                                                  }];
                                                  
                                              }]];
    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"copy" fileName:@"feed"]
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                                  pasteboard.string = comment.content.text;
                                              }]];
    
    if ([comment.uid isEqual:[AppContext getInstance].accountManager.myAccount.uid]
        || [self.detailLayout.feedModel.uid isEqual:[AppContext getInstance].accountManager.myAccount.uid]) {
        [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"feed_delete_confirm" fileName:@"feed"]
                                                  style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                                                      [commentView deleteComment:layout cell:cell];
                                                  }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"common_cancel" fileName:@"common"]
                                              style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                  
                                              }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)feedCommentTableView:(WLFeedCommentTableView *)commentView didClickedUser:(NSString *)userID {
    WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithUserID:userID];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (void)feedCommentTableView:(WLFeedCommentTableView *)commentView didClickedTopic:(NSString *)topicID {
    WLTopicDetailViewController *ctr = [[WLTopicDetailViewController alloc] initWithTopicID:topicID];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
}

- (void)feedCommentTableView:(WLFeedCommentTableView *)commentView didClickedTranspond:(WLCommentLayout *)layout {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Repost];
    kNeedLogin
    
    [WLTrackerRepostAndComment setFeedSource:WLTrackerFeedSource_FeedDetail_Comments];
    
    WLRepostViewController *repostViewController = [[WLRepostViewController alloc] init];
    repostViewController.type = WELIKE_DRAFT_TYPE_FORWARD_COMMENT;
    repostViewController.comment = layout.commentModel;
    repostViewController.postBase = self.detailLayout.feedModel;
    RDRootViewController *navController = [[RDRootViewController alloc] initWithRootViewController:repostViewController];
    
    [self presentViewController:navController animated:YES completion:^{
        
    }];
}

- (void)feedCommentTableView:(WLFeedCommentTableView *)commentView didClickedComment:(WLCommentLayout *)layout {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Comment];
    kNeedLogin
    
    [WLTrackerRepostAndComment setFeedSource:WLTrackerFeedSource_FeedDetail_Comments];
    
    WLCommentPostViewController *commentPostViewController = [[WLCommentPostViewController alloc] init];
  
    commentPostViewController.type = WELIKE_DRAFT_TYPE_REPLY;
    commentPostViewController.comment = layout.commentModel;
    commentPostViewController.postBase = self.detailLayout.feedModel;
    RDRootViewController *navController = [[RDRootViewController alloc] initWithRootViewController:commentPostViewController];
    
    [self presentViewController:navController animated:YES completion:^{
        
    }];
}

- (void)feedCommentTableView:(WLFeedCommentTableView *)commentView didClickedChild:(WLCommentLayout *)layout {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Other];
    kNeedLogin
    
    WLCommentDetailViewController *ctr = [[WLCommentDetailViewController alloc] initWithFeedLayout:self.detailLayout commentLayout:layout];
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark - WLFeedLikeTableViewDelegate

- (void)feedLikeTableView:(WLFeedLikeTableView *)view didSelectedWithUserID:(NSString *)userID {
    WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithUserID:userID];
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark - WLCommentOperateViewDelegate

- (void)commentOperateViewDidClickedComment:(WLCommentOperateView *)operateView {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Comment];
    kNeedLogin
    
    [WLTrackerRepostAndComment setFeedSource:WLTrackerFeedSource_FeedDetail_Bottom];
    
    WLCommentPostViewController *commentPostViewController = [[WLCommentPostViewController alloc] init];
  
    commentPostViewController.type = WELIKE_DRAFT_TYPE_COMMENT;
    commentPostViewController.postBase = self.detailLayout.feedModel;
    RDRootViewController *navController = [[RDRootViewController alloc] initWithRootViewController:commentPostViewController];
    
    [self presentViewController:navController animated:YES completion:^{
        
    }];
}

- (void)commentOperateViewDidClickedLike:(WLCommentOperateView *)operateView {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Like];
    kNeedLogin
    
    [WLTrackerLike setFeedSource:WLTrackerFeedSource_FeedDetail_Bottom];
    
    [self likeFeed:self.detailLayout];
}

- (void)commentOperateViewDidClickedShare:(WLCommentOperateView *)operateView {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Other];
    kNeedLogin
    
    WLShareModel *shareModel = [WLShareModel modelWithPost:self.detailLayout.feedModel];
    [self.shareManager whatsAppShareWithShareModel:shareModel];
}

- (void)commentOperateViewDidClickedTranspond:(WLCommentOperateView *)operateView {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Repost];
    kNeedLogin
    
    [WLTrackerRepostAndComment setFeedSource:WLTrackerFeedSource_FeedDetail_Bottom];
    
    WLRepostViewController *repostViewController = [[WLRepostViewController alloc] init];
    repostViewController.type = WELIKE_DRAFT_TYPE_FORWARD_POST;
    repostViewController.postBase = self.detailLayout.feedModel;
    RDRootViewController *navController = [[RDRootViewController alloc] initWithRootViewController:repostViewController];
    
    [self presentViewController:navController animated:YES completion:^{
        
    }];
}

#pragma mark - UIScrollViewEmptyDataSource

- (NSString *)descriptionForEmptyDataSource:(UIScrollView *)scrollView {
    return [AppContext getStringForKey:@"error_post_deleted" fileName:@"error"];
}

#pragma mark - WLMixedPlayerViewProtocol

- (void)mixedPlayerViewAutoPlay {
    if ([AFNetworkManager getInstance].reachabilityStatus != HLNetWorkStatusWiFi) {
        [self destroyMixedPlayerView];
        return;
    }
    
    if (nil == _displayVideoCell) {
        [self destroyMixedPlayerView];
        return;
    }
    
    WLFeedLayout *layout = self.detailLayout;
    WLPostBase *feedModel = layout.feedModel;
    if (layout.feedModel.type == WELIKE_POST_TYPE_FORWARD) {
        feedModel = [(WLForwardPost *)layout.feedModel rootPost];
    }
    
    if (feedModel.type != WELIKE_POST_TYPE_VIDEO || feedModel.deleted) {
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

#pragma mark - WLComboxViewDelegate

- (void)comboxView:(WLComboxView *)combox indexChanged:(NSInteger)index {
    if (index == 0) {
        _commentView.sortType = WLFeedCommentSortType_Top;
    } else {
        _commentView.sortType = WLFeedCommentSortType_Latest;
    }
}

#pragma mark - Event

- (void)navRightBtnOnClicked {
    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Other];
    kNeedLogin
    
    WLAlertController *alert = [WLAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"feed_share" fileName:@"feed"]
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self showShareController:self.detailLayout.feedModel];
                                            }]];
    
    if ([self.detailLayout.feedModel.uid isEqualToString:[[AppContext getInstance].accountManager myAccount].uid] == YES) {
        [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"feed_delete_confirm" fileName:@"feed"]
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [self deleteFeed:self.detailLayout];
                                                }]];
    } else {
        [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"report" fileName:@"feed"]
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    WLReportViewController *vc = [[WLReportViewController alloc] init];
                                                    vc.post = self.detailLayout.feedModel;
                                                    [[AppContext rootViewController] pushViewController:vc animated:YES];
                                                }]];
        NSString *blockAction = [NSString stringWithFormat:@"%@@%@", [AppContext getStringForKey:@"block" fileName:@"common"], self.detailLayout.feedModel.nickName];
        [alert addAction:[UIAlertAction actionWithTitle:blockAction
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [self blockFeed:self.detailLayout];
                                                }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"common_cancel" fileName:@"common"]
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                
                                            }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Private

- (CGFloat)p_topCellHeight {
    return self.detailLayout.cellHeight;
    
//    return self.detailLayout ? self.detailLayout.cellHeight - CGRectGetHeight(self.sectionHeaderView.bounds) : 0;
}

- (CGFloat)p_scrollCellHeight {
    return CGRectGetHeight(self.view.bounds) - kNavBarHeight - CGRectGetHeight(self.sectionHeaderView.bounds) - kCommentOperateHeight;
}

- (NSString *)p_segmentTitle:(NSString *)title count:(NSInteger)count {
    return count > 0
    ? [NSString stringWithFormat:@"%@ %ld", title, (long)count]
    : [NSString stringWithFormat:@"%@", title];
}

- (void)blockFeed:(WLFeedLayout *)layout {
    [[AppContext getInstance].singleUserManager blockUserWithUid:layout.feedModel.uid];
    [WLTrackerBlock appendTrackerWithBlockType:WLTrackerBlockType_Block post:layout.feedModel];
    
    if ([self.delegate respondsToSelector:@selector(feedDetailViewController:didDeleted:)]) {
        [self.delegate feedDetailViewController:self didDeleted:self.detailLayout];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)p_addSectionHeaderShadow {
    self.sectionHeaderView.layer.shadowColor = kUIColorFromRGB(0x000000).CGColor;
    self.sectionHeaderView.layer.shadowOffset = CGSizeMake(0, 2);
    self.sectionHeaderView.layer.shadowOpacity = 0.1;
    self.sectionHeaderView.layer.shadowPath = CGPathCreateWithRect(CGRectMake(0, 5, CGRectGetWidth(self.sectionHeaderView.bounds), CGRectGetHeight(self.sectionHeaderView.bounds) - 5), NULL);
}

- (void)p_clearSectionHeaderShadow {
    self.sectionHeaderView.layer.shadowColor = kUIColorFromRGBA(0x000000, 0.0).CGColor;
}

#pragma mark - Setter

- (void)setDetailLayout:(WLFeedLayout *)detailLayout {
    _detailLayout = detailLayout;
    _postModel = detailLayout.feedModel;
    
    self.navigationBar.rightBtn.hidden = NO;
    [self.navigationBar.rightBtn setImage:[AppContext getImageForKey:@"common_more"] forState:UIControlStateNormal];
    [self.navigationBar.rightBtn addTarget:self action:@selector(navRightBtnOnClicked) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Getter

- (WLPostDetailManager *)detailManager {
    if (!_detailManager) {
        _detailManager = [WLPostDetailManager new];
    }
    return _detailManager;
}

- (WLSingleContentManager *)deleteManager {
    return [AppContext getInstance].singleContentManager;
}

- (WLShareManager *)shareManager {
    if (!_shareManager) {
        _shareManager = [[WLShareManager alloc] init];
    }
    return _shareManager;
}

- (UIView *)sectionHeaderView {
    if (!_sectionHeaderView) {
        _sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 32)];
        _sectionHeaderView.backgroundColor = [UIColor whiteColor];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_sectionHeaderView.frame) - 1, CGRectGetWidth(_sectionHeaderView.frame), 1)];
        line.backgroundColor = kUIColorFromRGB(0xF8F8F8);
        [_sectionHeaderView addSubview:line];
        
        CGFloat centerY = CGRectGetHeight(_sectionHeaderView.frame) * 0.5;
        CGFloat padding = 12;
        
        UIView *signView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 20)];
        signView.center = CGPointMake(0, centerY);
        signView.backgroundColor = kMainColor;
        signView.layer.cornerRadius = kCornerRadius;
        [_sectionHeaderView addSubview:signView];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = [AppContext getStringForKey:@"feed_detail_menu_comment" fileName:@"feed"];
        label.textColor = kNameFontColor;
        label.font = kBoldFont(kLightFontSize);
        [label sizeToFit];
        label.center = CGPointMake(CGRectGetMaxX(signView.frame) + padding + CGRectGetWidth(label.frame) * 0.5, centerY);
        [_sectionHeaderView addSubview:label];
        
        _combox = [[WLComboxView alloc] initWithFrame:CGRectMake(0, 0, 148, CGRectGetHeight(_sectionHeaderView.frame))];
        _combox.center = CGPointMake(CGRectGetWidth(_sectionHeaderView.frame) - CGRectGetWidth(_combox.frame) * 0.5 - padding, centerY);
        _combox.delegate = self;
        [_combox setDataArray:@[[AppContext getStringForKey:@"feed_comment_sort_top" fileName:@"feed"],
                                [AppContext getStringForKey:@"feed_comment_sort_latest" fileName:@"feed"]]];
        _combox.currentIndex = 0;
        [_sectionHeaderView addSubview:_combox];
    }
    return _sectionHeaderView;
}

@end
