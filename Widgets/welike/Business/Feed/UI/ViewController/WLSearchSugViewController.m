//
//  WLSearchSugViewController.m
//  welike
//
//  Created by 刘斌 on 2018/5/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSearchSugViewController.h"
#import "WLSearchBox.h"
#import "WLSugManager.h"
#import "WLUser.h"
#import "WLSearchSugSectionCell.h"
#import "WLNormalHistoryCell.h"
#import "WLShowAllHisCell.h"
#import "WLFollowCell.h"
#import "WLSearchResultViewController.h"
#import "WLUserDetailViewController.h"
#import "WLTrackerSearch.h"

static NSString *WLSearchUserSugCellIdentifier = @"WLSearchUserSugCell";

@interface WLSearchSugViewController () <WLSearchBoxDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, WLSearchSugSectionCellDelegate, WLNormalHistoryCellDelegate>

@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) WLSearchBox *searchBox;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) WLSugManager *sugManager;

- (void)loadRecentHisDataList:(NSArray *)results hasMore:(BOOL)hasMore;
- (void)loadAllHisDataList:(NSArray *)results;
- (void)loadSugDataList:(NSArray *)results keyword:(NSString *)keyword;
- (void)toSearchResult:(NSString *)keyword;
- (NSInteger)sugCount;

@end

@implementation WLSearchSugViewController

- (void)loadView
{
    [super loadView];
    self.sugManager = [[WLSugManager alloc] init];
    self.dataList = [NSMutableArray array];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kSystemStatusBarHeight)];
    topBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topBar];
    
    self.searchBox = [[WLSearchBox alloc] initWithFrame:CGRectMake(0, topBar.bottom, kScreenWidth, kSearchBarHeight)];
    self.searchBox.placeholder = [AppContext getStringForKey:@"discover_search_default" fileName:@"search"];
    self.searchBox.leftIconResId = @"searchbar_icon";
    self.searchBox.rightBtnTitle = [AppContext getStringForKey:@"common_cancel" fileName:@"common"];
    self.searchBox.searchTextField.text = self.keyword;
    [self.searchBox.searchTextField becomeFirstResponder];
    self.searchBox.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchBox.delegate = self;
    self.searchBox.searchTextField.delegate = self;
    [self.view addSubview:self.searchBox];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.searchBox.bottom, self.view.width, self.view.height - self.searchBox.bottom - kSafeAreaBottomY) style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = kLightBackgroundViewColor;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    __weak typeof(self) weakSelf = self;
    if ([self.searchBox.searchTextField.text length] > 0)
    {
        [self.sugManager inputKeyword:self.searchBox.searchTextField.text successed:^(NSString *keyword, NSArray *results) {
            [weakSelf loadSugDataList:results keyword:keyword];
        }];
    }
    else
    {
        [self.sugManager listRecentKeywords:^(NSArray *results, BOOL hasMore) {
            [weakSelf loadRecentHisDataList:results hasMore:hasMore];
        }];
    }
    
    [WLTrackerSearch appendTrackerSearchRecommend];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[AppContext rootViewController] setDisableInteractivePopGestureRecognizer:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[AppContext rootViewController] setDisableInteractivePopGestureRecognizer:NO];
}

#pragma mark UITextFieldDelegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.searchBox.searchTextField)
    {
        NSString *keyword = [self.searchBox.searchTextField.text stringByReplacingCharactersInRange:range withString:string];
        [self postKeyword:keyword];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField == self.searchBox.searchTextField)
    {
        [self postKeyword:nil];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.searchBox.searchTextField)
    {
        NSString *keyword = [self.searchBox.searchTextField.text copy];
        if ([keyword length] > 0)
        {
            [self toSearchResult:keyword];
        }
    }
    return YES;
}

#pragma mark WLSearchBoxDelegate methods
- (void)onClickRightButton:(WLSearchBox *)searchBox
{
    [[AppContext rootViewController] popViewControllerAnimated:YES];
}

#pragma mark UITableViewDelegate & UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    id item = nil;
    NSInteger row = indexPath.row;
    if ([self.dataList count] > row)
    {
        item = [self.dataList objectAtIndex:row];
    }
    if (item != nil)
    {
        if ([item isKindOfClass:[WLSearchSugSectionItem class]])
        {
            WLSearchSugSectionCell *sectionCell = [tableView dequeueReusableCellWithIdentifier:WLSearchSugSectionCellIdentifier];
            if (sectionCell == nil)
            {
                sectionCell = [[WLSearchSugSectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLSearchSugSectionCellIdentifier];
                [sectionCell setDelegate:self];
                [sectionCell setDataSourceItem:item];
            }
            else
            {
                [sectionCell setDataSourceItem:item];
            }
            cell = sectionCell;
        }
        else if ([item isKindOfClass:[WLNormalHisDataSourceItem class]])
        {
            WLNormalHisDataSourceItem *hisItem = (WLNormalHisDataSourceItem *)item;
            if (hisItem.sug.category == WELIKE_SUG_RESULT_CATEGORY_USER)
            {
                WLFollowCell *userCell = [tableView dequeueReusableCellWithIdentifier:WLSearchUserSugCellIdentifier];
                if (userCell == nil)
                {
                    userCell = [[WLFollowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLSearchUserSugCellIdentifier];
                    userCell.type = WELIKE_FOLLOW_CELL_TYPE_SEARCH;
                    [userCell setItemModel:hisItem.sug.object];
                }
                else
                {
                    userCell.type = WELIKE_FOLLOW_CELL_TYPE_SEARCH;
                    [userCell setItemModel:hisItem.sug.object];
                }
                cell = userCell;
            }
            else
            {
                WLNormalHistoryCell *hisCell = [tableView dequeueReusableCellWithIdentifier:WLNormalHistoryCellIdentifier];
                if (hisCell == nil)
                {
                    hisCell = [[WLNormalHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLNormalHistoryCellIdentifier];
                    [hisCell setDelegate:self];
                    [hisCell setDataSourceItem:item indexPath:indexPath];
                }
                else
                {
                    [hisCell setDataSourceItem:item indexPath:indexPath];
                }
                cell = hisCell;
            }
        }
        else if ([item isKindOfClass:[WLShowAllHisDataSourceItem class]])
        {
            WLShowAllHisCell *showAllCell = [tableView dequeueReusableCellWithIdentifier:WLShowAllHisCellIdentifier];
            if (showAllCell == nil)
            {
                showAllCell = [[WLShowAllHisCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLShowAllHisCellIdentifier];
            }
            [showAllCell setDataSourceItem:item];
            cell = showAllCell;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = nil;
    
    NSInteger row = indexPath.row;
    if ([self.dataList count] > row)
    {
        item = [self.dataList objectAtIndex:row];
    }
    if (item != nil)
    {
        if ([item isKindOfClass:[WLSearchSugSectionItem class]])
        {
            return ((WLSearchSugSectionItem *)item).cellHeight;
        }
        else if ([item isKindOfClass:[WLNormalHisDataSourceItem class]])
        {
            WLNormalHisDataSourceItem *hisItem = (WLNormalHisDataSourceItem *)item;
            if (hisItem.sug.category == WELIKE_SUG_RESULT_CATEGORY_USER)
            {
                return kFollowUserCellHeight;
            }
            else
            {
                return hisItem.cellHeight;
            }
        }
        else if ([item isKindOfClass:[WLShowAllHisDataSourceItem class]])
        {
            return ((WLShowAllHisDataSourceItem *)item).cellHeight;
        }
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = nil;
    
    NSInteger row = indexPath.row;
    if ([self.dataList count] > row)
    {
        item = [self.dataList objectAtIndex:row];
    }
    if (item != nil)
    {
        if ([item isKindOfClass:[WLShowAllHisDataSourceItem class]])
        {
            __weak typeof(self) weakSelf = self;
            [self.sugManager listAllHistory:^(NSArray *results) {
                [weakSelf loadAllHisDataList:results];
            }];
        }
        else if ([item isKindOfClass:[WLNormalHisDataSourceItem class]])
        {
            WLNormalHisDataSourceItem *hisItem = (WLNormalHisDataSourceItem *)item;
            if (hisItem.sug.category == WELIKE_SUG_RESULT_CATEGORY_USER)
            {
                WLUser *user = hisItem.sug.object;
                [self.sugManager insert:user.nickName];
                WLUserDetailViewController *vc = [[WLUserDetailViewController alloc] initWithUserID:user.uid];
                [[AppContext rootViewController] popViewControllerAnimated:NO];
                [[AppContext rootViewController] pushViewController:vc animated:YES];
            }
            else
            {
                [self toSearchResult:hisItem.sug.object];
            }
        }
    }
}

#pragma mark WLSearchSugSectionCellDelegate methods
- (void)deleteAll
{
    [self.dataList removeAllObjects];
    [self.sugManager cleanAllHistory];
    [self.tableView reloadData];
}

#pragma mark WLNormalHistoryCellDelegate methods
- (void)onRemove:(NSIndexPath *)indexPath
{
    id item = nil;
    NSInteger row = indexPath.row;
    if ([self.dataList count] > row)
    {
        item = [self.dataList objectAtIndex:row];
    }
    if (item != nil)
    {
        if ([item isKindOfClass:[WLNormalHisDataSourceItem class]])
        {
            WLNormalHisDataSourceItem *hisItem = (WLNormalHisDataSourceItem *)item;
            if (hisItem.sug.type == WELIKE_SUG_RESULT_TYPE_HIS)
            {
                [self.sugManager deleteHistory:hisItem.sug.object];
                [self.dataList removeObjectAtIndex:row];
                if ([self sugCount] == 0)
                {
                    [self.dataList removeAllObjects];
                }
                [self.tableView reloadData];
            }
        }
    }
}

#pragma mark private methods
- (void)loadRecentHisDataList:(NSArray *)results hasMore:(BOOL)hasMore
{
    [self.dataList removeAllObjects];
    
    if ([results count] > 0)
    {
        WLSearchSugSectionItem *section = [[WLSearchSugSectionItem alloc] init];
        section.title = [AppContext getStringForKey:@"recent_search" fileName:@"search"];
        [self.dataList addObject:section];
        for (WLSugResult *res in results)
        {
            WLNormalHisDataSourceItem *sug = [[WLNormalHisDataSourceItem alloc] init];
            sug.sug = res;
            sug.actionType = WELIKE_NORMAL_HISTORY_ACTION_TYPE_DEL;
            [self.dataList addObject:sug];
        }
        WLNormalHisDataSourceItem *lastSug = [self.dataList lastObject];
        lastSug.isTail = NO;
        if (hasMore == YES)
        {
            [self.dataList addObject:[[WLShowAllHisDataSourceItem alloc] init]];
        }
    }
    
    [self.tableView reloadData];
}

- (void)loadAllHisDataList:(NSArray *)results
{
    [self.dataList removeAllObjects];
    
    if ([results count] > 0)
    {
        WLSearchSugSectionItem *section = [[WLSearchSugSectionItem alloc] init];
        section.title = [AppContext getStringForKey:@"recent_search" fileName:@"search"];
        [self.dataList addObject:section];
        for (WLSugResult *res in results)
        {
            WLNormalHisDataSourceItem *sug = [[WLNormalHisDataSourceItem alloc] init];
            sug.sug = res;
            sug.actionType = WELIKE_NORMAL_HISTORY_ACTION_TYPE_DEL;
            [self.dataList addObject:sug];
        }
    }
    
    [self.tableView reloadData];
}

- (void)loadSugDataList:(NSArray *)results keyword:(NSString *)keyword
{
    [self.dataList removeAllObjects];
    
    if ([results count] > 0)
    {
        for (WLSugResult *res in results)
        {
            WLNormalHisDataSourceItem *sug = [[WLNormalHisDataSourceItem alloc] init];
            sug.sug = res;
            sug.actionType = WELIKE_NORMAL_HISTORY_ACTION_TYPE_NAV;
            sug.keyword = keyword;
            [self.dataList addObject:sug];
        }
    }
    
    [self.tableView reloadData];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.searchBox.searchTextField resignFirstResponder];
}

- (void)postKeyword:(NSString *)keyword
{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEXT_CHECK_DELAY * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        if ([keyword length] > 0)
        {
            [weakSelf.sugManager inputKeyword:keyword successed:^(NSString *keyword, NSArray *results) {
                [weakSelf loadSugDataList:results keyword:keyword];
            }];
        }
        else
        {
            [weakSelf.sugManager listRecentKeywords:^(NSArray *results, BOOL hasMore) {
                [weakSelf loadRecentHisDataList:results hasMore:hasMore];
            }];
        }
    });
}

- (void)toSearchResult:(NSString *)keyword
{
    [self.sugManager insert:keyword];
    WLSearchResultViewController *vc = [[WLSearchResultViewController alloc] init];
    vc.keyword = keyword;
    [[AppContext rootViewController] popViewControllerAnimated:NO];
    [[AppContext rootViewController] pushViewController:vc animated:NO];
}

- (NSInteger)sugCount
{
    NSInteger count = 0;
    for (id item in self.dataList)
    {
        if ([item isKindOfClass:[WLNormalHisDataSourceItem class]])
        {
            count++;
        }
    }
    return count;
}

@end
