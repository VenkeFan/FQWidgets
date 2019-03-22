//
//  WLBlockUsersListViewController.m
//  welike
//
//  Created by 刘斌 on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLBlockUsersListViewController.h"
#import "WLBlockUsersProvider.h"
#import "WLUsersManager.h"
#import "WLAccountManager.h"
#import "WLSingleUserManager.h"
#import "WLEmptySectionCell.h"
#import "WLBlockUserCell.h"
#import "WLUser.h"
#import "WLTrackerBlock.h"

@interface WLBlockUsersListViewController () <WLUsersManagerDelegate, WLBlockUserCellDelegate>

@property (nonatomic, strong) NSMutableArray *arrayList;
@property (nonatomic, strong) WLUsersManager *usersManager;

@end

@implementation WLBlockUsersListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.arrayList = [NSMutableArray array];
        self.usersManager = [[WLUsersManager alloc] init];
        WLBlockUsersProvider *provider = [[WLBlockUsersProvider alloc] init];
        [self.usersManager setDataSourceProvider:provider];
        self.usersManager.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.title = [AppContext getStringForKey:@"block" fileName:@"common"];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.tableView.frame = CGRectMake(0, kTabBarHeight + kSystemStatusBarHeight, CGRectGetWidth(self.view.bounds), self.view.height - (kTabBarHeight + kSystemStatusBarHeight) - kSafeAreaBottomY);
    [self.tableView addTarget:self refreshAction:@selector(refreshData) moreAction:@selector(moreData)];
    [self.tableView beginRefresh];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    id item = nil;
    NSInteger row = indexPath.row;
    if ([self.arrayList count] > row)
    {
        item = [self.arrayList objectAtIndex:row];
    }
    if (item != nil)
    {
        if ([item isKindOfClass:[WLEmptySectionDataSourceItem class]])
        {
            WLEmptySectionCell *sectionCell = [tableView dequeueReusableCellWithIdentifier:WLEmptySectionCellIdentifier];
            if (sectionCell == nil)
            {
                sectionCell = [[WLEmptySectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLEmptySectionCellIdentifier];
                [sectionCell setDataSourceItem:item];
            }
            else
            {
                [sectionCell setDataSourceItem:item];
            }
            cell = sectionCell;
        }
        else if ([item isKindOfClass:[WLBlockUserDataSourceItem class]])
        {
            WLBlockUserCell *blockCell = [tableView dequeueReusableCellWithIdentifier:WLBlockUserCellIdentifier];
            if (blockCell == nil)
            {
                blockCell = [[WLBlockUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLBlockUserCellIdentifier];
                [blockCell setDataSourceItem:item indexPath:indexPath];
                blockCell.delegate = self;
            }
            else
            {
                [blockCell setDataSourceItem:item indexPath:indexPath];
                blockCell.delegate = self;
            }
            cell = blockCell;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = nil;
    
    NSInteger row = indexPath.row;
    if ([self.arrayList count] > row)
    {
        item = [self.arrayList objectAtIndex:row];
    }
    if (item != nil)
    {
        if ([item isKindOfClass:[WLBlockUserDataSourceItem class]])
        {
            return ((WLBlockUserDataSourceItem *)item).cellHeight;
        }
        else if ([item isKindOfClass:[WLEmptySectionDataSourceItem class]])
        {
            return ((WLEmptySectionDataSourceItem *)item).cellHeight;
        }
    }
    
    return 0;
}

#pragma mark - WLUsersManagerDelegate
- (void)onRefreshManager:(WLUsersManager *)manager users:(NSArray *)users kid:(NSString *)kid newCount:(NSInteger)newCount last:(BOOL)last errCode:(NSInteger)errCode
{
    [self endRefresh];
    
    [self.arrayList removeAllObjects];
    if (errCode == ERROR_SUCCESS)
    {
        if ([users count] > 0)
        {
            WLEmptySectionDataSourceItem *section = [[WLEmptySectionDataSourceItem alloc] init];
            section.title = [AppContext getStringForKey:@"block_user_list_title" fileName:@"user"];
            section.cellHeight = 40.f;
            section.sectionMark = YES;
            section.backgroundColor = [UIColor whiteColor];
            [self.arrayList addObject:section];
            for (NSInteger i = 0; i < [users count]; i++)
            {
                WLUser *u = [users objectAtIndex:i];
                WLBlockUserDataSourceItem *item = [[WLBlockUserDataSourceItem alloc] init];
                item.uid = u.uid;
                item.nickName = u.nickName;
                item.head = u.headUrl;
                [self.arrayList addObject:item];
            }
        }
        else
        {
            self.tableView.emptyType = WLScrollEmptyType_Empty_Data;
        }
        
        self.tableView.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
        
        [self.tableView reloadData];
        [self.tableView reloadEmptyData];
    }
    else
    {
        [self.tableView reloadData];
        
        self.tableView.emptyType = WLScrollEmptyType_Empty_Network;
        [self.tableView reloadEmptyData];
    }
}

- (void)onReceiveHisManager:(WLUsersManager *)manager users:(NSArray *)users kid:(NSString *)kid last:(BOOL)last errCode:(NSInteger)errCode
{
   [self.tableView endLoadMore];
    if (errCode == ERROR_SUCCESS)
    {
        if ([users count] > 0)
        {
            for (NSInteger i = 0; i < [users count]; i++)
            {
                WLUser *u = [users objectAtIndex:i];
                WLBlockUserDataSourceItem *item = [[WLBlockUserDataSourceItem alloc] init];
                item.nickName = u.nickName;
                item.head = u.headUrl;
                [self.arrayList addObject:item];
            }
        }
        
        self.tableView.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
    }
    else
    {
        self.tableView.refreshFooterView.result = WLRefreshFooterResult_Error;
    }
}

#pragma mark - WLBlockUserCellDelegate
- (void)onUnblock:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if ([self.arrayList count] > row)
    {
        id item = [self.arrayList objectAtIndex:row];
        if ([item isKindOfClass:[WLBlockUserDataSourceItem class]])
        {
            [[AppContext getInstance].singleUserManager unblockUserWithUid:((WLBlockUserDataSourceItem *)item).uid];
            [WLTrackerBlock appendTrackerWithBlockType:WLTrackerBlockType_Unblock
                                                userID:((WLBlockUserDataSourceItem *)item).uid
                                                source:WLTrackerFeedSource_Setting_Report];
            [self.arrayList removeObjectAtIndex:row];
            if ([self.arrayList count] == 1)
            {
                [self.arrayList removeAllObjects];
            }
        }
        if ([self.arrayList count] == 0)
        {
            self.tableView.emptyType = WLScrollEmptyType_Empty_Data;
        }
        [self.tableView reloadData];
        [self.tableView reloadEmptyData];
    }
}

#pragma mark - UIScrollViewEmptyDataSource
- (NSString *)descriptionForEmptyDataSource:(UIScrollView *)scrollView
{
    if (self.tableView.emptyType == WLScrollEmptyType_Empty_Data)
    {
        return [AppContext getStringForKey:@"empty_block_users" fileName:@"user"];
    }
    return nil;
}

#pragma mark - private
- (void)refreshData
{
     [self.usersManager tryRefreshUsersWithKeyId:[[AppContext getInstance].accountManager myAccount].uid];
}

- (void)moreData
{
    [self.usersManager tryHisUsersWithKeyId:[[AppContext getInstance].accountManager myAccount].uid];
}

@end
