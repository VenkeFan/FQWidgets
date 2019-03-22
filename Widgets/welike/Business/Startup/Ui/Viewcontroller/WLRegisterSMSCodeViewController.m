//
//  WLRegisterSMSCodeViewController.m
//  welike
//
//  Created by 刘斌 on 2018/4/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRegisterSMSCodeViewController.h"
#import "WLTextField.h"
#import "WLStartHandler.h"
#import "WLRegLikeIcon.h"
#import "WLTrackerLogin.h"

#define kRegisterSMSCodeLogoBottomMargin      74.f
#define kRegisterSMSCodeNoteHeight            36.f
#define kRegisterSMSCodeNoteBottomMargin      41.f
#define kRegisterSMSCodeChangeNumHeight       36.f
#define kRegisterSMSCodeChangeNumTextHeight   16.f
#define kRegisterSMSCodeResendTimeWidth       170.f
#define kRegisterSMSCodeResendTimeTopMargin   10.f

#define kRegisterSMSCodeChangeNumFontSize     13.f

@interface WLRegisterSMSCodeViewController () <WLStartHandlerDelegate, WLTextFieldDelegate>

@property (nonatomic, copy) NSString *smsCode;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIImageView *logo;
@property (nonatomic, strong) UILabel *note;
@property (nonatomic, strong) WLTextField *smsCodeField;
@property (nonatomic, strong) UIButton *changeNumberBtn;
@property (nonatomic, strong) UILabel *resendTime;
@property (nonatomic, strong) UIButton *resendBtn;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, assign) CGFloat changeNumberBtnBottomAnchor;
@property (nonatomic, assign) CGFloat changeNumberBtnAnchor;
@property (nonatomic, assign) CGFloat resendBtnAnchor;
@property (nonatomic, assign) CGFloat resendTimeAnchor;
@property (nonatomic, assign) CGFloat smsCodeFieldAnchor;
@property (nonatomic, assign) CGFloat noteAnchor;
@property (nonatomic, assign) CGFloat logoAnchor;
@property (nonatomic, assign) NSInteger sec;
@property (nonatomic, strong) NSTimer *resendTimer;

- (void)layout;
- (void)onBack;
- (void)onSMSRetryHold;

@end

@implementation WLRegisterSMSCodeViewController {
    NSInteger _checkCount;
    CFTimeInterval _beginTime;
    CFTimeInterval _endTime;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
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
    [self.resendTimer invalidate];
    self.resendTimer = nil;
}

- (void)loadView
{
    [super loadView];
    self.sec = 60;
    self.changeNumberBtnAnchor = 0;
    self.changeNumberBtnBottomAnchor = 0;
    self.resendBtnAnchor = 0;
    self.resendTimeAnchor = 0;
    self.smsCodeFieldAnchor = 0;
    self.noteAnchor = 0;
    self.logoAnchor = 0;
    self.resendTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(onSMSRetryHold) userInfo:nil repeats:YES];
    [self layout];
    
    [WLTrackerLogin setCodeSendCount:1];
    _beginTime = CACurrentMediaTime();
    [WLTrackerLogin appendLoginCodeViewAppear:WLTrackerLoginCodeViewType_SMS
                                  requestType:WLTrackerLoginVerifyRequestType_Auto
                                     codeType:WLTrackerLoginVerifyCodeType_SMS
                                     userType:WLTrackerLoginUserType_Invalid];
}

- (void)layout
{
    [self.view removeAllSubviews];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    WLRegLikeIcon *topIcon = [[WLRegLikeIcon alloc] initWithFrame:CGRectMake(0, 35.f, 0, 0)];
    topIcon.right = self.view.width - kLargeBtnXMargin;
    [self.view addSubview:topIcon];
    
    UIImage *backIcon = [AppContext getImageForKey:@"register_back"];
    if (self.backBtn == nil)
    {
        self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    [self.backBtn setImage:backIcon forState:UIControlStateNormal];
    self.backBtn.frame = CGRectMake(kRegisterLeftMargin, kRegisterLeftMargin + kSystemStatusBarHeight, backIcon.size.width + 20, backIcon.size.height + 20);
    self.backBtn.imageEdgeInsets = UIEdgeInsetsMake(-backIcon.size.height * 2, -backIcon.size.width, -backIcon.size.height, backIcon.size.width);
    [self.backBtn addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
    
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
    
    if (self.note == nil)
    {
        self.note = [[UILabel alloc] init];
    }
    self.note.frame = CGRectMake(kRegisterLeftMargin, self.logo.bottom + kRegisterSMSCodeLogoBottomMargin, self.view.width - kRegisterLeftMargin * 2, kRegisterSMSCodeNoteHeight);
    self.note.backgroundColor = [UIColor clearColor];
    self.note.textColor = kBodyFontColor;
    self.note.textAlignment = NSTextAlignmentLeft;
    self.note.numberOfLines = 2;
    self.note.text = [NSString stringWithFormat:[AppContext getStringForKey:@"regist_sms_code_hint" fileName:@"register"], [AppContext getInstance].startHandler.mobile];
    self.note.font = [UIFont systemFontOfSize:kNoteFontSize];
    [self.view addSubview:self.note];
    
    if (self.smsCodeField == nil)
    {
        self.smsCodeField = [[WLTextField alloc] init];
    }
    self.smsCodeField.frame = CGRectMake(kRegisterLeftMargin, self.note.bottom + kRegisterSMSCodeNoteBottomMargin, self.view.width - kRegisterLeftMargin * 2, 0);
    self.smsCodeField.textField.returnKeyType = UIReturnKeyDone;
    self.smsCodeField.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.smsCodeField.delegate = self;
    [self.view addSubview:self.smsCodeField];
    
    UIFont *smallFont = [UIFont systemFontOfSize:kRegisterSMSCodeChangeNumFontSize];
    NSString *btnStr = [AppContext getStringForKey:@"regist_sms_code_back" fileName:@"register"];
    CGFloat changeNumberTextWidth = [btnStr sizeWithFont:smallFont size:CGSizeMake(self.view.width / 2.f, kRegisterSMSCodeChangeNumTextHeight)].width;
    if (self.changeNumberBtn == nil)
    {
        self.changeNumberBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    self.changeNumberBtn.backgroundColor = [UIColor clearColor];
    self.changeNumberBtn.frame = CGRectMake(kRegisterLeftMargin, self.smsCodeField.bottom, changeNumberTextWidth, kRegisterSMSCodeChangeNumHeight);
    [self.changeNumberBtn setTitle:btnStr forState:UIControlStateNormal];
    [self.changeNumberBtn.titleLabel setFont:smallFont];
    [self.changeNumberBtn setTitleColor:kClickableTextColor forState:UIControlStateNormal];
    [self.changeNumberBtn addTarget:self action:@selector(onChange) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.changeNumberBtn];
    
    if (self.resendTime == nil)
    {
        self.resendTime = [[UILabel alloc] init];
    }
    self.resendTime.frame = CGRectMake(self.view.width - kRegisterLeftMargin - kRegisterSMSCodeResendTimeWidth, self.smsCodeField.bottom + kRegisterSMSCodeResendTimeTopMargin, kRegisterSMSCodeResendTimeWidth, kRegisterSMSCodeChangeNumTextHeight);
    self.resendTime.backgroundColor = [UIColor clearColor];
    self.resendTime.textColor = kBodyFontColor;
    self.resendTime.textAlignment = NSTextAlignmentRight;
    self.resendTime.text = [NSString stringWithFormat:[AppContext getStringForKey:@"regist_otp_resent" fileName:@"register"], self.sec];
    self.resendTime.font = [UIFont systemFontOfSize:kNoteFontSize];
    [self.view addSubview:self.resendTime];
    
    NSString *resendStr = [AppContext getStringForKey:@"regist_enter_code_resend" fileName:@"register"];
    CGFloat resendTextWidth = [resendStr sizeWithFont:smallFont size:CGSizeMake(self.view.width / 2.f, kRegisterSMSCodeChangeNumTextHeight)].width;
    if (self.resendBtn == nil)
    {
        self.resendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    self.resendBtn.backgroundColor = [UIColor clearColor];
    self.resendBtn.frame = CGRectMake(self.view.width - kRegisterLeftMargin - resendTextWidth, self.smsCodeField.bottom, resendTextWidth, kRegisterSMSCodeChangeNumHeight);
    [self.resendBtn setTitle:resendStr forState:UIControlStateNormal];
    [self.resendBtn.titleLabel setFont:smallFont];
    [self.resendBtn setTitleColor:kClickableTextColor forState:UIControlStateNormal];
    [self.resendBtn addTarget:self action:@selector(onResend) forControlEvents:UIControlEventTouchUpInside];
    self.resendBtn.hidden = YES;
    [self.view addSubview:self.resendBtn];
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

#pragma mark WLTextFieldDelegate methods
- (BOOL)textField:(WLTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.smsCodeField)
    {
        NSString *t = [textField.textField.text stringByReplacingCharactersInRange:range withString:string];
        NSInteger length = [t length];
        self.smsCode = [t copy];
        if (length == 4)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.smsCodeField.textField resignFirstResponder];
                [self showLoading];
                [[AppContext getInstance].startHandler setSmsCode:self.smsCode];
                [[AppContext getInstance].startHandler next:WELIKE_STARTUP_STATE_TRY_LOGIN];
            });
            
            _endTime = CACurrentMediaTime();
            CFTimeInterval duration = (_endTime - _beginTime) * 1000;
            [WLTrackerLogin appendVerifyCode:[[AppContext getInstance].startHandler mobile]
                                  checkCount:++_checkCount
                                    userType:WLTrackerLoginUserType_Invalid
                                    codeType:WLTrackerLoginVerifyCodeType_SMS
                                    viewType:WLTrackerLoginCodeViewType_SMS
                                    duration:duration];
            
            return YES;
        }
        else if (length < 4)
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(WLTextField *)textField
{
    if (textField == self.smsCodeField)
    {
        self.smsCode = nil;
    }
    return YES;
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

#pragma mark WLRegisterMobileViewController private methods
- (void)onBack
{
    [self.smsCodeField.textField resignFirstResponder];
    [AppContext getInstance].startHandler.mobile = nil;
    [AppContext getInstance].startHandler.smsCode = nil;
    [[AppContext getInstance].startHandler runNext:WELIKE_STARTUP_STATE_LOGIN_MOBILE];
}

- (void)onChange
{
    [WLTrackerLogin appendCodeChange:[[AppContext getInstance].startHandler mobile]
                            viewType:WLTrackerLoginCodeViewType_SMS
                            userType:WLTrackerLoginUserType_Invalid];
    
    [self onBack];
}

- (void)onResend
{
    self.resendBtn.hidden = YES;
    self.resendTime.hidden = NO;
    self.sec = 60;
    self.resendTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(onSMSRetryHold) userInfo:nil repeats:YES];
    [[AppContext getInstance].startHandler resend];
    
    WLTrackerLogin.codeSendCount++;
    [WLTrackerLogin appendCodeResend:[[AppContext getInstance].startHandler mobile]
                            viewType:WLTrackerLoginCodeViewType_SMS
                         requestType:WLTrackerLoginVerifyRequestType_Resend
                            codeType:WLTrackerLoginVerifyCodeType_SMS
                            userType:WLTrackerLoginUserType_Invalid];
}

- (void)onKeyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    CGFloat height = keyboardRect.size.height;
    
    if (self.changeNumberBtnAnchor == 0)
    {
        self.changeNumberBtnAnchor = self.changeNumberBtn.top;
    }
    if (self.changeNumberBtnBottomAnchor == 0)
    {
        self.changeNumberBtnBottomAnchor = self.changeNumberBtn.bottom;
    }
    if (self.resendBtnAnchor == 0)
    {
        self.resendBtnAnchor = self.resendBtn.top;
    }
    if (self.resendTimeAnchor == 0)
    {
        self.resendTimeAnchor = self.resendTime.top;
    }
    if (self.smsCodeFieldAnchor == 0)
    {
        self.smsCodeFieldAnchor = self.smsCodeField.top;
    }
    if (self.noteAnchor == 0)
    {
        self.noteAnchor = self.note.top;
    }
    if (self.logoAnchor == 0)
    {
        self.logoAnchor = self.logo.top;
    }
    
    CGFloat y1 = self.view.height - height - kLargeBtnYMargin;
    CGFloat y2 = self.changeNumberBtnBottomAnchor + kLargeBtnYMargin;
    if (y1 < y2)
    {
        self.offsetY = self.changeNumberBtnAnchor - (y1 - self.changeNumberBtn.height - kLargeBtnYMargin);
        self.changeNumberBtn.top = self.changeNumberBtnAnchor - self.offsetY;
        self.resendBtn.top = self.resendBtnAnchor - self.offsetY;
        self.resendTime.top = self.resendTimeAnchor - self.offsetY;
        self.smsCodeField.top = self.smsCodeFieldAnchor - self.offsetY;
        self.note.top = self.noteAnchor - self.offsetY;
        self.logo.top = self.logoAnchor - self.offsetY;
    }
}

- (void)onKeyboardWillHide:(NSNotification *)notification
{
    if (self.offsetY > 0)
    {
        self.changeNumberBtn.top = self.changeNumberBtnAnchor;
        self.resendBtn.top = self.resendBtnAnchor;
        self.resendTime.top = self.resendTimeAnchor;
        self.smsCodeField.top = self.smsCodeFieldAnchor;
        self.note.top = self.noteAnchor;
        self.logo.top = self.logoAnchor;
        self.offsetY = 0;
    }
    self.changeNumberBtnAnchor = 0;
    self.changeNumberBtnBottomAnchor = 0;
    self.resendBtnAnchor = 0;
    self.resendTimeAnchor = 0;
    self.smsCodeFieldAnchor = 0;
    self.noteAnchor = 0;
    self.logoAnchor = 0;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.smsCodeField.textField resignFirstResponder];
}

- (void)onSMSRetryHold
{
    self.sec--;
    if (self.sec == 0)
    {
        [self.resendTimer invalidate];
        self.resendTimer = nil;
        self.resendTime.text = [NSString stringWithFormat:[AppContext getStringForKey:@"regist_otp_resent" fileName:@"register"], 60];;
        self.resendTime.hidden = YES;
        self.resendBtn.hidden = NO;
    }
    else
    {
        self.resendTime.text = [NSString stringWithFormat:[AppContext getStringForKey:@"regist_otp_resent" fileName:@"register"], self.sec];
    }
}

@end
