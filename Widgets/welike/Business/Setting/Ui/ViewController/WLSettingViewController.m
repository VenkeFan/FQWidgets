//
//  WLSettingViewController.m
//  welike
//
//  Created by fan qi on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSettingViewController.h"
#import "WLSettingViewModel.h"
#import "WLSettingCell.h"
#import "WLSwitchCell.h"
#import "WLStartHandler.h"
#import "WLAccountManager.h"
#import "WLPushSettingManager.h"
#import "WLLanguageSwitchViewController.h"
#import "WLNotificationSettingViewController.h"
#import "WLBlockUsersListViewController.h"

#define kSettingLogoutBottomMargin            20.f
#define kSettingVersionBottomMargin           15.f
#define kSettingVersionHeight                 19.f
#define kSettingVersiontopMargin              10.f

static NSString * const kSettingCellReuseCellID = @"SettingCellReuseCellID";

@interface WLSettingViewController () <UITableViewDelegate, UITableViewDataSource, WLSwitchCellDelegate>

@property (nonatomic, strong) WLSettingViewModel *viewModel;
@property (nonatomic, strong) UIButton *logoutBtn;
@property (nonatomic, strong) UITableView *tableView;

- (void)onLogout;

@end

@implementation WLSettingViewController

- (void)loadView
{
    [super loadView];
    
    self.viewModel = [[WLSettingViewModel alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBar.title = [AppContext getStringForKey:@"mine_setting_text" fileName:@"user"];
    
    NSString *logoutTitle = [AppContext getStringForKey:@"mine_setting_log_out_text" fileName:@"user"];
    self.logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.logoutBtn.frame = CGRectMake(kLargeBtnXMargin, self.view.bottom - kLargeBtnHeight - kSettingLogoutBottomMargin - kSafeAreaBottomY, self.view.width - kLargeBtnXMargin * 2, kLargeBtnHeight);
    [self.logoutBtn setTitle:logoutTitle forState:UIControlStateNormal];
    [self.logoutBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:kNameFontSize]];
    [self.logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logoutBtn setBackgroundImage:[UIImage imageWithColor:kSettingLogoutBtnColor] forState:UIControlStateNormal];
    [self.logoutBtn.layer setMasksToBounds:YES];
    [self.logoutBtn.layer setCornerRadius:kLargeBtnRadius];
    [self.logoutBtn addTarget:self action:@selector(onLogout) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.logoutBtn];
    
    UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(0, self.logoutBtn.top - kSettingVersionBottomMargin - kSettingVersionHeight, self.view.width, kSettingVersionHeight)];
    version.backgroundColor = [UIColor clearColor];
    version.textColor = kEmptyContentFontColor;
    version.font = kRegularFont(kNameFontSize);
    version.text = [NSString stringWithFormat:@"%@ V%@", [LuuUtils appDisplayName], [LuuUtils appVersion]];
    version.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:version];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, CGRectGetWidth(self.view.bounds), kScreenHeight - kSafeAreaBottomY - kNavBarHeight - (self.logoutBtn.height + version.height + kSettingLogoutBottomMargin + kSettingVersionBottomMargin + kSettingVersiontopMargin))];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[WLSettingCell class] forCellReuseIdentifier:kSettingCellReuseCellID];
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewModel.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    id item = self.viewModel.dataArray[indexPath.row];
    if (item != nil)
    {
        if ([item isKindOfClass:[WLSettingDataSourceItem class]])
        {
            WLSettingCell *settingCell = [tableView dequeueReusableCellWithIdentifier:kSettingCellReuseCellID];
            if (settingCell == nil)
            {
                settingCell = [[WLSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSettingCellReuseCellID];
                [settingCell setDataSourceItem:item];
            }
            else
            {
                [settingCell setDataSourceItem:item];
            }
            cell = settingCell;
        }
        else if ([item isKindOfClass:[WLSwitchCellDataSourceItem class]])
        {
            WLSwitchCell *switchCell = [tableView dequeueReusableCellWithIdentifier:WLSwitchCellIdentifier];
            if (switchCell == nil)
            {
                switchCell = [[WLSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLSwitchCellIdentifier];
                switchCell.delegate = self;
                [switchCell setDataSourceItem:item];
            }
            else
            {
                [switchCell setDataSourceItem:item];
            }
            cell = switchCell;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = self.viewModel.dataArray[indexPath.row];
    if (item != nil)
    {
        if ([item isKindOfClass:[WLSettingDataSourceItem class]])
        {
            if ([((WLSettingDataSourceItem *)item).settingTag isEqualToString:kSettingLanguageTag] == YES)
            {
                WLLanguageSwitchViewController *vc = [[WLLanguageSwitchViewController alloc] init];
                [[AppContext rootViewController] pushViewController:vc animated:YES];
            } else if ([((WLSettingDataSourceItem *)item).settingTag isEqualToString:kSettingNotificationTag]) {
                WLNotificationSettingViewController *vc = [[WLNotificationSettingViewController alloc] init];
                [[AppContext rootViewController] pushViewController:vc animated:YES];
            }
            else if ([((WLSettingDataSourceItem *)item).settingTag isEqualToString:kSettingBlockTag] == YES)
            {
                WLBlockUsersListViewController *vc = [[WLBlockUsersListViewController alloc] init];
                [[AppContext rootViewController] pushViewController:vc animated:YES];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - private
- (void)switchCellTag:(NSString *)tag switchOn:(BOOL)on
{
    if ([tag isEqualToString:kSettingHideMobileModelTag] == YES)
    {
        WLAccountSetting *setting = [[AppContext getInstance].accountManager mySetting];
        setting.mobileModel = !on;
        [[AppContext getInstance].accountManager updateSetting:setting];
        [[AppContext getInstance].accountManager syncSetting:setting successed:nil error:nil];
    }
}

#pragma mark - private
- (void)onLogout
{
    [[AppContext getInstance].pushSettingManager logout];
    [[AppContext getInstance].startHandler logout];
}

@end
