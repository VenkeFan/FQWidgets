//
//  UINavigationController+FQNavigation.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/13.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "UINavigationController+FQNavigation.h"

@implementation UINavigationController (FQNavigation)

- (void)viewDidLoad {
    self.interactivePopGestureRecognizer.delegate = self;
}

//#pragma mark - UINavigationControllerDelegate
//
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    if (navigationController.viewControllers.count == 1) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    } else {
//        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//    }
//}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"gestureRecognizerShouldBegin: %zd", [self.navigationController.viewControllers count]);
    
    if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer) {
        return [self.navigationController.viewControllers count] > 1;
    } else {
        return YES;
    }
}

@end
