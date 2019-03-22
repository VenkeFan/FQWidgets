//
//  WLModifyIntroViewController.m
//  welike
//
//  Created by 刘斌 on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLModifyIntroViewController.h"
#import "WLAccountManager.h"
#import "WLTrackerEditProfile.h"

#define kLeftMargin                     12.f
#define kTextTopMargin                  11.f
#define kTextAreaHeight                 179.f
#define kNumHeight                      16.f
#define kNumTop                         16.f
#define kNumWidth                       60.f

@interface WLModifyIntroViewController ()

@property (nonatomic, strong) UITextView *introView;
@property (nonatomic, strong) UILabel *numView;
@property (nonatomic, strong) UIButton *saveBtn;

@end

@implementation WLModifyIntroViewController

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
}

- (void)loadView
{
    [super loadView];
    
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    
    self.navigationBar.title = [AppContext getStringForKey:@"mine_user_host_brief_title" fileName:@"user"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.introView = [[UITextView alloc] initWithFrame:CGRectMake(kLeftMargin, kNavBarHeight + kTextTopMargin, self.view.width - kLeftMargin * 2.f, kTextAreaHeight - kTextTopMargin)];
    self.introView.backgroundColor = [UIColor clearColor];
    self.introView.tintColor = kMainColor;
    self.introView.textColor = kPublishEditColor;
    self.introView.font = [UIFont systemFontOfSize:kMediumNameFontSize];
    self.introView.scrollEnabled = YES;
    self.introView.text = account.introduction;
    [self.view addSubview:self.introView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChangeText:) name:UITextViewTextDidChangeNotification object:self.introView];
    
    self.numView = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width - kLeftMargin - kNumWidth, self.introView.bottom + kNumTop, kNumWidth, kNumHeight)];
    self.numView.textColor = kLightLightFontColor;
    self.numView.font = [UIFont systemFontOfSize:kMediumNameFontSize];
    self.numView.textAlignment = NSTextAlignmentRight;
    NSInteger c = INTRO_MAX_NUM - [account.introduction length];
    if (c < 0) c = 0;
    self.numView.text = [NSString stringWithFormat:@"%ld", (long)c];
    [self.view addSubview:self.numView];
    
    self.saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveBtn.frame = CGRectMake(kLargeBtnXMargin, self.view.bottom - kLargeBtnHeight - kLargeBtnYMargin, self.view.width - kLargeBtnXMargin * 2, kLargeBtnHeight);
    [self.saveBtn setTitle:[AppContext getStringForKey:@"mine_user_host_personal_edit_name_save" fileName:@"user"] forState:UIControlStateNormal];
    [self.saveBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:kNameFontSize]];
    [self.saveBtn setTitleColor:kCommonBtnTextColor forState:UIControlStateNormal];
    [self.saveBtn setTitleColor:kCommonBtnDisableTextColor forState:UIControlStateDisabled];
    [self.saveBtn setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
    [self.saveBtn setBackgroundImage:[UIImage imageWithColor:kMainPressColor] forState:UIControlStateHighlighted];
    [self.saveBtn setBackgroundImage:[UIImage imageWithColor:kLargeBtnDisableColor] forState:UIControlStateDisabled];
    [self.saveBtn.layer setMasksToBounds:YES];
    [self.saveBtn.layer setCornerRadius:kLargeBtnRadius];
    [self.saveBtn addTarget:self action:@selector(onSave) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveBtn];
}

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
    NSString *content = @"";
    if ([self.introView.text length] > 0)
    {
        content = [WLAccount formatIntro:self.introView.text];
    }
    [[AppContext getInstance].accountManager syncAccountIntro:content successed:^{
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
    [self.introView resignFirstResponder];
}

- (void)textViewDidChangeText:(NSNotification *)notification
{
    UITextView *textView = (UITextView *)notification.object;
    if (textView != self.introView) return;
    
    NSString *toBeString = textView.text;
    if (toBeString.length > INTRO_MAX_NUM)
    {
        textView.text = [toBeString substringToIndex:INTRO_MAX_NUM];
    }
    
    NSInteger c = INTRO_MAX_NUM - [textView.text length];
    if (c < 0) c = 0;
    self.numView.text = [NSString stringWithFormat:@"%ld", (long)c];
}

@end
