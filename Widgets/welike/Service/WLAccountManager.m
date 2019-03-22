//
//  WLAccountManager.m
//  welike
//
//  Created by 刘斌 on 2018/4/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLAccountManager.h"
#import "WLNickNameCheckRequest.h"
#import "WLSyncAccountRequest.h"
#import "WLCommonDBManager.h"
#import "WLStorageDBManager.h"
#import "LuuUtils.h"
#import "NSDictionary+JSON.h"

#define PROFILE_COL_UID                                 @"uid"
#define PROFILE_COL_NICK                                @"nick"
#define PROFILE_COL_HEAD                                @"head"
#define PROFILE_COL_ACC_TOKEN                           @"atoken"
#define PROFILE_COL_REF_TOKEN                           @"rtoken"
#define PROFILE_COL_EXPIRED                             @"expired"
#define PROFILE_COL_INTRO                               @"introduction"
#define PROFILE_COL_GENDER                              @"gender"
#define PROFILE_COL_POSTS_COUNT                         @"posts_count"
#define PROFILE_COL_FOLLOW_USERS_COUNT                  @"follow_users_count"
#define PROFILE_COL_FOLLOWED_USERS_COUNT                @"followed_users_count"
#define PROFILE_COL_LIKE_MY_POSTS_COUNT                 @"liked_my_posts_count"
#define PROFILE_COL_MY_LIKED_POSTS_COUNT                @"my_liked_posts_count"
#define PROFILE_COL_ALLOW_UPDATE_NICK                   @"allow_update_nick"
#define PROFILE_COL_ALLOW_UPDATE_GENDER                 @"allow_update_gender"
#define PROFILE_COL_NEXT_UPDATE_NICK_DATE               @"next_update_nick_date"
#define PROFILE_COL_GENDER_UPDATE_COUNT                 @"gender_update_count"
#define PROFILE_COL_COMPLETE_LEVEL                      @"complete_level"
#define PROFILE_COL_VIP                                 @"vip"
#define PROFILE_COL_INTERESTS                           @"interests"

#define SETTING_COL_SID                                 @"settingid"
#define SETTING_COL_COMMENT_COUNT                       @"comment_count"
#define SETTING_COL_MENTION_COUNT                       @"mention_count"
#define SETTING_COL_LIKE_COUNT                          @"like_count"
#define SETTING_COL_MOBILE_MODEL                        @"mobile_model"

#define PROFILE_JSON_KEY_COMPLETED_LEVEL                @"finishLevel"
#define PROFILE_JSON_KEY_ALLOW_UPDATE_NICK_NAME         @"allowUpdateNickName"
#define PROFILE_JSON_KEY_ALLOW_UPDATE_GENDER            @"allowUpdateSex"
#define PROFILE_JSON_KEY_NEXT_UPDATE_NICK_NAME_DATE     @"nextUpdateNickNameDate"
#define PROFILE_JSON_KEY_GENDER_UPDATE_COUNT            @"sexUpdateCount"
#define PROFILE_JSON_KEY_SETTING                        @"settings"
#define SETTING_JSON_KEY_MOBILE_MODEL                   @"mobileModel"

@interface WLAccount ()

@end

@implementation WLAccount

- (WLAccount *)copy
{
    WLAccount *account = [[WLAccount alloc] init];
    account.uid = self.uid;
    account.nickName = self.nickName;
    account.headUrl = self.headUrl;
    account.gender = self.gender;
    account.introduction = self.introduction;
    account.postsCount = self.postsCount;
    account.followUsersCount = self.followUsersCount;
    account.followedUsersCount = self.followedUsersCount;
    account.likedMyPostsCount = self.likedMyPostsCount;
    account.myLikedPostsCount = self.myLikedPostsCount;
    account.allowUpdateNickName = self.allowUpdateNickName;
    account.allowUpdateGender = self.allowUpdateGender;
    account.nextUpdateNickNameDate = self.nextUpdateNickNameDate;
    account.genderUpdateCount = self.genderUpdateCount;
    account.accessToken = self.accessToken;
    account.refreshToken = self.refreshToken;
    account.expired = self.expired;
    account.completeLevel = self.completeLevel;
    account.vip = self.vip;
    account.links = self.links;
    account.curLevel = self.curLevel;
    account.cover = self.cover;
    account.canChangeCover = self.canChangeCover;
    if ([self.interests count] > 0)
    {
        account.interests = [NSArray arrayWithArray:self.interests];
    }
    if (self.honors.count > 0) {
        account.honors = [NSArray arrayWithArray:self.honors];
    }
    return account;
}

+ (WLAccount *)parseFromNetworkJSON:(NSDictionary *)result
{
    WLAccount *account = nil;
    NSString *uid = [result stringForKey:USER_JSON_KEY_UID];
    if ([uid length] > 0)
    {
        account = [[WLAccount alloc] init];
        account.uid = uid;
        account.postsCount = [result integerForKey:USER_JSON_KEY_POSTS_COUNT def:0];
        account.followUsersCount = [result integerForKey:USER_JSON_KEY_FOLLOW_USERS_COUNT def:0];
        account.followedUsersCount = [result integerForKey:USER_JSON_KEY_FOLLOWED_USERS_COUNT def:0];
        account.likedMyPostsCount = [result integerForKey:USER_JSON_KEY_LIKE_MY_POSTS_COUNT def:0];
        account.myLikedPostsCount = [result integerForKey:USER_JSON_KEY_MY_LIKED_POSTS_COUNT def:0];
        NSInteger completeLevel = [result integerForKey:PROFILE_JSON_KEY_COMPLETED_LEVEL def:0];
        if (completeLevel == 0)
        {
            account.completeLevel = WELIKE_PROFILE_COMPLETE_LEVEL_BASE;
        }
        else
        {
            account.completeLevel = completeLevel;
        }
        account.allowUpdateNickName = [result boolForKey:PROFILE_JSON_KEY_ALLOW_UPDATE_NICK_NAME def:YES];
        account.allowUpdateGender = [result boolForKey:PROFILE_JSON_KEY_ALLOW_UPDATE_GENDER def:YES];
        account.nextUpdateNickNameDate = [result longLongForKey:PROFILE_JSON_KEY_NEXT_UPDATE_NICK_NAME_DATE def:0];
        account.genderUpdateCount = [result integerForKey:PROFILE_JSON_KEY_GENDER_UPDATE_COUNT def:0];
        account.nickName = [result stringForKey:USER_JSON_KEY_NICK_NAME];
        account.headUrl = [[result stringForKey:USER_JSON_KEY_HEAD] convertToHttps];
        account.gender = (WELIKE_USER_GENDER)[result integerForKey:USER_JSON_KEY_GENDER def:0];
        account.vip = [result integerForKey:USER_JSON_KEY_VIP def:0];
        account.introduction = [result stringForKey:USER_JSON_KEY_INTRO];
        account.curLevel = (WLUserLevel)[result integerForKey:USER_JSON_KEY_LEVEL def:0];
        NSArray *interests = [result objectForKey:USER_JSON_KEY_INTERESTS];
        if ([interests count] > 0)
        {
            account.interests = interests;
        }
        NSArray *linkJsons = [result objectForKey:USER_JSON_KEY_LINKS];
        if (linkJsons.count > 0) {
            NSMutableArray *linkArray = [NSMutableArray array];
            for (int i = 0; i < linkJsons.count; i++) {
                WLUserLinkModel *linkModel = [WLUserLinkModel parseWithNetworkJson:linkJsons[i]];
                if (linkModel) {
                    [linkArray addObject:linkModel];
                }
            }
            
            account.links = linkArray;
        }
        
        account.cover = [result stringForKey:@"coverPage"];
        account.canChangeCover = [result boolForKey:@"canChangeCoverPage" def:NO];
        NSArray *honorJsons = [result objectForKey:@"userhonors"];
        if (honorJsons.count > 0) {
            NSMutableArray<WLUserHonorModel *> *honorArray = [NSMutableArray array];
            for (int i = 0; i < honorJsons.count; i++) {
                WLUserHonorModel *model = [WLUserHonorModel parseWithNetworkJson:honorJsons[i]];
                if (model) {
                    [honorArray addObject:model];
                }
            }
            
            [honorArray sortUsingComparator:^NSComparisonResult(WLUserHonorModel *obj1, WLUserHonorModel *obj2) {
                return obj1.index > obj2.index;
            }];
            
            account.honors = honorArray;
        }
    }
    return account;
}

+ (NSString *)toNetworkJSONForInterests:(NSArray *)interests
{
    if (interests != nil)
    {
        return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:interests options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (NSString *)formatIntro:(NSString *)source
{
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:@"\n{1,}" options:NSRegularExpressionCaseInsensitive error:nil];
    return [regular stringByReplacingMatchesInString:source options:0 range:NSMakeRange(0, [source length]) withTemplate:@"\n"];
}

@end

@implementation WLAccountSetting

- (id)init
{
    self = [super init];
    if (self)
    {
        self.commentCount = 0;
        self.mentionCount = 0;
        self.likeCount = 0;
    }
    return self;
}

- (WLAccountSetting *)copy
{
    WLAccountSetting *setting = [[WLAccountSetting alloc] init];
    setting.commentCount = self.commentCount;
    setting.mentionCount = self.mentionCount;
    setting.likeCount = self.likeCount;
    setting.mobileModel = self.mobileModel;
    return setting;
}

- (NSString *)toNetworkJSON
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:self.mobileModel], SETTING_JSON_KEY_MOBILE_MODEL, nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (WLAccountSetting *)parseFromNetworkJSON:(NSDictionary *)result
{
    WLAccountSetting *setting = nil;
    id settingObj = [result objectForKey:PROFILE_JSON_KEY_SETTING];
    if (settingObj != nil && [settingObj isKindOfClass:[NSString class]] == YES)
    {
        NSString *settingJSON = (NSString *)settingObj;
        NSDictionary *settingDic = [NSJSONSerialization JSONObjectWithData:[settingJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        setting = [[WLAccountSetting alloc] init];
        setting.mobileModel = [settingDic boolForKey:SETTING_JSON_KEY_MOBILE_MODEL def:NO];
    }
    return setting;
}

@end

#define kNickNameCheckerMinLength     2
#define kNickNameCheckerMaxLength     20

@interface WLNickNameChecker ()

@property (nonatomic, strong) WLNickNameCheckRequest *request;

- (void)handleResult:(NSInteger)errCode result:(nickNameChecked)result;

@end

@implementation WLNickNameChecker

- (void)checkForNickName:(NSString *)nickName result:(nickNameChecked)result
{
    if (self.request != nil)
    {
        [self.request cancel];
        self.request = nil;
    }
    if ([nickName length] > 0)
    {
        if ([nickName length] < kNickNameCheckerMinLength)
        {
            if (result != nil)
            {
                result(nickName, ERROR_USERINFO_NICKNAME_TOO_SHORT);
            }
        }
        else if ([nickName length] > kNickNameCheckerMaxLength)
        {
            if (result != nil)
            {
                result(nickName, ERROR_USERINFO_NICKNAME_TOO_LONG);
            }
        }
        else
        {
            __weak typeof(self) weakSelf = self;
            self.request = [[WLNickNameCheckRequest alloc] initNickNameCheckRequest];
            [self.request checkForNickName:nickName successed:^{
                [weakSelf handleResult:ERROR_SUCCESS result:result];
            } error:^(NSInteger errorCode) {
                [weakSelf handleResult:errorCode result:result];
            }];
        }
    }
    else
    {
        if (result != nil)
        {
            result(nickName, ERROR_USERINFO_NICKNAME_EMPTY);
        }
    }
}

- (void)cancel
{
    if (self.request != nil)
    {
        [self.request cancel];
        self.request = nil;
    }
}

- (void)handleResult:(NSInteger)errCode result:(nickNameChecked)result
{
    NSString *nickName = [self.request.nickName copy];
    self.request = nil;
    if (result != nil)
    {
        result(nickName, errCode);
    }
}

@end

#define CREATE_PROFILE_TABLE_SQL @"CREATE TABLE IF NOT EXISTS profile (%@ TEXT, %@ TEXT, %@ TEXT, %@ TEXT, %@ TEXT, %@ INTEGER, %@ TEXT, %@ INTEGER, %@ INTEGER, %@ INTEGER, %@ INTEGER, %@ INTEGER, %@ INTEGER, %@ INTEGER, %@ INTEGER, %@ INTEGER, %@ INTEGER, %@ INTEGER, %@ TEXT, %@ INTEGER, PRIMARY KEY(%@))"
#define UPDATE_PROFILE_SQL @"INSERT OR REPLACE INTO profile (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"

#define CREATE_SETTING_TABLE_SQL @"CREATE TABLE IF NOT EXISTS setting (%@ TEXT, %@ INTEGER, %@ INTEGER, %@ INTEGER, %@ INTEGER, PRIMARY KEY(%@))"
#define UPDATE_SETTING_SQL @"INSERT OR REPLACE INTO setting (%@, %@, %@, %@, %@) VALUES (?, ?, ?, ?, ?)"

@interface WLAccountManager ()

@property (nonatomic, strong) WLAccount *account;
@property (nonatomic, strong) WLAccountSetting *setting;

- (void)loadLocalProfile;
- (void)loadLocalSetting;

@end

@implementation WLAccountManager

#pragma mark WLAccountManager public methods
- (void)prepare
{
    NSString *sql1 = [NSString stringWithFormat:CREATE_PROFILE_TABLE_SQL, PROFILE_COL_UID, PROFILE_COL_NICK, PROFILE_COL_HEAD, PROFILE_COL_ACC_TOKEN, PROFILE_COL_REF_TOKEN, PROFILE_COL_EXPIRED, PROFILE_COL_INTRO, PROFILE_COL_GENDER, PROFILE_COL_POSTS_COUNT, PROFILE_COL_FOLLOW_USERS_COUNT, PROFILE_COL_FOLLOWED_USERS_COUNT, PROFILE_COL_LIKE_MY_POSTS_COUNT, PROFILE_COL_MY_LIKED_POSTS_COUNT, PROFILE_COL_ALLOW_UPDATE_NICK, PROFILE_COL_ALLOW_UPDATE_GENDER, PROFILE_COL_NEXT_UPDATE_NICK_DATE, PROFILE_COL_GENDER_UPDATE_COUNT, PROFILE_COL_COMPLETE_LEVEL, PROFILE_COL_INTERESTS, PROFILE_COL_VIP, PROFILE_COL_UID];
    
    FMDatabase *db1 = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] syncBlock:^{
        [db1 beginTransaction];
        [db1 executeUpdate:sql1];
        [db1 commit];
    }];
    [self loadLocalProfile];
    
    NSString *sql2 = [NSString stringWithFormat:CREATE_SETTING_TABLE_SQL, SETTING_COL_SID, SETTING_COL_COMMENT_COUNT, SETTING_COL_MENTION_COUNT, SETTING_COL_LIKE_COUNT, SETTING_COL_MOBILE_MODEL, SETTING_COL_SID];
    FMDatabase *db2 = [WLStorageDBManager getInstance].db;
    [[WLStorageDBManager getInstance] syncBlock:^{
        [db2 beginTransaction];
        [db2 executeUpdate:sql2];
        [db2 commit];
    }];
    [self loadLocalSetting];
}

- (void)logout
{
    self.account = nil;
    self.setting = nil;
}

- (WLAccount *)myAccount
{
    return [self.account copy];
}

- (WLAccountSetting *)mySetting
{
    return [self.setting copy];
}

- (void)updateAccount:(WLAccount *)account
{
    if (account != nil)
    {
        __weak typeof(self) weakSelf = self;
        FMDatabase *db = [WLCommonDBManager getInstance].db;
        [[WLCommonDBManager getInstance] syncBlock:^{
            [db beginTransaction];
            
            BOOL res = [db executeUpdate:@"DELETE FROM profile"];
            if (res == NO)
            {
                [db rollback];
                return;
            }
            
            NSString *interests = [WLAccount toNetworkJSONForInterests:account.interests];
            NSString *sql = [NSString stringWithFormat:UPDATE_PROFILE_SQL, PROFILE_COL_UID, PROFILE_COL_NICK, PROFILE_COL_HEAD, PROFILE_COL_ACC_TOKEN, PROFILE_COL_REF_TOKEN, PROFILE_COL_EXPIRED, PROFILE_COL_INTRO, PROFILE_COL_GENDER, PROFILE_COL_POSTS_COUNT, PROFILE_COL_FOLLOW_USERS_COUNT, PROFILE_COL_FOLLOWED_USERS_COUNT, PROFILE_COL_LIKE_MY_POSTS_COUNT, PROFILE_COL_MY_LIKED_POSTS_COUNT, PROFILE_COL_ALLOW_UPDATE_NICK, PROFILE_COL_ALLOW_UPDATE_GENDER, PROFILE_COL_NEXT_UPDATE_NICK_DATE, PROFILE_COL_GENDER_UPDATE_COUNT, PROFILE_COL_COMPLETE_LEVEL, PROFILE_COL_INTERESTS, PROFILE_COL_VIP];
            res = [[WLCommonDBManager getInstance].db executeUpdate:sql,
                   account.uid, account.nickName, account.headUrl, account.accessToken, account.refreshToken, [NSNumber numberWithLongLong:account.expired], account.introduction, [NSNumber numberWithInteger:account.gender], [NSNumber numberWithInteger:account.postsCount], [NSNumber numberWithInteger:account.followUsersCount], [NSNumber numberWithInteger:account.followedUsersCount], [NSNumber numberWithInteger:account.likedMyPostsCount], [NSNumber numberWithInteger:account.myLikedPostsCount], [NSNumber numberWithBool:account.allowUpdateNickName], [NSNumber numberWithBool:account.allowUpdateGender], [NSNumber numberWithLongLong:account.nextUpdateNickNameDate], [NSNumber numberWithInteger:account.genderUpdateCount], [NSNumber numberWithInteger:account.completeLevel], interests, [NSNumber numberWithInteger:account.vip]];
            if (res == NO)
            {
                [db rollback];
                return;
            }
            
            weakSelf.account = account;
            
            [db commit];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kWLAccountChangedNotification object:self userInfo:nil];
            });
        }];
    }
}

- (void)updateSetting:(WLAccountSetting *)setting
{
    __weak typeof(self) weakSelf = self;
    FMDatabase *db = [WLStorageDBManager getInstance].db;
    [[WLStorageDBManager getInstance] syncBlock:^{
        [db beginTransaction];
        
        if (setting != nil)
        {
            BOOL res = [db executeUpdate:@"DELETE FROM setting"];
            if (res == NO)
            {
                [db rollback];
                return;
            }
            
            NSString *sql = [NSString stringWithFormat:UPDATE_SETTING_SQL, SETTING_COL_SID, SETTING_COL_COMMENT_COUNT, SETTING_COL_MENTION_COUNT, SETTING_COL_LIKE_COUNT, SETTING_COL_MOBILE_MODEL];
            res = [db executeUpdate:sql, [LuuUtils uuid], [NSNumber numberWithLongLong:setting.commentCount], [NSNumber numberWithLongLong:setting.mentionCount], [NSNumber numberWithLongLong:setting.likeCount], [NSNumber numberWithBool:setting.mobileModel]];
            if (res == NO)
            {
                [db rollback];
                return;
            }
            
            weakSelf.setting = setting;
        }
        else
        {
            [db executeUpdate:@"DELETE FROM setting"];
            weakSelf.setting = [[WLAccountSetting alloc] init];
            weakSelf.setting.commentCount = 0;
            weakSelf.setting.mentionCount = 0;
            weakSelf.setting.likeCount = 0;
            weakSelf.setting.mobileModel = NO;
        }
        
        [db commit];
    }];
}

- (void)syncAccountNickName:(NSString *)nickName gender:(WELIKE_USER_GENDER)gender head:(NSString *)head completeLevel:(WELIKE_ACCOUNT_COMPLETE_LEVEL)completeLevel successed:(accountSyncSuccessed)successed error:(accountSyncFailed)error
{
    if ([nickName length] > 0 && gender != WELIKE_USER_GENDER_UNKNOWN)
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
        [params setObject:nickName forKey:@"nickName"];
        [params setObject:[NSNumber numberWithInteger:completeLevel] forKey:@"finishLevel"];
        [params setObject:[NSString stringWithFormat:@"%d", (int)gender] forKey:@"sex"];
        if ([head length] > 0)
        {
            [params setObject:head forKey:@"avatarUrl"];
        }
        __weak typeof(self) weakSelf = self;
        WLSyncAccountRequest *request = [[WLSyncAccountRequest alloc] initSyncAccountRequest];
        [request syncAccount:self.account.uid info:params successed:^(WLAccount *account) {
            WLAccount *newAccount = [weakSelf.account copy];
            newAccount.nickName = account.nickName;
            newAccount.headUrl = account.headUrl;
            newAccount.gender = account.gender;
            newAccount.completeLevel = account.completeLevel;
            newAccount.allowUpdateNickName = account.allowUpdateNickName;
            newAccount.nextUpdateNickNameDate = account.nextUpdateNickNameDate;
            newAccount.genderUpdateCount = account.genderUpdateCount;
            newAccount.allowUpdateGender = account.allowUpdateGender;
            [weakSelf updateAccount:newAccount];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (successed)
                {
                    successed();
                }
            });
        } error:^(NSInteger errorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    error(errorCode);
                }
            });
        }];
    }
    else
    {
        if (error)
        {
            error(ERROR_USERINFO_FAILED);
        }
    }
}

- (void)syncAccountCompleteLevel:(WELIKE_ACCOUNT_COMPLETE_LEVEL)completeLevel successed:(accountSyncSuccessed)successed error:(accountSyncFailed)error
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:[NSNumber numberWithInteger:completeLevel] forKey:@"finishLevel"];
    __weak typeof(self) weakSelf = self;
    WLSyncAccountRequest *request = [[WLSyncAccountRequest alloc] initSyncAccountRequest];
    [request syncAccount:self.account.uid info:params successed:^(WLAccount *account) {
        WLAccount *newAccount = [weakSelf.account copy];
        newAccount.completeLevel = account.completeLevel;
        [weakSelf updateAccount:newAccount];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (successed)
            {
                successed();
            }
        });
    } error:^(NSInteger errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                error(errorCode);
            }
        });
    }];
}

- (void)syncAccountNickName:(NSString *)nickName successed:(accountSyncSuccessed)successed error:(accountSyncFailed)error
{
    if ([nickName length] > 0)
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
        [params setObject:nickName forKey:@"nickName"];
        __weak typeof(self) weakSelf = self;
        WLSyncAccountRequest *request = [[WLSyncAccountRequest alloc] initSyncAccountRequest];
        [request syncAccount:self.account.uid info:params successed:^(WLAccount *account) {
            WLAccount *newAccount = [weakSelf.account copy];
            newAccount.nickName = account.nickName;
            newAccount.allowUpdateNickName = account.allowUpdateNickName;
            newAccount.nextUpdateNickNameDate = account.nextUpdateNickNameDate;
            [weakSelf updateAccount:newAccount];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (successed)
                {
                    successed();
                }
            });
        } error:^(NSInteger errorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    error(errorCode);
                }
            });
        }];
    }
    else
    {
        if (error)
        {
            error(ERROR_USERINFO_NICKNAME_EMPTY);
        }
    }
}

- (void)syncAccountGender:(WELIKE_USER_GENDER)gender successed:(accountSyncSuccessed)successed error:(accountSyncFailed)error
{
    if (gender != WELIKE_USER_GENDER_UNKNOWN)
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
        [params setObject:[NSString stringWithFormat:@"%d", (int)gender] forKey:@"sex"];
        __weak typeof(self) weakSelf = self;
        WLSyncAccountRequest *request = [[WLSyncAccountRequest alloc] initSyncAccountRequest];
        [request syncAccount:self.account.uid info:params successed:^(WLAccount *account) {
            WLAccount *newAccount = [weakSelf.account copy];
            newAccount.gender = account.gender;
            newAccount.genderUpdateCount = account.genderUpdateCount;
            newAccount.allowUpdateGender = account.allowUpdateGender;
            [weakSelf updateAccount:newAccount];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (successed)
                {
                    successed();
                }
            });
        } error:^(NSInteger errorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    error(errorCode);
                }
            });
        }];
    }
    else
    {
        if (error)
        {
            error(ERROR_USERINFO_FAILED);
        }
    }
}

- (void)syncAccountHead:(NSString *)head successed:(accountSyncSuccessed)successed error:(accountSyncFailed)error
{
    if ([head length] > 0)
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
        [params setObject:head forKey:@"avatarUrl"];
        __weak typeof(self) weakSelf = self;
        WLSyncAccountRequest *request = [[WLSyncAccountRequest alloc] initSyncAccountRequest];
        [request syncAccount:self.account.uid info:params successed:^(WLAccount *account) {
            WLAccount *newAccount = [weakSelf.account copy];
            newAccount.headUrl = account.headUrl;
            [weakSelf updateAccount:newAccount];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (successed)
                {
                    successed();
                }
            });
        } error:^(NSInteger errorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    error(errorCode);
                }
            });
        }];
    }
    else
    {
        if (error)
        {
            error(ERROR_USERINFO_FAILED);
        }
    }
}

- (void)syncAccountIntro:(NSString *)intro successed:(accountSyncSuccessed)successed error:(accountSyncFailed)error
{
    NSString *intr = nil;
    if (intro == nil)
    {
        intr = @"";
    }
    else
    {
        intr = [intro copy];
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:intr forKey:@"introduction"];
    __weak typeof(self) weakSelf = self;
    WLSyncAccountRequest *request = [[WLSyncAccountRequest alloc] initSyncAccountRequest];
    [request syncAccount:self.account.uid info:params successed:^(WLAccount *account) {
        WLAccount *newAccount = [weakSelf.account copy];
        newAccount.introduction = account.introduction;
        [weakSelf updateAccount:newAccount];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (successed)
            {
                successed();
            }
        });
    } error:^(NSInteger errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                error(errorCode);
            }
        });
    }];
}

- (void)syncAccountInterests:(NSArray *)interests successed:(accountSyncSuccessed)successed error:(accountSyncFailed)error
{
    if (interests != nil)
    {
        __weak typeof(self) weakSelf = self;
        WLSyncAccountRequest *request = [[WLSyncAccountRequest alloc] initSyncAccountRequest];
        [request syncAccount:self.account.uid interests:interests successed:^(WLAccount *account) {
            WLAccount *newAccount = [weakSelf.account copy];
            newAccount.interests = account.interests;
            [weakSelf updateAccount:newAccount];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (successed)
                {
                    successed();
                }
            });
        } error:^(NSInteger errorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    error(errorCode);
                }
            });
        }];
    }
    else
    {
        if (error)
        {
            error(ERROR_USERINFO_FAILED);
        }
    }
}

- (void)syncSetting:(WLAccountSetting *)setting successed:(accountSyncSuccessed)successed error:(accountSyncFailed)error
{
    __weak typeof(self) weakSelf = self;
    WLSyncAccountRequest *request = [[WLSyncAccountRequest alloc] initSyncAccountRequest];
    [request syncAccount:self.account.uid setting:setting successed:^(WLAccountSetting *setting) {
        [weakSelf updateSetting:setting];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (successed)
            {
                successed();
            }
        });
    } error:^(NSInteger errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                error(errorCode);
            }
        });
    }];
}

#pragma mark WLAccountManager private methods
- (void)loadLocalProfile
{
    FMDatabase *db = [WLCommonDBManager getInstance].db;
    [[WLCommonDBManager getInstance] syncBlock:^{
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM profile"];
        if ([rs next])
        {
            self.account = [[WLAccount alloc] init];
            self.account.uid = [rs stringForColumn:PROFILE_COL_UID];
            self.account.nickName = [rs stringForColumn:PROFILE_COL_NICK];
            self.account.headUrl = [rs stringForColumn:PROFILE_COL_HEAD];
            self.account.gender = [rs intForColumn:PROFILE_COL_GENDER];
            self.account.introduction = [rs stringForColumn:PROFILE_COL_INTRO];
            self.account.postsCount = [rs intForColumn:PROFILE_COL_POSTS_COUNT];
            self.account.followUsersCount = [rs intForColumn:PROFILE_COL_FOLLOW_USERS_COUNT];
            self.account.followedUsersCount = [rs intForColumn:PROFILE_COL_FOLLOWED_USERS_COUNT];
            self.account.likedMyPostsCount = [rs intForColumn:PROFILE_COL_LIKE_MY_POSTS_COUNT];
            self.account.myLikedPostsCount = [rs intForColumn:PROFILE_COL_MY_LIKED_POSTS_COUNT];
            self.account.allowUpdateNickName = [rs boolForColumn:PROFILE_COL_ALLOW_UPDATE_NICK];
            self.account.allowUpdateGender = [rs boolForColumn:PROFILE_COL_ALLOW_UPDATE_GENDER];
            self.account.nextUpdateNickNameDate = [rs longLongIntForColumn:PROFILE_COL_NEXT_UPDATE_NICK_DATE];
            self.account.genderUpdateCount = [rs intForColumn:PROFILE_COL_GENDER_UPDATE_COUNT];
            self.account.accessToken = [rs stringForColumn:PROFILE_COL_ACC_TOKEN];
            self.account.refreshToken = [rs stringForColumn:PROFILE_COL_REF_TOKEN];
            self.account.expired = [rs longLongIntForColumn:PROFILE_COL_EXPIRED];
            self.account.completeLevel = [rs intForColumn:PROFILE_COL_COMPLETE_LEVEL];
            self.account.vip = [rs boolForColumn:PROFILE_COL_VIP];
            NSString *interests = [rs stringForColumn:PROFILE_COL_INTERESTS];
            if ([interests length] > 0)
            {
                NSData *jsonData = [interests dataUsingEncoding:NSUTF8StringEncoding];
                NSArray *interestsObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
                if (interestsObject != nil)
                {
                    self.account.interests = [NSMutableArray arrayWithArray:interestsObject];
                }
            }
        }
        [rs close];
    }];
}

- (void)loadLocalSetting
{
    FMDatabase *db = [WLStorageDBManager getInstance].db;
    [[WLStorageDBManager getInstance] syncBlock:^{
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM setting"];
        if ([rs next])
        {
            self.setting = [[WLAccountSetting alloc] init];
            self.setting.commentCount = [rs intForColumn:SETTING_COL_COMMENT_COUNT];
            self.setting.mentionCount = [rs intForColumn:SETTING_COL_MENTION_COUNT];
            self.setting.likeCount = [rs intForColumn:SETTING_COL_LIKE_COUNT];
            self.setting.mobileModel = [rs boolForColumn:SETTING_COL_MOBILE_MODEL];
        }
        [rs close];
        
        if (self.setting == nil)
        {
            self.setting = [[WLAccountSetting alloc] init];
            self.setting.commentCount = 0;
            self.setting.mentionCount = 0;
            self.setting.likeCount = 0;
            self.setting.mobileModel = YES;
        }
    }];
}

- (BOOL)isLogin
{
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"current_uid"];
    if ([uid length] > 0)
    {
        WLAccount *account = [[AppContext getInstance].accountManager myAccount];
        if (account != nil)
        {
            return YES;
        }
        else
        {
          //  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"current_uid"];
            return NO;
        }
    }
    else
    {
        return NO;
    }
}

@end
