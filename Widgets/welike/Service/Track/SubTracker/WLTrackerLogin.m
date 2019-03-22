//
//  WLTrackerLogin.m
//  welike
//
//  Created by fan qi on 2018/11/14.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLTrackerLogin.h"
#import "WLTracker.h"
#import "WLAccountManager.h"
#import "RDLocalizationManager.h"

#define kWLTrackerLoginEventIDKey                   @"5001014"

#define kWLTrackerLoginActionKey                    @"action"
#define kWLTrackerLoginPageSource                   @"page_source"
#define kWLTrackerLoginLanguageKey                  @"language"
#define kWLTrackerLoginSNSVerifyTypeKey             @"login_verify_type"
#define kWLTrackerLoginAccountStatusKey             @"account_status"
#define kWLTrackerLoginPageTypeKey                  @"page_type"
#define kWLTrackerLoginTypeKey                      @"login_source"
#define kWLTrackerLoginRelateAccountKey             @"verify_source"
#define kWLTrackerLoginUserTypeKey                  @"isNewUser"
#define kWLTrackerLoginResultKey                    @"return_result"
#define kWLTrackerLoginInputTypeKey                 @"input_way"
#define kWLTrackerLoginPhoneKey                     @"phone_number"
#define kWLTrackerLoginCodeViewType                 @"page_status"
#define kWLTrackerLoginCodeRequestType              @"request_way"
#define kWLTrackerLoginCodeType                     @"verify_type"
#define kWLTrackerLoginCodeSendCountType            @"SMS_send"
#define kWLTrackerLoginCodeCheckCountType           @"SMS_check"
#define kWLTrackerLoginViewDurationType             @"stay_time"
#define kWLTrackerLoginNickNameKey                  @"nickname"
#define kWLTrackerLoginNickNameCheckCountKey        @"nickname_check"
#define kWLTrackerLoginSNSSourceKey                 @"from_page"

static NSString *_phone;
static NSInteger _codeSendCount;
static NSInteger _codeCheckCount;
static NSString *_nickName;
static NSInteger _nameCheckCount;
static WLTrackerLoginType _loginType = WLTrackerLoginType_Mobile;
static WLTrackerLoginVerifyCodeType _codeType = WLTrackerLoginVerifyCodeType_SMS;
static WLTrackerLoginPageSource _pageSource = WLTrackerLoginPageSource_LoginBtn;
static WLTrackerLoginCodeViewType _codeViewType = WLTrackerLoginCodeViewType_SMS;
static WLTrackerLoginPhoneInputType _inputType = WLTrackerLoginPhoneInputType_Manual;
static WLTrackerLoginCodeRequestType _codeRequestType = WLTrackerLoginVerifyRequestType_Auto;
static WLTrackerLoginSNSVerifyType _snsVerifyType = WLTrackerLoginSNSVerifyType_Login;
static WLTrackerLoginPageType _pageType = WLTrackerLoginPageType_FullScreen;
static WLTrackerLoginRelateAccountType _relateAccountType = WLTrackerLoginRelateAccountType_LoginBtn;

@implementation WLTrackerLogin

+ (void)appendLoginViewAppear:(WLTrackerLoginSNSVerifyType)snsVerifyType
                loginPageType:(WLTrackerLoginPageType)loginPageType {
    [self setSnsVerifyType:snsVerifyType];
    [self setPageType:loginPageType];
    
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerLoginAction_LoginView_Appear) forKey:kWLTrackerLoginActionKey];
    
    [eventInfo setObject:@([self pageSource]) forKey:kWLTrackerLoginPageSource];
    [eventInfo setObject:@(snsVerifyType) forKey:kWLTrackerLoginSNSVerifyTypeKey];
    [eventInfo setObject:@([self accountStatus]) forKey:kWLTrackerLoginAccountStatusKey];
    [eventInfo setObject:@(loginPageType) forKey:kWLTrackerLoginPageTypeKey];
    
    NSString *language = [[RDLocalizationManager getInstance] getCurrentLanguage];
    if (language.length > 0) {
        [eventInfo setObject:language forKey:kWLTrackerLoginLanguageKey];
    }
    
    [[WLTracker getInstance] appendEventId:kWLTrackerLoginEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendLoginBtnClicked:(WLTrackerLoginType)loginType
                snsVerifyType:(WLTrackerLoginSNSVerifyType)snsVerifyType
                loginPageType:(WLTrackerLoginPageType)loginPageType
            relateAccountType:(WLTrackerLoginRelateAccountType)relateAccountType {
    [self setLoginType:loginType];
    [self setSnsVerifyType:snsVerifyType];
    [self setPageType:loginPageType];
    [self setRelateAccountType:relateAccountType];
    
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerLoginAction_LoginView_BtnClicked) forKey:kWLTrackerLoginActionKey];
    
    [eventInfo setObject:@(loginType) forKey:kWLTrackerLoginTypeKey];
    [eventInfo setObject:@(snsVerifyType) forKey:kWLTrackerLoginSNSVerifyTypeKey];
    [eventInfo setObject:@(loginPageType) forKey:kWLTrackerLoginPageTypeKey];
    [eventInfo setObject:@(relateAccountType) forKey:kWLTrackerLoginRelateAccountKey];
    
    [[WLTracker getInstance] appendEventId:kWLTrackerLoginEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendSNSLoginCallback:(WLTrackerLoginType)loginType
                      userType:(WLTrackerLoginUserType)userType
                        result:(WLTrackerLoginResult)result {
    [self setLoginType:loginType];
    
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerLoginAction_LoginView_SNS_Callback) forKey:kWLTrackerLoginActionKey];
    
    [eventInfo setObject:@(loginType) forKey:kWLTrackerLoginTypeKey];
    [eventInfo setObject:@(userType) forKey:kWLTrackerLoginUserTypeKey];
    [eventInfo setObject:@(result) forKey:kWLTrackerLoginResultKey];
    
    [[WLTracker getInstance] appendEventId:kWLTrackerLoginEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendLoginPhoneViewAppear:(WLTrackerLoginPageType)loginPageType
                     snsVerifyType:(WLTrackerLoginSNSVerifyType)snsVerifyType {
    [self setPageType:loginPageType];
    [self setSnsVerifyType:snsVerifyType];
    
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerLoginAction_PhoneView_Appear) forKey:kWLTrackerLoginActionKey];
    
    [eventInfo setObject:@([self pageSource]) forKey:kWLTrackerLoginPageSource];
    [eventInfo setObject:@(loginPageType) forKey:kWLTrackerLoginPageTypeKey];
    [eventInfo setObject:@(snsVerifyType) forKey:kWLTrackerLoginSNSVerifyTypeKey];
    [eventInfo setObject:@([self accountStatus]) forKey:kWLTrackerLoginAccountStatusKey];
    
    [[WLTracker getInstance] appendEventId:kWLTrackerLoginEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendLoginPhoneViewNext:(NSString *)phoneNum
                        userType:(WLTrackerLoginUserType)userType {
    [self setPhone:phoneNum];
    
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerLoginAction_PhoneView_Next) forKey:kWLTrackerLoginActionKey];
    
    if (phoneNum.length > 0) {
        [eventInfo setObject:phoneNum forKey:kWLTrackerLoginPhoneKey];
    }
    [eventInfo setObject:@([self inputType]) forKey:kWLTrackerLoginInputTypeKey];
    [eventInfo setObject:@([self pageSource]) forKey:kWLTrackerLoginPageSource];
    [eventInfo setObject:@(userType) forKey:kWLTrackerLoginUserTypeKey];
    
    [[WLTracker getInstance] appendEventId:kWLTrackerLoginEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendLoginCodeViewAppear:(WLTrackerLoginCodeViewType)viewType
                      requestType:(WLTrackerLoginCodeRequestType)requestType
                         codeType:(WLTrackerLoginVerifyCodeType)codeType
                         userType:(WLTrackerLoginUserType)userType {
    [self setCodeViewType:viewType];
    [self setCodeRequestType:requestType];
    [self setCodeType:codeType];
    
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerLoginAction_CodeView_Appear) forKey:kWLTrackerLoginActionKey];
    
    [eventInfo setObject:@([self pageSource]) forKey:kWLTrackerLoginPageSource];
    [eventInfo setObject:@(viewType) forKey:kWLTrackerLoginCodeViewType];
    [eventInfo setObject:@(requestType) forKey:kWLTrackerLoginCodeRequestType];
    [eventInfo setObject:@(codeType) forKey:kWLTrackerLoginCodeType];
    [eventInfo setObject:@(userType) forKey:kWLTrackerLoginUserTypeKey];
    
    [[WLTracker getInstance] appendEventId:kWLTrackerLoginEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendCodeResend:(NSString *)phoneNum
                viewType:(WLTrackerLoginCodeViewType)viewType
             requestType:(WLTrackerLoginCodeRequestType)requestType
                codeType:(WLTrackerLoginVerifyCodeType)codeType
                userType:(WLTrackerLoginUserType)userType {
    [self setPhone:phoneNum];
    [self setCodeViewType:viewType];
    [self setCodeRequestType:requestType];
    [self setCodeType:codeType];
    
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerLoginAction_CodeView_Resend) forKey:kWLTrackerLoginActionKey];
    
    if (phoneNum.length > 0) {
        [eventInfo setObject:phoneNum forKey:kWLTrackerLoginPhoneKey];
    }
    [eventInfo setObject:@([self codeSendCount]) forKey:kWLTrackerLoginCodeSendCountType];
    [eventInfo setObject:@(viewType) forKey:kWLTrackerLoginCodeViewType];
    [eventInfo setObject:@(requestType) forKey:kWLTrackerLoginCodeRequestType];
    [eventInfo setObject:@(codeType) forKey:kWLTrackerLoginCodeType];
    [eventInfo setObject:@(userType) forKey:kWLTrackerLoginUserTypeKey];
    
    [[WLTracker getInstance] appendEventId:kWLTrackerLoginEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendCodeChange:(NSString *)phoneNum
                viewType:(WLTrackerLoginCodeViewType)viewType
                userType:(WLTrackerLoginUserType)userType {
    [self setPhone:phoneNum];
    [self setCodeViewType:viewType];
    
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerLoginAction_CodeView_Change) forKey:kWLTrackerLoginActionKey];
    
    if (phoneNum.length > 0) {
        [eventInfo setObject:phoneNum forKey:kWLTrackerLoginPhoneKey];
    }
    [eventInfo setObject:@([self codeSendCount]) forKey:kWLTrackerLoginCodeSendCountType];
    [eventInfo setObject:@(viewType) forKey:kWLTrackerLoginCodeViewType];
    [eventInfo setObject:@(userType) forKey:kWLTrackerLoginUserTypeKey];
    [eventInfo setObject:@([self inputType]) forKey:kWLTrackerLoginInputTypeKey];
    
    [[WLTracker getInstance] appendEventId:kWLTrackerLoginEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendVerifyCode:(NSString *)phoneNum
              checkCount:(NSInteger)checkCount
                userType:(WLTrackerLoginUserType)userType
                codeType:(WLTrackerLoginVerifyCodeType)codeType
                viewType:(WLTrackerLoginCodeViewType)viewType
                duration:(CFTimeInterval)duration {
    [self setPhone:phoneNum];
    [self setCodeCheckCount:checkCount];
    [self setCodeType:codeType];
    [self setCodeViewType:viewType];
    
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerLoginAction_CodeView_Verify) forKey:kWLTrackerLoginActionKey];
    
    if (phoneNum.length > 0) {
        [eventInfo setObject:phoneNum forKey:kWLTrackerLoginPhoneKey];
    }
    [eventInfo setObject:@([self codeSendCount]) forKey:kWLTrackerLoginCodeSendCountType];
    [eventInfo setObject:@(checkCount) forKey:kWLTrackerLoginCodeCheckCountType];
    [eventInfo setObject:@(userType) forKey:kWLTrackerLoginUserTypeKey];
    [eventInfo setObject:@(codeType) forKey:kWLTrackerLoginCodeType];
    [eventInfo setObject:@(viewType) forKey:kWLTrackerLoginCodeViewType];
    [eventInfo setObject:@([self pageSource]) forKey:kWLTrackerLoginPageSource];
    [eventInfo setObject:@(duration) forKey:kWLTrackerLoginViewDurationType];
    
    [[WLTracker getInstance] appendEventId:kWLTrackerLoginEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendInfoViewAppear:(NSString *)phoneNum
                    codeType:(WLTrackerLoginVerifyCodeType)codeType
                    duration:(CFTimeInterval)duration {
    [self setPhone:phoneNum];
    [self setCodeType:codeType];
    
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerLoginAction_InfoView_Appear) forKey:kWLTrackerLoginActionKey];
    
    if (phoneNum.length > 0) {
        [eventInfo setObject:phoneNum forKey:kWLTrackerLoginPhoneKey];
    }
    [eventInfo setObject:@([self codeSendCount]) forKey:kWLTrackerLoginCodeSendCountType];
    [eventInfo setObject:@(codeType) forKey:kWLTrackerLoginCodeType];
    [eventInfo setObject:@([self pageSource]) forKey:kWLTrackerLoginPageSource];
    [eventInfo setObject:@(duration) forKey:kWLTrackerLoginViewDurationType];
    
    [[WLTracker getInstance] appendEventId:kWLTrackerLoginEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendInfoViewSkip:(NSString *)phoneNum
                  codeType:(WLTrackerLoginVerifyCodeType)codeType {
    [self setPhone:phoneNum];
    [self setCodeType:codeType];
    
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerLoginAction_InfoView_Skip) forKey:kWLTrackerLoginActionKey];
    
    if (phoneNum.length > 0) {
        [eventInfo setObject:phoneNum forKey:kWLTrackerLoginPhoneKey];
    }
    [eventInfo setObject:@([self codeSendCount]) forKey:kWLTrackerLoginCodeSendCountType];
    [eventInfo setObject:@(codeType) forKey:kWLTrackerLoginCodeType];
    [eventInfo setObject:@([self accountStatus]) forKey:kWLTrackerLoginAccountStatusKey];
    
    [[WLTracker getInstance] appendEventId:kWLTrackerLoginEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendInfoViewNext:(NSString *)nickName
            nameCheckCount:(NSInteger)nameCheckCount
                  phoneNum:(NSString *)phoneNum
                  codeType:(WLTrackerLoginVerifyCodeType)codeType
                  duration:(CFTimeInterval)duration {
    [self setNickName:nickName];
    [self setNameCheckCount:nameCheckCount];
    [self setPhone:phoneNum];
    [self setCodeType:codeType];
    
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerLoginAction_InfoView_Next) forKey:kWLTrackerLoginActionKey];
    
    if (nickName.length > 0) {
        [eventInfo setObject:nickName forKey:kWLTrackerLoginNickNameKey];
    }
    [eventInfo setObject:@(nameCheckCount) forKey:kWLTrackerLoginNickNameCheckCountKey];
    if (phoneNum.length > 0) {
        [eventInfo setObject:phoneNum forKey:kWLTrackerLoginPhoneKey];
    }
    [eventInfo setObject:@(codeType) forKey:kWLTrackerLoginCodeType];
    [eventInfo setObject:@([self codeSendCount]) forKey:kWLTrackerLoginCodeSendCountType];
    [eventInfo setObject:@(duration) forKey:kWLTrackerLoginViewDurationType];
    
    [[WLTracker getInstance] appendEventId:kWLTrackerLoginEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendLoginResultWithLoginType:(WLTrackerLoginType)type
                                result:(WLTrackerLoginResult)result
                                mobile:(nullable NSString *)mobile {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerLoginAction_Login_Succeed) forKey:kWLTrackerLoginActionKey];
    
    [eventInfo setObject:@(type) forKey:kWLTrackerLoginTypeKey];
    [eventInfo setObject:@(result) forKey:kWLTrackerLoginResultKey];
    [eventInfo setObject:@(WLTrackerLoginUserType_Old) forKey:kWLTrackerLoginUserTypeKey];
    
    NSString *language = [[RDLocalizationManager getInstance] getCurrentLanguage];
    if (language.length > 0) {
        [eventInfo setObject:language forKey:kWLTrackerLoginLanguageKey];
    }
    if (mobile) {
        [eventInfo setObject:mobile forKey:kWLTrackerLoginPhoneKey];
    }
    [eventInfo setObject:@([self codeSendCount]) forKey:kWLTrackerLoginCodeSendCountType];
    [eventInfo setObject:@([self codeCheckCount]) forKey:kWLTrackerLoginCodeCheckCountType];
    
    if ([self nickName]) {
        [eventInfo setObject:[self nickName] forKey:kWLTrackerLoginNickNameKey];
    }
    [eventInfo setObject:@([self nameCheckCount]) forKey:kWLTrackerLoginNickNameCheckCountKey];
    [eventInfo setObject:@([self codeType]) forKey:kWLTrackerLoginCodeType];
    [eventInfo setObject:@([self pageSource]) forKey:kWLTrackerLoginPageSource];
    [eventInfo setObject:@([self codeViewType]) forKey:kWLTrackerLoginCodeViewType];
    [eventInfo setObject:@([self inputType]) forKey:kWLTrackerLoginInputTypeKey];
    [eventInfo setObject:@([self codeRequestType]) forKey:kWLTrackerLoginCodeRequestType];
    [eventInfo setObject:@([self snsVerifyType]) forKey:kWLTrackerLoginSNSVerifyTypeKey];
    [eventInfo setObject:@([self accountStatus]) forKey:kWLTrackerLoginAccountStatusKey];
    [eventInfo setObject:@([self pageType]) forKey:kWLTrackerLoginPageTypeKey];
    [eventInfo setObject:@([self relateAccountType]) forKey:kWLTrackerLoginRelateAccountKey];
    
    [[WLTracker getInstance] appendEventId:kWLTrackerLoginEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendRegisterSucceed {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerLoginAction_Register_Succeed) forKey:kWLTrackerLoginActionKey];
    
    [eventInfo setObject:@([self loginType]) forKey:kWLTrackerLoginTypeKey];
    [eventInfo setObject:@(WLTrackerLoginResult_Succeed) forKey:kWLTrackerLoginResultKey];
    [eventInfo setObject:@(WLTrackerLoginUserType_New) forKey:kWLTrackerLoginUserTypeKey];
    
    NSString *language = [[RDLocalizationManager getInstance] getCurrentLanguage];
    if (language.length > 0) {
        [eventInfo setObject:language forKey:kWLTrackerLoginLanguageKey];
    }
    if ([self phone]) {
        [eventInfo setObject:[self phone] forKey:kWLTrackerLoginPhoneKey];
    }
    [eventInfo setObject:@([self codeSendCount]) forKey:kWLTrackerLoginCodeSendCountType];
    [eventInfo setObject:@([self codeCheckCount]) forKey:kWLTrackerLoginCodeCheckCountType];
    
    if ([self nickName]) {
        [eventInfo setObject:[self nickName] forKey:kWLTrackerLoginNickNameKey];
    }
    [eventInfo setObject:@([self nameCheckCount]) forKey:kWLTrackerLoginNickNameCheckCountKey];
    [eventInfo setObject:@([self codeType]) forKey:kWLTrackerLoginCodeType];
    [eventInfo setObject:@([self pageSource]) forKey:kWLTrackerLoginPageSource];
    [eventInfo setObject:@([self codeViewType]) forKey:kWLTrackerLoginCodeViewType];
    [eventInfo setObject:@([self inputType]) forKey:kWLTrackerLoginInputTypeKey];
    [eventInfo setObject:@([self codeRequestType]) forKey:kWLTrackerLoginCodeRequestType];
    [eventInfo setObject:@([self snsVerifyType]) forKey:kWLTrackerLoginSNSVerifyTypeKey];
    [eventInfo setObject:@([self accountStatus]) forKey:kWLTrackerLoginAccountStatusKey];
    [eventInfo setObject:@([self pageType]) forKey:kWLTrackerLoginPageTypeKey];
    [eventInfo setObject:@([self relateAccountType]) forKey:kWLTrackerLoginRelateAccountKey];
    
    [[WLTracker getInstance] appendEventId:kWLTrackerLoginEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendNameViewAppear {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerLoginAction_NameView_Appear) forKey:kWLTrackerLoginActionKey];
    
    [eventInfo setObject:@([self pageSource]) forKey:kWLTrackerLoginPageSource];
    
    [[WLTracker getInstance] appendEventId:kWLTrackerLoginEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendNameTextField {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerLoginAction_NameView_TextField) forKey:kWLTrackerLoginActionKey];
    
    [eventInfo setObject:@([self pageSource]) forKey:kWLTrackerLoginPageSource];
    
    [[WLTracker getInstance] appendEventId:kWLTrackerLoginEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

+ (void)appendNameNext:(NSString *)nickName
              userType:(WLTrackerLoginUserType)userType {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    [eventInfo setObject:@(WLTrackerLoginAction_NameView_Next) forKey:kWLTrackerLoginActionKey];
    
    if (nickName.length > 0) {
        [eventInfo setObject:nickName forKey:kWLTrackerLoginNickNameKey];
    }
    [eventInfo setObject:@([self pageSource]) forKey:kWLTrackerLoginPageSource];
    [eventInfo setObject:@(userType) forKey:kWLTrackerLoginUserTypeKey];
    
    [[WLTracker getInstance] appendEventId:kWLTrackerLoginEventIDKey
                                 eventInfo:eventInfo];
    [[WLTracker getInstance] synchronize];
}

#pragma mark - Private

+ (WLTrackerLoginAccountStatus)accountStatus {
    if ([AppContext getInstance].accountManager.myAccount) {
        if ([AppContext getInstance].accountManager.isLogin) {
            return WLTrackerLoginAccountStatus_Login;
        } else {
            return WLTrackerLoginAccountStatus_UnVerify;
        }
    } else {
        return WLTrackerLoginAccountStatus_Unlogin;
    }
}

#pragma mark - Getter & Setter

+ (void)setPhone:(NSString *)phone {
    _phone = [phone copy];
}

+ (NSString *)phone {
    return _phone;
}

+ (void)setCodeSendCount:(NSInteger)codeSendCount {
    _codeSendCount = codeSendCount;
}

+ (NSInteger)codeSendCount {
    return _codeSendCount;
}

+ (void)setCodeCheckCount:(NSInteger)codeCheckCount {
    _codeCheckCount = codeCheckCount;
}

+ (NSInteger)codeCheckCount {
    return _codeCheckCount;
}

+ (void)setNickName:(NSString *)nickName {
    _nickName = [nickName copy];
}

+ (NSString *)nickName {
    return _nickName;
}

+ (void)setNameCheckCount:(NSInteger)nameCheckCount {
    _nameCheckCount = nameCheckCount;
}

+ (NSInteger)nameCheckCount {
    return _nameCheckCount;
}

+ (void)setLoginType:(WLTrackerLoginType)loginType {
    _loginType = loginType;
}

+ (WLTrackerLoginType)loginType {
    return _loginType;
}

+ (void)setCodeType:(WLTrackerLoginVerifyCodeType)codeType {
    _codeType = codeType;
}

+ (WLTrackerLoginVerifyCodeType)codeType {
    return _codeType;
}

+ (void)setPageSource:(WLTrackerLoginPageSource)pageSource {
    _pageSource = pageSource;
}

+ (WLTrackerLoginPageSource)pageSource {
    return _pageSource;
}

+ (void)setCodeViewType:(WLTrackerLoginCodeViewType)codeViewType {
    _codeViewType = codeViewType;
}

+ (WLTrackerLoginCodeViewType)codeViewType {
    return _codeViewType;
}

+ (void)setInputType:(WLTrackerLoginPhoneInputType)inputType {
    _inputType = inputType;
}

+ (WLTrackerLoginPhoneInputType)inputType {
    return _inputType;
}

+ (void)setCodeRequestType:(WLTrackerLoginCodeRequestType)codeRequestType {
    _codeRequestType = codeRequestType;
}

+ (WLTrackerLoginCodeRequestType)codeRequestType {
    return _codeRequestType;
}

+ (void)setSnsVerifyType:(WLTrackerLoginSNSVerifyType)snsVerifyType {
    _snsVerifyType = snsVerifyType;
}

+ (WLTrackerLoginSNSVerifyType)snsVerifyType {
    return _snsVerifyType;
}

+ (void)setPageType:(WLTrackerLoginPageType)pageType {
    _pageType = pageType;
}

+ (WLTrackerLoginPageType)pageType {
    return _pageType;
}

+ (void)setRelateAccountType:(WLTrackerLoginRelateAccountType)relateAccountType {
    _relateAccountType = relateAccountType;
}

+ (WLTrackerLoginRelateAccountType)relateAccountType {
    return _relateAccountType;
}

@end
