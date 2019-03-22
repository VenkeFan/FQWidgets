//
//  WLDiscoveryViewController.m
//  WeLike
//
//  Created by fan qi on 2018/3/28.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQTabBarController.h"
#import "WLDiscoveryViewController.h"
#import "WLSearchSugViewController.h"
#import "WLTopicDetailViewController.h"

#import "WLRisingFeedsProvider.h"
#import "WLTopicManager.h"
#import "WLBannerManager.h"

#import "WLSearchBar.h"
#import "WLMainTableView.h"
#import "WLSegmentedControl.h"
#import "GBRefreshTableHeaderView.h"
#import "WLScrollViewCell.h"
#import "WLResidentTopicCell.h"
#import "WLBannerCell.h"
#import "WLDiscoverFeedsTableView.h"
#import "WLWebViewController.h"
#import "RDLocalizationManager.h"
#import "WLWatchWithoutLoginRequestManager.h"

static NSString * const reuseResidentTopicCellID = @"WLResidentTopicCellID";
static NSString * const reuseBannerCellID = @"WLBannerCellID";

@interface WLDiscoveryViewController () <WLSearchBarDelegate, UITableViewDelegate, UITableViewDataSource, WLResidentTopicCellDelegate, GBRefreshTableHeaderViewDelegate>

@property (nonatomic, strong) WLSearchBar *searchBar;

@property (nonatomic, strong) WLTopicManager *topicManager;
@property (nonatomic, strong) NSMutableArray *topicArray;

@property (nonatomic, strong) WLBannerManager *bannerManager;
@property (nonatomic, strong) NSMutableArray *bannerArray;

@property (nonatomic, strong) WLWatchWithoutLoginRequestManager *rankManager;
@property (nonatomic, copy) NSString *rankUrlStr;

@property (nonatomic, strong) WLMainTableView *containerTableView;
@property (nonatomic, strong) GBRefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *searchBtn;

@property (nonatomic, strong) WLScrollViewCell *scrollViewCell;
@property (nonatomic, strong) WLDiscoverFeedsTableView *latestTableView;

@property (nonatomic, assign) BOOL isScrollToSegmentedCtr;
@property (nonatomic, weak) UIView *statusMaskView;
@property (nonatomic, weak) UIView *sectionHeaderView;
@property (nonatomic, assign, getter=isShowShadow) BOOL showShadow;

@end

@implementation WLDiscoveryViewController {
    BOOL _hasRefreshed;
    BOOL _isForceManualRefresh;
    
    dispatch_group_t _taskGroup;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
        
    _hasRefreshed = NO;
    _isForceManualRefresh = NO;
    self.isScrollToSegmentedCtr = NO;
    
    [self layoutUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)layoutUI {
    self.searchBar = [[WLSearchBar alloc] initWithIcon:@"searchbar_icon" placeholder:[AppContext getStringForKey:@"discover_search_default" fileName:@"search"]];
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
    
    [self.searchBar addRankBtn];
    
    
    self.containerTableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kTabBarHeight);
    [self.view addSubview:self.containerTableView];
    [self.view sendSubviewToBack:self.containerTableView];

    {
        _refreshHeaderView = [[GBRefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -kScreenHeight, kScreenWidth, kScreenHeight) type:Normal];
        _refreshHeaderView.delegate = self;
        [self.containerTableView addSubview:_refreshHeaderView];

        [self beginRefresh];
    }

    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kSystemStatusBarHeight + 1.0)];
        view.backgroundColor = [UIColor whiteColor];
        view.alpha = 0.0;
        [self.view addSubview:view];
        self.statusMaskView = view;
    }
}

#pragma mark - Network

- (void)beginRefresh {
    [_refreshHeaderView manualFresh:self.containerTableView];
}

- (void)endRefresh {
    [_refreshHeaderView GBRefreshScrollViewStopLoading:self.containerTableView];
}

- (void)refreshData {
    if (_taskGroup) {
        return;
    }
    
    [self.rankManager listTrendingUsers:^(WLTrendingUserModel *model, NSString *forwardUrl, NSInteger errCode) {
        self.rankUrlStr = forwardUrl;
    }];
    
    _taskGroup = dispatch_group_create();
    
    _hasRefreshed = NO;
    
    [self fetchBannerInGroup:_taskGroup];
    
    [self fetchResidentTopicsInGroup:_taskGroup];
    
    dispatch_group_notify(_taskGroup, dispatch_get_main_queue(), ^{
        [self endRefresh];
        self->_hasRefreshed = YES;
        self->_isForceManualRefresh = NO;
        
        [self.containerTableView reloadData];
        
        self->_taskGroup = nil;
    });
}

- (void)fetchBannerInGroup:(dispatch_group_t)group {
    dispatch_group_enter(group);

    [self.bannerManager loadBannerWithSucceed:^(NSArray *banners) {
        if (banners.count > 0) {
            [self.bannerArray removeAllObjects];
        }
        [self.bannerArray addObjectsFromArray:banners];

        dispatch_group_leave(group);

    } failed:^(NSInteger errorCode) {
        dispatch_group_leave(group);
    }];
}

- (void)fetchResidentTopicsInGroup:(dispatch_group_t)group {
    dispatch_group_enter(group);
    
    [self.topicManager loadResidentTopicWithSucceed:^(NSArray *dataArray) {
        if (dataArray.count > 0) {
            [self.topicArray removeAllObjects];
        }
        [self.topicArray addObjectsFromArray:dataArray];

        dispatch_group_leave(group);
    } failed:^(NSString *topicID, NSInteger errorCode) {
        dispatch_group_leave(group);
    }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self p_sectionCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == [self p_sectionCount] - 1) {
        return kSegmentHeight;
    }
    
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == [self p_sectionCount] - 1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kSegmentHeight)];
        view.backgroundColor = [UIColor whiteColor];
        
        self.backBtn.frame = CGRectMake(0, 0, CGRectGetHeight(view.bounds), CGRectGetHeight(view.bounds));
        [view addSubview:self.backBtn];
        
        self.searchBtn.frame = CGRectMake(CGRectGetWidth(view.bounds) - CGRectGetHeight(view.bounds), 0, CGRectGetHeight(view.bounds), CGRectGetHeight(view.bounds));
        [view addSubview:self.searchBtn];
        
        {
            UILabel *label = [[UILabel alloc] init];
            label.text = [AppContext getStringForKey:@"sort_rising_text" fileName:@"common"];
            label.textColor = kNameFontColor;
            label.font = kBoldFont(kMediumNameFontSize);
            label.textAlignment = NSTextAlignmentCenter;
            [label sizeToFit];
            label.center = CGPointMake(CGRectGetWidth(view.bounds) * 0.5, CGRectGetHeight(view.bounds) * 0.5);
            [view addSubview:label];
            
            CGFloat padding = 5.0;
            
            UILabel *fixLab = [[UILabel alloc] init];
            fixLab.text = @"//";
            fixLab.textColor = kMainColor;
            fixLab.font = kBoldFont(11);
            [fixLab sizeToFit];
            fixLab.center = CGPointMake(CGRectGetMinX(label.frame) - CGRectGetWidth(fixLab.frame) - padding, label.center.y);
            [view addSubview:fixLab];
            
            fixLab = [[UILabel alloc] init];
            fixLab.text = @"//";
            fixLab.textColor = kMainColor;
            fixLab.font = kBoldFont(11);
            [fixLab sizeToFit];
            fixLab.center = CGPointMake(CGRectGetMaxX(label.frame) + CGRectGetWidth(fixLab.frame) + padding, label.center.y);
            [view addSubview:fixLab];
        }
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.bounds) - 1.0, CGRectGetWidth(view.bounds), 1.0)];
        line.backgroundColor = kSeparateLineColor;
        [view addSubview:line];
        
        self.sectionHeaderView = view;
        
        return view;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == [self p_sectionCount] - 1) {
        return [self p_scrollCellHeight];
    } else if ([self p_showBanner] && indexPath.section == 0) {
        return kWLBannerCellHeight;
    } else if ([self p_showResidentTopic]) {
        return kWLResidentTopicCellHeight;
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
            
            self.latestTableView.superCell = _scrollViewCell;
            
            [_scrollViewCell setSubViews:@[self.latestTableView]];
            [_scrollViewCell setCurrentIndex:0];
        }
        
        return _scrollViewCell;
        
    } else if ([self p_showBanner] && indexPath.section == 0) {
        WLBannerCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseBannerCellID];
        [cell setDataArray:self.bannerArray];
        return cell;
    } else if ([self p_showResidentTopic]) {
        WLResidentTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseResidentTopicCellID];
        [cell setDataArray:self.topicArray];
        cell.delegate = self;
        return cell;
    }
    
    return [UITableViewCell new];
}

#pragma mark - WLResidentTopicCellDelegate

- (void)residentTopicCell:(WLResidentTopicCell *)cell didClickedTopic:(NSString *)topicID {
    WLTopicDetailViewController *ctr = [[WLTopicDetailViewController alloc] initWithTopicID:topicID];
    [self.navigationController pushViewController:ctr animated:YES];
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
    
    [self p_updateStatusMaskViewAlphaWithOffsetY:scrollView.contentOffset.y];
    
    if (_isForceManualRefresh == YES && [scrollView isEqual:self.containerTableView]) {
        return;
    }

    if (self.isScrollToSegmentedCtr) {
        self.containerTableView.contentOffset = CGPointMake(0, [self p_topCellHeight]);
        return;
    }
    
    if (scrollView.contentOffset.y >= [self p_topCellHeight]) {
        self.containerTableView.contentOffset = CGPointMake(0, [self p_topCellHeight]);
        _scrollViewCell.superScrollViewScrolling = NO;

        self.isScrollToSegmentedCtr = YES;

    } else {
        _scrollViewCell.superScrollViewScrolling = YES;
        
        self.isScrollToSegmentedCtr = NO;
        
        if (scrollView.contentOffset.y >= -scrollView.contentInset.top) {
            self.searchBar.transform = CGAffineTransformMakeTranslation(0, -(scrollView.contentOffset.y + scrollView.contentInset.top));
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_refreshHeaderView GBRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - WLSearchBarDelegate

- (void)onClickSearchBar:(WLSearchBar *)searchBar {
    WLSearchSugViewController *vc = [[WLSearchSugViewController alloc] init];
    [[AppContext rootViewController] pushViewController:vc animated:NO];
}

- (void)onClickRank {
    NSString *language = [[RDLocalizationManager getInstance] getCurrentLanguage];
    
    NSString *urlStr = nil;
    
    if (self.rankUrlStr.length == 0) {
        if ([AppContext getInstance].accountManager.isLogin) {
            urlStr = [NSString stringWithFormat:@"%@discovery/user/leaderboard/forward?userId=%@&token=%@&la=%@&source=web&ve=%@&appType=0",
                      [AppContext getHostName],
                      [AppContext getInstance].accountManager.myAccount.uid,
                      [AppContext getInstance].accountManager.myAccount.accessToken,
                      language,
                      [LuuUtils appVersion]];
        } else {
            urlStr = [NSString stringWithFormat:@"%@discovery/skip/user/leaderboard/forward?userId=0&token=null&la=%@&source=web&ve=%@&appType=0",
                      [AppContext getHostName],
                      language,
                      [LuuUtils appVersion]];
        }
    } else {
        urlStr = [NSString stringWithFormat:@"%@/%@", [AppContext getHostName], self.rankUrlStr];
    }
    
    WLWebViewController *webViewController = [[WLWebViewController alloc] initWithUrl:urlStr];
    [[AppContext rootViewController] pushViewController:webViewController animated:YES];
}

#pragma mark - FQTabBarControllerProtocol

- (void)refreshViewController {
    if (_isForceManualRefresh) {
        return;
    }
    
    for (int i = 0; i < _scrollViewCell.subViews.count; i++) {
        [_scrollViewCell.subViews[i] setContentOffset:CGPointZero];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isScrollToSegmentedCtr = NO;
        [self.containerTableView setContentOffset:CGPointMake(0, -self.containerTableView.contentInset.top) animated:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self->_isForceManualRefresh = YES;
            [self beginRefresh];
        });
    });
}

- (void)viewControllerWillDisappear {
    [self.scrollViewCell.subViews enumerateObjectsUsingBlock:^(id<WLScrollContentViewProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[WLDiscoverFeedsTableView class]]) {
            WLDiscoverFeedsTableView *feedsTableView = (WLDiscoverFeedsTableView *)obj;
            [feedsTableView.tableView destroyMixedPlayerView];
        }
    }];
}

#pragma mark - Private

- (BOOL)p_showResidentTopic {
    return self.topicArray.count >= kDefaultButtonCount;
}

- (BOOL)p_showBanner {
    return self.bannerArray.count > 0;
}

- (CGFloat)p_topCellHeight {
    CGFloat height = 0;
    if ([self p_showResidentTopic]) {
        height += kWLResidentTopicCellHeight;
    }
    if ([self p_showBanner]) {
        height += kWLBannerCellHeight;
    }
    
    height -= kSystemStatusBarHeight;
    
    return height;
}

- (CGFloat)p_scrollCellHeight {
  return kScreenHeight - kSegmentHeight - kTabBarHeight - kSystemStatusBarHeight;
}

- (NSInteger)p_sectionCount {
    NSInteger count = 1;
    if ([self p_showResidentTopic]) {
        count++;
    }
    if ([self p_showBanner]) {
        count++;
    }
    return count;
}

- (void)p_updateStatusMaskViewAlphaWithOffsetY:(CGFloat)offsetY {
    CGFloat ratio = (offsetY + self.containerTableView.contentInset.top) / fabs([self p_topCellHeight]);
    self.statusMaskView.alpha = ratio;
}

- (void)p_addShadow {
    if (self.isShowShadow) {
        return;
    }
    
    _showShadow = YES;
    self.sectionHeaderView.layer.shadowColor = kUIColorFromRGB(0x000000).CGColor;
    self.sectionHeaderView.layer.shadowOffset = CGSizeMake(0, 1);
    self.sectionHeaderView.layer.shadowOpacity = 0.1;
    self.sectionHeaderView.layer.shadowPath = CGPathCreateWithRect(self.sectionHeaderView.bounds, NULL);
}

- (void)p_clearShadow {
    if (!self.isShowShadow) {
        return;
    }
    
    _showShadow = NO;
    self.sectionHeaderView.layer.shadowColor = kUIColorFromRGBA(0x000000, 0.0).CGColor;
}

#pragma mark - Event

- (void)backBtnClicked {
    for (int i = 0; i < _scrollViewCell.subViews.count; i++) {
        [_scrollViewCell.subViews[i] setContentOffset:CGPointZero];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isScrollToSegmentedCtr = NO;
        [self.containerTableView setContentOffset:CGPointMake(0, -self.containerTableView.contentInset.top) animated:YES];
    });
}

- (void)searchBtnClicked {
    WLSearchSugViewController *vc = [[WLSearchSugViewController alloc] init];
    [[AppContext rootViewController] pushViewController:vc animated:NO];
}

#pragma mark - Setter

- (void)setIsScrollToSegmentedCtr:(BOOL)isScrollToSegmentedCtr {
    _isScrollToSegmentedCtr = isScrollToSegmentedCtr;
    
    if (isScrollToSegmentedCtr) {
        self.backBtn.hidden = self.searchBtn.hidden = NO;
        self.latestTableView.displayRefreshHeaderView = YES;
        
        [self p_addShadow];
    } else {
        self.backBtn.hidden = self.searchBtn.hidden = YES;
        self.latestTableView.displayRefreshHeaderView = NO;
        
        [self p_clearShadow];
    }
}

#pragma mark - Getter

- (WLTopicManager *)topicManager {
    if (!_topicManager) {
        _topicManager = [[WLTopicManager alloc] init];
    }
    return _topicManager;
}

- (NSMutableArray *)topicArray {
    if (!_topicArray) {
        _topicArray = [NSMutableArray array];
    }
    return _topicArray;
}

- (WLBannerManager *)bannerManager {
    if (!_bannerManager) {
        _bannerManager = [[WLBannerManager alloc] initWithType:WLBannerManagerType_Discovery];
    }
    return _bannerManager;
}

- (NSMutableArray *)bannerArray {
    if (!_bannerArray) {
        _bannerArray = [NSMutableArray array];
    }
    return _bannerArray;
}

- (WLWatchWithoutLoginRequestManager *)rankManager {
    if (!_rankManager) {
        _rankManager = [[WLWatchWithoutLoginRequestManager alloc] init];
    }
    return _rankManager;
}

- (WLMainTableView *)containerTableView {
    if (!_containerTableView) {
        WLMainTableView *tableView = [[WLMainTableView alloc] initWithFrame:CGRectZero
                                                                      style:UITableViewStyleGrouped];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.sectionHeaderHeight = kSegmentHeight;
        tableView.sectionFooterHeight = CGFLOAT_MIN;
        tableView.showsVerticalScrollIndicator = NO;
        [tableView registerClass:[WLResidentTopicCell class] forCellReuseIdentifier:reuseResidentTopicCellID];
        [tableView registerClass:[WLBannerCell class] forCellReuseIdentifier:reuseBannerCellID];
        if (@available(iOS 11.0, *)) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.searchBar.bounds), 0, 0, 0);
        
        _containerTableView = tableView;
    }
    return _containerTableView;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.hidden = YES;
        btn.frame = CGRectMake(0, 0, kSingleNavBarHeight, kSingleNavBarHeight);
        [btn setImage:[AppContext getImageForKey:@"common_icon_back"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        _backBtn = btn;
    }
    return _backBtn;
}

- (UIButton *)searchBtn {
    if (!_searchBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.hidden = YES;
        btn.frame = CGRectMake(0, 0, kSingleNavBarHeight, kSingleNavBarHeight);
        [btn setImage:[AppContext getImageForKey:@"common_icon_search"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(searchBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        _searchBtn = btn;
    }
    return _searchBtn;
}

- (WLDiscoverFeedsTableView *)latestTableView {
    if (!_latestTableView) {
        _latestTableView = [[WLDiscoverFeedsTableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, [self p_scrollCellHeight])];
        [_latestTableView setProvider:[WLRisingFeedsProvider new] userID:nil];
    }
    return _latestTableView;
}

@end
