//
//  WLNotificationSettingViewController.m
//  welike
//
//  Created by luxing on 2018/5/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNotificationSettingViewController.h"
#import "WLSwitchCell.h"
#import "WLTimeSelectTableViewCell.h"
#import "WLNotificationSelectTimeViewController.h"
#import "WLNotificationSettingSectionView.h"
#import "WLNotificationViewModel.h"
#import "WLPushSettingManager.h"

#define kNotificationSettingDefaultCellHeight       48.0
#define kNotificationSettingTimeSelectCellHeight    70.0
#define kNotificationSettingDefaultSectionHeight    43.0

@interface WLNotificationSettingViewController () <UITableViewDelegate, UITableViewDataSource, WLSwitchCellDelegate,WLNotificationSelectTimeViewDelegate>

@property (nonatomic, strong) WLNotificationViewModel *viewModel;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation WLNotificationSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.viewModel = [[WLNotificationViewModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBar.title = [AppContext getStringForKey:@"notification_setting" fileName:@"user"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, CGRectGetWidth(self.view.bounds), kScreenHeight - kNavBarHeight - kSafeAreaBottomY) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor whiteColor];;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self.viewModel refresh:[[AppContext getInstance].pushSettingManager currentPushSetting]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)dealloc
{
    [[AppContext getInstance].pushSettingManager refreshPushSetting];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.viewModel sectionCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewModel rowCoutInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    id item = [self.viewModel itemDataAtRow:indexPath.row inSection:indexPath.section];
    if ([item isKindOfClass:[WLSwitchCellDataSourceItem class]])
    {
        WLSwitchCell *switchCell = [tableView dequeueReusableCellWithIdentifier:WLSwitchCellIdentifier];
        if (switchCell == nil)
        {
            switchCell = [[WLSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLSwitchCellIdentifier];
        }
        switchCell.selectionStyle = UITableViewCellSelectionStyleNone;
        switchCell.delegate = self;
        [switchCell setDataSourceItem:item];
        cell = switchCell;
    } else {
        WLTimeSelectTableViewCell *timeCell = [tableView dequeueReusableCellWithIdentifier:@"WLTimeSelectTableViewCell"];
        if (timeCell == nil)
        {
            timeCell = [[WLTimeSelectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WLTimeSelectTableViewCell"];
        }
        timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [timeCell setDataSourceItem:item];
        cell = timeCell;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    WLNotificationSettingSectionView *headView = [[WLNotificationSettingSectionView alloc] initWithFrame:CGRectMake(0, 0,CGRectGetWidth(tableView.frame), kNotificationSettingDefaultSectionHeight)];
    NSString *sectionTitle = [self.viewModel sectionTitle:section];
    [headView setSectionTitle:sectionTitle];
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kNotificationSettingDefaultSectionHeight;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self.viewModel itemDataAtRow:indexPath.row inSection:indexPath.section];
    if ([item isKindOfClass:[WLSwitchCellDataSourceItem class]])
    {
        return kNotificationSettingDefaultCellHeight;
    } else {
        return kNotificationSettingTimeSelectCellHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    id item = [self.viewModel itemDataAtRow:indexPath.row inSection:indexPath.section];
    if ([item isKindOfClass:[WLTimeSelectViewModel class]])
    {
        WLNotificationSelectTimeViewController *vc = [[WLNotificationSelectTimeViewController alloc] initWithTimeSelectModel:item];
        vc.delegate = self;
        [[AppContext rootViewController] pushViewController:vc animated:YES];
    }
}

#pragma mark - WLSwitchCellDelegate

- (void)switchCellTag:(NSString *)tag switchOn:(BOOL)on
{
    [self.viewModel setSwitchVal:on forKey:tag];
    [[AppContext getInstance].pushSettingManager syncPushSetting:tag value:on];
    if ([tag isEqualToString:kDisturbNotificationKey])
    {
        [self.viewModel setTail:on forKey:tag];
        [self.tableView reloadData];
    }
}

#pragma mark - WLNotificationSelectTimeViewDelegate

- (void)refreshNotificationSelectTime:(WLTimeSelectViewModel *)model
{
    [[AppContext getInstance].pushSettingManager syncPushSettingLimitTime:model];
}

@end
