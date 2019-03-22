//
//  WLUnloginViewController.m
//  welike
//
//  Created by gyb on 2018/8/15.
//  Copyright © 2018年 redefine. All rights reserved.
//  2.0版本免登陆

#import "WLUnloginHomeViewController.h"
#import "WLUnloginIntrestView.h"
#import "WLRegisterMobileViewController.h"
#import "WLFeedCell.h"
#import "WLInterestFeedTableView.h"
#import "WLVerticalItem.h"
#import "WLGuideViewController.h"

@interface WLUnloginHomeViewController ()<WLUnloginIntrestViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) WLUnloginIntrestView *interestView;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<WLInterestFeedTableView *> *subViews;
@property (nonatomic, assign) NSInteger currentIndex;


@end

@implementation WLUnloginHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.navigationBar.leftBtn.hidden = YES;
    self.navigationBar.rightBtn.hidden = YES;
    self.navigationBar.titleLabel.hidden = YES;
    
    self.interestView = [[WLUnloginIntrestView alloc] init];
    self.interestView.delegate = self;
    self.interestView.top = kSystemStatusBarHeight;
    [self.navigationBar addSubview:self.interestView];
    
    [self.view addSubview:self.scrollView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight - kNavBarHeight - kTabBarHeight);
}


#pragma mark - WLELInterestViewDelegate

- (void)interestView:(WLUnloginIntrestView *)view didRecviceItems:(NSArray<WLVerticalItem *> *)items {
    
    if (self.subViews.count > 0)
    {
        [self.subViews removeAllObjects];
        [self.scrollView removeAllSubviews];
        
    }
    
    for (int i = 0; i < items.count; i++) {
        WLInterestFeedTableView *subView = [[WLInterestFeedTableView alloc] initWithFrame:CGRectMake(i * CGRectGetWidth(self.scrollView.bounds), 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds))];
        subView.interestId = items[i].verticalId;
        subView.refreshFromTop = ^{
            //当发生错误时才会刷新
            [self.interestView refreshWhenError];
        };
        [self.scrollView addSubview:subView];

        [self.subViews addObject:subView];
    }

    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * items.count, CGRectGetHeight(self.scrollView.bounds));
    _currentIndex = 0;
    [self.subViews[_currentIndex] display];
}

- (void)interestView:(WLUnloginIntrestView *)view didSetCurrentIndex:(NSInteger)currentIndex preIndex:(NSInteger)preIndex {
    [self.scrollView setContentOffset:CGPointMake(kScreenWidth * currentIndex, 0) animated:NO];
    currentIndex < self.subViews.count ? [self.subViews[currentIndex] display] : nil;
    preIndex < self.subViews.count ? [self.subViews[preIndex] destroyMixedPlayerView] : nil;
    _currentIndex = currentIndex;
}

- (void)interestView:(WLUnloginIntrestView *)view refreshWhenIntrestErrorReload:(NSArray<WLVerticalItem *> *)items withCurrentIndex:(NSInteger)currentIndex
{
    if (self.subViews.count > 0)
    {
        [self.subViews removeAllObjects];
        [self.scrollView removeAllSubviews];
        
    }
    
    for (int i = 0; i < items.count; i++) {
        WLInterestFeedTableView *subView = [[WLInterestFeedTableView alloc] initWithFrame:CGRectMake(i * CGRectGetWidth(self.scrollView.bounds), 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds))];
        subView.interestId = items[i].verticalId;
        subView.refreshFromTop = ^{
            //当发生错误时才会刷新
            [self.interestView refreshWhenError];
        };
        [self.scrollView addSubview:subView];
        
        [self.subViews addObject:subView];
    }
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * items.count, CGRectGetHeight(self.scrollView.bounds));
    _currentIndex = currentIndex;
    [self.subViews[_currentIndex] refreshFeed];
    
}


#pragma mark - FQTabBarControllerProtocol
- (void)refreshViewController {
    if (self.subViews.count > 0)
    {
        [self.subViews[_currentIndex] refreshFeed];
        //当发生错误时才会刷新
        [self.interestView refreshWhenError];
    }
}

- (void)viewControllerDidAppeared {
    
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat x = scrollView.contentOffset.x;
    NSInteger index = x / kScreenWidth;
    
    self.interestView.currentIndex = index;
}

#pragma mark - FQTabBarControllerProtocol
- (void)viewControllerWillDisappear {
    [self.subViews enumerateObjectsUsingBlock:^(WLInterestFeedTableView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj destroyMixedPlayerView];
    }];
}

#pragma mark - Event

- (void)navBarLeftBtnClicked {
    WLGuideViewController *ctr = [[WLGuideViewController alloc] init];
    ctr.statusBarHidden = YES;
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark - Getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (NSMutableArray<WLInterestFeedTableView *> *)subViews {
    if (!_subViews) {
        _subViews = [NSMutableArray array];
    }
    return _subViews;
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
