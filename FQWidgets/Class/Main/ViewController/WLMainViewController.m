//
//  WLMainViewController.m
//  WeLike
//
//  Created by fan qi on 2018/3/27.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLMainViewController.h"
#import "WLHomeViewController.h"
#import "WLDiscoveryViewController.h"
#import "WLMessageViewController.h"
#import "WLUserViewController.h"
#import "FQNavigationController.h"

#import "WLTabBar.h"

@interface WLMainViewController () <WLTabBarDelegate>

@end

@implementation WLMainViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WLTabBar *tabBar = [[WLTabBar alloc] initWithFrame:self.tabBar.bounds];
    tabBar.myDelegate = self;
    [self setValue:tabBar forKey:@"tabBar"];
    
    UIViewController *homeCtr = [self childCtrWithClass:[WLHomeViewController class]
                                                  imageName:@"main_home_normal"
                                            selectImageName:@"main_home_selected"];
    
    UIViewController *disCtr = [self childCtrWithClass:[WLDiscoveryViewController class]
                                                 imageName:@"main_discovery_normal"
                                           selectImageName:@"main_discovery_selected"];
    
    UIViewController *msgCtr = [self childCtrWithClass:[WLMessageViewController class]
                                                 imageName:@"main_msg_normal"
                                           selectImageName:@"main_msg_selected"];
    
    UIViewController *userCtr = [self childCtrWithClass:[WLUserViewController class]
                                                  imageName:@"main_user_normal"
                                            selectImageName:@"main_user_selected"];
    
    self.viewControllers = @[homeCtr, disCtr, msgCtr, userCtr];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (UIViewController *)childCtrWithClass:(Class)class
                                  imageName:(NSString *)imageName
                            selectImageName:(NSString *)selectImageName {
    UIViewController *ctr = [class new];
    
//    FQNavigationController *navCtr = [[FQNavigationController alloc] initWithRootViewController:ctr];
    ctr.tabBarItem.image = [[UIImage imageNamed:imageName]
                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    ctr.tabBarItem.selectedImage = [[UIImage imageNamed:selectImageName]
                                       imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    return ctr;
}

#pragma mark - WLTabBarDelegate

- (void)tabBarDidTappedCustomView:(WLTabBar *)tabBar {
    
}

@end
