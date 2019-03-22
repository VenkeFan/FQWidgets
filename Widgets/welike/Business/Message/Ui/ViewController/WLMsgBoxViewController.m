//
//  WLMsgBoxViewController.m
//  welike
//
//  Created by 刘斌 on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLMsgBoxViewController.h"
#import "WLMessageBoxManager.h"
#import "WLMsgBoxCell.h"
#import "WLMsgBoxMentionNotification.h"
#import "WLMsgBoxForwardPostNotification.h"
#import "WLMsgBoxCommentNotification.h"
#import "WLMsgBoxReplyNotification.h"
#import "WLMsgBoxLikePostNotification.h"
#import "WLMsgBoxLikeCommentNotification.h"
#import "WLMsgBoxLikeReplyNotification.h"
#import "WLFeedDetailViewController.h"
#import "WLCommentDetailViewController.h"

@interface WLMsgBoxViewController () <WLMessageBoxManagerDelegate>

@property (nonatomic, strong) WLMessageBoxManager *messageBoxManager;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation WLMsgBoxViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.messageBoxManager = [[WLMessageBoxManager alloc] init];
        self.dataArray = [NSMutableArray array];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    if (self.type == WELIKE_MSG_BOX_TYPE_MENTION)
    {
        self.navigationBar.title = [AppContext getStringForKey:@"message_mention_text" fileName:@"im"];
        self.messageBoxManager.type = MSG_BOX_TYPE_MENTION;
    }
    else if (self.type == WELIKE_MSG_BOX_TYPE_COMMENT)
    {
        self.navigationBar.title = [AppContext getStringForKey:@"message_comment_text" fileName:@"im"];
        self.messageBoxManager.type = MSG_BOX_TYPE_COMMENT;
    }
    else if (self.type == WELIKE_MSG_BOX_TYPE_LIKE)
    {
        self.navigationBar.title = [AppContext getStringForKey:@"message_comment_like_text" fileName:@"im"];
        self.messageBoxManager.type = MSG_BOX_TYPE_LIKE;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight - kNavBarHeight - kSafeAreaBottomY);
    [self addTarget:self refreshAction:@selector(refreshData) moreAction:@selector(loadMoreData)];
    [self beginRefresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.messageBoxManager.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.messageBoxManager.delegate = nil;
}

#pragma mark - WLMessageBoxManagerDelegate
- (void)onRefreshMessageBoxNotifications:(NSArray *)notifications last:(BOOL)last errCode:(NSInteger)errCode
{
    [self endRefresh];
    
    if (notifications.count > 0)
    {
        [self.dataArray removeAllObjects];
        WLMsgBoxDataSourceItem *item = [self.dataArray lastObject];
        item.end = YES;
    }
    
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
    [self.dataArray addObjectsFromArray:notifications];
    [self.tableView reloadData];
    
    if (self.dataArray.count == 0)
    {
        self.tableView.emptyType = WLScrollEmptyType_Empty_Data;
    }
    [self.tableView reloadEmptyData];
}

- (void)onReceiveHisMessageBoxNotifications:(NSArray *)notifications last:(BOOL)last errCode:(NSInteger)errCode
{
    [self.tableView endLoadMore];
    
    if (errCode != ERROR_SUCCESS)
    {
        self.tableView.refreshFooterView.result = WLRefreshFooterResult_Error;
        return;
    }
    
    self.tableView.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
    
    if (notifications.count > 0)
    {
        WLMsgBoxDataSourceItem *item = [self.dataArray lastObject];
        item.end = NO;
        [self.dataArray addObjectsFromArray:notifications];
        item = [self.dataArray lastObject];
        item.end = YES;
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
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
        if ([item isKindOfClass:[WLMsgBoxDataSourceItem class]])
        {
            return ((WLMsgBoxDataSourceItem *)item).cellHeight;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WLMsgBoxCell *cell = nil;
    id item = nil;
    
    NSInteger row = indexPath.row;
    if ([self.dataArray count] > row)
    {
        item = [self.dataArray objectAtIndex:row];
    }
    if (item != nil)
    {
        if ([item isKindOfClass:[WLMsgBoxDataSourceItem class]])
        {
            cell = [tableView dequeueReusableCellWithIdentifier:WLMsgBoxCellIdentifier];
            if (cell == nil)
            {
                cell = [[WLMsgBoxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLMsgBoxCellIdentifier];
                [cell setDataSourceItem:item];
            }
            else
            {
                [cell setDataSourceItem:item];
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = nil;
    
    NSInteger row = indexPath.row;
    if ([self.dataArray count] > row)
    {
        item = [self.dataArray objectAtIndex:row];
    }
    if (item != nil)
    {
        if ([item isKindOfClass:[WLMsgBoxDataSourceItem class]])
        {
            WLMsgBoxNotificationBase *notification = ((WLMsgBoxDataSourceItem *)item).notification;
            if ([notification isKindOfClass:[WLMsgBoxMentionNotification class]])
            {
                WLMsgBoxMentionNotification *n = (WLMsgBoxMentionNotification *)notification;
                if (n.parentType == WELIKE_MSG_BOX_MENTION_NOTIFICATION_TYPE_POST)
                {
                    WLFeedDetailViewController *ctr = [[WLFeedDetailViewController alloc] initWithID:n.parentPost.pid];
                    [[AppContext rootViewController] pushViewController:ctr animated:YES];
                }
                else if (n.parentType == WELIKE_MSG_BOX_MENTION_NOTIFICATION_TYPE_COMMENT)
                {
                    WLFeedDetailViewController *ctr = [[WLFeedDetailViewController alloc] initWithID:n.parentPost.pid];
                    [[AppContext rootViewController] pushViewController:ctr animated:YES];
                }
                else if (n.parentType == WELIKE_MSG_BOX_MENTION_NOTIFICATION_TYPE_REPLY)
                {
                    WLFeedDetailViewController *ctr = [[WLFeedDetailViewController alloc] initWithID:n.parentPost.pid];
                    [[AppContext rootViewController] pushViewController:ctr animated:YES];
                }
            }
            else if ([notification isKindOfClass:[WLMsgBoxForwardPostNotification class]])
            {
                WLFeedDetailViewController *ctr = [[WLFeedDetailViewController alloc] initWithID:notification.parentPost.pid];
                [[AppContext rootViewController] pushViewController:ctr animated:YES];
            }
            else if ([notification isKindOfClass:[WLMsgBoxCommentNotification class]])
            {
                WLMsgBoxCommentNotification *n = (WLMsgBoxCommentNotification *)notification;
                WLFeedDetailViewController *ctr = [[WLFeedDetailViewController alloc] initWithID:n.parentPost.pid];
                [[AppContext rootViewController] pushViewController:ctr animated:YES];
            }
            else if ([notification isKindOfClass:[WLMsgBoxReplyNotification class]])
            {
                WLMsgBoxReplyNotification *n = (WLMsgBoxReplyNotification *)notification;
                WLFeedDetailViewController *ctr = [[WLFeedDetailViewController alloc] initWithID:n.parentPost.pid];
                [[AppContext rootViewController] pushViewController:ctr animated:YES];
            }
            else if ([notification isKindOfClass:[WLMsgBoxLikePostNotification class]])
            {
                WLFeedDetailViewController *ctr = [[WLFeedDetailViewController alloc] initWithID:notification.parentPost.pid];
                [[AppContext rootViewController] pushViewController:ctr animated:YES];
            }
            else if ([notification isKindOfClass:[WLMsgBoxLikeCommentNotification class]])
            {
                WLMsgBoxLikeCommentNotification *n = (WLMsgBoxLikeCommentNotification *)notification;
                WLFeedDetailViewController *ctr = [[WLFeedDetailViewController alloc] initWithID:n.parentPost.pid];
                [[AppContext rootViewController] pushViewController:ctr animated:YES];
            }
            else if ([notification isKindOfClass:[WLMsgBoxLikeReplyNotification class]])
            {
                WLMsgBoxLikeReplyNotification *n = (WLMsgBoxLikeReplyNotification *)notification;
                WLFeedDetailViewController *ctr = [[WLFeedDetailViewController alloc] initWithID:n.parentPost.pid];
                [[AppContext rootViewController] pushViewController:ctr animated:YES];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UIScrollViewEmptyDelegate
- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView
{
    [self beginRefresh];
}

- (NSString *)descriptionForEmptyDataSource:(UIScrollView *)scrollView
{
    if (self.tableView.emptyType == WLScrollEmptyType_Empty_Data)
    {
        return [AppContext getStringForKey:@"message_no_information_text" fileName:@"im"];
    }
    return nil;
}

#pragma mark - private
- (void)refreshData
{
    [self.messageBoxManager tryRefresh];
}

- (void)loadMoreData
{
    [self.messageBoxManager tryHis];
}

@end
