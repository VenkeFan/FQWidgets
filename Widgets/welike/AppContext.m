//
//  AppContext.m
//  welike
//
//  Created by 刘斌 on 2018/4/12.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "AppContext.h"
#import "WLAccountManager.h"
#import "WLUploadManager.h"
#import "WLStartHandler.h"
#import "RDResManager.h"
#import "WLEmojiManager.h"
#import "WLContactsManager.h"
#import "WLDraftManager.h"
#import "WLPublishTaskManager.h"
#import "WLSingleContentManager.h"
#import "WLSingleUserManager.h"
#import "RDLocalizationManager.h"
#import "WLMessageCountObserver.h"
#import "WLPushSettingManager.h"
#import "AppDelegate.h"

static AppContext *_gAppContext = nil;

@interface AppContext () <RDLocalizationManagerDelegate>

@property (nonatomic, strong) RDResManager *resManager;
@property (nonatomic, strong) WLAccountManager *accountManager;
@property (nonatomic, strong) WLStartHandler *startHandler;
@property (nonatomic, strong) WLUploadManager *uploadManager;
@property (nonatomic, strong) WLContactsManager *contactsManager;
@property (nonatomic, strong) WLDraftManager *draftManager;
@property (nonatomic, strong) WLPublishTaskManager *publishTaskManager;
@property (nonatomic, strong) WLSingleContentManager *singleContentManager;
@property (nonatomic, strong) WLSingleUserManager *singleUserManager;
@property (nonatomic, strong) WLMessageCountObserver *messageCountObserver;
@property (nonatomic, strong) WLPushSettingManager *pushSettingManager;
#ifdef __WELIKE_TEST_
@property (nonatomic, copy) NSString *testEnv;
#endif

@end

@implementation AppContext

- (id)init
{
    self = [super init];
    if (self)
    {
        self.resManager = [[RDResManager alloc] init];
        self.accountManager = [[WLAccountManager alloc] init];
        self.startHandler = [[WLStartHandler alloc] init];
        self.uploadManager = [[WLUploadManager alloc] init];
        self.contactsManager = [[WLContactsManager alloc] init];
        self.draftManager = [[WLDraftManager alloc] init];
        self.publishTaskManager = [[WLPublishTaskManager alloc] init];
        self.singleContentManager = [[WLSingleContentManager alloc] init];
        self.singleUserManager = [[WLSingleUserManager alloc] init];
        self.messageCountObserver = [[WLMessageCountObserver alloc] init];
        self.pushSettingManager = [[WLPushSettingManager alloc] init];
        [[RDLocalizationManager getInstance] registerDelegate:self];
        [WLEmojiManager emotionsArray];
        
#ifdef __WELIKE_TEST_
        id obj = [[NSUserDefaults standardUserDefaults] objectForKey:@"test_env"];
        if (obj == nil)
        {
            self.testEnv = @"pre";
        }
        else
        {
            self.testEnv = obj;
        }
#endif
    }
    return self;
}

#pragma mark AppContext singleton methods
+ (AppContext *)getInstance
{
    if (!_gAppContext)
    {
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            _gAppContext = [[AppContext alloc] init];
        });
    }
    
    return _gAppContext;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized (self)
    {
        if (!_gAppContext)
        {
            _gAppContext = [super allocWithZone:zone];
            return _gAppContext;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _gAppContext;
}

+ (RDRootViewController *)rootViewController
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appDelegate.rootNavVC;
}

+ (WLMainViewController *)mainViewController
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appDelegate.mainVC;
}

+ (RDBaseViewController *)currentViewController
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    RDBaseViewController *currentVC = [self p_getCurrentCtrFrom:rootViewController];
    return currentVC;
}

+ (RDBaseViewController *)p_getCurrentCtrFrom:(UIViewController *)rootVC
{
    RDBaseViewController *currentVC;
    if ([rootVC presentedViewController])
    {
        rootVC = (RDBaseViewController *)[rootVC presentedViewController];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]])
    {
        currentVC = [self p_getCurrentCtrFrom:[(UITabBarController *)rootVC selectedViewController]];
    }
    else if ([rootVC isKindOfClass:[UINavigationController class]])
    {
        currentVC = [self p_getCurrentCtrFrom:[(UINavigationController *)rootVC visibleViewController]];
    }
    else
    {
        currentVC = (RDBaseViewController *)rootVC;
    }
    
    return (RDBaseViewController *)currentVC;
}

+ (UIImage *)getImageForKey:(NSString *)key
{
    return [[AppContext getInstance].resManager getImageForKey:key];
}

+ (NSString *)getStringForKey:(NSString *)key fileName:(NSString *)fileName
{
    NSString *language = [[RDLocalizationManager getInstance] getCurrentLanguage];
    if ([language length] == 0)
    {
        language = [[RDLocalizationManager getInstance] getCurrentSystemLanguage];
    }
    
    NSString *languagesBundlePath = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"languages.bundle"] stringByAppendingPathComponent:language];
    NSString *plistPath = [[[NSBundle alloc] initWithPath:languagesBundlePath] pathForResource:fileName ofType:@"plist"];
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSString *keyValue = dictionary[key];
    
//    NSLog(@"dictionary = %@",keyValue);
    
    if (keyValue.length == 0)
    {
        NSLog(@"=======================================wen an serious error");
    }
    
    return dictionary[key];
}

+ (NSString *)getCachePath
{
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *cachePath = [tmpDir stringByAppendingPathComponent:@"welikeTmp"];
    [LuuUtils createDirectory:cachePath];
    return cachePath;
}

+ (NSString *)getHostName
{
#ifdef __WELIKE_TEST_
    if ([[AppContext getInstance].testEnv isEqualToString:@"dev"] == YES)
    {
        return kDevHostName;
    }
    else
    {
        return kPreHostName;
    }
#else
    return kHostName;
#endif
}

+ (NSString *)getUploadHostName
{
#ifdef __WELIKE_TEST_
    if ([[AppContext getInstance].testEnv isEqualToString:@"dev"] == YES)
    {
        return kDevUploadHostName;
    }
    else
    {
        return kPreUploadHostName;
    }
#else
    return kUploadHostName;
#endif
}

+ (NSString *)getDownloadHostName
{
#ifdef __WELIKE_TEST_
    if ([[AppContext getInstance].testEnv isEqualToString:@"dev"] == YES)
    {
        return kDevDownloadHostName;
    }
    else
    {
        return kPreDownloadHostName;
    }
#else
    return kDownloadHostName;
#endif
}

+ (NSString *)getTrackHostName
{
#ifdef __WELIKE_TEST_
    if ([[AppContext getInstance].testEnv isEqualToString:@"dev"] == YES)
    {
        return kDevTrackHostName;
    }
    else
    {
        return kPreTrackHostName;
    }
#else
    return kTrackHostName;
#endif
}

+ (NSString *)getLongConnectionHostName
{
#ifdef __WELIKE_TEST_
    if ([[AppContext getInstance].testEnv isEqualToString:@"dev"] == YES)
    {
        return kDevLongConnectionAddress;
    }
    else
    {
        return kPreLongConnectionAddress;
    }
#else
    return kLongConnectionAddress;
#endif
}

+ (NSInteger)getLongConnectionPort
{
#ifdef __WELIKE_TEST_
    return kTestLongConnectionPort;
#else
    return kLongConnectionPort;
#endif
}

+ (NSString *)getAliBucket
{
#ifdef __WELIKE_TEST_
    return kPreAliBucket;
#else
    return kAliBucket;
#endif
}

+(NSString *)getEndPoint
{
#ifdef __WELIKE_TEST_
    return kPreEndPoint;
#else
    return kEndPoint;
#endif
}

+(NSString *)getAliUploadHostName
{
#ifdef __WELIKE_TEST_
    return kPreAliUploadHostName;
#else
    return kAliUploadHostName;
#endif
}

+(NSString *)getSts
{
#ifdef __WELIKE_TEST_
    return kPreSts;
#else
    return kSts;
#endif
}


+ (void)logout
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate logout];
    [[AppContext getInstance].accountManager logout];
}

- (void)testEnvSwitch:(NSString *)env
{
    #ifdef __WELIKE_TEST_
    self.testEnv = env;
    [[NSUserDefaults standardUserDefaults] setObject:self.testEnv forKey:@"test_env"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    #endif
}

#pragma mark RDLocalizationManagerDelegate methods
- (void)didChangedLanguage:(NSString *)language
{
    if ([self.accountManager myAccount] != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate remain];
        });
    }
}

@end
