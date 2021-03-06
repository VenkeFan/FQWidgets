//
//  AppDelegate.m
//  WeLike
//
//  Created by fan qi on 2018/3/27.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "AppDelegate.h"
#import "WLMainViewController.h"
#import "YYFPSLabel.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self p_configureNavBar];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.window.rootViewController = [WLMainViewController new];
    self.window.rootViewController = [[FQNavigationController alloc] initWithRootViewController:[WLMainViewController new]];
    [self.window makeKeyAndVisible];
    
    {
        YYFPSLabel *fpsLabel = [[YYFPSLabel alloc] init];
        [fpsLabel sizeToFit];
        fpsLabel.center = CGPointMake(CGRectGetMidX(self.window.frame), kStatusBarHeight);
        [self.window addSubview:fpsLabel];
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Private

- (void)p_configureNavBar {
    UINavigationBar *navBar = [UINavigationBar appearance];
    navBar.translucent = NO;
    [navBar setBackgroundImage:[UIImage imageWithColor:kMainColor]
                forBarPosition:UIBarPositionAny
                    barMetrics:UIBarMetricsDefault];
    navBar.shadowImage = [UIImage imageWithColor:kMainColor];
    [navBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kHeaderFontSize],
                                     NSForegroundColorAttributeName:kHeaderFontColor}];
}

@end
