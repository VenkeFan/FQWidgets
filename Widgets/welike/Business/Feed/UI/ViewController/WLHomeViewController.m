//
//  WLHomeViewController.m
//  WeLike
//
//  Created by fan qi on 2018/3/27.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQTabBarController.h"
#import "WLHomeViewController.h"
#import "YYFPSLabel.h"

//#import "WLHomeFeedsProvider.h"
//#import "WLBannerManager.h"
//
//#import "WLMainTableView.h"
//#import "GBRefreshTableHeaderView.h"
//#import "WLBannerCell.h"
//#import "WLScrollViewCell.h"
//#import "WLUserFeedsTableView.h"

#import "WLSegmentedControl.h"
#import "WLHomeFollowingFeedsView.h"
#import "WLHomeTrendingContentView.h"
#import "WLInterestFeedTableView.h"

static NSString * const reuseBannerCellID = @"WLBannerCellID";

//@interface WLHomeViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewEmptyDelegate, UIScrollViewEmptyDataSource, GBRefreshTableHeaderViewDelegate>
//
//@property (nonatomic, strong) WLBannerManager *bannerManager;
//@property (nonatomic, strong) NSMutableArray *bannerArray;
//
//@property (nonatomic, strong) WLMainTableView *containerTableView;
//@property (nonatomic, strong) GBRefreshTableHeaderView *refreshHeaderView;
//
//@property (nonatomic, strong) WLScrollViewCell *scrollViewCell;
//@property (nonatomic, strong) WLUserFeedsTableView *feedsTableView;
//
//@end

@interface WLHomeViewController () <WLSegmentedControlDelegate, UIScrollViewDelegate, WLHomeFollowingFeedsViewDelegate>

@property (nonatomic, strong) WLSegmentedControl *segmentedCtr;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) WLHomeFollowingFeedsView *followingView;
@property (nonatomic, strong) WLHomeTrendingContentView *trendingView;

@end

@implementation WLHomeViewController {
    BOOL _hasRefreshed;
    BOOL _isForceManualRefresh;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if DEBUG
    YYFPSLabel *fpsLabel = [[YYFPSLabel alloc] initWithFrame:CGRectMake(kScreenWidth/2 + 40, kSystemStatusBarHeight, 0, 0)];
    [fpsLabel sizeToFit];
    [[UIApplication sharedApplication].keyWindow addSubview:fpsLabel];
#endif
    
    [self layoutUI];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
}

- (void)layoutUI {
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavBarHeight)];
    navView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navView];
    
    _segmentedCtr = ({
        WLSegmentedControl *ctr = [[WLSegmentedControl alloc] initWithFrame:CGRectMake(0, kSystemStatusBarHeight, kScreenWidth, CGRectGetHeight(navView.bounds) - kSystemStatusBarHeight)];
        ctr.backgroundColor = [UIColor whiteColor];
        ctr.currentIndex = 0;
        ctr.delegate = self;
        [ctr setItems:@[[AppContext getStringForKey:@"following_btn_text" fileName:@"common"],
                        [AppContext getStringForKey:@"sort_trending_text" fileName:@"common"]]];
        [navView addSubview:ctr];
        
        ctr;
    });
    
    _scrollView = ({
        UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(navView.frame), kScreenWidth, kScreenHeight - kTabBarHeight - CGRectGetMaxY(navView.frame))];
        sv.delegate = self;
        sv.showsHorizontalScrollIndicator = NO;
        sv.pagingEnabled = YES;
        [self.view addSubview:sv];
        sv;
    });
    
    _followingView = [[WLHomeFollowingFeedsView alloc] initWithFrame:_scrollView.bounds];
    _followingView.delegate = self;
    [_scrollView addSubview:_followingView];
    
    _trendingView = [[WLHomeTrendingContentView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_scrollView.bounds), 0, CGRectGetWidth(_scrollView.bounds), CGRectGetHeight(_scrollView.bounds))];
    [_scrollView addSubview:_trendingView];
    
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.bounds) * _segmentedCtr.items.count, 0);
    _scrollView.contentOffset = CGPointMake(CGRectGetWidth(_scrollView.bounds) * _segmentedCtr.currentIndex, 0);
}

#pragma mark - WLSegmentedControlDelegate

- (void)segmentedControl:(WLSegmentedControl *)control
        didSelectedIndex:(NSInteger)index
                preIndex:(NSInteger)preIndex {
    [self p_destroyPlayerView:preIndex];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.scrollView.contentOffset = CGPointMake(kScreenWidth * index, 0);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat x = scrollView.contentOffset.x;
    NSInteger index = x / kScreenWidth;
    
    self.segmentedCtr.currentIndex = index;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.segmentedCtr setLineOffsetX:scrollView.contentOffset.x];
}

#pragma mark - WLHomeFollowingFeedsViewDelegate

- (void)homeFollowingFeedsViewDidEmptyClicked:(WLHomeFollowingFeedsView *)followingView {
    if ([self.delegate respondsToSelector:@selector(homeViewControllerDidEmptyClicked:)]) {
        [self.delegate homeViewControllerDidEmptyClicked:self];
    }
}

#pragma mark - FQTabBarControllerProtocol

- (void)refreshViewController {
    _isForceManualRefresh = YES;
    
    if (self.segmentedCtr.currentIndex == 0) {
        [_followingView foreceRefresh];
    } else if (self.segmentedCtr.currentIndex == 1) {
        if (_trendingView.currentIndex >= 0 && _trendingView.currentIndex < _trendingView.subFeedViews.count) {
            [_trendingView.subFeedViews[_trendingView.currentIndex] refreshFeed];
        }
    }
}

- (void)viewControllerWillDisappear {
    [self p_destroyPlayerView:self.segmentedCtr.currentIndex];
}

#pragma mark - Private

- (void)p_destroyPlayerView:(NSInteger)index {
    if (index == 0) {
        [_followingView destroyPlayerView];
    } else if (index == 1) {
        if (_trendingView.currentIndex >= 0 && _trendingView.currentIndex < _trendingView.subFeedViews.count) {
            [_trendingView.subFeedViews[_trendingView.currentIndex] destroyMixedPlayerView];
        }
    }
}




/*
- (void)viewDidLoad {
    [super viewDidLoad];
    
#if DEBUG
    YYFPSLabel *fpsLabel = [[YYFPSLabel alloc] initWithFrame:CGRectMake(kScreenWidth/2 + 40, kSystemStatusBarHeight, 0, 0)];
    [fpsLabel sizeToFit];
    [[UIApplication sharedApplication].keyWindow addSubview:fpsLabel];
#endif
    
    [self layoutUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)layoutUI {
    self.containerTableView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight - kNavBarHeight - kTabBarHeight);
    [self.view addSubview:self.containerTableView];
    
    _refreshHeaderView = [[GBRefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -kScreenHeight, kScreenWidth, kScreenHeight) type:Normal];
    _refreshHeaderView.delegate = self;
    [self.containerTableView addSubview:_refreshHeaderView];
    
    [self beginRefresh];
}

#pragma mark - Network

- (void)beginRefresh {
    [_refreshHeaderView manualFresh:self.containerTableView];
}

- (void)endRefresh {
    [_refreshHeaderView GBRefreshScrollViewStopLoading:self.containerTableView];
}

- (void)refreshData {
    [self fetchBanner];
}

- (void)fetchBanner {
    _hasRefreshed = NO;
    [self.bannerManager loadBannerWithSucceed:^(NSArray *banners) {
        [self endRefresh];
        self->_hasRefreshed = YES;
        self->_isForceManualRefresh = NO;
        
        if (banners.count > 0) {
            [self.bannerArray removeAllObjects];
        }
        [self.bannerArray addObjectsFromArray:banners];
        
        [self.containerTableView reloadData];
        
    } failed:^(NSInteger errorCode) {
        [self endRefresh];
        self->_hasRefreshed = YES;
        self->_isForceManualRefresh = NO;
        
        [self.containerTableView reloadData];
    }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self p_sectionCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == [self p_sectionCount] - 1) {
        return [self p_scrollCellHeight];
    } else if ([self p_showBanner] && indexPath.section == 0) {
        return kWLBannerCellHeight;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == [self p_sectionCount] - 1) {
        if (!_hasRefreshed) {
            return [UITableViewCell new];
        }
        
        if (_scrollViewCell) {
            [_scrollViewCell forceRefresh];
        }
        
        if (!_scrollViewCell) {
            _scrollViewCell = [[WLScrollViewCell alloc] init];
            
            self.feedsTableView.superCell = _scrollViewCell;
            
            [_scrollViewCell setSubViews:@[self.feedsTableView]];
            [_scrollViewCell setCurrentIndex:0];
        }
        
        return _scrollViewCell;
        
    } else if ([self p_showBanner] && indexPath.section == 0) {
        WLBannerCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseBannerCellID];
        [cell setDataArray:self.bannerArray];
        return cell;
    }
    
    return nil;
}

#pragma mark - GBRefreshTableHeaderViewDelegate

- (void)GBRefreshScrollViewStartLoading {
    [self refreshData];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_refreshHeaderView GBRefreshScrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_refreshHeaderView GBRefreshScrollViewDidScroll:scrollView];
    
    if (_isForceManualRefresh == YES && [scrollView isEqual:self.containerTableView]) {
        return;
    }
    
    if (_scrollViewCell.subScrollViewScrolling) {
        self.containerTableView.contentOffset = CGPointMake(0, [self p_topCellHeight]);
        return;
    }

    if (scrollView.contentOffset.y >= [self p_topCellHeight]) {
        self.containerTableView.contentOffset = CGPointMake(0, [self p_topCellHeight]);
        _scrollViewCell.superScrollViewScrolling = NO;
    } else {
        _scrollViewCell.superScrollViewScrolling = YES;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_refreshHeaderView GBRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - FQTabBarControllerProtocol

- (void)refreshViewController {
    _isForceManualRefresh = YES;
    
    for (int i = 0; i < _scrollViewCell.subViews.count; i++) {
        [_scrollViewCell.subViews[i] setContentOffset:CGPointZero];
    }
    
    [self beginRefresh];
}

- (void)viewControllerWillDisappear {
    [self.scrollViewCell.subViews enumerateObjectsUsingBlock:^(id<WLScrollContentViewProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[WLUserFeedsTableView class]]) {
            WLUserFeedsTableView *feedsTableView = (WLUserFeedsTableView *)obj;
            [feedsTableView.tableView destroyMixedPlayerView];
        }
    }];
}

#pragma mark - UIScrollViewEmptyDelegate & UIScrollViewEmptyDataSource

- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView {
    if (self.feedsTableView.tableView.emptyType == WLScrollEmptyType_Empty_Network) {
        [self.feedsTableView.tableView beginRefresh];
    } else {
        if ([self.delegate respondsToSelector:@selector(homeViewControllerDidEmptyClicked:)]) {
            [self.delegate homeViewControllerDidEmptyClicked:self];
        }

        [self.feedsTableView.tableView reloadData];
        [self.feedsTableView.tableView reloadEmptyData];
    }
}

- (NSString *)descriptionForEmptyDataSource:(UIScrollView *)scrollView {
    if (self.feedsTableView.tableView.emptyType == WLScrollEmptyType_Empty_Data) {
        return [AppContext getStringForKey:@"feed_home_empty_note" fileName:@"feed"];
    }
    return nil;
}

- (NSString *)buttonTitleForEmptyDataSource:(UIScrollView *)scrollView {
    if (self.feedsTableView.tableView.emptyType == WLScrollEmptyType_Empty_Network) {
        return nil;
    } else {
        return [AppContext getStringForKey:@"main_tab_discover" fileName:@"feed"];
    }
}

#pragma mark - Private

- (BOOL)p_showBanner {
    return self.bannerArray.count > 0;
}

- (CGFloat)p_topCellHeight {
    CGFloat height = 0;
    if ([self p_showBanner]) {
        height += kWLBannerCellHeight;
    }
    return height;
}

- (CGFloat)p_scrollCellHeight {
    return kScreenHeight - kNavBarHeight - kTabBarHeight;
}

- (NSInteger)p_sectionCount {
    NSInteger count = 1;
    if ([self p_showBanner]) {
        count++;
    }
    return count;
}

#pragma mark - Getter

- (WLBannerManager *)bannerManager {
    if (!_bannerManager) {
        _bannerManager = [[WLBannerManager alloc] initWithType:WLBannerManagerType_Home];
    }
    return _bannerManager;
}

- (NSMutableArray *)bannerArray {
    if (!_bannerArray) {
        _bannerArray = [NSMutableArray array];
    }
    return _bannerArray;
}

- (WLMainTableView *)containerTableView {
    if (!_containerTableView) {
        WLMainTableView *tableView = [[WLMainTableView alloc] initWithFrame:CGRectZero
                                                                      style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[WLBannerCell class] forCellReuseIdentifier:reuseBannerCellID];
        _containerTableView = tableView;
    }
    return _containerTableView;
}

- (WLUserFeedsTableView *)feedsTableView {
    if (!_feedsTableView) {
        _feedsTableView = [[WLUserFeedsTableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, [self p_scrollCellHeight])];
        [_feedsTableView setProvider:[WLHomeFeedsProvider new] userID:nil];
        _feedsTableView.tableView.emptyDelegate = self;
        _feedsTableView.tableView.emptyDataSource = self;
    }
    return _feedsTableView;
}
 
*/

@end
