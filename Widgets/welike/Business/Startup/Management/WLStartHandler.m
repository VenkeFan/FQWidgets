//
//  WLStartHandler.m
//  welike
//
//  Created by 刘斌 on 2018/4/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLStartHandler.h"
#import "WLSMSCodeRequest.h"
#import "WLLoginRequest.h"
#import "WLThirdLoginRequest.h"
#import "WLFollowUsersRequest.h"
#import "WLAuthRequest.h"
#import "RDLocalizationManager.h"
#import "RDRootViewController.h"
#import "WLMainViewController.h"
#import "WLRegisterSelectLanguageViewController.h"
#import "WLRegisterMobileViewController.h"
#import "WLRegisterSMSCodeViewController.h"
#import "WLRegisterProfileViewController.h"
#import "WLRegisterInterestsViewController.h"
#import "WLRegisterUserSugViewController.h"
#import "WLUnloginTabController.h"
#import "WLAccountManager.h"
#import "WLContactsManager.h"
#import "WLCommonDBManager.h"
#import "WLStorageDBManager.h"
#import "WLMessageManager.h"
#import "WLHistoryCache.h"
#import "WLUploadManager.h"
#import "WLDraftManager.h"
#import "WLPushSettingManager.h"
#import "WLRouter.h"
#import "WLTrackerLogin.h"
#import "WLStatusListRequest.h"

#define TOKEN_REFRESH_INTERVAL 3600 * 24

@interface WLStartHandler ()

@property (nonatomic, strong) WLSMSCodeRequest *smsCodeReq;
@property (nonatomic, strong) WLLoginRequest *loginReq;
@property (nonatomic, strong) WLThirdLoginRequest *thirdLoginReq;
@property (nonatomic, strong) WLFollowUsersRequest *followUsersReq;
@property (nonatomic, strong) WLAuthRequest *authRequest;
@property (nonatomic, assign) WELIKE_STARTUP_STATE state;
@property (nonatomic, strong) NSPointerArray *delegates;
@property (nonatomic, strong) WLStatusListRequest *statusListRequest;

- (void)accountTasksInitialized;
- (void)goNormalStart;
- (void)resumeRegister:(WELIKE_ACCOUNT_COMPLETE_LEVEL)level;
- (void)goSMSCodeVerify;
- (void)tryWelikeLogin;
- (void)tryFacebookLogin;
- (void)tryUpdateUserInfo;
- (void)tryInterests;
- (void)trySugUsers;
- (void)tryCompletedLevel:(WELIKE_ACCOUNT_COMPLETE_LEVEL)level state:(NSInteger)state;
- (void)tryMain;
- (void)routerUri;
- (void)doReauthWithRefreshToken:(NSString *)refreshToken;
- (void)attachDBWithUid:(NSString *)uid;
- (void)unattachDB;
- (void)broadcast;
- (void)broadcastFailed:(NSInteger)errCode;

@end

@implementation WLStartHandler

- (id)init
{
    self = [super init];
    if (self)
    {
        self.delegates = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

#pragma mark StartHandler public methods
- (void)registerWithDelegate:(id<WLStartHandlerDelegate>)delegate
{
    @synchronized (_delegates)
    {
        if ([_delegates containsObject:delegate] == NO)
        {
            [_delegates addObject:delegate];
        }
    }
}

- (void)unregister:(id<WLStartHandlerDelegate>)delegate
{
    @synchronized (_delegates)
    {
        [_delegates removeObject:delegate];
    }
}

- (void)start
{
    self.state = WELIKE_STARTUP_STATE_SPLASH;
    NSString *currentLanguage = [[RDLocalizationManager getInstance] getCurrentLanguage];
    if ([currentLanguage length] > 0)
    {
        [self goNormalStart];
    }
    else
    {
        [self next:WELIKE_STARTUP_STATE_LANG];
    }
}

- (void)next:(WELIKE_STARTUP_STATE)state
{
    switch (state)
    {
        case WELIKE_STARTUP_STATE_LANG:
        {
            self.state = WELIKE_STARTUP_STATE_LANG;
            [self broadcast];
            break;
        }
        case WELIKE_STARTUP_STATE_LANG_DONE:
        {
            [self goNormalStart];
            break;
        }
        case WELIKE_STARTUP_STATE_LOGIN_MOBILE:
        {
            self.mobile = nil;
            self.thirdToken = nil;
            self.nationCode = nil;
            self.smsCode = nil;
            self.nickName = nil;
            self.headUrl = nil;
            self.gender = WELIKE_USER_GENDER_UNKNOWN;
            self.state = WELIKE_STARTUP_STATE_LOGIN_MOBILE;
            [self broadcast];
            break;
        }
        case WELIKE_STARTUP_STATE_LOGIN_SMS_CODE:
        {
            [self goSMSCodeVerify];
            break;
        }
        case WELIKE_STARTUP_STATE_TRY_LOGIN:
        {
            [self tryWelikeLogin];
            break;
        }
        case WELIKE_STARTUP_STATE_TRY_FACEBOOK_LOGIN:
        {
            [self tryFacebookLogin];
            break;
        }
        case WELIKE_STARTUP_STATE_TRY_GOOGLE_LOGIN:
        {
            [self tryGoogleLogin];
            break;
        }
        case WELIKE_STARTUP_STATE_REGISTER_USERINFO:
        {
            self.state = WELIKE_STARTUP_STATE_REGISTER_USERINFO;
            [self broadcast];
            break;
        }
        case WELIKE_STARTUP_STATE_REGISTER_TRY_USERINFO:
        {
            [self tryUpdateUserInfo];
            break;
        }
        case WELIKE_STARTUP_STATE_REGISTER_INTERESTS:
        {
            self.state = WELIKE_STARTUP_STATE_REGISTER_INTERESTS;
            [self broadcast];
            break;
        }
        case WELIKE_STARTUP_STATE_REGISTER_TRY_INTERESTS:
        {
            [self tryInterests];
            break;
        }
        case WELIKE_STARTUP_STATE_REGISTER_SUG_USERS:
        {
            self.state = WELIKE_STARTUP_STATE_REGISTER_SUG_USERS;
            [self broadcast];
            break;
        }
        case WELIKE_STARTUP_STATE_REGISTER_TRY_SUG_USERS:
        {
            [self trySugUsers];
            break;
        }
        case WELIKE_STARTUP_STATE_MAIN:
        {
            [self tryMain];
            break;
        }
        case WELIKE_STARTUP_STATE_EXEMPT_LOGIN:
        {
            self.state = WELIKE_STARTUP_STATE_EXEMPT_LOGIN;
            [self broadcast];
            break;
        }
        default:
            break;
    }
}

- (void)runNext:(WELIKE_STARTUP_STATE)state
{
    switch (state)
    {
        case WELIKE_STARTUP_STATE_LOGIN_MOBILE:
        {
            WLRegisterMobileViewController *vc = [[WLRegisterMobileViewController alloc] init];
            [[AppContext rootViewController] pushViewControllerAfterClearAll:vc animated:NO];
            break;
        }
        case WELIKE_STARTUP_STATE_LOGIN_SMS_CODE:
        {
            WLRegisterSMSCodeViewController *vc = [[WLRegisterSMSCodeViewController alloc] init];
            [[AppContext rootViewController] pushViewControllerAfterClearAll:vc animated:NO];
            break;
        }
        case WELIKE_STARTUP_STATE_REGISTER_USERINFO:
        {
            WLRegisterProfileViewController *vc = [[WLRegisterProfileViewController alloc] init];
            [[AppContext rootViewController] pushViewControllerAfterClearAll:vc animated:NO];
            break;
        }
        case WELIKE_STARTUP_STATE_REGISTER_INTERESTS:
        {
            WLRegisterInterestsViewController *vc = [[WLRegisterInterestsViewController alloc] init];
            [[AppContext rootViewController] pushViewControllerAfterClearAll:vc animated:NO];
            break;
        }
        case WELIKE_STARTUP_STATE_REGISTER_SUG_USERS:
        {
            WLRegisterUserSugViewController *vc = [[WLRegisterUserSugViewController alloc] init];
            [[AppContext rootViewController] pushViewControllerAfterClearAll:vc animated:NO];
            break;
        }
        case WELIKE_STARTUP_STATE_MAIN:
        {
            [[AppContext rootViewController] pushViewControllerAfterClearAll:[AppContext mainViewController] animated:NO];
            break;
        }
        case WELIKE_STARTUP_STATE_EXEMPT_LOGIN:
        {
            [[AppContext rootViewController] pushViewControllerAfterClearAll:[WLUnloginTabController new] animated:NO];
            break;
        }
        default:
            break;
    }
}

- (void)logout
{
    [[WLMessageManager instance] stop];
    [AppContext logout];
    [self unattachDB];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"current_uid"];
    self.uri = nil;
    self.mobile = nil;
    self.thirdToken = nil;
    self.nationCode = nil;
    self.smsCode = nil;
    self.nickName = nil;
    self.headUrl = nil;
    self.gender = WELIKE_USER_GENDER_UNKNOWN;
    //    self.state = WELIKE_STARTUP_STATE_LOGIN_MOBILE;
    self.state = WELIKE_STARTUP_STATE_EXEMPT_LOGIN;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self runNext:self.state];
    });
}

- (void)resend
{
    if ([self.mobile length] > 0 && [self.nationCode length] > 0)
    {
        if (self.smsCodeReq != nil)
        {
            [self.smsCodeReq cancel];
            self.smsCodeReq = nil;
        }
        __weak typeof(self) weakSelf = self;
        self.smsCodeReq = [[WLSMSCodeRequest alloc] initSMSCodeRequest];
        [self.smsCodeReq reqSMSCodeWithMobile:self.mobile nationCode:self.nationCode successed:^{
            weakSelf.smsCodeReq = nil;
        } error:^(NSInteger errorCode) {
            weakSelf.smsCodeReq = nil;
        }];
    }
}

#pragma mark StartHandler private methods
- (void)accountTasksInitialized
{
    [[AppContext getInstance].draftManager reset];
    
    long long now = [[NSDate date] timeIntervalSince1970] * 1000;
    //请求完毕,记录时间
    long long requestTime = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ContactRequestTime"] longLongValue];
    long long days = (now - requestTime)/86400000;
    
    NSString *currentCursor = [[NSUserDefaults standardUserDefaults] objectForKey:kContactCurrentCursor];
    
    if (currentCursor.length > 0) //上次请求中断的情况,继续请求
    {
        [[AppContext getInstance].contactsManager refreshFromCursor:currentCursor];
    }
    else if (requestTime == -1) //请求第一页就失败的情况,直接重新请求
    {
        [[AppContext getInstance].contactsManager refreshAll];
    }
    else if (days >= 7) //如果距离上次更新超过七天则更新
    {
        long long now = [[NSDate date] timeIntervalSince1970] * 1000;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:now] forKey:@"ContactRequestTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[AppContext getInstance].contactsManager refreshAll];
    }
    
    [[WLMessageManager instance] restart];
    [[AppContext getInstance].pushSettingManager loginWithUid:[[AppContext getInstance].accountManager myAccount].uid];
}


- (void)goNormalStart
{
    self.mobile = nil;
    self.nationCode = nil;
    self.smsCode = nil;
    self.thirdToken = nil;
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"current_uid"];
    if ([uid length] > 0)
    {
        [self attachDBWithUid:uid];
        WLAccount *account = [[AppContext getInstance].accountManager myAccount];
        if (account != nil)
        {
            [self resumeRegister:account.completeLevel];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"current_uid"];
            [self next:WELIKE_STARTUP_STATE_LOGIN_MOBILE];
        }
    }
    else
    {
        //        [self next:WELIKE_STARTUP_STATE_LOGIN_MOBILE];
        [self next:WELIKE_STARTUP_STATE_EXEMPT_LOGIN];
    }
}

- (void)resumeRegister:(WELIKE_ACCOUNT_COMPLETE_LEVEL)level
{
    switch (level)
    {
        case WELIKE_PROFILE_COMPLETE_LEVEL_BASE:
        {
            [self next:WELIKE_STARTUP_STATE_REGISTER_USERINFO];
            break;
        }
        case WELIKE_PROFILE_COMPLETE_LEVEL_BASE_USERINFO:
        {
            [self next:WELIKE_STARTUP_STATE_REGISTER_INTERESTS];
            break;
        }
        case WELIKE_PROFILE_COMPLETE_LEVEL_INTEREST:
        {
            [self next:WELIKE_STARTUP_STATE_REGISTER_SUG_USERS];
            break;
        }
        case WELIKE_PROFILE_COMPLETE_LEVEL_MAIN_DONE:
        {
            [self next:WELIKE_STARTUP_STATE_MAIN];
            break;
        }
        default:
            break;
    }
}

- (void)goSMSCodeVerify
{
    if ([self.mobile length] > 0 && [self.nationCode length] > 0)
    {
        if (self.smsCodeReq != nil)
        {
            [self.smsCodeReq cancel];
            self.smsCodeReq = nil;
        }
        __weak typeof(self) weakSelf = self;
        self.smsCodeReq = [[WLSMSCodeRequest alloc] initSMSCodeRequest];
        [self.smsCodeReq reqSMSCodeWithMobile:self.mobile nationCode:self.nationCode successed:^{
            weakSelf.smsCodeReq = nil;
        } error:^(NSInteger errorCode) {
            weakSelf.smsCodeReq = nil;
        }];
        self.state = WELIKE_STARTUP_STATE_LOGIN_SMS_CODE;
        [weakSelf broadcast];
    }
    else
    {
        [self broadcastFailed:ERROR_LOGIN_MOBILE_EMPTY];
    }
}

- (void)tryWelikeLogin
{
    if (self.loginReq != nil)
    {
        [self broadcastFailed:ERROR_LOGIN_FAILED];
        return;
    }
    
    if ([self.mobile length] > 0 && [self.smsCode length] > 0)
    {
        __weak typeof(self) weakSelf = self;
        self.loginReq = [[WLLoginRequest alloc] initLoginRequest];
        [self.loginReq loginWithMobile:self.mobile smsCode:self.smsCode successed:^(WLAccount *account, WLAccountSetting *setting) {
            weakSelf.loginReq = nil;
            if (account != nil)
            {
                [self attachDBWithUid:account.uid];
                [[AppContext getInstance].accountManager updateAccount:account];
                
                //请求并记录请求时间
                long long now = [[NSDate date] timeIntervalSince1970] * 1000;
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:now] forKey:@"ContactRequestTime"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[AppContext getInstance].contactsManager refreshAll];
                if (setting != nil)
                {
                    [[AppContext getInstance].accountManager updateSetting:setting];
                }
                [[NSUserDefaults standardUserDefaults] setObject:account.uid forKey:@"current_uid"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [weakSelf resumeRegister:account.completeLevel];
                
                [WLTrackerLogin appendLoginResultWithLoginType:WLTrackerLoginType_Mobile
                                                        result:WLTrackerLoginResult_Succeed
                                                        mobile:self.mobile];
            }
            else
            {
                [weakSelf broadcastFailed:ERROR_NETWORK_RESP_INVALID];
                
                [WLTrackerLogin appendLoginResultWithLoginType:WLTrackerLoginType_Mobile
                                                        result:WLTrackerLoginResult_Invalid
                                                        mobile:self.mobile];
            }
        } error:^(NSInteger errorCode) {
            weakSelf.loginReq = nil;
            [weakSelf broadcastFailed:errorCode];
            
            [WLTrackerLogin appendLoginResultWithLoginType:WLTrackerLoginType_Mobile
                                                    result:WLTrackerLoginResult_Failed
                                                    mobile:self.mobile];
        }];
    }
    else
    {
        [self broadcastFailed:ERROR_LOGIN_SMS_EMPTY];
    }
}

- (void)tryFacebookLogin
{
    if (self.thirdLoginReq != nil)
    {
        [self broadcastFailed:ERROR_LOGIN_FAILED];
        return;
    }
    
    if ([self.thirdToken length] > 0)
    {
        __weak typeof(self) weakSelf = self;
        self.thirdLoginReq = [[WLThirdLoginRequest alloc] initThirdLoginRequest];
        [self.thirdLoginReq loginWithType:WLThirdLoginType_FaceBook token:self.thirdToken successed:^(WLAccount *account, WLAccountSetting *setting) {
            weakSelf.thirdLoginReq = nil;
            if (account != nil)
            {
                [self attachDBWithUid:account.uid];
                [[AppContext getInstance].accountManager updateAccount:account];
                long long now = [[NSDate date] timeIntervalSince1970] * 1000;
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:now] forKey:@"ContactRequestTime"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[AppContext getInstance].contactsManager refreshAll];
                if (setting != nil)
                {
                    [[AppContext getInstance].accountManager updateSetting:setting];
                }
                [[NSUserDefaults standardUserDefaults] setObject:account.uid forKey:@"current_uid"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [weakSelf resumeRegister:account.completeLevel];
                
                [WLTrackerLogin appendLoginResultWithLoginType:WLTrackerLoginType_Facebook
                                                        result:WLTrackerLoginResult_Succeed
                                                        mobile:nil];
            }
            else
            {
                [weakSelf broadcastFailed:ERROR_NETWORK_RESP_INVALID];
                
                [WLTrackerLogin appendLoginResultWithLoginType:WLTrackerLoginType_Facebook
                                                        result:WLTrackerLoginResult_Failed
                                                        mobile:nil];
            }
        } error:^(NSInteger errorCode) {
            weakSelf.thirdLoginReq = nil;
            [weakSelf broadcastFailed:errorCode];
            
            [WLTrackerLogin appendLoginResultWithLoginType:WLTrackerLoginType_Facebook
                                                    result:WLTrackerLoginResult_Failed
                                                    mobile:nil];
        }];
    }
    else
    {
        [self broadcastFailed:ERROR_LOGIN_FAILED];
    }
}

- (void)tryGoogleLogin
{
    if (self.thirdLoginReq != nil)
    {
        [self broadcastFailed:ERROR_LOGIN_FAILED];
        return;
    }
    
    if ([self.thirdToken length] > 0)
    {
        __weak typeof(self) weakSelf = self;
        self.thirdLoginReq = [[WLThirdLoginRequest alloc] initThirdLoginRequest];
        [self.thirdLoginReq loginWithType:WLThirdLoginType_Google token:self.thirdToken successed:^(WLAccount *account, WLAccountSetting *setting) {
            weakSelf.thirdLoginReq = nil;
            if (account != nil)
            {
                [self attachDBWithUid:account.uid];
                [[AppContext getInstance].accountManager updateAccount:account];
                long long now = [[NSDate date] timeIntervalSince1970] * 1000;
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:now] forKey:@"ContactRequestTime"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[AppContext getInstance].contactsManager refreshAll];
                if (setting != nil)
                {
                    [[AppContext getInstance].accountManager updateSetting:setting];
                }
                [[NSUserDefaults standardUserDefaults] setObject:account.uid forKey:@"current_uid"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [weakSelf resumeRegister:account.completeLevel];
                
                [WLTrackerLogin appendLoginResultWithLoginType:WLTrackerLoginType_Google
                                                        result:WLTrackerLoginResult_Succeed
                                                        mobile:nil];
            }
            else
            {
                [weakSelf broadcastFailed:ERROR_NETWORK_RESP_INVALID];
                
                [WLTrackerLogin appendLoginResultWithLoginType:WLTrackerLoginType_Google
                                                        result:WLTrackerLoginResult_Failed
                                                        mobile:nil];
            }
        } error:^(NSInteger errorCode) {
            weakSelf.thirdLoginReq = nil;
            [weakSelf broadcastFailed:errorCode];
            
            [WLTrackerLogin appendLoginResultWithLoginType:WLTrackerLoginType_Google
                                                    result:WLTrackerLoginResult_Failed
                                                    mobile:nil];
        }];
    }
    else
    {
        [self broadcastFailed:ERROR_LOGIN_FAILED];
    }
}

- (void)tryUpdateUserInfo
{
    if ([self.nickName length] > 0 && self.gender != WELIKE_USER_GENDER_UNKNOWN)
    {
        __weak typeof(self) weakSelf = self;
        [[AppContext getInstance].accountManager syncAccountNickName:self.nickName gender:self.gender head:self.headUrl completeLevel:WELIKE_PROFILE_COMPLETE_LEVEL_BASE_USERINFO successed:^{
            [weakSelf next:WELIKE_STARTUP_STATE_REGISTER_INTERESTS];
            [weakSelf broadcast];
        } error:^(NSInteger errCode) {
            [weakSelf broadcastFailed:errCode];
        }];
    }
}

- (void)tryInterests
{
    __weak typeof(self) weakSelf = self;
    [[AppContext getInstance].accountManager syncAccountInterests:self.interests successed:^{
        [weakSelf tryCompletedLevel:WELIKE_PROFILE_COMPLETE_LEVEL_INTEREST state:WELIKE_STARTUP_STATE_REGISTER_SUG_USERS];
    } error:^(NSInteger errCode) {
        [weakSelf broadcastFailed:errCode];
    }];
}

- (void)trySugUsers
{
    if (self.followUsersReq != nil) return;
    
    if ([self.followUids count] > 0)
    {
        __weak typeof(self) weakSelf = self;
        WLAccount *account = [[AppContext getInstance].accountManager myAccount];
        self.followUsersReq = [[WLFollowUsersRequest alloc] initFollowUsersRequestWithAccount:account];
        [self.followUsersReq followUsers:self.followUids successed:^{
            weakSelf.followUsersReq = nil;
            [weakSelf tryCompletedLevel:WELIKE_PROFILE_COMPLETE_LEVEL_MAIN_DONE state:WELIKE_STARTUP_STATE_MAIN];
            
            [WLTrackerLogin appendRegisterSucceed];
            
        } error:^(NSInteger errorCode) {
            weakSelf.followUsersReq = nil;
            [weakSelf broadcastFailed:errorCode];
        }];
    }
    else
    {
        [self tryCompletedLevel:WELIKE_PROFILE_COMPLETE_LEVEL_MAIN_DONE state:WELIKE_STARTUP_STATE_MAIN];
        [WLTrackerLogin appendRegisterSucceed];
    }
}

- (void)tryCompletedLevel:(WELIKE_ACCOUNT_COMPLETE_LEVEL)level state:(NSInteger)state
{
    __weak typeof(self) weakSelf = self;
    [[AppContext getInstance].accountManager syncAccountCompleteLevel:level successed:^{
        [weakSelf next:state];
    } error:^(NSInteger errCode) {
        [weakSelf broadcastFailed:errCode];
    }];
}

- (void)tryMain
{
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    if (account.completeLevel == WELIKE_PROFILE_COMPLETE_LEVEL_MAIN_DONE)
    {
        long long expired = account.expired - TOKEN_REFRESH_INTERVAL;
        long long now = [[NSDate date] timeIntervalSince1970] * 1000;
        if (now < expired)
        {
            [self listAllStatus];
            [self routerUri];
        }
        else
        {
            [self doReauthWithRefreshToken:account.refreshToken];
        }
    }
    else
    {
        [self logout];
    }
}

-(void)listAllStatus
{
    if (self.statusListRequest != nil)
    {
        [self.statusListRequest cancel];
        self.statusListRequest = nil;
    }
    
    __weak typeof(self) weakSelf = self;
    
    self.statusListRequest = [[WLStatusListRequest alloc] init];
    
    [self.statusListRequest requestStatusJsonSuccess:^(NSMutableArray * _Nonnull items) {
        
        if (items > 0)
        {
            [[NSUserDefaults standardUserDefaults] setObject:items forKey:kStatusListKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //            NSLog(@"===================status suc");
        }
        
    } error:^(NSInteger errorCode) {
        
        weakSelf.statusListRequest = nil;
        //     NSLog(@"===================status fail");
        
    }];
}

- (void)routerUri
{
    [self accountTasksInitialized];
    self.state = WELIKE_STARTUP_STATE_MAIN;
    [self broadcast];
    
    WLRouterBuilder *builder = [WLRouterBuilder createByUri:self.uri];
    [WLRouter go:builder];
    self.uri = nil;
}

- (void)doReauthWithRefreshToken:(NSString *)refreshToken
{
    if (self.authRequest != nil) return;
    
    __weak typeof(self) weakSelf = self;
    self.authRequest = [[WLAuthRequest alloc] initAuthRequest];
    [self.authRequest authWithRefreshToken:refreshToken successed:^(WLAccount *account) {
        weakSelf.authRequest = nil;
        [[AppContext getInstance].accountManager updateAccount:account];
        [weakSelf routerUri];
    } error:^(NSInteger errorCode) {
        weakSelf.authRequest = nil;
        [self logout];
    }];
}

- (void)attachDBWithUid:(NSString *)uid
{
    [[WLCommonDBManager getInstance] loginWithUid:uid];
    [[WLStorageDBManager getInstance] loginWithUid:uid];
    [[WLMessageManager instance] openWithUid:uid];
    [[AppContext getInstance].accountManager prepare];
    [[AppContext getInstance].contactsManager prepare];
    [[AppContext getInstance].uploadManager prepare];
    [[AppContext getInstance].draftManager prepare];
    [WLHistoryCache prepare];
}

- (void)unattachDB
{
    [[WLMessageManager instance] close];
    [[WLStorageDBManager getInstance] logout];
    [[WLCommonDBManager getInstance] logout];
}

- (void)broadcast
{
    @synchronized (_delegates)
    {
        for (int i = 0; i < [_delegates count]; i++)
        {
            id<WLStartHandlerDelegate> delegate = [_delegates pointerAtIndex:i];
            if ([delegate respondsToSelector:@selector(goProcess:)])
            {
                [delegate goProcess:self.state];
            }
        }
    }
}

- (void)broadcastFailed:(NSInteger)errCode
{
    @synchronized (_delegates)
    {
        for (int i = 0; i < [_delegates count]; i++)
        {
            id<WLStartHandlerDelegate> delegate = [_delegates pointerAtIndex:i];
            if ([delegate respondsToSelector:@selector(goFailed:)])
            {
                [delegate goFailed:errCode];
            }
        }
    }
}

@end
