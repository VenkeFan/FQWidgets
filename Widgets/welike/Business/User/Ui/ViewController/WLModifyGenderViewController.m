//
//  WLModifyGenderViewController.m
//  welike
//
//  Created by 刘斌 on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLModifyGenderViewController.h"
#import "WLAccountManager.h"
#import "WLTrackerEditProfile.h"

#define kLeftMargin                 12.f
#define kSingleHeight               47.f

@interface WLModifyGenderViewController ()

@property (nonatomic, assign) NSInteger selectedIdx;
@property (nonatomic, strong) UIImageView *selMale;
@property (nonatomic, strong) UIImageView *selFemale;
@property (nonatomic, strong) UIImage *selIcon;
@property (nonatomic, strong) UIImage *unselIcon;

@end

@implementation WLModifyGenderViewController

- (void)loadView
{
    [super loadView];
    
    self.selIcon = [AppContext getImageForKey:@"radio_on"];
    self.unselIcon = [AppContext getImageForKey:@"radio_off"];
    
    self.navigationBar.title = [AppContext getStringForKey:@"mine_user_host_gender_title" fileName:@"user"];
    
    UIButton *back1 = [UIButton buttonWithType:UIButtonTypeCustom];
    back1.frame = CGRectMake(0, kNavBarHeight, self.view.width, kSingleHeight);
    back1.backgroundColor = [UIColor whiteColor];
    [back1 addTarget:self action:@selector(onClickMale) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back1];
    
    UIButton *back2 = [UIButton buttonWithType:UIButtonTypeCustom];
    back2.frame = CGRectMake(0, back1.bottom + 1.f, self.view.width, kSingleHeight);
    back2.backgroundColor = [UIColor whiteColor];
    [back2 addTarget:self action:@selector(onClickFemale) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back2];
    
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    if (account.gender == WELIKE_USER_GENDER_MALE)
    {
        self.selectedIdx = 0;
    }
    else if (account.gender == WELIKE_USER_GENDER_FEMALE)
    {
        self.selectedIdx = 1;
    }
    
    UILabel *male = [[UILabel alloc] initWithFrame:CGRectMake(kLeftMargin, (kSingleHeight - 19.f) / 2.f, 100.f, 19.f)];
    male.font = [UIFont systemFontOfSize:kMediumNameFontSize];
    male.textColor = kNameFontColor;
    male.text = [AppContext getStringForKey:@"user_sex_boy" fileName:@"common"];
    [back1 addSubview:male];
    
    self.selMale = [[UIImageView alloc] init];
    if (self.selectedIdx == 0)
    {
        self.selMale.image = self.selIcon;
    }
    else
    {
        self.selMale.image = self.unselIcon;
    }
    self.selMale.frame = CGRectMake(self.view.width - self.selIcon.size.width - kLeftMargin, (kSingleHeight - self.selIcon.size.height) / 2.f, self.selIcon.size.width, self.selIcon.size.height);
    [back1 addSubview:self.selMale];
    
    UILabel *female = [[UILabel alloc] initWithFrame:CGRectMake(kLeftMargin, (kSingleHeight - 19.f) / 2.f, 100.f, 19.f)];
    female.font = [UIFont systemFontOfSize:kMediumNameFontSize];
    female.textColor = kNameFontColor;
    female.text = [AppContext getStringForKey:@"user_sex_girl" fileName:@"common"];
    [back2 addSubview:female];
    
    self.selFemale = [[UIImageView alloc] init];
    if (self.selectedIdx == 1)
    {
        self.selFemale.image = self.selIcon;
    }
    else
    {
        self.selFemale.image = self.unselIcon;
    }
    self.selFemale.frame = CGRectMake(self.view.width - self.selIcon.size.width - kLeftMargin, (kSingleHeight - self.selIcon.size.height) / 2.f, self.selIcon.size.width, self.selIcon.size.height);
    [back2 addSubview:self.selFemale];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(kLargeBtnXMargin, self.view.bottom - kLargeBtnHeight - kLargeBtnYMargin, self.view.width - kLargeBtnXMargin * 2, kLargeBtnHeight);
    [saveBtn setTitle:[AppContext getStringForKey:@"mine_user_host_personal_edit_name_save" fileName:@"user"] forState:UIControlStateNormal];
    [saveBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:kNameFontSize]];
    [saveBtn setTitleColor:kCommonBtnTextColor forState:UIControlStateNormal];
    [saveBtn setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
    [saveBtn setBackgroundImage:[UIImage imageWithColor:kMainPressColor] forState:UIControlStateHighlighted];
    [saveBtn.layer setMasksToBounds:YES];
    [saveBtn.layer setCornerRadius:kLargeBtnRadius];
    [saveBtn addTarget:self action:@selector(onSave) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
}

- (void)onClickMale
{
    self.selectedIdx = 0;
    self.selMale.image = self.selIcon;
    self.selFemale.image = self.unselIcon;
}

- (void)onClickFemale
{
    self.selectedIdx = 1;
    self.selFemale.image = self.selIcon;
    self.selMale.image = self.unselIcon;
}

- (void)onSave
{
    [WLTrackerEditProfile appendTrackerWithEditAction:WLTrackerEditProfileAction_Submit];
    
    [self showLoading];
    WELIKE_USER_GENDER gender = WELIKE_USER_GENDER_UNKNOWN;
    if (self.selectedIdx == 0)
    {
        gender = WELIKE_USER_GENDER_MALE;
    }
    else if (self.selectedIdx == 1)
    {
        gender = WELIKE_USER_GENDER_FEMALE;
    }
    [[AppContext getInstance].accountManager syncAccountGender:gender successed:^{
        [WLTrackerEditProfile appendTrackerWithEditResult:WLTrackerEditProfileResult_Succeed];
        
        [self hideLoading];
        [[AppContext rootViewController] popViewControllerAnimated:YES];
    } error:^(NSInteger errCode) {
        [WLTrackerEditProfile appendTrackerWithEditResult:WLTrackerEditProfileResult_Failed];
        
        [self hideLoading];
        [self showToastWithNetworkErr:errCode];
    }];
}

@end
