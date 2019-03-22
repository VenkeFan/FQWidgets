//
//  WLRegisterMobileViewController.m
//  welike
//
//  Created by 刘斌 on 2018/4/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRegisterMobileViewController.h"
#import "WLTextField.h"
#import "WLStartHandler.h"
#import "WLRegLikeIcon.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "WLTrackerLogin.h"

#define kRegisterMobileLogoBottomMargin       74.f
#define kRegisterErrorNoteTopMargin           10.f
#define kRegisterFacebookXMargin              34.f
#define kRegisterFacebookHeight               35.f

@interface WLRegisterMobileViewController () <WLStartHandlerDelegate, WLTextFieldDelegate, UIActionSheetDelegate, GIDSignInDelegate, GIDSignInUIDelegate>

@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *nationCode;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIImageView *logo;
@property (nonatomic, strong) UIButton *hideLogo;
@property (nonatomic, strong) UIButton *envSel;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIButton *facebookBtn;
@property (nonatomic, strong) UIButton *googleBtn;
@property (nonatomic, strong) WLTextField *mobileField;
@property (nonatomic, strong) UILabel *errorNote;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, assign) CGFloat errorNoteBottomAnchor;
@property (nonatomic, assign) CGFloat errorNoteAnchor;
@property (nonatomic, assign) CGFloat mobileFieldAnchor;
@property (nonatomic, assign) CGFloat logoAnchor;
@property (nonatomic, assign) CGFloat hideLogoAnchor;

- (void)layout;
- (void)onNext;

@end

@implementation WLRegisterMobileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.nationCode = @"91";
        
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
}

- (void)loadView
{
    [super loadView];
    self.errorNoteBottomAnchor = 0;
    self.errorNoteAnchor = 0;
    self.mobileFieldAnchor = 0;
    self.logoAnchor = 0;
    self.hideLogoAnchor = 0;
    [self layout];
    
    [WLTrackerLogin appendLoginPhoneViewAppear:WLTrackerLoginPageType_FullScreen
                                 snsVerifyType:WLTrackerLoginSNSVerifyType_Login];
}

- (void)layout
{
    [self.view removeAllSubviews];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImage *backIcon = [AppContext getImageForKey:@"register_back"];
    if (self.backBtn == nil)
    {
        self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    [self.backBtn setImage:backIcon forState:UIControlStateNormal];
    self.backBtn.frame = CGRectMake(0, kSystemStatusBarHeight, kSingleNavBarHeight, kSingleNavBarHeight);
    [self.backBtn addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
    
    WLRegLikeIcon *topIcon = [[WLRegLikeIcon alloc] init];
    topIcon.right = self.view.width - kLargeBtnXMargin;
    topIcon.centerY = self.backBtn.centerY;
    [self.view addSubview:topIcon];
    
    if (self.logo == nil)
    {
        self.logo = [[UIImageView alloc] initWithImage:[AppContext getImageForKey:@"welike_reg_logo"]];
    }
    if ([LuuUtils mainScreenBounds].width <= 640)
    {
        self.logo.top = kRegisterLogoTopMargin_smal;
    }
    else
    {
        self.logo.top = kRegisterLogoTopMargin_larg;
    }
    self.logo.left = (self.view.width - self.logo.width) / 2.f;
    [self.view addSubview:self.logo];

#ifdef __WELIKE_TEST_
    if (self.hideLogo == nil)
    {
        self.hideLogo = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    self.hideLogo.frame = self.logo.frame;
    self.hideLogo.backgroundColor = [UIColor clearColor];
    [self.hideLogo addTarget:self action:@selector(onShowDEBUGNativeCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.hideLogo];
    
    if (self.envSel == nil)
    {
        self.envSel = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    self.envSel.frame = CGRectMake(0, self.hideLogo.top, self.hideLogo.left, self.hideLogo.height);
    self.envSel.backgroundColor = [UIColor clearColor];
    [self.envSel addTarget:self action:@selector(onShowDEBUGEnvCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.envSel];
#endif
    
    if (self.mobileField == nil)
    {
        self.mobileField = [[WLTextField alloc] init];
    }
    self.mobileField.frame = CGRectMake(kRegisterLeftMargin, self.logo.bottom + kRegisterMobileLogoBottomMargin, self.view.width - kRegisterLeftMargin * 2, 0);
    self.mobileField.title = @"+91";
    self.mobileField.textField.returnKeyType = UIReturnKeyDone;
    self.mobileField.textField.keyboardType = UIKeyboardTypePhonePad;
    self.mobileField.delegate = self;
    self.mobileField.textField.placeholder = [AppContext getStringForKey:@"regist_input_mobile" fileName:@"register"];
    [self.view addSubview:self.mobileField];
    
    if (self.errorNote == nil)
    {
        self.errorNote = [[UILabel alloc] initWithFrame:CGRectMake(kRegisterLeftMargin, self.mobileField.bottom + kRegisterErrorNoteTopMargin, [LuuUtils mainScreenBounds].width - kRegisterLeftMargin * 2.f, kErrorNoteHeight)];
    }
    self.errorNote.backgroundColor = [UIColor clearColor];
    self.errorNote.textColor = kErrorNoteFontColor;
    self.errorNote.textAlignment = NSTextAlignmentLeft;
    self.errorNote.numberOfLines = 1;
    self.errorNote.font = [UIFont systemFontOfSize:kErrorNoteFontSize];
    [self.view addSubview:self.errorNote];
    
//    if (self.facebookBtn == nil)
//    {
//        self.facebookBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    }
//    UIFont *facebookFont = [UIFont systemFontOfSize:kNameFontSize];
//    NSString *facebookTitle = [AppContext getStringForKey:@"regist_login_facebook" fileName:@"register"];
//    UIImage *ficon = [AppContext getImageForKey:@"facebook_login_icon"];
//    self.facebookBtn.frame = CGRectMake(kRegisterLeftMargin, self.errorNote.bottom + 5.f, self.view.width - kRegisterLeftMargin * 2, kRegisterFacebookHeight);
//    self.facebookBtn.backgroundColor = kFacebookFontColor;
//    [self.facebookBtn.titleLabel setFont:facebookFont];
//    [self.facebookBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.facebookBtn setTitle:facebookTitle forState:UIControlStateNormal];
//    [self.facebookBtn.layer setMasksToBounds:YES];
//    [self.facebookBtn.layer setCornerRadius:18.f];
//    [self.facebookBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -15, 0.0, 0.0)];
//    [self.facebookBtn addTarget:self action:@selector(onFacebookLogin) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.facebookBtn];
//    [self.facebookBtn addSubview:({
//        UIImageView *imgView = [[UIImageView alloc] initWithImage:ficon];
//        [imgView sizeToFit];
//        imgView.center = CGPointMake(24 + ficon.size.width * 0.5, CGRectGetHeight(self.facebookBtn.frame) * 0.5);
//        imgView;
//    })];
//
//    if (self.googleBtn == nil)
//    {
//        self.googleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    }
//    self.googleBtn.frame = CGRectMake(kRegisterLeftMargin, self.facebookBtn.bottom + 10.f, self.view.width - kRegisterLeftMargin * 2, kRegisterFacebookHeight);
//    self.googleBtn.backgroundColor = kGoogleFontColor;
//    [self.googleBtn.titleLabel setFont:facebookFont];
//    [self.googleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.googleBtn setTitle:[AppContext getStringForKey:@"regist_login_google" fileName:@"register"]
//                    forState:UIControlStateNormal];
//    [self.googleBtn.layer setMasksToBounds:YES];
//    [self.googleBtn.layer setCornerRadius:18.f];
//    [self.googleBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -15, 0.0, 0.0)];
//    [self.googleBtn addTarget:self action:@selector(onGoogleLogin) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.googleBtn];
//    [self.googleBtn addSubview:({
//        UIImageView *imgView = [[UIImageView alloc] initWithImage:[AppContext getImageForKey:@"google_login_icon"]];
//        [imgView sizeToFit];
//        imgView.center = CGPointMake(24 + ficon.size.width * 0.5, CGRectGetHeight(self.facebookBtn.frame) * 0.5);
//        imgView;
//    })];
    
    NSString *nextTitle = [AppContext getStringForKey:@"regist_next_btn" fileName:@"register"];
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[AppContext getInstance].startHandler registerWithDelegate:self];
    
    [self.mobileField.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[AppContext getInstance].startHandler unregister:self];
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

#pragma mark UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
#ifdef __WELIKE_TEST_
    if (actionSheet.tag == 1)
    {
        if (buttonIndex == 0)
        {
            self.nationCode = @"91";
        }
        else if (buttonIndex == 1)
        {
            self.nationCode = @"86";
        }
    }
    else if (actionSheet.tag == 2)
    {
        if (buttonIndex == 0)
        {
            [[AppContext getInstance] testEnvSwitch:@"pre"];
        }
        else if (buttonIndex == 1)
        {
            [[AppContext getInstance] testEnvSwitch:@"dev"];
        }
    }
#endif
}

#pragma mark WLTextFieldDelegate methods
- (BOOL)textField:(WLTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.mobileField)
    {
        NSString *t = [textField.textField.text stringByReplacingCharactersInRange:range withString:string];
        NSInteger length = [t length];
        self.mobile = [t copy];
        if (length > 9)
        {
            self.mobileField.errorState = NO;
            if ([self.nextBtn isEnabled] == NO)
            {
                [self.nextBtn setEnabled:YES];
            }
        }
        else if (length == 0)
        {
            self.errorNote.text = [AppContext getStringForKey:@"error_regist_input_phonenumber_not_empty" fileName:@"register"];
            self.mobileField.errorState = YES;
            [self.nextBtn setEnabled:NO];
        }
        else if (length > 0 && length < 11)
        {
            self.errorNote.text = nil;
            self.mobileField.errorState = NO;
            if ([self.nextBtn isEnabled] == YES)
            {
                [self.nextBtn setEnabled:NO];
            }
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(WLTextField *)textField
{
    self.errorNote.text = [AppContext getStringForKey:@"error_regist_input_phonenumber_not_empty" fileName:@"register"];
    self.mobileField.errorState = YES;
    [self.nextBtn setEnabled:NO];
    self.mobile = nil;
    return YES;
}

#pragma mark - GIDSignInDelegate

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (user) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showLoading];
            [self.mobileField.textField resignFirstResponder];
            [[AppContext getInstance].startHandler setThirdToken:user.authentication.idToken];
            [[AppContext getInstance].startHandler next:WELIKE_STARTUP_STATE_TRY_GOOGLE_LOGIN];
        });
    }
}

#pragma mark - GIDSignInUIDelegate

- (void)presentSignInViewController:(UIViewController *)viewController {
    [[self navigationController] pushViewController:viewController animated:YES];
}

#pragma mark WLRegisterMobileViewController private methods
- (void)onBack
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [AppContext getInstance].startHandler.mobile = nil;
        [AppContext getInstance].startHandler.smsCode = nil;
        [[AppContext getInstance].startHandler runNext:WELIKE_STARTUP_STATE_EXEMPT_LOGIN];
    }
}

- (void)onNext
{
    [self.mobileField.textField resignFirstResponder];
    [[AppContext getInstance].startHandler setMobile:self.mobile];
    [[AppContext getInstance].startHandler setNationCode:self.nationCode];
    [[AppContext getInstance].startHandler next:WELIKE_STARTUP_STATE_LOGIN_SMS_CODE];
    
    [WLTrackerLogin appendLoginPhoneViewNext:self.mobile
                                    userType:WLTrackerLoginUserType_Invalid];
}

- (void)onKeyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    CGFloat height = keyboardRect.size.height;
    self.nextBtn.bottom = self.view.height - height - kLargeBtnYMargin;
    
    if (self.errorNoteBottomAnchor == 0)
    {
        self.errorNoteBottomAnchor = self.errorNote.bottom;
    }
    if (self.errorNoteAnchor == 0)
    {
        self.errorNoteAnchor = self.errorNote.top;
    }
    if (self.mobileFieldAnchor == 0)
    {
        self.mobileFieldAnchor = self.mobileField.top;
    }
    if (self.logoAnchor == 0)
    {
        self.logoAnchor = self.logo.top;
    }
    if (self.hideLogoAnchor == 0)
    {
        self.hideLogoAnchor = self.hideLogo.top;
    }
    
    CGFloat y1 = self.nextBtn.top - kLargeBtnYMargin;
    CGFloat y2 = self.errorNoteBottomAnchor;
    if (y1 < y2)
    {
        self.offsetY = self.errorNoteAnchor - (y1 - self.errorNote.height);
        self.errorNote.top = self.errorNoteAnchor - self.offsetY;
        self.mobileField.top = self.mobileFieldAnchor - self.offsetY;
        self.logo.top = self.logoAnchor - self.offsetY;
        self.hideLogo.top = self.hideLogoAnchor - self.offsetY;
    }
}

- (void)onKeyboardWillHide:(NSNotification *)notification
{
    self.nextBtn.bottom = self.view.bottom - kLargeBtnYMargin - kSafeAreaBottomY;
    if (self.offsetY > 0)
    {
        self.errorNote.top = self.errorNoteAnchor;
        self.mobileField.top = self.mobileFieldAnchor;
        self.logo.top = self.logoAnchor;
        self.hideLogo.top = self.hideLogoAnchor;
        self.offsetY = 0;
    }
    self.errorNoteBottomAnchor = 0;
    self.errorNoteAnchor = 0;
    self.mobileFieldAnchor = 0;
    self.logoAnchor = 0;
    self.hideLogoAnchor = 0;
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self.mobileField.textField resignFirstResponder];
//}

- (void)onFacebookLogin
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];

    [login logInWithReadPermissions:@[@"public_profile"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error == nil)
        {
            if (result.isCancelled == NO)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.mobileField.textField resignFirstResponder];
                    [self showLoading];
                    [[AppContext getInstance].startHandler setThirdToken:result.token.tokenString];
                    [[AppContext getInstance].startHandler next:WELIKE_STARTUP_STATE_TRY_FACEBOOK_LOGIN];
                });
            }
        }
    }];
}

- (void)onGoogleLogin
{
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    [[GIDSignIn sharedInstance] signIn];
}

- (void)onShowDEBUGNativeCode
{
#ifdef __WELIKE_TEST_
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"native code" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"91", @"86", nil];
    actionSheet.tag = 1;
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
#endif
}

- (void)onShowDEBUGEnvCode
{
#ifdef __WELIKE_TEST_
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"env" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"pre", @"dev", nil];
    actionSheet.tag = 2;
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
#endif
}

@end
