//
//  WLNavBarBaseViewController.m
//  welike
//
//  Created by gyb on 2018/4/25.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNavBarBaseViewController.h"

@interface WLNavBarBaseViewController () <WLNavigationBarDelegate> {
    WLNavigationBar *_navigationBar;
}

@end

@implementation WLNavBarBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _navigationBarAlwaysFront = YES;
    
    [self.view addSubview:self.navigationBar];
    
    self.navigationBar.leftBtn.hidden = !self.presentingViewController && self.navigationController.viewControllers.count <= 1;
//    self.navigationBar.rightBtn.hidden = !(self.presentingViewController && self.navigationController.viewControllers.count == 1);
    if (self.navigationController.viewControllers.count == 1 && self.presentingViewController)
    {
         [self.navigationBar setLeftBtnImageName:@"common_nav_close"];
    }
}

- (void)viewDidLayoutSubviews {
    if (_navigationBarAlwaysFront) {
        [self.view bringSubviewToFront:self.navigationBar];
    }
}

#pragma mark - Override

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    
    [self.navigationBar setTitle:title];
}

#pragma mark - WLNavigationBarDelegate

- (void)navigationBarLeftBtnDidClicked {
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)navigationBarRightBtnDidClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getter

- (WLNavigationBar *)navigationBar {
    if (!_navigationBar) {
        WLNavigationBar *bar = [[WLNavigationBar alloc] init];
        bar.delegate = self;
        _navigationBar = bar;
    }
    return _navigationBar;
}

@end

