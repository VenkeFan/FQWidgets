//
//  WLUnloginTabController.m
//  welike
//
//  Created by gyb on 2018/8/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUnloginTabController.h"
#import "FQTabBarView.h"
#import "WLUnloginTabBarView.h"
#import "WLUnloginHomeViewController.h"
#import "WLGuideViewController.h"
#import "FQTabBarController.h"
#import "WLUnloginDiscoverViewController.h"
#import "WLNoneLoginHomeViewController.h"
#import "WLDiscoveryViewController.h"

@interface WLUnloginTabController ()<WLUnloginTabBarViewDelegate>



@end

@implementation WLUnloginTabController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.unloginTabBar];
    
    WLNoneLoginHomeViewController *unloginHomeViewController = [[WLNoneLoginHomeViewController alloc] init];
    WLDiscoveryViewController *discoveryViewController = [[WLDiscoveryViewController alloc] init];
    
    self.viewControllers = @[unloginHomeViewController, discoveryViewController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appActive) name:kWLAppDidBecomeActiveNotificationName object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect frame = self.unloginTabBar.frame;
    frame.origin.y = self.view.frame.size.height - kTabBarHeight;
    self.unloginTabBar.frame = frame;
}

-(void)appActive
{
    [self.unloginTabBar resumeAnimationPlay];
}

#pragma mark - Private

- (void)p_addSubViewController:(UIViewController *)subCtr {
    if ([self.childViewControllers containsObject:subCtr]) {
        return;
    }
    
    [self addChildViewController:subCtr];
    CGRect frame = subCtr.view.frame;
    frame.size.height -= (kTabBarHeight);
    subCtr.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - kTabBarHeight);
    [self.view insertSubview:subCtr.view belowSubview:self.unloginTabBar];
}

#pragma mark - Setter

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers {
    if (viewControllers.count == 0) {
        return;
    }
    
    _viewControllers = viewControllers;
    [self.view.subviews enumerateObjectsWithOptions:NSEnumerationReverse
                                         usingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                             if (![obj isEqual:self.unloginTabBar]) {
                                                 [obj removeFromSuperview];
                                             }
                                         }];
    
    [self setSelectedIndex:_selectedIndex];
}

#pragma mark - TabBarViewDelegate
- (void)tabBarView:(WLUnloginTabBarView *)tabBarView didSelectItem:(FQTabBarItem *)item index:(NSUInteger)index {
    switch (item.type) {
        case FQTabBarItemType_Exclusive:
            [self setSelectedIndex:index];
            break;
            
        case FQTabBarItemType_Present: {
            [self clickedUnExclusiveViewController];
        }
            break;
    }
}



#pragma mark - Getter

- (WLUnloginTabBarView *)unloginTabBar {
    
    if (!_unloginTabBar) {
       _unloginTabBar = [[WLUnloginTabBarView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kTabBarHeight, kScreenWidth, kTabBarHeight)];
       _unloginTabBar.delegate = self;
    }
    return _unloginTabBar;
}


- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex == _selectedIndex) {
        if (selectedIndex < self.viewControllers.count && [self.viewControllers[selectedIndex] respondsToSelector:@selector(refreshViewController)]) {
            [self.viewControllers[selectedIndex] performSelector:@selector(refreshViewController)];
        }
    }
    else {
        if (selectedIndex < self.viewControllers.count && [self.viewControllers[selectedIndex] respondsToSelector:@selector(viewControllerDidAppeared)]) {
            [self.viewControllers[selectedIndex] performSelector:@selector(viewControllerDidAppeared)];
        }
        if (_selectedIndex < self.viewControllers.count && [self.viewControllers[_selectedIndex] respondsToSelector:@selector(viewControllerWillDisappear)]) {
            [self.viewControllers[_selectedIndex] performSelector:@selector(viewControllerWillDisappear)];
        }
    }
    
    
    if (selectedIndex >= self.viewControllers.count) {
        _selectedIndex = selectedIndex;
        return;
    }
    if (_selectedIndex < self.viewControllers.count && [self.viewControllers[_selectedIndex] respondsToSelector:@selector(viewControllerWillDisappear)]) {
        [self.viewControllers[_selectedIndex] performSelector:@selector(viewControllerWillDisappear)];
    }
    self.viewControllers[_selectedIndex].view.hidden = YES;
    _selectedIndex = selectedIndex;
    
    _selectedViewController = self.viewControllers[selectedIndex];
    _selectedViewController.view.hidden = NO;
    [self p_addSubViewController:_selectedViewController];
    
    self.title = _selectedViewController.title;
    
    if (selectedIndex < self.unloginTabBar.items.count) {
        self.unloginTabBar.items[selectedIndex].selected = YES;
        [self.unloginTabBar.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isEqual:self.unloginTabBar.items[selectedIndex]]) {
                [(FQTabBarItem *)obj setSelected:NO];
            }
        }];
    }
}

- (void)clickedUnExclusiveViewController {
    WLGuideViewController *ctr = [[WLGuideViewController alloc] init];
    ctr.statusBarHidden = YES;
    [self.navigationController pushViewController:ctr animated:YES];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
