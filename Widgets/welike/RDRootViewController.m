//
//  RDRootViewController.m
//  welike
//
//  Created by 刘斌 on 2018/4/13.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDRootViewController.h"

@interface RDRootViewController () <UIGestureRecognizerDelegate>

@end

@implementation RDRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _disableInteractivePopGestureRecognizer = NO;
    self.interactivePopGestureRecognizer.delegate = self;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)pushViewControllerAfterClearAll:(UIViewController *)viewController animated:(BOOL)animated
{
    NSArray *newViewControllers = [NSArray arrayWithObjects:viewController, nil];
    [self setViewControllers:newViewControllers animated:animated];
}

- (void)popToViewControllerByClass:(Class)vcClass animated:(BOOL)animated
{
    UIViewController *targetVc = nil;
    NSInteger count = [self.viewControllers count];
    for (NSInteger i = count - 1; i >= 0; i--)
    {
        UIViewController *vc = [self.viewControllers objectAtIndex:i];
        if ([vc isKindOfClass:vcClass])
        {
            targetVc = vc;
            break;
        }
    }
    if (targetVc != nil)
    {
        [self popToViewController:targetVc animated:animated];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        if (self.disableInteractivePopGestureRecognizer) {
            return NO;
        }
        return [self.viewControllers count] > 1;
    } else {
        return YES;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]] &&
        [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        if ([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
            [otherGestureRecognizer requireGestureRecognizerToFail:gestureRecognizer];
        }
        
        return YES;
    }
    return NO;
}

@end
