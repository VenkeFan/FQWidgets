//
//  FQTabBarController.m
//  WeLike
//
//  Created by fan qi on 2018/3/27.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQTabBarController.h"
#import "WLPublishViewController.h"

@interface FQTabBarController () <FQTabBarViewDelegate>

@property (nonatomic, strong, readwrite) FQTabBarView *tabBarView;

@end

@implementation FQTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selectedIndex = 0;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tabBarView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Public

- (void)clickedUnExclusiveViewController {
    NSLog(@"点击了发布...");
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
//    subCtr.view.frame = frame;
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
    
    [self setSelectedIndex:0];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex >= self.viewControllers.count) {
        return;
    }
    
    self.viewControllers[_selectedIndex].view.hidden = YES;
    _selectedIndex = selectedIndex;
    
    _selectedViewController = self.viewControllers[selectedIndex];
    _selectedViewController.view.hidden = NO;
    [self p_addSubViewController:_selectedViewController];
    
    self.title = _selectedViewController.title;
    
    if (self.tabBarView.items[selectedIndex].badgeNum > 0) {
        self.tabBarView.items[selectedIndex].badgeNum = 0;
    }
}

#pragma mark - Getter

- (FQTabBarView *)tabBarView {
    if (!_tabBarView) {
        CGFloat y = self.navigationController ? kScreenHeight - kNavBarHeight - kTabBarHeight : kScreenHeight - kTabBarHeight;
        _tabBarView = [[FQTabBarView alloc] initWithFrame:CGRectMake(0, y, kScreenWidth, kSingleTabBarHeight)];
        _tabBarView.delegate = self;
    }
    return _tabBarView;
}

@end
