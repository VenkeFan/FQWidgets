//
//  WLAccountManager.h
//  welike
//
//  Created by 刘斌 on 2018/4/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUserBase.h"

#define kWLAccountChangedNotification        @"WLAccountChangedNotification"

typedef NS_ENUM(NSInteger, WELIKE_ACCOUNT_COMPLETE_LEVEL)
{
    WELIKE_PROFILE_COMPLETE_LEVEL_BASE = 1,
    WELIKE_PROFILE_COMPLETE_LEVEL_BASE_USERINFO,
    WELIKE_PROFILE_COMPLETE_LEVEL_INTEREST,
    WELIKE_PROFILE_COMPLETE_LEVEL_MAIN_DONE
};

@interface WLAccount : WLUserBase

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *refreshToken;
@property (nonatomic, assign) long long expired;
@property (nonatomic, assign) WELIKE_ACCOUNT_COMPLETE_LEVEL completeLevel;
@property (nonatomic, assign) BOOL allowUpdateNickName;
@property (nonatomic, assign) BOOL allowUpdateGender;
@property (nonatomic, assign) long long nextUpdateNickNameDate;
@property (nonatomic, assign) NSInteger genderUpdateCount;

- (WLAccount *)copy;
+ (WLAccount *)parseFromNetworkJSON:(NSDictionary *)result;
+ (NSString *)toNetworkJSONForInterests:(NSArray *)interests;

+ (NSString *)formatIntro:(NSString *)source;

@end

@interface WLAccountSetting : NSObject

@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, assign) NSInteger mentionCount;
@property (nonatomic, assign) NSInteger likeCount;
@property (nonatomic, assign) BOOL mobileModel;

- (WLAccountSetting *)copy;
- (NSString *)toNetworkJSON;
+ (WLAccountSetting *)parseFromNetworkJSON:(NSDictionary *)result;

@end

typedef void(^nickNameChecked) (NSString *nickName, NSInteger errCode);

@interface WLNickNameChecker : NSObject

- (void)checkForNickName:(NSString *)nickName result:(nickNameChecked)result;
- (void)cancel;

@end

typedef void(^accountSyncSuccessed) (void);
typedef void(^accountSyncFailed) (NSInteger errCode);

@interface WLAccountManager : NSObject

- (void)prepare;
- (void)logout;
- (WLAccount *)myAccount;
- (WLAccountSetting *)mySetting;
- (void)updateAccount:(WLAccount *)account;
- (void)updateSetting:(WLAccountSetting *)setting;
- (void)syncAccountNickName:(NSString *)nickName gender:(WELIKE_USER_GENDER)gender head:(NSString *)head completeLevel:(WELIKE_ACCOUNT_COMPLETE_LEVEL)completeLevel successed:(accountSyncSuccessed)successed error:(accountSyncFailed)error;
- (void)syncAccountCompleteLevel:(WELIKE_ACCOUNT_COMPLETE_LEVEL)completeLevel successed:(accountSyncSuccessed)successed error:(accountSyncFailed)error;
- (void)syncAccountNickName:(NSString *)nickName successed:(accountSyncSuccessed)successed error:(accountSyncFailed)error;
- (void)syncAccountGender:(WELIKE_USER_GENDER)gender successed:(accountSyncSuccessed)successed error:(accountSyncFailed)error;
- (void)syncAccountHead:(NSString *)head successed:(accountSyncSuccessed)successed error:(accountSyncFailed)error;
- (void)syncAccountIntro:(NSString *)intro successed:(accountSyncSuccessed)successed error:(accountSyncFailed)error;
- (void)syncAccountInterests:(NSArray *)interests successed:(accountSyncSuccessed)successed error:(accountSyncFailed)error;
- (void)syncSetting:(WLAccountSetting *)setting successed:(accountSyncSuccessed)successed error:(accountSyncFailed)error;
- (BOOL)isLogin;


@end
