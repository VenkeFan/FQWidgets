//
//  WLHomeFollowingFeedsView.m
//  welike
//
//  Created by fan qi on 2018/12/19.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLHomeFollowingFeedsView.h"
#import "WLHomeFeedsProvider.h"
#import "WLBannerManager.h"

#import "WLMainTableView.h"
#import "GBRefreshTableHeaderView.h"
#import "WLBannerCell.h"
#import "WLScrollViewCell.h"
#import "WLUserFeedsTableView.h"

static NSString * const reuseBannerCellID = @"WLBannerCellID";

@interface WLHomeFollowingFeedsView () <UITableViewDelegate, UITableViewDataSource, UIScrollViewEmptyDelegate, UIScrollViewEmptyDataSource, GBRefreshTableHeaderViewDelegate>

@property (nonatomic, strong) WLBannerManager *bannerManager;
@property (nonatomic, strong) NSMutableArray *bannerArray;

@property (nonatomic, strong) WLMainTableView *containerTableView;
@property (nonatomic, strong) GBRefreshTableHeaderView *refreshHeaderView;

@property (nonatomic, strong) WLScrollViewCell *scrollViewCell;
@property (nonatomic, strong) WLUserFeedsTableView *feedsTableView;

@end

@implementation WLHomeFollowingFeedsView {
    BOOL _hasRefreshed;
    BOOL _isForceManualRefresh;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    self.containerTableView.frame = self.bounds;
    [self addSubview:self.containerTableView];
    
    _refreshHeaderView = [[GBRefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) type:Normal];
    _refreshHeaderView.delegate = self;
    [self.containerTableView addSubview:_refreshHeaderView];
    
    [self beginRefresh];
}

#pragma mark - Public

- (void)foreceRefresh {
    _isForceManualRefresh = YES;
    
    for (int i = 0; i < self.scrollViewCell.subViews.count; i++) {
        [self.scrollViewCell.subViews[i] setContentOffset:CGPointZero];
    }
    [self beginRefresh];
}

- (void)destroyPlayerView {
    [self.scrollViewCell.subViews enumerateObjectsUsingBlock:^(id<WLScrollContentViewProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[WLUserFeedsTableView class]]) {
            WLUserFeedsTableView *feedsTableView = (WLUserFeedsTableView *)obj;
            [feedsTableView.tableView destroyMixedPlayerView];
        }
    }];
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

#pragma mark - UIScrollViewEmptyDelegate & UIScrollViewEmptyDataSource

- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView {
    if (self.feedsTableView.tableView.emptyType == WLScrollEmptyType_Empty_Network) {
        [self.feedsTableView.tableView beginRefresh];
    } else {
        if ([self.delegate respondsToSelector:@selector(homeFollowingFeedsViewDidEmptyClicked:)]) {
            [self.delegate homeFollowingFeedsViewDidEmptyClicked:self];
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
    return CGRectGetHeight(self.bounds);
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
        _feedsTableView = [[WLUserFeedsTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), [self p_scrollCellHeight])];
        [_feedsTableView setProvider:[WLHomeFeedsProvider new] userID:nil];
        _feedsTableView.tableView.emptyDelegate = self;
        _feedsTableView.tableView.emptyDataSource = self;
    }
    return _feedsTableView;
}

@end
