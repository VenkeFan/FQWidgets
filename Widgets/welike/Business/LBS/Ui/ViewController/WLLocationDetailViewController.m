//
//  WLLocationDetailViewController.m
//  welike
//
//  Created by gyb on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLocationDetailViewController.h"
#import "WLSegmentedControl.h"
#import "GBRefreshTableHeaderView.h"
#import "WLScrollViewCell.h"
#import "WLMainTableView.h"
#import "WLLocationDetailManager.h"
#import "WLLocationDetail.h"
#import "WLLatestLocationFeedsTableView.h"
#import "WLLocationTopView.h"
#import "WLLocationsUserlistViewController.h"
#import "WLLocationFeedsProvider.h"
#import "WLLocationHotFeedsProvider.h"
#import "WLPostViewController.h"
#import "WLLocationInfo.h"


#define kLocalTableDataObserveKey       @"tableView.hasData"

@interface WLLocationDetailViewController ()<UITableViewDelegate, UITableViewDataSource,UIScrollViewEmptyDelegate, UIScrollViewEmptyDataSource,WLSegmentedControlDelegate, WLScrollViewCellDelegate, GBRefreshTableHeaderViewDelegate,WLLocationTopViewDelegate>
{
 
}

@property (nonatomic, strong) WLLocationTopView *locationTopView;
@property (nonatomic, strong) WLLocationDetailManager *locationDetailManager;
@property (nonatomic, strong) WLMainTableView *containerTableView;
@property (nonatomic, strong) WLSegmentedControl *segmentedCtr;
@property (nonatomic, strong) GBRefreshTableHeaderView *refreshHeaderView;

@property (nonatomic, strong) WLScrollViewCell *scrollViewCell;
@property (nonatomic, strong) WLLatestLocationFeedsTableView *hotTableView;
@property (nonatomic, strong) WLLatestLocationFeedsTableView *latestTableView;

@property (nonatomic, strong) WLLocationDetail *locationDetail;
@property (nonatomic, assign) BOOL isHaveHotView;

@property (nonatomic, strong) NSMutableArray *userArray;


@end

@implementation WLLocationDetailViewController

- (void)dealloc {
  [_hotTableView removeObserver:self forKeyPath:kLocalTableDataObserveKey];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view.backgroundColor = kLightBackgroundViewColor;
    self.title = [AppContext getStringForKey:@"location_select_title" fileName:@"location"];
    
    _locationDetailManager = [[WLLocationDetailManager alloc] init];
    _userArray = [NSMutableArray array];
    
    [self layoutUI];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.containerTableView.emptyType == WLScrollEmptyType_Empty_Data) {
        [self refreshData];
    }
}


- (void)layoutUI {

    _locationTopView = [[WLLocationTopView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, 120)];
    _locationTopView.delegate = self;
    
    
    self.containerTableView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight - kNavBarHeight - kSafeAreaBottomY);
    [self.view addSubview:self.containerTableView];
    
    self.containerTableView.tableHeaderView = _locationTopView;
    
    _hotTableView = [[WLLatestLocationFeedsTableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, [self cellheight])];
    WLLocationHotFeedsProvider *hotProvider = [WLLocationHotFeedsProvider new];
    hotProvider.placeId = _placeId;
    [_hotTableView setProvider:hotProvider userID:nil];
    
    [_hotTableView addObserver:self
                        forKeyPath:kLocalTableDataObserveKey
                           options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                           context:nil];
    

    _latestTableView = [[WLLatestLocationFeedsTableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, [self cellheight])];
    WLLocationFeedsProvider *latestProvider = [WLLocationFeedsProvider new];
    latestProvider.placeId = _placeId;
    [_latestTableView setProvider:latestProvider userID:nil];
    
    
    self.hotTableView.superCell = self.scrollViewCell;
    self.latestTableView.superCell = self.scrollViewCell;
    
    
    
    _refreshHeaderView = [[GBRefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -kScreenHeight, kScreenWidth, kScreenHeight) type:Normal];
    _refreshHeaderView.delegate = self;
    [self.containerTableView addSubview:_refreshHeaderView];
    
    [self beginRefresh];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kLocalTableDataObserveKey]) {
        if ([object isEqual:self.hotTableView]) {
            if (change[NSKeyValueChangeNewKey]) {
                self.isHaveHotView = [change[NSKeyValueChangeNewKey] boolValue];
                
                if (self.isHaveHotView)
                {
                    self.hotTableView.height = [self cellheight];
                    self.latestTableView.height = [self cellheight];
                    [self.scrollViewCell setSubViews:@[self.hotTableView,self.latestTableView]];
                }
                else
                {
                    self.hotTableView.height = [self cellheight];
                    self.latestTableView.height = [self cellheight];
                    [self.scrollViewCell setSubViews:@[self.latestTableView]];
                }
                
                [self.containerTableView reloadData];
                [self.containerTableView reloadEmptyData];
            }
        }
    }
}


#pragma mark - GBRefreshTableHeaderViewDelegate

- (void)GBRefreshScrollViewStartLoading {
    [self refreshData];
}


#pragma mark - Network

- (void)beginRefresh {
    [_refreshHeaderView manualFresh:self.containerTableView];
}

- (void)endRefresh {
    [_refreshHeaderView GBRefreshScrollViewStopLoading:self.containerTableView];
}

- (void)refreshData {
    [self fetchDetailInfo];
    [self fetchUserArray];
    
    [self.hotTableView forceRefresh];
    [self.latestTableView forceRefresh];
}

- (void)fetchDetailInfo {
    
     __weak typeof(self) weakSelf = self;
    [_locationDetailManager loadLocationsDetail:_placeId succeed:^(WLLocationDetail *locationInfo) {
        
        [self endRefresh];
        
        if ([weakSelf p_isEmptyLocation:locationInfo])
        {
            weakSelf.containerTableView.emptyType = WLScrollEmptyType_Empty_Data;
        }
        else
        {
            weakSelf.containerTableView.emptyType = WLScrollEmptyType_None;
        }
        
        weakSelf.locationDetail = locationInfo;

        weakSelf.hotTableView.height = [self cellheight];
        weakSelf.latestTableView.height = [self cellheight];
        [self.scrollViewCell setSubViews:@[self.latestTableView]];


        weakSelf.locationTopView.locationDetail = weakSelf.locationDetail;
        [weakSelf.containerTableView reloadData];
        [weakSelf.containerTableView reloadEmptyData];
        
        
    } failed:^(NSString *placeId, NSInteger errorCode) {
        
        [weakSelf endRefresh];
        weakSelf.locationDetail = nil;
         weakSelf.isHaveHotView = NO;
        weakSelf.containerTableView.emptyType = WLScrollEmptyType_Empty_Network;
        [weakSelf.containerTableView reloadData];
        [weakSelf.containerTableView reloadEmptyData];
    }];
}

- (void)fetchUserArray {
    
      __weak typeof(self) weakSelf = self;
    [_locationDetailManager loadLocationDetailUsers:_placeId succeed:^(NSArray *users, NSInteger errCode) {
        
        if (users.count > 0)
        {
            [weakSelf.userArray removeAllObjects];
        }
        
        [weakSelf.userArray addObjectsFromArray:users];
        weakSelf.locationTopView.userArray = weakSelf.userArray;
        
    } failed:^(NSArray *users, NSInteger errCode) {
        
    
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
    if (self.isHaveHotView)
    {
        return kSegmentHeight;
    }
    else
    {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.isHaveHotView)
    {
        return self.segmentedCtr;
    }
    else
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self p_scrollCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return self.scrollViewCell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_refreshHeaderView GBRefreshScrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_refreshHeaderView GBRefreshScrollViewDidScroll:scrollView];
    
    if (self.scrollViewCell.subScrollViewScrolling) {
       self.containerTableView.contentOffset = CGPointMake(0, 120);
        return;
    }
    
    if (scrollView.contentOffset.y >= 120) {
        self.containerTableView.contentOffset = CGPointMake(0, 120);
        self.scrollViewCell.superScrollViewScrolling = NO;
        
        [self.segmentedCtr addShadow];
    } else {
        self.scrollViewCell.superScrollViewScrolling = YES;
        
        [self.segmentedCtr clearShadow];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_refreshHeaderView GBRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - WLScrollViewCellDelegate

- (void)userDetailCellHorizontalScrollViewDidScroll:(UIScrollView *)scrollView {
    [self.segmentedCtr setLineOffsetX:scrollView.contentOffset.x];
}

- (void)userDetailCellHorizontalScrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat x = scrollView.contentOffset.x;
    NSInteger index = x / kScreenWidth;
    
    self.segmentedCtr.currentIndex = index;
}

#pragma mark - UIScrollViewEmptyDelegate & UIScrollViewEmptyDataSource

- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView {
    WLLocationInfo *detailInfo = [[WLLocationInfo alloc] init];
    detailInfo.placeId = _placeId;
    detailInfo.name = _locationDetail.placeName;
   
    WLPostViewController *postViewController = [[WLPostViewController alloc] init];
    postViewController.locationInfo = detailInfo;
    RDRootViewController *nav = [[RDRootViewController alloc] initWithRootViewController:postViewController];
    
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

- (NSString *)descriptionForEmptyDataSource:(UIScrollView *)scrollView {
    if (self.containerTableView.emptyType == WLScrollEmptyType_Empty_Data) {
        return [AppContext getStringForKey:@"location_empty_view" fileName:@"location"];
    }
    return nil;
}

- (NSString *)buttonTitleForEmptyDataSource:(UIScrollView *)scrollView {
    return [AppContext getStringForKey:@"post" fileName:@"common"];
}

#pragma mark - WLLocationTopViewDelegate

- (void)didClickedUsers {
    WLLocationsUserlistViewController *ctr = [[WLLocationsUserlistViewController alloc] init];
    ctr.placeId = _placeId;
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark - WLSegmentedControlDelegate

- (void)segmentedControl:(WLSegmentedControl *)control didSelectedIndex:(NSInteger)index preIndex:(NSInteger)preIndex {
    if (preIndex < self.scrollViewCell.subViews.count) {
        [[(WLLatestLocationFeedsTableView *)self.scrollViewCell.subViews[preIndex] tableView] destroyMixedPlayerView];
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.scrollViewCell.currentIndex = index;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark - Private

- (NSInteger)p_sectionCount {
    return [self p_isEmptyLocation:_locationDetail] ? 0 : 1;
}

- (CGFloat)p_scrollCellHeight {
    return self.isHaveHotView ? (kScreenHeight - kNavBarHeight - 40 - kSafeAreaBottomY):(kScreenHeight - kNavBarHeight - kSafeAreaBottomY);
}




- (BOOL)p_isEmptyLocation:(WLLocationDetail *)locationDetail {
    return locationDetail.feedCount == 0;
}

- (WLSegmentedControl *)segmentedCtr {
    if (!_segmentedCtr) {
        WLSegmentedControl *segmentCtr = [[WLSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kSegmentHeight)];
        segmentCtr.backgroundColor = [UIColor whiteColor];
        segmentCtr.currentIndex = 0;
        segmentCtr.delegate = self;
        segmentCtr.items = @[[AppContext getStringForKey:@"sort_trending_text" fileName:@"common"],
                             [AppContext getStringForKey:@"sort_created_text" fileName:@"common"]];
        _segmentedCtr = segmentCtr;
    }
    return _segmentedCtr;
}

- (WLMainTableView *)containerTableView {
    if (!_containerTableView) {
        WLMainTableView *tableView = [[WLMainTableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight - kNavBarHeight - kSafeAreaBottomY)
                                                                      style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.emptyDelegate = self;
        tableView.emptyDataSource = self;
//        tableView.backgroundColor = kLightBackgroundViewColor;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.sectionHeaderHeight = kSegmentHeight;
        tableView.showsVerticalScrollIndicator = NO;
        _containerTableView = tableView;
    }
    return _containerTableView;
}

//- (WLHotLocationFeedsTableView *)hotTableView {
//    if (!_hotTableView) {
//        _hotTableView = [[WLHotLocationFeedsTableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, [self cellheight])];
//        WLLocationHotFeedsProvider *hotProvider = [WLLocationHotFeedsProvider new];
//        hotProvider.placeId = _placeId;
//        [_hotTableView setProvider:hotProvider userID:nil];
//    }
//
//
//    return _hotTableView;
//}
//
//- (WLLatestLocationFeedsTableView *)latestTableView {
//    if (!_latestTableView) {
//        _latestTableView = [[WLLatestLocationFeedsTableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 555)];
//        WLLocationFeedsProvider *latestProvider = [WLLocationFeedsProvider new];
//        latestProvider.placeId = _placeId;
//        [_latestTableView setProvider:latestProvider userID:nil];
//    }
//
//
//    return _latestTableView;
//}
//
- (WLScrollViewCell *)scrollViewCell {
    if (!_scrollViewCell) {
        _scrollViewCell = [[WLScrollViewCell alloc] init];
        _scrollViewCell.delegate = self;
    }
    return _scrollViewCell;
}


-(CGFloat)cellheight
{
    CGFloat height;
    if (_isHaveHotView)
    {
        height = kIsiPhoneX?(kScreenHeight - kNavBarHeight - 40 - kSafeAreaBottomY):(kScreenHeight - kNavBarHeight - 40);
    }
    else
    {
        height = kIsiPhoneX?(kScreenHeight - kNavBarHeight - kSafeAreaBottomY):(kScreenHeight - kNavBarHeight);
    }
    return height;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
