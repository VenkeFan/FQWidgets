//
//  FQNavigationController.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/13.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQNavigationController.h"
#import "FQAnimatedTransitioning.h"

@interface FQNavigationController () <UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem *leftBarBtn;

@end

@implementation FQNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    self.interactivePopGestureRecognizer.delegate = weakSelf;
    self.delegate = weakSelf;
    
    
//    {
//        unsigned int count = 0;
//        Ivar *ivars = class_copyIvarList([self.navigationController.navigationBar class], &count);
//        
//        for (int i = 0; i < count; i++) {
//            Ivar ivar = ivars[i];
//            NSString *objcName = [NSString stringWithUTF8String:ivar_getName(ivar)];
//            NSString *objcType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
//            NSLog(@"%@ : %@", objcName, objcType);
//        }
//        
//        //            UIView *view = [self.navigationController.navigationBar valueForKey:@"_barBackgroundView"];
//        UIView *view = [self.navigationController.navigationBar valueForKey:@"_backgroundView"];
//        NSLog(@"%@", view);
//    }
//    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Override

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.navigationItem.leftBarButtonItem = self.leftBarBtn;
    }
    
    [super pushViewController:viewController animated:animated];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        return [self.viewControllers count] > 1;
    } else {
        return YES;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]] &&
        [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        if ([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
            [otherGestureRecognizer requireGestureRecognizerToFail:gestureRecognizer];
        }
        
        return YES;
    }
    return NO;
}

#pragma mark - UINavigationControllerDelegate

//- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
//    
//    if (operation == UINavigationControllerOperationPop) {
//        return [FQAnimatedTransitioning new];
//    }
//    
//    return nil;
//}

//- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
//    
//}

#pragma mark - Event

- (void)backBtnClicked {
    [self popViewControllerAnimated:YES];
}

#pragma mark - Getter

- (UIBarButtonItem *)leftBarBtn {
    if (!_leftBarBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, kSingleNavBarHeight, kSingleNavBarHeight);
        [btn setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btn addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        _leftBarBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    return _leftBarBtn;
}

@end
