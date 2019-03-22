//
//  WLRegisterUserSugViewController.m
//  welike
//
//  Created by 刘斌 on 2018/5/1.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRegisterUserSugViewController.h"
#import "WLRegisterSugUserSectionDataSourceItem.h"
#import "WLRegisterSugUserDataSourceItem.h"
#import "WLRegisterSugUserSectionCell.h"
#import "WLRegisterSugUserCell.h"
#import "WLStartHandler.h"
#import "WLSugUsersRequest.h"
#import "UIScrollView+FQEmptyData.h"

#define kRegisterSugUsersMainTitleTopMargin           63.f
#define kRegisterSugUsersMainTitleHeight              26.f
#define kRegisterSugUsersSubTitleTopMargin            8.f
#define kRegisterSugUsersSubTitleHeight               17.f
#define kRegisterSugUsersTableViewTop                 19.f

@interface WLRegisterUserSugViewController () <UITableViewDelegate, UITableViewDataSource, WLStartHandlerDelegate, UIScrollViewEmptyDelegate, UIScrollViewEmptyDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) WLSugUsersRequest *sugUsersRequest;

- (void)layout;
- (void)onNext;
- (void)refresh;
- (void)onRefreshSugUsers:(NSArray *)groups referrerInfo:(WLReferrerInfo *)referrerInfo errCode:(NSInteger)errCode;

@end

@implementation WLRegisterUserSugViewController

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
    [self layout];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refresh];
}

- (void)layout
{
    [self.view removeAllSubviews];
    
    UILabel *mainTitle = [[UILabel alloc] initWithFrame:CGRectMake(kLargeBtnXMargin, kRegisterSugUsersMainTitleTopMargin, self.view.width - kLargeBtnXMargin * 2, kRegisterSugUsersMainTitleHeight)];
    mainTitle.backgroundColor = [UIColor clearColor];
    mainTitle.textColor = kWeightTitleFontColor;
    mainTitle.textAlignment = NSTextAlignmentLeft;
    mainTitle.text = [AppContext getStringForKey:@"regist_suggest_persons_title" fileName:@"register"];
    mainTitle.font = [UIFont systemFontOfSize:kNameFontSize];
    [self.view addSubview:mainTitle];
    
    UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(kLargeBtnXMargin, mainTitle.bottom + kRegisterSugUsersSubTitleTopMargin, self.view.width - kLargeBtnXMargin * 2, kRegisterSugUsersSubTitleHeight)];
    subTitle.backgroundColor = [UIColor clearColor];
    subTitle.textColor = kLightLightFontColor;
    subTitle.textAlignment = NSTextAlignmentLeft;
    subTitle.font = [UIFont systemFontOfSize:kLinkFontSize];
    subTitle.text = [AppContext getStringForKey:@"regist_suggest_persons_title_sub" fileName:@"register"];
    [self.view addSubview:subTitle];
    
    NSString *nextTitle = [AppContext getStringForKey:@"regist_jion_weLike" fileName:@"register"];
    if (self.nextBtn == nil)
    {
        self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    self.nextBtn.frame = CGRectMake(kLargeBtnXMargin, self.view.bottom - kLargeBtnHeight - kLargeBtnYMargin - kSafeAreaBottomY, self.view.width - kLargeBtnXMargin * 2, kLargeBtnHeight);
    [self.nextBtn setTitle:nextTitle forState:UIControlStateNormal];
    [self.nextBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:kNameFontSize]];
    [self.nextBtn setTitleColor:kCommonBtnTextColor forState:UIControlStateNormal];
    [self.nextBtn setTitleColor:kCommonBtnDisableTextColor forState:UIControlStateDisabled];
    [self.nextBtn setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
    [self.nextBtn setBackgroundImage:[UIImage imageWithColor:kMainPressColor] forState:UIControlStateHighlighted];
    [self.nextBtn setBackgroundImage:[UIImage imageWithColor:kLargeBtnDisableColor] forState:UIControlStateDisabled];
    [self.nextBtn setEnabled:NO];
    [self.nextBtn.layer setMasksToBounds:YES];
    [self.nextBtn.layer setCornerRadius:kLargeBtnRadius];
    [self.nextBtn addTarget:self action:@selector(onNext) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextBtn];
    
    CGFloat tableHeight = self.view.height - (subTitle.bottom + kRegisterSugUsersTableViewTop) - self.nextBtn.height - kLargeBtnYMargin * 2 - kSafeAreaBottomY;
    if (self.tableView == nil)
    {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, subTitle.bottom + kRegisterSugUsersTableViewTop, self.view.width, tableHeight) style:UITableViewStylePlain];
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.emptyDelegate = self;
    self.tableView.emptyDataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[AppContext getInstance].startHandler registerWithDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[AppContext getInstance].startHandler unregister:self];
}

#pragma mark UIScrollViewEmptyDelegate methods
- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView
{
    if (self.tableView == scrollView)
    {
        [self refresh];
    }
}

#pragma mark UIScrollViewEmptyDataSource methods
- (NSString *)descriptionForEmptyDataSource:(UIScrollView *)scrollView
{
    if (self.tableView == scrollView)
    {
        return [AppContext getStringForKey:@"load_error" fileName:@"common"];
    }
    return @"";
}

#pragma mark WLStartHandlerDelegate methods
- (void)goProcess:(WELIKE_STARTUP_STATE)state
{
    [self hideLoading];
    [[AppContext getInstance].startHandler runNext:state];
}

- (void)goFailed:(NSInteger)errcode
{
    [self hideLoading];
    [self showToastWithNetworkErr:errcode];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < [self.dataArray count])
    {
        WLRegisterSugUserSectionDataSourceItem *sectionItem = [self.dataArray objectAtIndex:section];
        return ([sectionItem.users count] + 1);
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    id item = nil;
    NSInteger section = indexPath.section;
    if ([self.dataArray count] > section)
    {
        WLRegisterSugUserSectionDataSourceItem *sectionItem = [self.dataArray objectAtIndex:section];
        NSInteger row = indexPath.row;
        if (row == 0)
        {
            item = sectionItem;
        }
        else if (row < ([sectionItem.users count] + 1))
        {
            item = [sectionItem.users objectAtIndex:(row - 1)];
        }
    }
    if (item != nil)
    {
        if ([item isKindOfClass:[WLRegisterSugUserSectionDataSourceItem class]] == YES)
        {
            WLRegisterSugUserSectionDataSourceItem *sectionItem = (WLRegisterSugUserSectionDataSourceItem *)item;
            cell = [tableView dequeueReusableCellWithIdentifier:WLRegisterSugUserSectionCellIdentifier];
            if (cell == nil)
            {
                WLRegisterSugUserSectionCell *sectionCell = [[WLRegisterSugUserSectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLRegisterSugUserSectionCellIdentifier];
                cell = sectionCell;
                [sectionCell setDataSourceItem:sectionItem];
            }
            else
            {
                WLRegisterSugUserSectionCell *sectionCell = (WLRegisterSugUserSectionCell *)cell;
                [sectionCell setDataSourceItem:sectionItem];
            }
        }
        else if ([item isKindOfClass:[WLRegisterSugUserDataSourceItem class]] == YES)
        {
             WLRegisterSugUserDataSourceItem *userItem = (WLRegisterSugUserDataSourceItem *)item;
            cell = [tableView dequeueReusableCellWithIdentifier:WLRegisterSugUserCellIdentifier];
            if (cell == nil)
            {
                WLRegisterSugUserCell *userCell = [[WLRegisterSugUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLRegisterSugUserCellIdentifier];
                cell = userCell;
                [userCell setDataSourceItem:userItem];
            }
            else
            {
                WLRegisterSugUserCell *userCell = (WLRegisterSugUserCell *)cell;
                [userCell setDataSourceItem:userItem];
            }
        }
    }
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if ([self.dataArray count] > section)
    {
        WLRegisterSugUserSectionDataSourceItem *sectionItem = [self.dataArray objectAtIndex:section];
        NSInteger row = indexPath.row;
        if (row == 0)
        {
            return sectionItem.height;
        }
        else if (row < ([sectionItem.users count] + 1))
        {
            WLRegisterSugUserDataSourceItem *user = [sectionItem.users objectAtIndex:(row - 1)];
            return user.height;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if ([self.dataArray count] > section)
    {
        WLRegisterSugUserSectionDataSourceItem *sectionItem = [self.dataArray objectAtIndex:section];
        NSInteger row = indexPath.row;
        if (row == 0)
        {
            NSInteger count = [sectionItem selectedUsersCount];
            if (count < [sectionItem.users count])
            {
                [sectionItem selectAll:YES];
            }
            else
            {
                [sectionItem selectAll:NO];
            }
            [self.tableView reloadData];
        }
        else if (row < ([sectionItem.users count] + 1))
        {
            WLRegisterSugUserDataSourceItem *user = [sectionItem.users objectAtIndex:(row - 1)];
            if (user.isSelected == YES)
            {
                user.isSelected = NO;
            }
            else
            {
                user.isSelected = YES;
            }
            [self.tableView reloadData];
        }
    }
}

#pragma mark private methods
- (void)onNext
{
    [self showLoading];
    
    NSMutableArray *uids = [NSMutableArray array];
    for (NSInteger i = 0; i < [self.dataArray count]; i++)
    {
        WLRegisterSugUserSectionDataSourceItem *section = [self.dataArray objectAtIndex:i];
        for (NSInteger j = 0; j < [section.users count]; j++)
        {
            WLRegisterSugUserDataSourceItem *user = [section.users objectAtIndex:j];
            if (user.isSelected == YES)
            {
                [uids addObject:user.uid];
            }
        }
    }
    [AppContext getInstance].startHandler.followUids = [NSArray arrayWithArray:uids];
    [[AppContext getInstance].startHandler next:WELIKE_STARTUP_STATE_REGISTER_TRY_SUG_USERS];
}

- (void)refresh
{
    if (self.sugUsersRequest == nil)
    {
        __weak typeof(self) weakSelf = self;
        self.sugUsersRequest = [[WLSugUsersRequest alloc] initSugUsersRequest];
        [self.sugUsersRequest listSugUsersWithReferrerId:nil successed:^(NSArray *groups, WLReferrerInfo *referrerInfo) {
            weakSelf.sugUsersRequest = nil;
            [weakSelf onRefreshSugUsers:groups referrerInfo:referrerInfo errCode:ERROR_SUCCESS];
        } error:^(NSInteger errorCode) {
            weakSelf.sugUsersRequest = nil;
            [weakSelf onRefreshSugUsers:nil referrerInfo:nil errCode:errorCode];
        }];
    }
}

- (void)onRefreshSugUsers:(NSArray *)groups referrerInfo:(WLReferrerInfo *)referrerInfo errCode:(NSInteger)errCode
{
    [self.dataArray removeAllObjects];
    if (errCode == ERROR_SUCCESS)
    {
        [self.dataArray addObjectsFromArray:groups];
        [self.nextBtn setEnabled:YES];
        [self.tableView reloadData];
        [self.tableView reloadEmptyData];
    }
    else
    {
        [self.nextBtn setEnabled:NO];
        [self.tableView reloadData];
        [self.tableView reloadEmptyData];
    }
}

@end
