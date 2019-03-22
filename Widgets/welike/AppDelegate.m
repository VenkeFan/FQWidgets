//
//  AppDelegate.m
//  welike
//
//  Created by 刘斌 on 2018/4/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "AppDelegate.h"
#import "WLSplashViewController.h"
#import "WLMainViewController.h"
#import "RDRootViewController.h"
#import "WLStartHandler.h"
#import "WLMessageManager.h"
#import "WLPushSettingManager.h"
#import "WLRouter.h"
#import "WLTracker.h"
#import "NSDictionary+JSON.h"
#import "LuuLogger.h"
#import "WLIMEventDefines.h"
#import <AVKit/AVKit.h>
#import <UserNotifications/UserNotifications.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
//#import "WLAppInfoManager.h"
#import "WLNewVersionView.h"
#import "WLNewVersionInfo.h"
#import "WLTrackerDayLive.h"

static NSString * const kGoogleClientID = @"668487685656-m7kuj523qf7hbu599rjk28v8593gdalc.apps.googleusercontent.com";

#define kBackgroundRestartDuration 5

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@property (nonatomic, strong) NSDate *backDate;
@property (nonatomic, strong) NSDate *enterDate;
//@property (nonatomic, strong) WLAppInfoManager *appInfoManager;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    application.applicationIconBadgeNumber = 0;
    
    [self registerPushNotification:application];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    [GIDSignIn sharedInstance].clientID = kGoogleClientID;

#ifdef __WELIKE_TEST_
    [LuuLogger share].enable = YES;
#else
    [LuuLogger share].enable = NO;
#endif
    [LuuLogger share].fileMode = NO;
    //[[LuuLogger share] appendTag:@"publish"];
    //[[LuuLogger share] appendTag:IMLogTag];
    //[[LuuLogger share] appendTag:@"guoyibo"];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    [LuuUtils removeFilesInPath:[AppContext getCachePath]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.mainVC = [[WLMainViewController alloc] init];

    WLSplashViewController *vc = [[WLSplashViewController alloc] init];
    self.rootNavVC = [[RDRootViewController alloc] initWithRootViewController:vc];
    
    self.window.rootViewController = self.rootNavVC;
    
//    [self addObservers];
    
    [WLTracker getInstance].entrance = WELIKE_APP_ENTRANCE_NORMAL;
    
    NSObject *notif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notif) {
        [WLTrackerDayLive appendTrackWithOpenType:WLTrackerDayLiveOpenType_Push];
    } else {
        [WLTrackerDayLive appendTrackWithOpenType:WLTrackerDayLiveOpenType_Other];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [WLTracker getInstance].entrance = WELIKE_APP_ENTRANCE_SCHEME;
    BOOL res1 = [self app:application openURL:url];
    BOOL res2 = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
    BOOL res3 = [[GIDSignIn sharedInstance] handleURL:url
                                    sourceApplication:sourceApplication
                                           annotation:annotation];
    if (res1 == YES || res2 == YES || res3 == YES) return YES;
    return NO;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    [WLTracker getInstance].entrance = WELIKE_APP_ENTRANCE_SCHEME;
    BOOL res1 = [self app:app openURL:url];
    if (@available(iOS 9.0, *))
    {
        BOOL res2 = [[FBSDKApplicationDelegate sharedInstance] application:app
                                                                   openURL:url
                                                         sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                                annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
        BOOL res3 = [[GIDSignIn sharedInstance] handleURL:url
                                        sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                               annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
        
        if (res1 == YES || res2 == YES || res3 == YES) return YES;
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kWLAppWillResignActiveNotificationName object:nil];
    
    [[WLTracker getInstance] synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    self.backDate = [NSDate date];
    
    [[WLMessageManager instance] stop];
    
    //dot
    NSTimeInterval timeLength = [_backDate timeIntervalSinceDate:_enterDate];
    [WLTrackUseTime trackUseTimeLength:(NSInteger)(timeLength *1000)];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
    
    [[WLMessageManager instance] restart];
    
    NSDate *now = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSinceDate:self.backDate];
    if (interval >= kBackgroundRestartDuration)
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kWLAppDidBecomeActiveNotificationName object:nil];
    
    _enterDate = [NSDate date];
  
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kWLMemoryWarningNotificationName object:nil];
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceTokenStr = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[AppContext getInstance].pushSettingManager bindPushToken:deviceTokenStr];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary * _Nonnull)userInfo fetchCompletionHandler:(void (^ _Nonnull)(UIBackgroundFetchResult))completionHandler
{
    if (application.applicationState != UIApplicationStateActive)
    {
        [self handlePushMessage:userInfo];
    }
    completionHandler(UIBackgroundFetchResultNewData);
    
    [WLTrackerDayLive appendTrackWithOpenType:WLTrackerDayLiveOpenType_Push];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0))
{
    
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0))
{
    [self handlePushMessage:response.notification.request.content.userInfo];
    completionHandler();
    
    [WLTrackerDayLive appendTrackWithOpenType:WLTrackerDayLiveOpenType_Push];
}


- (void)logout
{
    [self.mainVC close];
    self.mainVC = [[WLMainViewController alloc] init];
}

- (void)remain
{
    [self.mainVC close];
    self.mainVC = [[WLMainViewController alloc] init];
    [self.rootNavVC pushViewControllerAfterClearAll:self.mainVC animated:NO];
}

- (BOOL)app:(UIApplication *)application openURL:(NSURL *)url
{
    application.applicationIconBadgeNumber = 0;
    NSString *uri = [url absoluteString];
    
    if ([WLRouter welikeLink:url] == YES)
    {
        if ([AppContext getInstance].startHandler.state == WELIKE_STARTUP_STATE_MAIN)
        {
            WLRouterBuilder *builder = [WLRouterBuilder createByUri:uri];
            [WLRouter go:builder];
        }
        else
        {
            [AppContext getInstance].startHandler.uri = uri;
        }
        return YES;
    }
    return NO;
}

- (void)registerPushNotification:(UIApplication *)application
{
    if (@available(iOS 10.0, *))
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center setDelegate:self];
        UNAuthorizationOptions type = UNAuthorizationOptionBadge|UNAuthorizationOptionSound|UNAuthorizationOptionAlert;
        [center requestAuthorizationWithOptions:type completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
        }];
    }
    else
    {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
}

- (void)handlePushMessage:(NSDictionary *)userInfo
{
    NSDictionary *data = [userInfo objectForKey:@"data"];
    if (data != nil)
    {
        NSString *forwardUrl = [data stringForKey:@"forwardUrl"];
        WELIKE_PUSH_TYPE pushType = [data integerForKey:@"pushType" def:WELIKE_PUSH_TYPE_UNKNOWN];
        if (pushType >= 200 && pushType != WELIKE_PUSH_TYPE_UNKNOWN)
        {
            [WLTracker getInstance].entrance = WELIKE_APP_ENTRANCE_OFFICIAL_PUSH;
        }
        else if (pushType >= 100)
        {
            [WLTracker getInstance].entrance = WELIKE_APP_ENTRANCE_IM_PUSH;
        }
        else
        {
            [WLTracker getInstance].entrance = WELIKE_APP_ENTRANCE_MSG_PUSH;
        }
        NSURL *url = [NSURL URLWithString:forwardUrl];
        if ([WLRouter welikeLink:url] == YES)
        {
            if ([AppContext getInstance].startHandler.state == WELIKE_STARTUP_STATE_MAIN)
            {
                WLRouterBuilder *builder = [WLRouterBuilder createByUri:forwardUrl];
                [WLRouter go:builder];
            }
            else
            {
                [AppContext getInstance].startHandler.uri = forwardUrl;
            }
        }
    }
}

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(screenshotting:)
                                                 name:UIApplicationUserDidTakeScreenshotNotification
                                               object:nil];
}

- (void)screenshotting:(NSNotification *)notification
{
//    UIImage *image = [self dataWithScreenshotInPNGFormat];
//
//    CGFloat width = [UIScreen mainScreen].bounds.size.width * 0.25;
//    CGFloat height = image.size.height / image.size.width * width;
//
//    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(15, kSystemStatusBarHeight, width, height)];
//    view.image = image;
}

- (UIImage *)dataWithScreenshotInPNGFormat
{
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation))
    {
        imageSize = [UIScreen mainScreen].bounds.size;
    }
    else
    {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft)
        {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        }
        else if (orientation == UIInterfaceOrientationLandscapeRight)
        {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        }
        else if (orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
        {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        }
        else
        {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    {
        CGFloat left = 12, bottom = 12;
        CGFloat y = imageSize.height - bottom;
        
        {
            NSString *text = [NSString stringWithFormat:@"@%@", [AppContext getInstance].accountManager.myAccount.nickName];
            NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                         NSFontAttributeName: kRegularFont(12)};
            
            CGSize size = [text boundingRectWithSize:imageSize
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:attributes
                                             context:nil].size;
            CGFloat width = size.width, height = size.height;
            y -= height;
            
            [text drawInRect:CGRectMake(left, y, width, height) withAttributes:attributes];
        }
        
        {
            UIImage *watermark = [AppContext getImageForKey:@"common_watermark"];
            
            CGFloat width = watermark.size.width, height = watermark.size.height;
            y -= height;
            
            [watermark drawInRect:CGRectMake(left, y, width, height) blendMode:kCGBlendModeNormal alpha:1.0];
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *data = UIImagePNGRepresentation(image);
    return [UIImage imageWithData:data];
}

//- (WLAppInfoManager *)appInfoManager {
//    if (!_appInfoManager) {
//        _appInfoManager = [[WLAppInfoManager alloc] init];
//    }
//    return _appInfoManager;
//}

@end
