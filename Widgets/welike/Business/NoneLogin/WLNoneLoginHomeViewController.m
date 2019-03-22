//
//  WLNoneLoginHomeViewController.m
//  welike
//
//  Created by fan qi on 2018/12/21.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLNoneLoginHomeViewController.h"
#import "WLHomeTrendingContentView.h"
#import "WLInterestFeedTableView.h"

@interface WLNoneLoginHomeViewController () <FQTabBarControllerProtocol>

@property (nonatomic, strong) WLHomeTrendingContentView *trendingView;

@end

@implementation WLNoneLoginHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.titleAlignment = WLNavigationBarTitleAlignment_Center;
    self.title = [AppContext getStringForKey:@"sort_trending_text" fileName:@"common"];
    
    _trendingView = [[WLHomeTrendingContentView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kNavBarHeight - kTabBarHeight)];
    [self.view addSubview:_trendingView];
}

#pragma mark - FQTabBarControllerProtocol

- (void)refreshViewController {
    if (_trendingView.currentIndex >= 0 && _trendingView.currentIndex < _trendingView.subFeedViews.count) {
        [_trendingView.subFeedViews[_trendingView.currentIndex] refreshFeed];
    }
}

- (void)viewControllerWillDisappear {
    if (_trendingView.currentIndex >= 0 && _trendingView.currentIndex < _trendingView.subFeedViews.count) {
        [_trendingView.subFeedViews[_trendingView.currentIndex] destroyMixedPlayerView];
    }
}

@end
