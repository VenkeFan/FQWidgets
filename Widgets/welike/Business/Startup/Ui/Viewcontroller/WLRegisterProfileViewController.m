//
//  WLRegisterProfileViewController.m
//  welike
//
//  Created by 刘斌 on 2018/4/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLRegisterProfileViewController.h"
#import "WLAssetsViewController.h"
#import "WLTextField.h"
#import "WLUploadManager.h"
#import "WLAccountManager.h"
#import "WLStartHandler.h"
#import "WLHeadView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "WLTrackerLogin.h"

#define kRegisterProfileHeadTopMargin               49.f
#define kRegisterProfileNickNoteTopMargin           40.f
#define kRegisterProfileNickNoteHeight              18.f
#define kRegisterProfileNickFieldTopMargin          20.f
#define kRegisterProfileErrorNoteTopMargin          10.f
#define kRegisterProfileGenderXMargin               50.f
#define kRegisterProfileGenderTopMargin             34.f
#define kRegisterProfileGenderWidth                 60.f
#define kRegisterProfileGenderHeight                60.f

@interface WLRegisterProfileViewController () <WLTextFieldDelegate, WLHeadViewDelegate, WLAssetsViewControllerDelegate, WLUploadManagerDelegate, WLStartHandlerDelegate>

@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, assign) NSInteger gender;
@property (nonatomic, copy) NSString *uploadKey;
@property (nonatomic, copy) NSString *headUrl;
@property (nonatomic, strong) WLHeadView *head;
@property (nonatomic, strong) UILabel *nickNote;
@property (nonatomic, strong) WLTextField *nickField;
@property (nonatomic, strong) UILabel *errorNote;
@property (nonatomic, strong) UIButton *maleBox;
@property (nonatomic, strong) UIButton *femaleBox;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, assign) CGFloat maleBoxBottomAnchor;
@property (nonatomic, assign) CGFloat maleBoxAnchor;
@property (nonatomic, assign) CGFloat femaleBoxAnchor;
@property (nonatomic, assign) CGFloat headAnchor;
@property (nonatomic, assign) CGFloat nickNoteAnchor;
@property (nonatomic, assign) CGFloat nickFieldAnchor;
@property (nonatomic, assign) CGFloat errorNoteAnchor;

@property (nonatomic, strong) WLNickNameChecker *nickNameChecker;

- (void)postNickNameChecking:(NSString *)nickName;
- (void)handleNickNameCheckResult:(NSInteger)errCode;

@end

@implementation WLRegisterProfileViewController {
    CFTimeInterval _beginTime;
    CFTimeInterval _endTime;
    
    NSInteger _nameCheckCount;
}

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
    self.offsetY = 0;
    self.maleBoxBottomAnchor = 0;
    self.maleBoxAnchor = 0;
    self.femaleBoxAnchor = 0;
    self.headAnchor = 0;
    self.nickNoteAnchor = 0;
    self.nickFieldAnchor = 0;
    self.errorNoteAnchor = 0;
    self.gender = WELIKE_USER_GENDER_UNKNOWN;
    [self layout];
    
    _beginTime = CACurrentMediaTime();
    [WLTrackerLogin appendInfoViewAppear:[[AppContext getInstance].startHandler mobile]
                                codeType:WLTrackerLoginVerifyCodeType_SMS
                                duration:0.0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[AppContext getInstance].uploadManager registerDelegate:self];
    [[AppContext getInstance].startHandler registerWithDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[AppContext getInstance].uploadManager unregister:self];
    [[AppContext getInstance].startHandler unregister:self];
}

- (void)layout
{
    [self.view removeAllSubviews];
    
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImage *headIcon = [AppContext getImageForKey:@"select_head"];
    if (self.head == nil)
    {
        self.head = [[WLHeadView alloc] initWithDefaultImageId:@"select_head"];
    }
    self.head.headUrl = account.headUrl;
    self.head.frame = CGRectMake((self.view.width - headIcon.size.width) / 2.f, kRegisterProfileHeadTopMargin, headIcon.size.width, headIcon.size.height);
    self.head.delegate = self;
    [self.view addSubview:self.head];
    
    if (self.nickNote == nil)
    {
        self.nickNote = [[UILabel alloc] init];
    }
    self.nickNote.frame = CGRectMake(kRegisterLeftMargin, self.head.bottom + kRegisterProfileNickNoteTopMargin, self.view.width - kRegisterLeftMargin * 2.f, kRegisterProfileNickNoteHeight);
    self.nickNote.backgroundColor = [UIColor clearColor];
    self.nickNote.textColor = kBodyFontColor;
    self.nickNote.textAlignment = NSTextAlignmentLeft;
    self.nickNote.text = [AppContext getStringForKey:@"regist_user_info_name" fileName:@"register"];
    self.nickNote.font = [UIFont systemFontOfSize:kNoteFontSize];
    [self.view addSubview:self.nickNote];
    
    self.nickName = account.nickName;
    if (self.nickField == nil)
    {
        self.nickField = [[WLTextField alloc] init];
    }
    self.nickField.frame = CGRectMake(kRegisterLeftMargin, self.nickNote.bottom + kRegisterProfileNickFieldTopMargin, self.view.width - kRegisterLeftMargin * 2, 0);
    self.nickField.title = @"@";
    self.nickField.textField.returnKeyType = UIReturnKeyDone;
    self.nickField.textField.keyboardType = UIKeyboardTypeDefault;
    self.nickField.textField.clearButtonMode = UITextFieldViewModeNever;
    self.nickField.delegate = self;
    self.nickField.textField.text = self.nickName;
    self.nickField.textField.placeholder = [AppContext getStringForKey:@"regist_user_info_name_hint" fileName:@"register"];
    [self.view addSubview:self.nickField];
    
    if (self.errorNote == nil)
    {
        self.errorNote = [[UILabel alloc] init];
    }
    self.errorNote.frame = CGRectMake(kRegisterLeftMargin, self.nickField.bottom + kRegisterProfileErrorNoteTopMargin, [LuuUtils mainScreenBounds].width - kRegisterLeftMargin * 2.f, kErrorNoteHeight * 3.f);
    self.errorNote.backgroundColor = [UIColor clearColor];
    self.errorNote.textColor = kErrorNoteFontColor;
    self.errorNote.textAlignment = NSTextAlignmentLeft;
    self.errorNote.numberOfLines = 2;
    self.errorNote.font = [UIFont systemFontOfSize:kErrorNoteFontSize];
    [self.view addSubview:self.errorNote];
    
    UIImage *maleUnselectedIcon = [AppContext getImageForKey:@"register_male_unselected"];
    UIImage *maleSelectedIcon = [AppContext getImageForKey:@"register_male_selected"];
    if (self.maleBox == nil)
    {
        self.maleBox = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    self.maleBox.frame = CGRectMake(self.view.center.x - kRegisterProfileGenderXMargin - kRegisterProfileGenderWidth, self.errorNote.bottom + kRegisterProfileGenderTopMargin, kRegisterProfileGenderWidth, kRegisterProfileGenderHeight);
    [self.maleBox setImage:maleUnselectedIcon forState:UIControlStateNormal];
    [self.maleBox setImage:maleSelectedIcon forState:UIControlStateSelected];
    [self.maleBox setTitleColor:kGenderFontColor forState:UIControlStateNormal];
    [self.maleBox setTitleColor:kNameFontColor forState:UIControlStateSelected];
    self.maleBox.titleLabel.font = [UIFont systemFontOfSize:kBodyFontSize];
    [self.maleBox setTitle:[AppContext getStringForKey:@"user_sex_boy" fileName:@"common"] forState:UIControlStateNormal];
    [self.maleBox setSelected:NO];
    self.maleBox.imageEdgeInsets = UIEdgeInsetsMake(-(kRegisterProfileGenderHeight / 2.f - self.maleBox.titleLabel.height - self.maleBox.titleLabel.top), (kRegisterProfileGenderWidth - self.maleBox.imageView.width) / 2.f, 0, 0);
    self.maleBox.titleEdgeInsets = UIEdgeInsetsMake(kRegisterProfileGenderHeight - self.maleBox.imageView.height - self.maleBox.imageView.top, -self.maleBox.imageView.width, 0, 0);
    [self.maleBox addTarget:self action:@selector(onTapMale) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.maleBox];
    
    UIImage *femaleUnselectedIcon = [AppContext getImageForKey:@"register_female_unselected"];
    UIImage *femaleSelectedIcon = [AppContext getImageForKey:@"register_female_selected"];
    if (self.femaleBox == nil)
    {
        self.femaleBox = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    self.femaleBox.frame = CGRectMake(self.view.center.x + kRegisterProfileGenderXMargin, self.errorNote.bottom + kRegisterProfileGenderTopMargin, kRegisterProfileGenderWidth, kRegisterProfileGenderHeight);
    [self.femaleBox setImage:femaleUnselectedIcon forState:UIControlStateNormal];
    [self.femaleBox setImage:femaleSelectedIcon forState:UIControlStateSelected];
    [self.femaleBox setTitleColor:kGenderFontColor forState:UIControlStateNormal];
    [self.femaleBox setTitleColor:kNameFontColor forState:UIControlStateSelected];
    self.femaleBox.titleLabel.font = [UIFont systemFontOfSize:kBodyFontSize];
    [self.femaleBox setTitle:[AppContext getStringForKey:@"user_sex_girl" fileName:@"common"] forState:UIControlStateNormal];
    [self.femaleBox setSelected:NO];
    self.femaleBox.imageEdgeInsets = UIEdgeInsetsMake(-(kRegisterProfileGenderHeight / 2.f - self.femaleBox.titleLabel.height - self.femaleBox.titleLabel.top), (kRegisterProfileGenderWidth - self.femaleBox.imageView.width) / 2.f - 6.f, 0, 0);
    self.femaleBox.titleEdgeInsets = UIEdgeInsetsMake(kRegisterProfileGenderHeight - self.femaleBox.imageView.height - self.femaleBox.imageView.top, -self.femaleBox.imageView.width, 0, 0);
    [self.femaleBox addTarget:self action:@selector(onTapFemale) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.femaleBox];
    
    NSString *nextTitle = [AppContext getStringForKey:@"regist_next_btn" fileName:@"register"];
    if (self.nextBtn == nil)
    {
        self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    self.nextBtn.frame = CGRectMake(kLargeBtnXMargin, self.view.bottom - kLargeBtnHeight - kLargeBtnYMargin - kSafeAreaBottomY, self.view.width - kLargeBtnXMargin * 2, kLargeBtnHeight);
    [self.nextBtn setTitle:nextTitle forState:UIControlStateNormal];
    [self.nextBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:kNameFontSize]];
    [self.nextBtn setTitleColor:kCommonBtnTextColor forState:UIControlStateSelected];
    [self.nextBtn setTitleColor:kCommonBtnDisableTextColor forState:UIControlStateNormal];
    [self.nextBtn setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateSelected];
    [self.nextBtn setBackgroundImage:[UIImage imageWithColor:kLargeBtnDisableColor] forState:UIControlStateNormal];
    [self.nextBtn setSelected:NO];
    [self.nextBtn.layer setMasksToBounds:YES];
    [self.nextBtn.layer setCornerRadius:kLargeBtnRadius];
    [self.nextBtn addTarget:self action:@selector(onNext) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextBtn];
}

#pragma mark WLTextFieldDelegate methods
- (BOOL)textField:(WLTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.nickField)
    {
        NSString *nickName = [textField.textField.text stringByReplacingCharactersInRange:range withString:string];
        self.nickName = [nickName copy];
        [self postNickNameChecking:self.nickName];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(WLTextField *)textField
{
    if (textField == self.nickField)
    {
        self.nickName = nil;
        [self postNickNameChecking:self.nickName];
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

#pragma mark WLHeadViewDelegate methods
- (void)onClick:(WLHeadView *)headView
{
    if (headView == self.head)
    {
        WLAssetsViewController *vc = [[WLAssetsViewController alloc] initWithSelectionMode:WLAssetsSelectionMode_Single];
        vc.delegate = self;
        [[AppContext rootViewController] pushViewController:vc animated:YES];
    }
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

#pragma mark WLUploadManagerDelegate methods
- (void)onUploadingKey:(NSString *)objectKey completed:(NSString *)url
{
    if ([self.uploadKey isEqualToString:objectKey])
    {
        self.uploadKey = nil;
        self.headUrl = url;
        [self.head setHeadUrl:url];
    }
}

- (void)onUploadingKey:(NSString *)objectKey failed:(NSInteger)errCode
{
    if ([self.uploadKey isEqualToString:objectKey])
    {
        self.uploadKey = nil;
        [self showToastWithNetworkErr:ERROR_NETWORK_UPLOAD_FAILED];
    }
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
        }
        else
        {
            [self showToastWithNetworkErr:ERROR_NETWORK_UPLOAD_FAILED];
        }
    }
}

#pragma mark WLRegisterProfileViewController private methods
- (void)onKeyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    CGFloat height = keyboardRect.size.height;
    self.nextBtn.bottom = self.view.height - height - kLargeBtnYMargin;
    
    if (self.maleBoxBottomAnchor == 0)
    {
        self.maleBoxBottomAnchor = self.maleBox.bottom;
    }
    if (self.maleBoxAnchor == 0)
    {
        self.maleBoxAnchor = self.maleBox.top;
    }
    if (self.femaleBoxAnchor == 0)
    {
        self.femaleBoxAnchor = self.femaleBox.top;
    }
    if (self.headAnchor == 0)
    {
        self.headAnchor = self.head.top;
    }
    if (self.nickNoteAnchor == 0)
    {
        self.nickNoteAnchor = self.nickNote.top;
    }
    if (self.nickFieldAnchor == 0)
    {
        self.nickFieldAnchor = self.nickField.top;
    }
    if (self.errorNoteAnchor == 0)
    {
        self.errorNoteAnchor = self.errorNote.top;
    }
    
    CGFloat y1 = self.view.height - height - kLargeBtnYMargin;
    CGFloat y2 = self.maleBoxBottomAnchor + kLargeBtnYMargin;
    if (y1 < y2)
    {
        self.offsetY = self.maleBoxAnchor - (y1 - self.maleBox.height - kLargeBtnYMargin);
        self.head.top = self.headAnchor - self.offsetY;
        self.nickNote.top = self.nickNoteAnchor - self.offsetY;
        self.nickField.top = self.nickFieldAnchor - self.offsetY;
        self.errorNote.top = self.errorNoteAnchor - self.offsetY;
        self.maleBox.top = self.maleBoxAnchor - self.offsetY;
        self.femaleBox.top = self.femaleBoxAnchor - self.offsetY;
    }
}

- (void)onKeyboardWillHide:(NSNotification *)notification
{
    self.nextBtn.bottom = self.view.bottom - kLargeBtnYMargin - kSafeAreaBottomY;
    if (self.offsetY > 0)
    {
        self.head.top = self.headAnchor;
        self.nickNote.top = self.nickNoteAnchor;
        self.nickField.top = self.nickFieldAnchor;
        self.errorNote.top = self.errorNoteAnchor;
        self.maleBox.top = self.maleBoxAnchor;
        self.femaleBox.top = self.femaleBoxAnchor;
        self.offsetY = 0;
    }
    self.maleBoxBottomAnchor = 0;
    self.maleBoxAnchor = 0;
    self.femaleBoxAnchor = 0;
    self.headAnchor = 0;
    self.nickNoteAnchor = 0;
    self.nickFieldAnchor = 0;
    self.errorNoteAnchor = 0;
}

- (void)onTapMale
{
    self.maleBox.selected = YES;
    self.femaleBox.selected = NO;
    self.gender = WELIKE_USER_GENDER_MALE;
    if (self.nickField.errorState == YES)
    {
        [self.nextBtn setSelected:NO];
    }
    else
    {
        if ([self.nickField.textField.text length] > 0)
        {
            [self.nextBtn setSelected:YES];
        }
        else
        {
            [self.nextBtn setSelected:NO];
        }
    }
}

- (void)onTapFemale
{
    self.femaleBox.selected = YES;
    self.maleBox.selected = NO;
    self.gender = WELIKE_USER_GENDER_FEMALE;
    if (self.nickField.errorState == YES)
    {
        [self.nextBtn setSelected:NO];
    }
    else
    {
        if ([self.nickField.textField.text length] > 0)
        {
            [self.nextBtn setSelected:YES];
        }
        else
        {
            [self.nextBtn setSelected:NO];
        }
    }
}

- (void)onNext
{
    if (self.nextBtn.selected == YES)
    {
        [AppContext getInstance].startHandler.headUrl = self.headUrl;
        [AppContext getInstance].startHandler.nickName = self.nickName;
        [AppContext getInstance].startHandler.gender = self.gender;
        [[AppContext getInstance].startHandler next:WELIKE_STARTUP_STATE_REGISTER_TRY_USERINFO];
        [self showLoading];
        
        _endTime = CACurrentMediaTime();
        CFTimeInterval duration = (_endTime - _beginTime) * 1000;
        [WLTrackerLogin appendInfoViewNext:[[AppContext getInstance].startHandler nickName]
                            nameCheckCount:_nameCheckCount
                                  phoneNum:[[AppContext getInstance].startHandler mobile]
                                  codeType:WLTrackerLoginVerifyCodeType_SMS
                                  duration:duration];
    }
    else if (self.gender == WELIKE_USER_GENDER_UNKNOWN)
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        shake.fromValue = [NSNumber numberWithFloat:-6.f];
        shake.toValue = [NSNumber numberWithFloat:6.f];
        shake.duration = 0.05;
        shake.autoreverses = YES;
        shake.repeatCount = 2;
        [self.maleBox.layer addAnimation:shake forKey:@"shakeAnimation"];
        [self.femaleBox.layer addAnimation:shake forKey:@"shakeAnimation"];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.nickField.textField resignFirstResponder];
}

- (void)postNickNameChecking:(NSString *)nickName
{
    _nameCheckCount++;
    
    self.nickField.showLoading = YES;
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
        if (self.gender != WELIKE_USER_GENDER_UNKNOWN)
        {
            [self.nextBtn setSelected:YES];
        }
    }
    else
    {
        self.nickField.showOK = NO;
        self.nickField.errorState = YES;
        self.errorNote.text = [WLErrorHelper getErrCodeTextForErrCode:errCode];
        [self.nextBtn setSelected:NO];
    }
}

@end
