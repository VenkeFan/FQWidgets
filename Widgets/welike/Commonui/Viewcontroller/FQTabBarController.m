//
//  FQTabBarController.m
//  WeLike
//
//  Created by fan qi on 2018/3/27.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQTabBarController.h"

@interface FQTabBarController () <FQTabBarViewDelegate>

@property (nonatomic, strong, readwrite) FQTabBarView *tabBarView;

@end

@implementation FQTabBarController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tabBarView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect frame = self.tabBarView.frame;
    frame.origin.y = self.view.frame.size.height - kTabBarHeight;
    self.tabBarView.frame = frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Public

- (void)clickedUnExclusiveViewController {
  
}

#pragma mark - FQTabBarViewDelegate

- (void)tabBarView:(FQTabBarView *)tabBarView didSelectItem:(FQTabBarItem *)item index:(NSUInteger)index {
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

#pragma mark - Private

- (void)p_addSubViewController:(UIViewController *)subCtr {
    if ([self.childViewControllers containsObject:subCtr]) {
        return;
    }
    
    [self addChildViewController:subCtr];
    CGRect frame = subCtr.view.frame;
    frame.size.height -= (kTabBarHeight);
    subCtr.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - kTabBarHeight);
    [self.view insertSubview:subCtr.view belowSubview:self.tabBarView];
}

#pragma mark - Setter

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers {
    if (viewControllers.count == 0) {
        return;
    }
    
    _viewControllers = viewControllers;
    [self.view.subviews enumerateObjectsWithOptions:NSEnumerationReverse
                                         usingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                             if (![obj isEqual:self.tabBarView]) {
                                                 [obj removeFromSuperview];
                                             }
                                         }];
    
    [self setSelectedIndex:_selectedIndex];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex >= self.viewControllers.count) {
        _selectedIndex = selectedIndex;
        return;
    }
    
    self.viewControllers[_selectedIndex].view.hidden = YES;
    _selectedIndex = selectedIndex;
    
    _selectedViewController = self.viewControllers[selectedIndex];
    _selectedViewController.view.hidden = NO;
    [self p_addSubViewController:_selectedViewController];
    
    self.title = _selectedViewController.title;
    
    if (selectedIndex < self.tabBarView.items.count) {
        self.tabBarView.items[selectedIndex].selected = YES;
        [self.tabBarView.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isEqual:self.tabBarView.items[selectedIndex]]) {
                [(FQTabBarItem *)obj setSelected:NO];
            }
        }];
    }
}

#pragma mark - Getter

- (FQTabBarView *)tabBarView {
    if (!_tabBarView) {
        _tabBarView = [[FQTabBarView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - kTabBarHeight, kScreenWidth, kTabBarHeight)];
        _tabBarView.delegate = self;
    }
    return _tabBarView;
}

@end
