//
//  WLCommentDetailViewController.m
//  welike
//
//  Created by fan qi on 2018/5/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLCommentDetailViewController.h"
#import "WLCommentDetailManager.h"
#import "WLFeedLayout.h"
#import "WLCommentLayout.h"
#import "WLFeedCommentCell.h"
#import "WLHeadView.h"
#import "TYLabel.h"
#import "WLRichItem.h"
#import "WLUserDetailViewController.h"
#import "WLFeedDetailViewController.h"
#import "WLAlertController.h"
#import "WLRepostViewController.h"
#import "WLCommentPostViewController.h"
#import "WLTopicDetailViewController.h"
#import "WLAccountManager.h"
#import "WLSingleContentManager.h"
#import "WLCommentOperateView.h"
#import "WLPublishTaskManager.h"
#import "WLWebViewController.h"
#import "WLTrackerRepostAndComment.h"
#import "WLTrackerLike.h"

static NSString * const reuseCommentCellID = @"WLFeedCommentCellID";

@interface WLCommentDetailViewController () <WLCommentDetailManagerDelegate, TYLabelDelegate, WLFeedCommentCellDelegate, WLHeadViewDelegate, WLSingleContentManagerDelegate, WLCommentOperateViewDelegate, WLPublishTaskManagerDelegate>

@property (nonatomic, copy) NSString *commentID;

@property (nonatomic, strong) WLFeedLayout *feedLayout;
@property (nonatomic, strong) WLCommentLayout *commentLayout;
@property (nonatomic, strong) WLPostBase *feedModel;
@property (nonatomic, strong) WLComment *commentModel;

@property (nonatomic, strong) WLCommentDetailManager *manager;
@property (nonatomic, strong) WLSingleContentManager *deleteManager;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) UIView *tableHeaderView;

@property (nonatomic, weak) WLCommentOperateView *operateView;

@end

@implementation WLCommentDetailViewController

#pragma mark - LifeCycle

- (instancetype)initWithFeedLayout:(WLFeedLayout *)feedLayout commentLayout:(WLCommentLayout *)commentLayout {
    if (self = [self initWithFeedModel:feedLayout.feedModel commentModel:commentLayout.commentModel]) {
        _feedLayout = feedLayout;
        _commentLayout = commentLayout;
    }
    return self;
}

- (instancetype)initWithFeedModel:(WLPostBase *)feedModel commentModel:(WLComment *)commentModel {
    if (self = [super init]) {
        _feedModel = feedModel;
        _commentModel = commentModel;
        _commentID = [commentModel.cid copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [AppContext getStringForKey:@"comment_detail" fileName:@"feed"];
    
    [[AppContext getInstance].publishTaskManager registerDelegate:self];
    
    WLCommentOperateView *operateView = [[WLCommentDetailOperateView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kCommentOperateHeight, kScreenWidth, kCommentOperateHeight)];
    operateView.liked = self.commentLayout.commentModel.like;
    operateView.delegate = self;
    [self.view addSubview:operateView];
    self.operateView = operateView;
    
    self.tableView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight - kNavBarHeight - kCommentOperateHeight);
    [self.tableView registerClass:[WLFeedCommentCell class] forCellReuseIdentifier:reuseCommentCellID];
    self.tableView.tableHeaderView = self.tableHeaderView;
    [self addTarget:self refreshAction:@selector(refreshData) moreAction:@selector(loadMoreData)];
    [self beginRefresh];
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

- (void)dealloc {
    [_deleteManager unregister:self];
    [[AppContext getInstance].publishTaskManager unregister:self];
}

#pragma mark - Network

- (void)refreshData {
    [self.manager tryRefreshWithMainCid:self.commentID];
}

- (void)loadMoreData {
    [self.manager tryHisWithMainCid:self.commentID];
}

- (void)deleteReplay:(WLCommentLayout *)layout cell:(WLFeedCommentCell *)cell {
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
    
    [self.deleteManager deleteReply:layout.commentModel];
}

- (void)likeReply:(WLCommentLayout *)layout cell:(WLFeedCommentCell *)cell {
    if (layout.commentModel.like) {
        [self.deleteManager dislikeReply:layout.commentModel.cid];
        layout.commentModel.likeCount--;
    } else {
        [self.deleteManager likeReply:layout.commentModel.cid];
        layout.commentModel.likeCount++;
    }
    
    layout.commentModel.like = !layout.commentModel.like;
    layout.commentModel.likeCount = layout.commentModel.likeCount > 0 ?: 0;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)likeComment:(WLCommentLayout *)layout {
    if (layout.commentModel.like) {
        [self.deleteManager dislikeComment:layout.commentModel.cid];
        layout.commentModel.likeCount--;
    } else {
        [self.deleteManager likeComment:layout.commentModel.cid];
        layout.commentModel.likeCount++;
    }
    
    layout.commentModel.like = !layout.commentModel.like;
    layout.commentModel.likeCount = layout.commentModel.likeCount > 0 ?: 0;
    
    self.operateView.liked = layout.commentModel.like;
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

#pragma mark - WLCommentDetailManagerDelegate

- (void)onRefreshCommentDetail:(WLCommentDetailManager *)manager
                       replies:(NSArray *)replies
                           cid:(NSString *)cid
                          last:(BOOL)last
                       errCode:(NSInteger)errCode {
    [self endRefresh];
    
    if (replies.count > 0) {
        [self.dataArray removeAllObjects];
    }
    
    if (errCode != ERROR_SUCCESS) {
        [self.tableView reloadData];
        
        self.tableView.emptyType = WLScrollEmptyType_Empty_Network;
        [self.tableView reloadEmptyData];
        return;
    }
    
    self.tableView.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
    
    [self.dataArray addObjectsFromArray:replies];
    [self.tableView reloadData];
    
    if (self.dataArray.count == 0) {
        self.tableView.emptyType = WLScrollEmptyType_Empty_Data;
    }
    [self.tableView reloadEmptyData];
}

- (void)onReceiveCommentDetailHis:(WLCommentDetailManager *)manager
                          replies:(NSArray *)replies
                              cid:(NSString *)cid
                             last:(BOOL)last
                          errCode:(NSInteger)errCode {
    [self.tableView endLoadMore];
    
    if (errCode != ERROR_SUCCESS) {
        self.tableView.refreshFooterView.result = WLRefreshFooterResult_Error;
        return;
    }
    
    self.tableView.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
    
    if (replies.count > 0) {
        [self.dataArray addObjectsFromArray:replies];
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
    return self.dataArray.count > indexPath.row ? [(WLCommentLayout *)self.dataArray[indexPath.row] cellHeight] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WLFeedCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCommentCellID];
    self.dataArray.count > indexPath.row ? [cell setLayout:self.dataArray[indexPath.row]] : nil;
    cell.delegate = self;
    return cell;
}

#pragma mark - WLFeedCommentCellDelegate

- (void)feedCommentCell:(WLFeedCommentCell *)cell didClickedSelf:(WLCommentLayout *)layout {
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
                                                
                                                  commentPostViewController.type = WELIKE_DRAFT_TYPE_REPLY_OF_REPLY;
                                                  commentPostViewController.comment = self->_commentLayout.commentModel;//一级
                                                  commentPostViewController.secondeComment = comment;//二级
                                                  commentPostViewController.postBase = self->_feedLayout.feedModel;
                                                  
                                                  RDRootViewController *navController = [[RDRootViewController alloc] initWithRootViewController:commentPostViewController];
                                                  
                                                  [self presentViewController:navController animated:YES completion:^{
                                                      
                                                  }];
                                              }]];
    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"comment_menu_forward" fileName:@"feed"]
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                  
                                                  WLRepostViewController *repostViewController = [[WLRepostViewController alloc] init];
                                                
                                                  repostViewController.type = WELIKE_DRAFT_TYPE_FORWARD_COMMENT;
                                                  repostViewController.comment = comment;
                                                  repostViewController.postBase = self->_feedLayout.feedModel;
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
        || [self.feedLayout.feedModel.uid isEqual:[AppContext getInstance].accountManager.myAccount.uid]) {
        [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"feed_delete_confirm" fileName:@"feed"]
                                                  style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                                                      [self deleteReplay:layout cell:cell];
                                                  }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"common_cancel" fileName:@"common"]
                                              style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                  
                                              }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)feedCommentCell:(WLFeedCommentCell *)cell didClickedUser:(NSString *)userID {
    WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithUserID:userID];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (void)feedCommentCell:(WLFeedCommentCell *)cell didClickedTopic:(NSString *)topicID {
    WLTopicDetailViewController *ctr = [[WLTopicDetailViewController alloc] initWithTopicID:topicID];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
}

- (void)feedCommentCell:(WLFeedCommentCell *)cell didClickedTranspond:(WLCommentLayout *)layout {
    [WLTrackerRepostAndComment setFeedSource:WLTrackerFeedSource_CommentDetail_Comments];
    
    WLRepostViewController *repostViewController = [[WLRepostViewController alloc] init];
    repostViewController.type = WELIKE_DRAFT_TYPE_FORWARD_COMMENT;
    repostViewController.comment = layout.commentModel;
    repostViewController.postBase = self.feedLayout.feedModel;
    RDRootViewController *navController = [[RDRootViewController alloc] initWithRootViewController:repostViewController];
    
    [self presentViewController:navController animated:YES completion:^{
        
    }];
}

- (void)feedCommentCell:(WLFeedCommentCell *)cell didClickedComment:(WLCommentLayout *)layout {
    [WLTrackerRepostAndComment setFeedSource:WLTrackerFeedSource_CommentDetail_Comments];
    
    WLCommentPostViewController *commentPostViewController = [[WLCommentPostViewController alloc] init];
    commentPostViewController.type = WELIKE_DRAFT_TYPE_REPLY_OF_REPLY;
    commentPostViewController.comment = self.commentLayout.commentModel;//一级
    commentPostViewController.secondeComment = layout.commentModel;//二级
    commentPostViewController.postBase = self.feedLayout.feedModel;
    
    RDRootViewController *navController = [[RDRootViewController alloc] initWithRootViewController:commentPostViewController];
    
    [self presentViewController:navController animated:YES completion:^{
        
    }];
}

- (void)feedCommentCell:(WLFeedCommentCell *)cell didClickedLike:(WLCommentLayout *)layout {
    [WLTrackerLike setFeedSource:WLTrackerFeedSource_CommentDetail_Comments];
    
    [self likeReply:layout cell:cell];
}

#pragma mark - WLCommentOperateViewDelegate

- (void)commentOperateViewDidClickedComment:(WLCommentOperateView *)operateView {
    [WLTrackerRepostAndComment setFeedSource:WLTrackerFeedSource_CommentDetail_Bottom];
    
    WLCommentPostViewController *commentPostViewController = [[WLCommentPostViewController alloc] init];
   
    commentPostViewController.type = WELIKE_DRAFT_TYPE_REPLY;
    commentPostViewController.comment = self.commentModel;
    commentPostViewController.postBase = self.feedLayout.feedModel;
    RDRootViewController *navController = [[RDRootViewController alloc] initWithRootViewController:commentPostViewController];
    
    [self presentViewController:navController animated:YES completion:^{
        
    }];
}

- (void)commentOperateViewDidClickedLike:(WLCommentOperateView *)operateView {
    [WLTrackerLike setFeedSource:WLTrackerFeedSource_CommentDetail_Bottom];
    
    [self likeComment:self.commentLayout];
}

- (void)commentOperateViewDidClickedTranspond:(WLCommentOperateView *)operateView {
    [WLTrackerRepostAndComment setFeedSource:WLTrackerFeedSource_CommentDetail_Bottom];
    
    WLRepostViewController *repostViewController = [[WLRepostViewController alloc] init];
 
    repostViewController.type = WELIKE_DRAFT_TYPE_FORWARD_COMMENT;
    repostViewController.comment = self.commentModel;
    repostViewController.postBase = self.feedModel;
    RDRootViewController *navController = [[RDRootViewController alloc] initWithRootViewController:repostViewController];
    
    [self presentViewController:navController animated:YES completion:^{
        
    }];
}

#pragma mark - WLHeadViewDelegate

- (void)onClick:(WLHeadView *)headView {
    [self headerNameLabTapped];
}

#pragma mark - TYLabelDelegate

- (void)label:(TYLabel *)label didTappedTextHighlight:(TYTextHighlight *)textHighlight {
    NSString *key = textHighlight.userInfo.allKeys.firstObject;
    if ([key isEqualToString:WLRICH_TYPE_MENTION]) {
        WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithUserID:textHighlight.userInfo[key]];
        [self.navigationController pushViewController:ctr animated:YES];
    } else if ([key isEqualToString:WLRICH_TYPE_TOPIC]) {
        WLTopicDetailViewController *ctr = [[WLTopicDetailViewController alloc] initWithTopicID:textHighlight.userInfo[key]];
        [[AppContext rootViewController] pushViewController:ctr animated:YES];
    } else if ([key isEqualToString:WLRICH_TYPE_LINK]) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:textHighlight.userInfo[key]]];
        WLWebViewController *webViewController = [[WLWebViewController alloc] initWithUrl:textHighlight.userInfo[key]];
        [[AppContext rootViewController] pushViewController:webViewController animated:YES];
    } else if ([key isEqualToString:WLRICH_TYPE_MORE]) {
        
    }
}

#pragma mark - Event

- (void)headerNameLabTapped {
    WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithUserID:self.commentLayout.commentModel.uid];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (void)originFeedBtnClicked {
    WLFeedDetailViewController *ctr = [[WLFeedDetailViewController alloc] initWithID:self.commentLayout.commentModel.pid];
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark - Getter

- (WLCommentDetailManager *)manager {
    if (!_manager) {
        _manager = [WLCommentDetailManager new];
        _manager.delegate = self;
    }
    return _manager;
}

- (WLSingleContentManager *)deleteManager {
    if (!_deleteManager) {
        _deleteManager = [AppContext getInstance].singleContentManager;
        [_deleteManager registerDelegate:self];
    }
    return _deleteManager;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UIView *)tableHeaderView {
    if (!_tableHeaderView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
        view.backgroundColor = [UIColor clearColor];
        _tableHeaderView = view;
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
        contentView.backgroundColor = [UIColor whiteColor];
        [view addSubview:contentView];
        
        CGFloat x = 12, y = 14, paddingX = 8, paddingY = 2, avatarSize = kAvatarSizeMedium;
        WLHeadView *avatarView = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
        avatarView.frame = CGRectMake(x, y, avatarSize, avatarSize);
        avatarView.delegate = self;
        [avatarView setComment:self.commentLayout.commentModel];
        [contentView addSubview:avatarView];
        
        UILabel *nameLab = [[UILabel alloc] init];
        nameLab.frame = (CGRect){.origin = CGPointMake(x + avatarSize + paddingX, y), .size = CGSizeZero};
        nameLab.text = self.commentLayout.commentModel.nickName;
        nameLab.textColor = kNameFontColor;
        nameLab.font = kBoldFont(kMediumNameFontSize);
        [nameLab sizeToFit];
        [contentView addSubview:nameLab];
        {
            nameLab.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerNameLabTapped)];
            [nameLab addGestureRecognizer:tap];
        }
        
        UILabel *timeLab = [[UILabel alloc] init];
        timeLab.frame = (CGRect){.origin = CGPointMake(CGRectGetMinX(nameLab.frame), CGRectGetMaxY(nameLab.frame) + paddingY),
            .size = CGSizeZero};
        timeLab.text = self.commentLayout.timeString;
        timeLab.textColor = kDateTimeFontColor;
        timeLab.font = kRegularFont(kDateTimeFontSize);
        [timeLab sizeToFit];
        [contentView addSubview:timeLab];
        y += (avatarSize + paddingY);
        
        TYLabel *commentLab = [[TYLabel alloc] init];
        commentLab.frame = CGRectMake(x, y, CGRectGetWidth(view.bounds) - x * 2, self.commentLayout.textFrame.size.height);
        commentLab.delegate = self;
        [commentLab setTextRender:self.commentLayout.handledFeedModel.textRender];
        [contentView addSubview:commentLab];
        y += (CGRectGetHeight(commentLab.frame) + paddingY);
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(x, y, 0, 0);
        [btn setTitle:[AppContext getStringForKey:@"comment_detail_view_blog" fileName:@"feed"] forState:UIControlStateNormal];
        [btn setTitleColor:kClickableTextColor forState:UIControlStateNormal];
        btn.titleLabel.font = kRegularFont(kLightFontSize);
        [btn addTarget:self action:@selector(originFeedBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [btn sizeToFit];
        [contentView addSubview:btn];
        y += (CGRectGetHeight(btn.frame) + paddingY);
        
        contentView.frame = CGRectMake(0, 0, kScreenWidth, y);
        view.frame = CGRectMake(0, 0, kScreenWidth, y + 1.0);
    }
    return _tableHeaderView;
}

@end
