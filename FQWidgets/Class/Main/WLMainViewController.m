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
#import "WLPublishViewController.h"
#import "WLMessageViewController.h"
#import "WLUserViewController.h"

@interface WLMainViewController ()

@end

@implementation WLMainViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WLHomeViewController *homeCtr = [[WLHomeViewController alloc] init];
    homeCtr.title = kLocalizedString(@"main_home");
    
    WLDiscoveryViewController *disCtr = [[WLDiscoveryViewController alloc] init];
    disCtr.title = kLocalizedString(@"main_discovery");
    
    WLMessageViewController *msgCtr = [[WLMessageViewController alloc] init];
    msgCtr.title = kLocalizedString(@"main_msg");
    
    WLUserViewController *userCtr = [[WLUserViewController alloc] init];
    userCtr.title = kLocalizedString(@"main_user");
    
    self.viewControllers = @[homeCtr, disCtr, msgCtr, userCtr];
    self.tabBarView.items[1].badgeNum = 10;
}

#pragma mark - Override

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    
}

- (void)clickedUnExclusiveViewController {
    [super clickedUnExclusiveViewController];
    
    UIAlertController *ctr = [UIAlertController alertControllerWithTitle:@"" message:@"点击了发布..." preferredStyle:UIAlertControllerStyleAlert];
    [ctr addAction:[UIAlertAction actionWithTitle:@"cancel"
                                            style:UIAlertActionStyleCancel
                                          handler:^(UIAlertAction * _Nonnull action) {
                                              
                                          }]];
    [self presentViewController:ctr animated:YES completion:nil];
    
//    WLPublishViewController *publishCtr = [[WLPublishViewController alloc] init];
//    publishCtr.title = kLocalizedString(@"main_publish");
//    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:publishCtr] animated:YES completion:nil];
}

- (UINavigationController *)generateNavigationCtr:(UIViewController *)ctr {
    UINavigationController *navigationCtr = [[UINavigationController alloc] initWithRootViewController:ctr];
    
    if([navigationCtr respondsToSelector:@selector(interactivePopGestureRecognizer)])
        navigationCtr.interactivePopGestureRecognizer.delegate = nil;
    
    return navigationCtr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
