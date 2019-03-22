//
//  WLInterestFeedTableView.m
//  welike
//
//  Created by fan qi on 2018/7/25.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLInterestFeedTableView.h"
#import "WLWatchWithoutLoginRequestManager.h"
#import "WLUsersManager.h"
#import "WLRecommendUsersProvider.h"
#import "WLFeedCell.h"
#import "WLRecommendInterestsCell.h"
#import "WLRecommendUserArrayCell.h"
#import "WLVerticalItem.h"
#import "WLLoginHintView.h"
#import "WLPicPost.h"
#import "WLPicInfo.h"
#import "WLForwardPost.h"
#import "WLVideoPost.h"
#import "WLFeedDetailViewController.h"
#import "WLUserDetailViewController.h"
#import "WLTopicDetailViewController.h"
#import "WLPlayerViewController.h"
#import "WLLocationDetailViewController.h"
#import "WLShareViewController.h"
#import "WLPlayerCollectionView.h"
#import "WLMixedPlayerViewManager.h"
#import "WLTrackerLogin.h"
#import "WLInterestCollectionView.h"

static NSString * const reuseFeedCellID = @"WLFeedTableViewCellID";
static NSString * const reuseInterestsCellID = @"WLRecommendInterestsCellID";
static NSString * const reuseRecommendUserCellID = @"WLRecommendUserArrayCellID";

@interface WLInterestFeedTableView () <WLRecommendInterestsCellDelegate, WLUsersManagerDelegate>

@property (nonatomic, strong) WLWatchWithoutLoginRequestManager *manager;
@property (nonatomic, strong) WLUsersManager *userManager;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSArray<WLVerticalItem *> *recommendInterestArray;
@property (nonatomic, strong) NSMutableArray<WLUser *> *recommendUserArray;

@end

@implementation WLInterestFeedTableView {
    BOOL _isLoaded;
    BOOL _isClosedInterestsSelection;
    dispatch_group_t _taskGroup;
    WLFeedCell *_displayVideoCell;
}

@synthesize mixedPlayerView;

#pragma mark - LifeCycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _isLoaded = NO;
        _isClosedInterestsSelection = NO;
        
        self.showsVerticalScrollIndicator = YES;
        self.contentInset = UIEdgeInsetsMake(kCommonCellSpacing, 0, 0, 0);
        [self registerClass:[WLFeedCell class] forCellReuseIdentifier:reuseFeedCellID];
        [self registerClass:[WLRecommendInterestsCell class] forCellReuseIdentifier:reuseInterestsCellID];
        [self registerClass:[WLRecommendUserArrayCell class] forCellReuseIdentifier:reuseRecommendUserCellID];
        [self addTarget:self refreshAction:@selector(refreshData) moreAction:@selector(loadMoreData)];
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    
    if (!newWindow) {
        if (self.mixedPlayerView.playerView.windowMode == WLPlayerViewWindowMode_Widget) {
            [self destroyMixedPlayerView];
        }
    }
}

- (void)dealloc {
    [self destroyMixedPlayerView];
}

#pragma mark - Public

- (void)display {
    if (!_isLoaded) {
        _isLoaded = YES;
        [self beginRefresh];
    }
}

- (void)refreshFeed {
    [self beginRefresh];
}

#pragma mark - Network

- (void)fetchFeedsInGroup:(dispatch_group_t)group {
    dispatch_group_enter(group);
    
    void(^refreshFinished)(NSArray *, BOOL, NSInteger) = ^(NSArray *items, BOOL isLast, NSInteger errCode) {
        dispatch_group_leave(group);
        
        if (self.dataArray.count > 0) {
            [self.dataArray removeAllObjects];
        }
        
        if (errCode != ERROR_SUCCESS) {
            self.emptyType = WLScrollEmptyType_Empty_Network;
            return;
        }
        
        self.refreshFooterView.result = isLast ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
        
        [self.dataArray addObjectsFromArray:items];
        
        if (self.dataArray.count == 0) {
            self.emptyType = WLScrollEmptyType_Empty_Data;
        }
        
        [self appendRefreshTrackerWithFetchCount:items.count];
    };
    
    if ([self.interestId isEqualToString:kInterestForYouID]) {
        [self.manager listForMeFeedsWithResult:^(NSArray *items, BOOL isLast, NSInteger errCode) {
            refreshFinished(items, isLast, errCode);
        }
                              isRefreshFromTop:YES];
    } else if ([self.interestId isEqualToString:kInterestVideoID]) {
        [self.manager listVideoTag:^(NSArray *items, BOOL isLast, NSInteger errCode) {
            refreshFinished(items, isLast, errCode);
        } isRefreshFromTop:YES];
    } else {
        [self.manager listVerticalFeedsWithinterestId:self.interestId
                                               Result:^(NSArray *items, BOOL isLast, NSInteger errCode) {
                                                   refreshFinished(items, isLast, errCode);
                                               }
                                     isRefreshFromTop:YES];
    }
}

- (void)fetchRecommendIntersetsInGroup:(dispatch_group_t)group {
    dispatch_group_enter(group);
    
    [self.manager listInterest:^(NSArray *items, NSInteger errCode) {
        dispatch_group_leave(group);
        
        if (errCode != ERROR_SUCCESS) {
            return;
        }
        self.recommendInterestArray = items;
    }];
}

- (void)fetchRecommendUserArrayInGroup:(dispatch_group_t)group {
    dispatch_group_enter(group);
    [self.userManager tryRefreshUsersWithKeyId:nil];
}

- (void)refreshData {
    if (_taskGroup) {
        return;
    }
    
    if (self.refreshFromTop) {
        self.refreshFromTop();
    }
    
    _taskGroup = dispatch_group_create();

    [self fetchFeedsInGroup:_taskGroup];
    
    self.recommendInterestArray = nil;
    BOOL hasSelected = [(NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:kSelectionInterestsKey] count] > 0;

    if ([self.interestId isEqualToString:kInterestForYouID]) {
        if ([AppContext getInstance].accountManager.isLogin) {
            [self fetchRecommendUserArrayInGroup:_taskGroup];
        }
        
        if (NO == _isClosedInterestsSelection && NO == hasSelected) {
            [self fetchRecommendIntersetsInGroup:_taskGroup];
        }
    }
    
    dispatch_group_notify(_taskGroup, dispatch_get_main_queue(), ^{
        [self endRefresh];
        
        if (self->_recommendUserArray.count > 0) {
            [self.dataArray removeObject:self.recommendUserArray];
            
            if (self.dataArray.count >= 7) {
                [self.dataArray insertObject:self.recommendUserArray atIndex:7];
            } else {
                [self.dataArray addObject:self.recommendUserArray];
            }
        }
        
        if (self.recommendInterestArray) {
            if (self.dataArray.count > 1) {
                [self.dataArray insertObject:self.recommendInterestArray atIndex:1];
            } else {
                [self.dataArray addObject:self.recommendInterestArray];
            }
        }
        
        if (self.dataArray.count > 0) {
            self.emptyType = WLScrollEmptyType_None;
        } else if (self.dataArray.count == 0) {
            if (self.emptyType != WLScrollEmptyType_Empty_Network) {
                self.emptyType = WLScrollEmptyType_Empty_Data;
            }
        }
        
        [self reloadData];
        [self reloadEmptyData];
        
        self->_taskGroup = nil;
    });
}

- (void)loadMoreData {
    void(^moreFinished)(NSArray *, BOOL, NSInteger) = ^(NSArray *items, BOOL isLast, NSInteger errCode) {
        [self endLoadMore];
        
        if (errCode != ERROR_SUCCESS) {
            self.refreshFooterView.result = WLRefreshFooterResult_Error;
            return;
        }
        
        self.refreshFooterView.result = isLast ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
        
        if (items.count > 0) {
            [self.dataArray addObjectsFromArray:items];
            [self reloadData];
        }
        
        [self appendMoreTrackerWithFetchCount:items.count];
    };
    
    if ([self.interestId isEqualToString:kInterestForYouID]) {
        [self.manager listForMeFeedsWithResult:^(NSArray *items, BOOL isLast, NSInteger errCode) {
            moreFinished(items, isLast, errCode);
        }
                              isRefreshFromTop:NO];
    } else if ([self.interestId isEqualToString:kInterestVideoID]) {
        [self.manager listVideoTag:^(NSArray *items, BOOL isLast, NSInteger errCode) {
            moreFinished(items, isLast, errCode);
        } isRefreshFromTop:NO];
    } else {
        [self.manager listVerticalFeedsWithinterestId:self.interestId
                                               Result:^(NSArray *items, BOOL isLast, NSInteger errCode) {
                                                   moreFinished(items, isLast, errCode);
                                               }
                                     isRefreshFromTop:NO];
    }
}

#pragma mark - Share

- (void)showShareController:(WLPostBase *)feedModel {
//    NSString *imgUrl = feedModel.headUrl;
//    if (feedModel.type == WELIKE_POST_TYPE_PIC) {
//        imgUrl = [(WLPicInfo *)[(WLPicPost *)feedModel picInfoList].firstObject picUrl];
//    }
    
    WLShareModel *shareModel = [WLShareModel modelWithPost:feedModel];
    
    WLShareViewController *ctr = [[WLShareViewController alloc] init];
    ctr.shareModel = shareModel;
    [[AppContext currentViewController] presentViewController:ctr animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray.count <= indexPath.row) {
        return 0;
    }
    
    id item = self.dataArray[indexPath.row];
    
    if ([item isKindOfClass:[WLFeedLayout class]]) {
        return [self.dataArray[indexPath.row] cellHeight];
    }
    
    if ([item isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)item;
        if ([array.firstObject isKindOfClass:[WLVerticalItem class]]) {
            return [WLRecommendInterestsCell height];
        } else if ([array.firstObject isKindOfClass:[WLUser class]]) {
            return kWLRecommendUserArrayCellHeight;
        }
        return 0;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray.count <= indexPath.row) {
        return [UITableViewCell new];
    }
    
    id item = self.dataArray[indexPath.row];
    
    if ([item isKindOfClass:[WLFeedLayout class]]) {
        WLFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseFeedCellID];
        cell.delegate = self;
        [cell setLayout:(WLFeedLayout *)item];
        return cell;
    }
    
    if ([item isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)item;
        if ([array.firstObject isKindOfClass:[WLVerticalItem class]]) {
            WLRecommendInterestsCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseInterestsCellID];
            cell.delegate = self;
            [cell setDataArray:array];
            return cell;
        } else if ([array.firstObject isKindOfClass:[WLUser class]]) {
            WLRecommendUserArrayCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseRecommendUserCellID];
            [cell setCellDataArray:(NSMutableArray *)item];
            return cell;
        } else {
            [UITableViewCell new];
        }
    }
    
    return [UITableViewCell new];
}

#pragma mark - WLFeedCellDelegate

//- (void)feedCell:(WLFeedCell *)cell didClickedFeed:(WLFeedLayout *)layout {
//    WLFeedDetailViewController *ctr = [[WLFeedDetailViewController alloc] initWithOriginalFeedLayout:layout];
//    [[AppContext rootViewController] pushViewController:ctr animated:YES];
//}
//
//- (void)feedCell:(WLFeedCell *)cell didClickedUser:(NSString *)userID {
//    WLUserDetailViewController *ctr = [[WLUserDetailViewController alloc] initWithUserID:userID];
//    [[AppContext rootViewController] pushViewController:ctr animated:YES];
//}
//
//- (void)feedCell:(WLFeedCell *)cell didClickedTopic:(NSString *)topicID {
//    WLTopicDetailViewController *ctr = [[WLTopicDetailViewController alloc] initWithTopicID:topicID];
//    [[AppContext rootViewController] pushViewController:ctr animated:YES];
//}
//
//- (void)feedCell:(WLFeedCell *)cell didClickedTranspond:(WLFeedLayout *)layout {
//    [[WLLoginHintView instance] display];
//
//    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Repost];
//}
//
//- (void)feedCell:(WLFeedCell *)cell didClickedComment:(WLFeedLayout *)layout {
//    [[WLLoginHintView instance] display];
//
//    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Comment];
//}
//
//- (void)feedCell:(WLFeedCell *)cell didClickedLike:(WLFeedLayout *)layout {
//    [[WLLoginHintView instance] display];
//
//    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Like];
//}
//
//- (void)feedCell:(WLFeedCell *)cell didClickedVideo:(WLVideoPost *)videoModel {
//    [self destroyMixedPlayerView];
//
//    WLPlayerCollectionView *playerCollectionView = [[WLPlayerCollectionView alloc] initWithPostID:videoModel.pid];
//    [playerCollectionView displayWithSubView:nil videoModel:videoModel];
//}
//
//- (void)feedCell:(WLFeedCell *)cell didClickedArrow:(WLFeedLayout *)layout {
//    [[WLLoginHintView instance] display];
//
//    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Other];
//}
//
//- (void)feedCell:(WLFeedCell *)cell didClickedLocation:(WLFeedLayout *)layout {
//    [WLTrackerLogin setPageSource:WLTrackerLoginPageSource_Other];
//    kNeedLogin
//
//    WLLocationDetailViewController *locationDetailViewController = [[WLLocationDetailViewController alloc] init];
//    locationDetailViewController.placeId = layout.feedModel.location.placeId;
//    [[AppContext rootViewController] pushViewController:locationDetailViewController animated:YES];
//}
//
//- (void)feedCell:(WLFeedCell *)cell didClickedShare:(WLFeedLayout *)layout {
//    [self showShareController:layout.feedModel];
//}

#pragma mark - WLRecommendInterestsCellDelegate

- (void)interestsCell:(WLRecommendInterestsCell *)cell didSelectedItems:(NSArray *)selectedItems {
    [self.manager refreshPostCache:^(NSArray *items, NSInteger errCode) {
        if (errCode == ERROR_SUCCESS) {
            [self beginRefresh];
        }
    }];
    
    [[NSUserDefaults standardUserDefaults] setObject:selectedItems forKey:kSelectionInterestsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self removeCell:cell];
}

- (void)interestsCellDidClosed:(WLRecommendInterestsCell *)cell {
    _isClosedInterestsSelection = YES;
    
    [self removeCell:cell];
}

- (void)removeCell:(WLRecommendInterestsCell *)cell {
    NSIndexPath *deletingIndexPath = [self indexPathForCell:cell];
    if (deletingIndexPath) {
        [self.dataArray removeObject:cell.dataArray];
        [self deleteRowsAtIndexPaths:@[deletingIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - WLUsersManagerDelegate

- (void)onRefreshManager:(WLUsersManager *)manager
                   users:(NSArray *)users
                     kid:(NSString *)kid
                newCount:(NSInteger)newCount
                    last:(BOOL)last
                 errCode:(NSInteger)errCode {
    [self.recommendUserArray removeAllObjects];
    [self.recommendUserArray addObjectsFromArray:users];
    
    dispatch_group_leave(_taskGroup);
}

- (void)onReceiveHisManager:(WLUsersManager *)manager
                      users:(NSArray *)users
                        kid:(NSString *)kid
                       last:(BOOL)last
                    errCode:(NSInteger)errCode {
    
}

#pragma mark - Private

- (WLFeedCell *)p_questDisplayingCell {
    __block WLFeedCell *displayingCell = nil;
    [self.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[WLFeedCell class]]) {
            WLFeedCell *feedCell = (WLFeedCell *)obj;

            CGRect frame = [feedCell.feedView.videoView convertRect:feedCell.feedView.videoView.bounds
                                                             toView:kCurrentWindow];
            if (CGRectGetMinY(frame) > kNavBarHeight && CGRectGetMaxY(frame) <= (CGRectGetHeight(self.frame) + kNavBarHeight)) {
                displayingCell = feedCell;
                *stop = YES;
            }
        }
    }];
    
    return displayingCell;
}

#pragma mark - Getter

- (WLWatchWithoutLoginRequestManager *)manager {
    if (!_manager) {
        _manager = [[WLWatchWithoutLoginRequestManager alloc] init];
    }
    return _manager;
}

- (WLUsersManager *)userManager {
    if (!_userManager) {
        _userManager = [[WLUsersManager alloc] init];
        [_userManager setDataSourceProvider:[WLRecommendUsersProvider new]];
        _userManager.delegate = self;
    }
    return _userManager;
}

- (NSMutableArray<WLUser *> *)recommendUserArray {
    if (!_recommendUserArray) {
        _recommendUserArray = [NSMutableArray array];
    }
    return _recommendUserArray;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
