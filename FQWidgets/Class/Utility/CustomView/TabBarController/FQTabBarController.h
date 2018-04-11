//
//  FQTabBarController.h
//  WeLike
//
//  Created by fan qi on 2018/3/27.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FQTabBarView.h"

@interface FQTabBarController : UIViewController

@property (nonatomic, copy) NSArray<UIViewController *> *viewControllers;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, weak, readonly) UIViewController *selectedViewController;
@property (nonatomic, strong, readonly) FQTabBarView *tabBarView;

- (void)clickedUnExclusiveViewController;

@end
