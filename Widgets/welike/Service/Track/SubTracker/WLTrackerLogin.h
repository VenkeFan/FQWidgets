//
//  WLTrackerLogin.h
//  welike
//
//  Created by fan qi on 2018/11/14.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLAccount;

typedef NS_ENUM(NSInteger, WLTrackerLoginAction) {
    WLTrackerLoginAction_LoginView_Appear               = 1,
    WLTrackerLoginAction_LoginView_BtnClicked           = 2,
    WLTrackerLoginAction_LoginView_SNS_Callback         = 3,
    
    WLTrackerLoginAction_PhoneView_Appear               = 5,
    WLTrackerLoginAction_PhoneView_Next                 = 6,
    
    WLTrackerLoginAction_CodeView_Appear                = 9,
    WLTrackerLoginAction_CodeView_Resend                = 12,
    WLTrackerLoginAction_CodeView_Change                = 13,
    WLTrackerLoginAction_CodeView_Verify                = 14,
    
    WLTrackerLoginAction_InfoView_Appear                = 15,
    WLTrackerLoginAction_InfoView_Skip                  = 16,
    WLTrackerLoginAction_InfoView_Next                  = 17,
    
    WLTrackerLoginAction_Login_Succeed                  = 18,
    WLTrackerLoginAction_Register_Succeed               = 19,
    
    WLTrackerLoginAction_NameView_Appear                = 20,
    WLTrackerLoginAction_NameView_TextField             = 21,
    WLTrackerLoginAction_NameView_Next                  = 22,
    
    WLTrackerLoginAction_FakeLoginView_Appear           = 23,
    WLTrackerLoginAction_RelateAccount_Appear           = 24,
    WLTrackerLoginAction_Relate_Succeed                 = 25
};

typedef NS_ENUM(NSInteger, WLTrackerLoginType) {
    WLTrackerLoginType_Mobile       = 1,
    WLTrackerLoginType_Facebook     = 2,
    WLTrackerLoginType_Google       = 3,
    WLTrackerLoginType_Truecaller   = 4
};

typedef NS_ENUM(NSInteger, WLTrackerLoginResult) {
    WLTrackerLoginResult_Invalid    = -1,
    WLTrackerLoginResult_Failed     = 0,
    WLTrackerLoginResult_Succeed    = 1,
    WLTrackerLoginResult_Cancel     = 2
};

typedef NS_ENUM(NSInteger, WLTrackerLoginUserType) {
    WLTrackerLoginUserType_Invalid      = -1,
    WLTrackerLoginUserType_New          = 0,
    WLTrackerLoginUserType_Old          = 1
};

typedef NS_ENUM(NSInteger, WLTrackerLoginVerifyCodeType) {
    WLTrackerLoginVerifyCodeType_SMS    = 0,
    WLTrackerLoginVerifyCodeType_Voice  = 1
};

typedef NS_ENUM(NSInteger, WLTrackerLoginPageSource) {
    WLTrackerLoginPageSource_LoginBtn       = 1,
    WLTrackerLoginPageSource_Logout         = 2,
    WLTrackerLoginPageSource_Force          = 3,
    WLTrackerLoginPageSource_AddFriend      = 4,
    WLTrackerLoginPageSource_Follow         = 5,
    WLTrackerLoginPageSource_Repost         = 6,
    WLTrackerLoginPageSource_Like           = 7,
    WLTrackerLoginPageSource_Comment        = 8,
    WLTrackerLoginPageSource_Publish        = 9,
    WLTrackerLoginPageSource_IM             = 10,
    WLTrackerLoginPageSource_Profile_Chat   = 11,
    WLTrackerLoginPageSource_Other          = 12
};

typedef NS_ENUM(NSInteger, WLTrackerLoginCodeViewType) {
    WLTrackerLoginCodeViewType_SMS        = 0,
    WLTrackerLoginCodeViewType_Voice      = 1
};

typedef NS_ENUM(NSInteger, WLTrackerLoginPhoneInputType) {
    WLTrackerLoginPhoneInputType_Manual     = 1,
    WLTrackerLoginPhoneInputType_History    = 2
};

typedef NS_ENUM(NSInteger, WLTrackerLoginCodeRequestType) {
    WLTrackerLoginVerifyRequestType_Auto    = 1,
    WLTrackerLoginVerifyRequestType_Resend  = 2
};

typedef NS_ENUM(NSInteger, WLTrackerLoginSNSSource) {
    WLTrackerLoginSNSSource_Main        = 1,
    WLTrackerLoginSNSSource_PhoneNum    = 2,
    WLTrackerLoginSNSSource_Verify      = 3
};

typedef NS_ENUM(NSInteger, WLTrackerLoginSNSVerifyType) {
    WLTrackerLoginSNSVerifyType_Relate      = 1,
    WLTrackerLoginSNSVerifyType_Login       = 2,
    WLTrackerLoginSNSVerifyType_FakeLogin   = 3
};

typedef NS_ENUM(NSInteger, WLTrackerLoginAccountStatus) {
    WLTrackerLoginAccountStatus_Unlogin     = 1,
    WLTrackerLoginAccountStatus_UnVerify    = 2,
    WLTrackerLoginAccountStatus_Login       = 3
};

typedef NS_ENUM(NSInteger, WLTrackerLoginPageType) {
    WLTrackerLoginPageType_FullScreen       = 1,
    WLTrackerLoginPageType_PopUp            = 2
};

typedef NS_ENUM(NSInteger, WLTrackerLoginRelateAccountType) {
    WLTrackerLoginRelateAccountType_LoginBtn    = 0,
    WLTrackerLoginRelateAccountType_HalfScreen  = 1,
    WLTrackerLoginRelateAccountType_UserDetail  = 2
};

NS_ASSUME_NONNULL_BEGIN

@interface WLTrackerLogin : NSObject

/**
 login页面展示
 */
+ (void)appendLoginViewAppear:(WLTrackerLoginSNSVerifyType)snsVerifyType
                loginPageType:(WLTrackerLoginPageType)loginPageType;

/**
 登录方式按钮的点击
 */
+ (void)appendLoginBtnClicked:(WLTrackerLoginType)loginType
                snsVerifyType:(WLTrackerLoginSNSVerifyType)snsVerifyType
                loginPageType:(WLTrackerLoginPageType)loginPageType
            relateAccountType:(WLTrackerLoginRelateAccountType)relateAccountType;

/**
 第三方登录回调
 */
+ (void)appendSNSLoginCallback:(WLTrackerLoginType)loginType
                      userType:(WLTrackerLoginUserType)userType
                        result:(WLTrackerLoginResult)result;

/**
 手机号输入页面展示
 */
+ (void)appendLoginPhoneViewAppear:(WLTrackerLoginPageType)loginPageType
                     snsVerifyType:(WLTrackerLoginSNSVerifyType)snsVerifyType;

/**
 下一步按钮的点击
 */
+ (void)appendLoginPhoneViewNext:(NSString *)phoneNum
                        userType:(WLTrackerLoginUserType)userType;

/**
 验证码页面的展示
 */
+ (void)appendLoginCodeViewAppear:(WLTrackerLoginCodeViewType)viewType
                      requestType:(WLTrackerLoginCodeRequestType)requestType
                         codeType:(WLTrackerLoginVerifyCodeType)codeType
                         userType:(WLTrackerLoginUserType)userType;

/**
 resend按钮点击
 */
+ (void)appendCodeResend:(NSString *)phoneNum
                viewType:(WLTrackerLoginCodeViewType)viewType
             requestType:(WLTrackerLoginCodeRequestType)requestType
                codeType:(WLTrackerLoginVerifyCodeType)codeType
                userType:(WLTrackerLoginUserType)userType;

/**
 change按钮点击
 */
+ (void)appendCodeChange:(NSString *)phoneNum
                viewType:(WLTrackerLoginCodeViewType)viewType
                userType:(WLTrackerLoginUserType)userType;

/**
 输入完验证码提交服务端验证
 */
+ (void)appendVerifyCode:(NSString *)phoneNum
              checkCount:(NSInteger)checkCount
                userType:(WLTrackerLoginUserType)userType
                codeType:(WLTrackerLoginVerifyCodeType)codeType
                viewType:(WLTrackerLoginCodeViewType)viewType
                duration:(CFTimeInterval)duration;

/**
 填写个人资料页面展示
 */
+ (void)appendInfoViewAppear:(NSString *)phoneNum
                    codeType:(WLTrackerLoginVerifyCodeType)codeType
                    duration:(CFTimeInterval)duration;

/**
 skip
 */
+ (void)appendInfoViewSkip:(NSString *)phoneNum
                  codeType:(WLTrackerLoginVerifyCodeType)codeType;

/**
 资料填写完成点击下一步
 */
+ (void)appendInfoViewNext:(NSString *)nickName
            nameCheckCount:(NSInteger)nameCheckCount
                  phoneNum:(NSString *)phoneNum
                  codeType:(WLTrackerLoginVerifyCodeType)codeType
                  duration:(CFTimeInterval)duration;

/**
 登录成功
 */
+ (void)appendLoginResultWithLoginType:(WLTrackerLoginType)type
                                result:(WLTrackerLoginResult)result
                                mobile:(nullable NSString *)mobile;

/**
 注册完成
 */
+ (void)appendRegisterSucceed;

#pragma mark - FakeLogin
/**
 填写名字页面展示
 */
+ (void)appendNameViewAppear;

/**
 点击名字输入框
 */
+ (void)appendNameTextField;

/**
 点击进入下一步
 */
+ (void)appendNameNext:(NSString *)nickName
              userType:(WLTrackerLoginUserType)userType;

#pragma mark - Property

@property (class, nonatomic, assign) WLTrackerLoginType loginType;
@property (class, nonatomic, copy) NSString *phone;
@property (class, nonatomic, assign) NSInteger codeSendCount;
@property (class, nonatomic, assign) NSInteger codeCheckCount;
@property (class, nonatomic, copy) NSString *nickName;
@property (class, nonatomic, assign) NSInteger nameCheckCount;
@property (class, nonatomic, assign) WLTrackerLoginVerifyCodeType codeType;
@property (class, nonatomic, assign) WLTrackerLoginPageSource pageSource;
@property (class, nonatomic, assign) WLTrackerLoginCodeViewType codeViewType;
@property (class, nonatomic, assign) WLTrackerLoginPhoneInputType inputType;
@property (class, nonatomic, assign) WLTrackerLoginCodeRequestType codeRequestType;
@property (class, nonatomic, assign) WLTrackerLoginSNSVerifyType snsVerifyType;
@property (class, nonatomic, assign) WLTrackerLoginPageType pageType;
@property (class, nonatomic, assign) WLTrackerLoginRelateAccountType relateAccountType;

@end

NS_ASSUME_NONNULL_END
