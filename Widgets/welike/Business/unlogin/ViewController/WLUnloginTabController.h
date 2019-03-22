//
//  WLUnloginTabController.h
//  welike
//
//  Created by gyb on 2018/8/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNavBarBaseViewController.h"

@class WLUnloginTabBarView;
@interface WLUnloginTabController : WLNavBarBaseViewController



@property (nonatomic, copy) NSArray<UIViewController *> *viewControllers;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, weak, readonly) UIViewController *selectedViewController;
@property (nonatomic, strong) WLUnloginTabBarView *unloginTabBar;




@end
