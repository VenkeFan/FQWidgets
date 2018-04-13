//
//  UIViewController+FQNavigationController.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/12.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "UIViewController+FQNavigationController.h"

@implementation UIViewController (FQNavigationController)

//+ (void)load {
//    Method originalMethod = class_getInstanceMethod([self class], @selector(viewDidLoad));
//    Method swizzleMethod = class_getInstanceMethod([self class], @selector(fq_viewDidLoad));
//    
//    method_exchangeImplementations(originalMethod, swizzleMethod);
//}
//
//#pragma mark - Swizzle
//
//- (void)fq_viewDidLoad {
//    [self fq_viewDidLoad];
//    
//    if (self.navigationController.viewControllers.count > 1) {
//        self.navigationItem.leftBarButtonItem = ({
//            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//            btn.frame = CGRectMake(0, 0, kSingleNavBarHeight, kSingleNavBarHeight);
//            [btn setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
//            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//            [btn addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//
//            UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
//            leftBarBtn;
//        });
//    }
//}
//
//#pragma mark - Event
//
//- (void)backBtnClicked {
//    [self.navigationController popViewControllerAnimated:YES];
//}

@end
