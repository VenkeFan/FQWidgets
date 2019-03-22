//
//  WLStartHandler.h
//  welike
//
//  Created by 刘斌 on 2018/4/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLUserBase.h"

typedef NS_ENUM(NSInteger, WELIKE_STARTUP_STATE)
{
    WELIKE_STARTUP_STATE_SPLASH = 0,
    WELIKE_STARTUP_STATE_LANG,
    WELIKE_STARTUP_STATE_LANG_DONE,
    WELIKE_STARTUP_STATE_LOGIN_MOBILE,
    WELIKE_STARTUP_STATE_LOGIN_SMS_CODE,
    WELIKE_STARTUP_STATE_TRY_LOGIN,
    WELIKE_STARTUP_STATE_TRY_FACEBOOK_LOGIN,
    WELIKE_STARTUP_STATE_TRY_GOOGLE_LOGIN,
    WELIKE_STARTUP_STATE_REGISTER_USERINFO,
    WELIKE_STARTUP_STATE_REGISTER_TRY_USERINFO,
    WELIKE_STARTUP_STATE_REGISTER_INTERESTS,
    WELIKE_STARTUP_STATE_REGISTER_TRY_INTERESTS,
    WELIKE_STARTUP_STATE_REGISTER_SUG_USERS,
    WELIKE_STARTUP_STATE_REGISTER_TRY_SUG_USERS,
    WELIKE_STARTUP_STATE_MAIN,
    WELIKE_STARTUP_STATE_EXEMPT_LOGIN
};

@protocol WLStartHandlerDelegate <NSObject>

@optional
- (void)goProcess:(WELIKE_STARTUP_STATE)state;
- (void)goFailed:(NSInteger)errcode;

@end

@interface WLStartHandler : NSObject

@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *thirdToken;
@property (nonatomic, copy) NSString *nationCode;
@property (nonatomic, copy) NSString *smsCode;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *headUrl;
@property (nonatomic, assign) WELIKE_USER_GENDER gender;
@property (nonatomic, strong) NSArray *interests;
@property (nonatomic, strong) NSArray *followUids;
@property (nonatomic, copy) NSString *uri;
@property (nonatomic, readonly) WELIKE_STARTUP_STATE state;

- (void)registerWithDelegate:(id<WLStartHandlerDelegate>)delegate;
- (void)unregister:(id<WLStartHandlerDelegate>)delegate;

- (void)start;
- (void)next:(WELIKE_STARTUP_STATE)state;
- (void)runNext:(WELIKE_STARTUP_STATE)state;
- (void)logout;
- (void)resend;

@end
