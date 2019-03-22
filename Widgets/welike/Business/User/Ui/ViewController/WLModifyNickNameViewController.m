//
//  WLModifyNickNameViewController.m
//  welike
//
//  Created by 刘斌 on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLModifyNickNameViewController.h"
#import "WLTextField.h"
#import "WLAccountManager.h"
#import "WLTrackerEditProfile.h"

#define kNoteTopMargin                  8.f
#define kNoteHeight                     18.f
#define kLeftMargin                     12.f
#define kWarningBottomMargin            13.f
#define kNameEditHeight                 48.f
#define kNameEditBottomMargin           17.f

@interface WLModifyNickNameViewController () <WLTextFieldDelegate>

@property (nonatomic, strong) UILabel *note1Label;
@property (nonatomic, strong) UILabel *note2Label;
@property (nonatomic, strong) WLTextField *nickField;
@property (nonatomic, strong) UILabel *errorNote;
@property (nonatomic, strong) UIButton *saveBtn;
@property (nonatomic, strong) WLNickNameChecker *nickNameChecker;

@end

@implementation WLModifyNickNameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.nickNameChecker = [[WLNickNameChecker alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onKeyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onKeyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.nickNameChecker cancel];
}

- (void)loadView
{
    [super loadView];
    
    self.navigationBar.title = [AppContext getStringForKey:@"regist_user_info_nickname" fileName:@"register"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.note1Label = [[UILabel alloc] initWithFrame:CGRectMake(kLeftMargin, kNavBarHeight + kNoteTopMargin, self.view.width - kLeftMargin, kNoteHeight)];
    self.note1Label.font = [UIFont systemFontOfSize:kMediumNameFontSize];
    self.note1Label.textColor = kDescriptionColor;
    self.note1Label.text = [AppContext getStringForKey:@"mine_user_host_personal_edit_name_slogen" fileName:@"user"];
    [self.view addSubview:self.note1Label];
    
    self.note2Label = [[UILabel alloc] initWithFrame:CGRectMake(kLeftMargin, self.note1Label.bottom, self.view.width - kLeftMargin, kNoteHeight)];
    self.note2Label.font = [UIFont systemFontOfSize:kLinkFontSize];
    self.note2Label.textColor = kDescriptionColor;
    self.note2Label.text = [AppContext getStringForKey:@"mine_user_host_personal_edit_name_attention" fileName:@"user"];
    [self.view addSubview:self.note2Label];
    
    self.nickField = [[WLTextField alloc] init];
    self.nickField.frame = CGRectMake(kLeftMargin, self.note2Label.bottom, self.view.width - kLeftMargin * 2, 0);
    self.nickField.textField.returnKeyType = UIReturnKeyDone;
    self.nickField.textField.keyboardType = UIKeyboardTypeDefault;
    self.nickField.textField.clearButtonMode = UITextFieldViewModeNever;
    self.nickField.delegate = self;
    self.nickField.textField.text = [[AppContext getInstance].accountManager myAccount].nickName;
    self.nickField.textField.placeholder = [AppContext getStringForKey:@"regist_user_info_name_hint" fileName:@"register"];
    [self.view addSubview:self.nickField];
    
    self.errorNote = [[UILabel alloc] initWithFrame:CGRectMake(kLeftMargin, self.nickField.bottom, self.view.width - kLeftMargin, kNoteHeight * 3.f)];
    self.errorNote.font = [UIFont systemFontOfSize:kLinkFontSize];
    self.errorNote.textColor = kErrorNoteFontColor;
    self.errorNote.numberOfLines = 2;
    [self.view addSubview:self.errorNote];
    
    self.saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveBtn.frame = CGRectMake(kLargeBtnXMargin, self.view.bottom - kLargeBtnHeight - kLargeBtnYMargin, self.view.width - kLargeBtnXMargin * 2, kLargeBtnHeight);
    [self.saveBtn setTitle:[AppContext getStringForKey:@"mine_user_host_personal_edit_name_save" fileName:@"user"] forState:UIControlStateNormal];
    [self.saveBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:kNameFontSize]];
    [self.saveBtn setTitleColor:kCommonBtnTextColor forState:UIControlStateNormal];
    [self.saveBtn setTitleColor:kCommonBtnDisableTextColor forState:UIControlStateDisabled];
    [self.saveBtn setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
    [self.saveBtn setBackgroundImage:[UIImage imageWithColor:kMainPressColor] forState:UIControlStateHighlighted];
    [self.saveBtn setBackgroundImage:[UIImage imageWithColor:kLargeBtnDisableColor] forState:UIControlStateDisabled];
    [self.saveBtn setEnabled:NO];
    [self.saveBtn.layer setMasksToBounds:YES];
    [self.saveBtn.layer setCornerRadius:kLargeBtnRadius];
    [self.saveBtn addTarget:self action:@selector(onSave) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveBtn];
}

#pragma mark WLTextFieldDelegate methods
- (BOOL)textField:(WLTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.nickField)
    {
        NSString *nickName = [textField.textField.text stringByReplacingCharactersInRange:range withString:string];
        [self postNickNameChecking:nickName];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(WLTextField *)textField
{
    if (textField == self.nickField)
    {
        [self postNickNameChecking:nil];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(WLTextField *)textField
{
    if (textField == self.nickField)
    {
        [self.nickField.textField resignFirstResponder];
    }
    return YES;
}

#pragma mark private methods
- (void)onKeyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    CGFloat height = keyboardRect.size.height;
    self.saveBtn.bottom = self.view.height - height - kLargeBtnYMargin;
}

- (void)onKeyboardWillHide:(NSNotification *)notification
{
    self.saveBtn.bottom = self.view.bottom - kLargeBtnYMargin;
}

- (void)onSave
{
    [WLTrackerEditProfile appendTrackerWithEditAction:WLTrackerEditProfileAction_Submit];
    
    [self showLoading];
    NSString *nickName = [self.nickField.textField.text copy];
    [[AppContext getInstance].accountManager syncAccountNickName:nickName successed:^{
        [WLTrackerEditProfile appendTrackerWithEditResult:WLTrackerEditProfileResult_Succeed];
        
        [self hideLoading];
        [[AppContext rootViewController] popViewControllerAnimated:YES];
    } error:^(NSInteger errCode) {
        [WLTrackerEditProfile appendTrackerWithEditResult:WLTrackerEditProfileResult_Failed];
        
        [self hideLoading];
        [self showToastWithNetworkErr:errCode];
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.nickField.textField resignFirstResponder];
}

- (void)postNickNameChecking:(NSString *)nickName
{
    self.nickField.showLoading = YES;
    self.saveBtn.enabled = NO;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEXT_CHECK_DELAY * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self.nickNameChecker checkForNickName:nickName result:^(NSString *nickName, NSInteger errCode) {
            [weakSelf handleNickNameCheckResult:errCode];
        }];
    });
}

- (void)handleNickNameCheckResult:(NSInteger)errCode
{
    self.nickField.showLoading = NO;
    if (errCode == ERROR_SUCCESS)
    {
        self.nickField.showOK = YES;
        self.nickField.errorState = NO;
        self.errorNote.text = nil;
        self.saveBtn.enabled = YES;
        self.note1Label.textColor = kDescriptionColor;
        self.note2Label.textColor = kDescriptionColor;
    }
    else
    {
        self.nickField.showOK = NO;
        self.nickField.errorState = YES;
        if (errCode == ERROR_USERINFO_NICKNAME_TOO_SHORT ||
            errCode == ERROR_USERINFO_NICKNAME_TOO_LONG)
        {
            self.errorNote.text = nil;
            self.note1Label.textColor = kErrorNoteFontColor;
            self.note2Label.textColor = kErrorNoteFontColor;
        }
        else
        {
            self.errorNote.text = [WLErrorHelper getErrCodeTextForErrCode:errCode];
            self.note1Label.textColor = kDescriptionColor;
            self.note2Label.textColor = kDescriptionColor;
        }
        self.saveBtn.enabled = NO;
    }
}

@end
