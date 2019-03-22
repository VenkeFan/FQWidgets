 //
//  WLArticalController.m
//  welike
//
//  Created by gyb on 2019/2/23.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLArticalController.h"
#import "WLPostDetailManager.h"
#import "WLFeedLayout.h"
#import "WLForwardPost.h"
#import "WLFeedCommentCell.h"
#import "GBRefreshTableHeaderView.h"

#import "WLMainTableView.h"
#import "WLSegmentedControl.h"
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

//#import "WLMixedPlayerViewManager.h"
#import "WLPlayerCollectionView.h"
#import "AFNetworkManager.h"
#import "WLArticalCell.h"

#import "WLArticalPostModel.h"
#import "WLArticalView.h"

#import "WLImageBrowseView.h"
#import "WLRichItem.h"
#import "WLWebViewController.h"

#import "WLUserDetailViewController.h"

#import "WLComboxView.h"
#import "WLFeedCommentTableView.h"
#import "WLHeadView.h"


static NSString *reuseArticalDetailCellID = @"ArticalDetailCellID";


@interface WLArticalController ()<WLSegmentedControlDelegate, WLFeedCommentTableViewDelegate, WLFeedLikeTableViewDelegate, WLCommentOperateViewDelegate, UIScrollViewEmptyDelegate, UIScrollViewEmptyDataSource, UITableViewDelegate, UITableViewDataSource, GBRefreshTableHeaderViewDelegate, WLPublishTaskManagerDelegate, WLArticalViewDelegate, WLComboxViewDelegate>{
   
}

@property (nonatomic, assign) BOOL hasRefreshed;

@property (nonatomic, strong) WLFeedLayout *detailLayout;
@property (nonatomic, copy) NSString *feedID;

@property (nonatomic, strong) WLPostDetailManager *detailManager;
@property (nonatomic, strong) WLSingleContentManager *deleteManager;
@property (nonatomic, strong) WLShareManager *shareManager;

@property (nonatomic, weak) WLMainTableView *containerTableView;
//@property (nonatomic, strong) WLSegmentedControl *segmentedCtr;
@property (nonatomic, strong) UIView *sectionHeaderView;
@property (nonatomic, strong) WLComboxView *combox;

@property (nonatomic, strong) WLScrollViewCell *scrollViewCell;

@property (nonatomic, weak) WLCommentOperateView *operateView;
@property (nonatomic, strong) WLFeedCommentTableView *commentView;


@property (nonatomic, strong) GBRefreshTableHeaderView *refreshHeaderView;

@property (nonatomic, strong) WLArticalView *articalView;//显示长文阅读

@end

@implementation WLArticalController

- (void)dealloc {
    [[AppContext getInstance].publishTaskManager unregister:self];
}

- (instancetype)initWithID:(NSString *)ID {
    if (self = [super init]) {
        _feedID = [ID copy];
    }
    return self;
}

- (instancetype)initWithOriginalFeedLayout:(WLPostBase *)postBase {
    if (self = [self initWithID:postBase.pid]) {
        [self setDetailLayout:[WLFeedLayout layoutWithFeedModel:postBase layoutType:WLFeedLayoutType_FeedDetail]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _postModel.nickName;
    [self.navigationBar addHeadView:_postModel.headUrl userID:_postModel.uid tapTarget:self];
    
    
    [self layoutUI];
    
    
    [self beginRefresh];
    
    
    [[AppContext getInstance].publishTaskManager registerDelegate:self];
}

- (void)layoutUI {
    WLMainTableView *tableView = [[WLMainTableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight,
                                                                                   CGRectGetWidth(self.view.bounds),
                                                                                   CGRectGetHeight(self.view.bounds) - kNavBarHeight - kCommentOperateHeight)
                                                                  style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.emptyDelegate = self;
    tableView.emptyDataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseArticalDetailCellID];
    [self.view addSubview:tableView];
    _containerTableView = tableView;
    
    _refreshHeaderView = [[GBRefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -kScreenHeight, kScreenWidth, kScreenHeight) type:Normal];
    _refreshHeaderView.delegate = self;
    [tableView addSubview:_refreshHeaderView];
    
    WLCommentOperateView *operateView = [[WLCommentOperateView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kCommentOperateHeight, kScreenWidth, kCommentOperateHeight)];
    operateView.delegate = self;
    [self.view addSubview:operateView];
    self.operateView = operateView;
    
    _articalView = [[WLArticalView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)];
    _articalView.delegate = self;
    
    
    if ([_detailLayout.feedModel isKindOfClass:[WLArticalPostModel class]])
    {
         _articalView.postBase = (WLArticalPostModel *)_detailLayout.feedModel;
    }
    tableView.tableHeaderView = _articalView;
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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

#pragma mark - WLSegmentedControlDelegate

- (void)segmentedControl:(WLSegmentedControl *)control didSelectedIndex:(NSInteger)index {
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.scrollViewCell.currentIndex = index;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
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
    
    if (self.scrollViewCell.subScrollViewScrolling) {
        self.containerTableView.contentOffset = CGPointMake(0, _articalView.height);
        return;
    }
    
    if (scrollView.contentOffset.y >= _articalView.height) {
        self.containerTableView.contentOffset = CGPointMake(0, _articalView.height);
        self.scrollViewCell.superScrollViewScrolling = NO;
        
    } else {
        self.scrollViewCell.superScrollViewScrolling = YES;
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
        return 0;
    }
    
    return [self p_scrollCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseArticalDetailCellID];
        
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


#pragma mark - WLFeedCommentTableViewDelegate

- (void)feedCommentTableView:(WLFeedCommentTableView *)commentView didClickedCell:(WLFeedCommentCell *)cell layout:(WLCommentLayout*)layout {
  
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
  
    kNeedLogin
    
    WLRepostViewController *repostViewController = [[WLRepostViewController alloc] init];
    repostViewController.type = WELIKE_DRAFT_TYPE_FORWARD_COMMENT;
    repostViewController.comment = layout.commentModel;
    repostViewController.postBase = self.detailLayout.feedModel;
    RDRootViewController *navController = [[RDRootViewController alloc] initWithRootViewController:repostViewController];
    
    [self presentViewController:navController animated:YES completion:^{
        
    }];
}

- (void)feedCommentTableView:(WLFeedCommentTableView *)commentView didClickedComment:(WLCommentLayout *)layout {
    kNeedLogin

    WLCommentPostViewController *commentPostViewController = [[WLCommentPostViewController alloc] init];
    
    commentPostViewController.type = WELIKE_DRAFT_TYPE_REPLY;
    commentPostViewController.comment = layout.commentModel;
    commentPostViewController.postBase = self.detailLayout.feedModel;
    RDRootViewController *navController = [[RDRootViewController alloc] initWithRootViewController:commentPostViewController];
    
    [self presentViewController:navController animated:YES completion:^{
        
    }];
}

- (void)feedCommentTableView:(WLFeedCommentTableView *)commentView didClickedChild:(WLCommentLayout *)layout {
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
    kNeedLogin

    WLCommentPostViewController *commentPostViewController = [[WLCommentPostViewController alloc] init];
    
    commentPostViewController.type = WELIKE_DRAFT_TYPE_COMMENT;
    commentPostViewController.postBase = self.detailLayout.feedModel;
    RDRootViewController *navController = [[RDRootViewController alloc] initWithRootViewController:commentPostViewController];
    
    [self presentViewController:navController animated:YES completion:^{
        
    }];
}

- (void)commentOperateViewDidClickedLike:(WLCommentOperateView *)operateView {
    kNeedLogin

    [self likeFeed:self.detailLayout];
}

- (void)commentOperateViewDidClickedShare:(WLCommentOperateView *)operateView {
    kNeedLogin
    
    WLShareModel *shareModel = [WLShareModel modelWithPost:self.detailLayout.feedModel];
    [self.shareManager whatsAppShareWithShareModel:shareModel];
}

- (void)commentOperateViewDidClickedTranspond:(WLCommentOperateView *)operateView {
    kNeedLogin

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

#pragma mark - WLComboxViewDelegate

- (void)comboxView:(WLComboxView *)combox indexChanged:(NSInteger)index {
    if (index == 0) {
        _commentView.sortType = WLFeedCommentSortType_Top;
    } else {
        _commentView.sortType = WLFeedCommentSortType_Latest;
    }
}

#pragma mark - WLArticalViewDelegate
-(void)updateArticalFrame
{
     _containerTableView.tableHeaderView = _articalView;
}

-(void)tapImage:(NSInteger)indexNum
{
    NSMutableArray *picItems = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i = 0; i < _postModel.attachments.count; i++)
    {
        WLRichItem *item = _postModel.attachments[i];
        if ([item.type isEqualToString:WLRICH_TYPE_ARTICLE_IMAGE])
        {
            [picItems addObject:item];
        }
    }
    
    
    NSMutableArray *itemArray = [NSMutableArray array];
    
    UIImageView *tapView = (UIImageView *)[_articalView viewWithTag:indexNum + 10];
    
    for (int i = 0; i < picItems.count; i++)
    {
        WLRichItem *item = picItems[i];
       
            WLPicInfo *picInfo = [[WLPicInfo alloc] init];
            picInfo.picUrl = item.source;
           
            FQImageBrowseItemModel *browseItem = [[FQImageBrowseItemModel alloc] init];
            browseItem.thumbView = (i == indexNum)? _articalView.onlyPicItems[i]:nil;
            browseItem.userName = _postModel.userInfo.nickName;
            browseItem.imageInfo = picInfo;
            
            [itemArray addObject:browseItem];
        
    }
    
    UIView *rootView = ([UIApplication sharedApplication].keyWindow.rootViewController).view;
    
    WLImageBrowseView *groupView = [[WLImageBrowseView alloc] initWithItemArray:itemArray];
    [groupView displayWithFromView:tapView toView:rootView];
    
}

-(void)tapVideo
{
    //拿到所有图
    NSString *videoUrl;
    for (int i = 0; i < _postModel.attachments.count; i++)
    {
        WLRichItem *item = _postModel.attachments[i];
       
        if ([item.type isEqualToString:@"VIDEO"])
        {
            videoUrl = item.source;
        }
    }
    
    if (videoUrl.length > 0 && [videoUrl hasSuffix:@"mp4"])
    {
        AVPlayer *player = [AVPlayer playerWithURL:[NSURL URLWithString:videoUrl]];
        
        AVPlayerViewController *playerController = [AVPlayerViewController new];
        playerController.player = player;
        [self presentViewController:playerController animated:YES completion:^{
            [playerController.player play];
        }];
    }
    else
    {
        WLWebViewController *webViewController = [[WLWebViewController alloc] initWithUrl:videoUrl];
        [[AppContext rootViewController] pushViewController:webViewController animated:YES];
    }
}


#pragma mark - Private
- (CGFloat)p_scrollCellHeight {
  return CGRectGetHeight(self.view.bounds) - kNavBarHeight - CGRectGetHeight(self.sectionHeaderView.bounds) - kCommentOperateHeight;
}

- (NSString *)p_segmentTitle:(NSString *)title count:(NSInteger)count {
    return count > 0
    ? [NSString stringWithFormat:@"%@ %ld", title, (long)count]
    : [NSString stringWithFormat:@"%@", title];
}

#pragma mark - Setter

- (void)setDetailLayout:(WLFeedLayout *)detailLayout {
    _detailLayout = detailLayout;
    
    if ([detailLayout.feedModel isKindOfClass:[WLArticalPostModel class]])
    {
        _postModel = (WLArticalPostModel *)detailLayout.feedModel;
    }
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

- (void)onClick:(WLHeadView *)headView
{
    WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithUserID:self.postModel.userInfo.uid];
    [self.navigationController pushViewController:ctr animated:YES];
    
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
