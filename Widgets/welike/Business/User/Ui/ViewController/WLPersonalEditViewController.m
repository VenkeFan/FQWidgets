//
//  WLPersonalEditViewController.m
//  welike
//
//  Created by 刘斌 on 2018/5/21.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPersonalEditViewController.h"
#import "WLPersonalHeadCell.h"
#import "WLPersonalCell.h"
#import "WLEmptySectionCell.h"
#import "WLAccountManager.h"
#import "WLAssetsViewController.h"
#import "WLModifyNickNameViewController.h"
#import "WLModifyGenderViewController.h"
#import "WLModifyIntroViewController.h"
#import "CKAlertViewController.h"
#import "WLUploadManager.h"
#import "WLAccountManager.h"
#import "WLTrackerEditProfile.h"
#import "WLSelectInterestViewController.h"

#define kPersonalEditTagNickName                 1
#define kPersonalEditTagGender                   2
#define kPersonalEditTagIntro                    3
#define kPersonalEditTagInterest                 4

@interface WLPersonalEditViewController () <UITableViewDelegate, UITableViewDataSource, WLPersonalHeadCellDelegate, WLAssetsViewControllerDelegate, WLUploadManagerDelegate>

@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSString *uploadKey;
@property (nonatomic, weak) WLPersonalHeadDataSourceItem *headItem;
@property (nonatomic, weak) WLPersonalDataSourceItem *nickNameItem;
@property (nonatomic, weak) WLPersonalDataSourceItem *genderItem;
@property (nonatomic, weak) WLPersonalDataSourceItem *introItem;
@property (nonatomic, weak) WLPersonalDataSourceItem *interestItem;


@end

@implementation WLPersonalEditViewController

- (void)loadView
{
    [super loadView];
    
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    
    self.navigationBar.title = [AppContext getStringForKey:@"mine_user_host_personal_info_page_title" fileName:@"user"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.dataList = [NSMutableArray array];
    
    WLPersonalHeadDataSourceItem *headItem = [[WLPersonalHeadDataSourceItem alloc] init];
    headItem.head = account.headUrl;
    [self.dataList addObject:headItem];
    self.headItem = headItem;
    
    NSArray *intrests = account.interests;
    NSMutableString *insterestStr = [[NSMutableString alloc] initWithCapacity:0];

    for (int i = 0; i < intrests.count; i++)
    {
        NSDictionary *dic = intrests[i];
        if (i == 0)
        {
            [insterestStr appendString:[NSString stringWithFormat:@"%@",[dic objectForKey:@"name"]]];
        }
        else
        {
            [insterestStr appendString:[NSString stringWithFormat:@",%@",[dic objectForKey:@"name"]]];
        }
    }
    
    WLPersonalDataSourceItem *nickName = [[WLPersonalDataSourceItem alloc] init];
    nickName.userTag = kPersonalEditTagNickName;
    nickName.title = [AppContext getStringForKey:@"regist_user_info_input_nickname" fileName:@"register"];
    nickName.content = account.nickName;
    if (account.allowUpdateNickName == NO)
    {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:(account.nextUpdateNickNameDate / 1000)];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"dd-MM-yyyy"];
        NSString *ff = [AppContext getStringForKey:@"mine_user_host_personal_edit_name_canot_modify_slogen" fileName:@"user"];
        nickName.warning = [NSString stringWithFormat:ff, [formatter stringFromDate:date]];
    }
    else
    {
        nickName.note = [AppContext getStringForKey:@"mine_user_host_personal_edit_name_slogen" fileName:@"user"];
    }
    nickName.contentSingleLine = NO;
    nickName.isTail = NO;
    [nickName cellHeight];
    [self.dataList addObject:nickName];
    self.nickNameItem = nickName;
    
    WLPersonalDataSourceItem *gender = [[WLPersonalDataSourceItem alloc] init];
    gender.userTag = kPersonalEditTagGender;
    gender.title = [AppContext getStringForKey:@"mine_user_host_gender_title" fileName:@"user"];
    if (account.gender == WELIKE_USER_GENDER_MALE)
    {
        gender.content = [AppContext getStringForKey:@"user_sex_boy" fileName:@"common"];
    }
    else if (account.gender == WELIKE_USER_GENDER_FEMALE)
    {
        gender.content = [AppContext getStringForKey:@"user_sex_girl" fileName:@"common"];
    }
    gender.contentSingleLine = NO;
    gender.isTail = NO;
    [gender cellHeight];
    [self.dataList addObject:gender];
    self.genderItem = gender;
    
    WLPersonalDataSourceItem *intro = [[WLPersonalDataSourceItem alloc] init];
    intro.userTag = kPersonalEditTagIntro;
    intro.title = [AppContext getStringForKey:@"mine_user_host_brief_title" fileName:@"user"];
    intro.content = account.introduction;
    intro.contentSingleLine = NO;
    intro.isTail = NO;
    [intro cellHeight];
    [self.dataList addObject:intro];
    self.introItem = intro;
    
    WLPersonalDataSourceItem *interest = [[WLPersonalDataSourceItem alloc] init];
    interest.userTag = kPersonalEditTagInterest;
    interest.title = [AppContext getStringForKey:@"Select_interest" fileName:@"user"];
    interest.content = insterestStr;
    interest.contentSingleLine = NO;
    interest.isTail = NO;
    [interest cellHeight];
    [self.dataList addObject:interest];
    self.interestItem = interest;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.tableView == nil)
    {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, CGRectGetWidth(self.view.bounds), self.view.height - kNavBarHeight) style:UITableViewStylePlain];
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView reloadData];
    
    [WLTrackerEditProfile appendTrackerWithEditAction:WLTrackerEditProfileAction_Display];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[AppContext getInstance].uploadManager registerDelegate:self];
    
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    self.nickNameItem.content = account.nickName;
    if (account.allowUpdateNickName == NO)
    {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:(account.nextUpdateNickNameDate / 1000)];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"dd-MM-yyyy"];
        NSString *ff = [AppContext getStringForKey:@"mine_user_host_personal_edit_name_canot_modify_slogen" fileName:@"user"];
        self.nickNameItem.warning = [NSString stringWithFormat:ff, [formatter stringFromDate:date]];
    }
    else
    {
        self.nickNameItem.note = [AppContext getStringForKey:@"mine_user_host_personal_edit_name_slogen" fileName:@"user"];
    }
    
    if (account.gender == WELIKE_USER_GENDER_MALE)
    {
        self.genderItem.content = [AppContext getStringForKey:@"user_sex_boy" fileName:@"common"];
    }
    else if (account.gender == WELIKE_USER_GENDER_FEMALE)
    {
        self.genderItem.content = [AppContext getStringForKey:@"user_sex_girl" fileName:@"common"];
    }
    
    self.introItem.content = account.introduction;
    
    
    NSArray *intrests = account.interests;
    NSMutableString *insterestStr = [[NSMutableString alloc] initWithCapacity:0];
    
    for (int i = 0; i < intrests.count; i++)
    {
        NSDictionary *dic = intrests[i];
        if (i == 0)
        {
            [insterestStr appendString:[NSString stringWithFormat:@"%@",[dic objectForKey:@"name"]]];
        }
        else
        {
            [insterestStr appendString:[NSString stringWithFormat:@",%@",[dic objectForKey:@"name"]]];
        }
    }
    self.interestItem.content = insterestStr;
    
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[AppContext getInstance].uploadManager unregister:self];
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
        if ([item isKindOfClass:[WLPersonalHeadDataSourceItem class]])
        {
            WLPersonalHeadCell *headCell = [tableView dequeueReusableCellWithIdentifier:WLPersonalHeadCellIdentifier];
            if (headCell == nil)
            {
                headCell = [[WLPersonalHeadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLPersonalHeadCellIdentifier];
                headCell.delegate = self;
                [headCell setDataSourceItem:item];
            }
            else
            {
                headCell.delegate = self;
                [headCell setDataSourceItem:item];
            }
            cell = headCell;
        }
        else if ([item isKindOfClass:[WLPersonalDataSourceItem class]])
        {
            WLPersonalCell *pCell = [tableView dequeueReusableCellWithIdentifier:WLPersonalCellIdentifier];
            if (pCell == nil)
            {
                pCell = [[WLPersonalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLPersonalCellIdentifier];
                [pCell setDataSourceItem:item];
            }
            else
            {
                [pCell setDataSourceItem:item];
            }
            cell = pCell;
        }
        else if ([item isKindOfClass:[WLEmptySectionDataSourceItem class]])
        {
            WLEmptySectionCell *emptySectionCell = [tableView dequeueReusableCellWithIdentifier:WLEmptySectionCellIdentifier];
            if (emptySectionCell == nil)
            {
                emptySectionCell = [[WLEmptySectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WLEmptySectionCellIdentifier];
                [emptySectionCell setDataSourceItem:item];
            }
            else
            {
                [emptySectionCell setDataSourceItem:item];
            }
            cell = emptySectionCell;
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
        if ([item isKindOfClass:[WLPersonalHeadDataSourceItem class]])
        {
            return ((WLPersonalHeadDataSourceItem *)item).cellHeight;
        }
        else if ([item isKindOfClass:[WLPersonalDataSourceItem class]])
        {
            return ((WLPersonalDataSourceItem *)item).cellHeight;
        }
        else if ([item isKindOfClass:[WLEmptySectionDataSourceItem class]])
        {
            return ((WLEmptySectionDataSourceItem *)item).cellHeight;
        }
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = nil;
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSInteger row = indexPath.row;
    if ([self.dataList count] > row)
    {
        item = [self.dataList objectAtIndex:row];
    }
    if (item != nil)
    {
        if ([item isKindOfClass:[WLPersonalDataSourceItem class]])
        {
            NSInteger tag = ((WLPersonalDataSourceItem *)item).userTag;
            if (tag == kPersonalEditTagNickName)
            {
                WLPersonalDataSourceItem *personalDataSourceItem = (WLPersonalDataSourceItem *)item;
                if ([personalDataSourceItem.warning length] > 0)
                {
                    NSString *messageStr = personalDataSourceItem.warning;

                    NSMutableAttributedString *messageString = [[NSMutableAttributedString alloc] initWithString:messageStr];
                    [messageString addAttribute:NSFontAttributeName value:kRegularFont(16) range:NSMakeRange(0, messageStr.length)];

                    CKAlertViewController *alertVC = [CKAlertViewController alertControllerWithTitle:nil message:messageString];
                    alertVC.messageAlignment = NSTextAlignmentCenter;
                    CKAlertAction *confirm = [CKAlertAction actionWithDeepColorTitle:[AppContext getStringForKey:@"common_ok" fileName:@"common"]
                                                                    handler:^(CKAlertAction *action) {
                                                                        [alertVC.view removeFromSuperview];
                                                                    }];
                    [alertVC addAction:confirm];
                    [alertVC show];
                }
                else
                {
                    WLModifyNickNameViewController *vc = [[WLModifyNickNameViewController alloc] init];
                    [[AppContext rootViewController] pushViewController:vc animated:YES];
                }
                
                [WLTrackerEditProfile appendTrackerWithEditAction:WLTrackerEditProfileAction_Name];
            }
            else if (tag == kPersonalEditTagGender)
            {
                WLModifyGenderViewController *vc = [[WLModifyGenderViewController alloc] init];
                [[AppContext rootViewController] pushViewController:vc animated:YES];
                
                [WLTrackerEditProfile appendTrackerWithEditAction:WLTrackerEditProfileAction_Gender];
            }
            else if (tag == kPersonalEditTagIntro)
            {
                WLModifyIntroViewController *vc = [[WLModifyIntroViewController alloc] init];
                [[AppContext rootViewController] pushViewController:vc animated:YES];
                
                [WLTrackerEditProfile appendTrackerWithEditAction:WLTrackerEditProfileAction_Intro];
            }
            else if (tag == kPersonalEditTagInterest)
            {
                WLSelectInterestViewController *vc = [[WLSelectInterestViewController alloc] init];
                [[AppContext rootViewController] pushViewController:vc animated:YES];
                
            }
        }
    }
}

#pragma mark WLPersonalHeadCellDelegate methods
- (void)onClickHead
{
    WLAssetsViewController *vc = [[WLAssetsViewController alloc] initWithSelectionMode:WLAssetsSelectionMode_Single];
    vc.delegate = self;
    [[AppContext rootViewController] pushViewController:vc animated:YES];
    
    [WLTrackerEditProfile appendTrackerWithEditAction:WLTrackerEditProfileAction_Avatar];
}

#pragma mark WLAssetsViewControllerDelegate methods
- (void)assetsViewCtr:(WLAssetsViewController *)viewCtr didCuttedImage:(UIImage *)image
{
    if (image != nil)
    {
        NSString *fileName = [[AppContext getCachePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", [LuuUtils uuid]]];
        BOOL res = [image storeToJPEG:fileName quality:0.6f];
        if (res == YES && [[NSFileManager defaultManager] fileExistsAtPath:fileName isDirectory:nil] == YES)
        {
            self.uploadKey = [[AppContext getInstance].uploadManager uploadWithFileName:fileName objectType:UPLOAD_TYPE_IMG];
            if ([self.uploadKey length] > 0)
            {
                [self showLoading];
            }
            else
            {
                [self showToastWithNetworkErr:ERROR_NETWORK_UPLOAD_FAILED];
            }
        }
        else
        {
            [self showToastWithNetworkErr:ERROR_NETWORK_UPLOAD_FAILED];
        }
    }
}

#pragma mark WLUploadManagerDelegate methods
- (void)onUploadingKey:(NSString *)objectKey completed:(NSString *)url
{
    if ([self.uploadKey isEqualToString:objectKey])
    {
        __weak typeof(self) weakSelf = self;
        self.uploadKey = nil;
        [[AppContext getInstance].accountManager syncAccountHead:url successed:^{
            [weakSelf hideLoading];
            weakSelf.headItem.head = url;
            [weakSelf.tableView reloadData];
        } error:^(NSInteger errCode) {
            [weakSelf hideLoading];
            [self showToastWithNetworkErr:ERROR_NETWORK_UPLOAD_FAILED];
        }];
    }
}

- (void)onUploadingKey:(NSString *)objectKey failed:(NSInteger)errCode
{
    if ([self.uploadKey isEqualToString:objectKey])
    {
        [self hideLoading];
        self.uploadKey = nil;
        [self showToastWithNetworkErr:ERROR_NETWORK_UPLOAD_FAILED];
    }
}

@end
