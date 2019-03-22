//
//  WLPlayerCollectionView.m
//  welike
//
//  Created by fan qi on 2018/8/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPlayerCollectionView.h"
#import "WLVideoSimilarManager.h"
#import "WLVideoPost.h"
#import "AFNetworkManager.h"
#import "WLHeadView.h"
#import "LOTAnimationView.h"
#import "WLNavBarBaseViewController.h"
#import "WLMixedPlayerViewManager.h"
#import "WLTrackerFeed.h"
#import "WLTrackerPlayer.h"
#import "WLTrackerActivity.h"

#define kAnimationDuration          0.25
#define kIsFirstPlayKey             @"kIsFirstPlayKey"

@interface WLPlayerCollectionCell : UICollectionViewCell

@property (nonatomic, strong) WLVideoPost *itemModel;
@property (nonatomic, strong, readonly) UIImageView *bgImgView;

@end

@implementation WLPlayerCollectionCell {
    UIImageView *_bgImgView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentView.clipsToBounds = YES;
        self.backgroundColor = [UIColor blackColor];
        
        [self layoutUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _bgImgView.frame = self.contentView.bounds;
}

- (void)layoutUI {
    _bgImgView = [[UIImageView alloc] init];
    _bgImgView.userInteractionEnabled = YES;
    _bgImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_bgImgView];
}

#pragma mark - Public

- (void)setItemModel:(WLVideoPost *)itemModel {
    _itemModel = itemModel;
    
    [_bgImgView fq_setImageWithURLString:itemModel.coverUrl];
}

@end

static NSString * const reuseVideoCellID = @"reuseCarouselCellID";

@interface WLPlayerCollectionView () <WLVideoSimilarManagerDelegate, WLMixedPlayerViewDelegate,
UICollectionViewDelegate, UICollectionViewDataSource> {
    NSString *_postID;
    BOOL _isDisplay;
    
    WLPlayerCollectionCell *_displayVideoCell;
    
    BOOL _isLast;
    BOOL _isLoading;
    
    CGFloat _position;
    
    WLPlayerViewOrientation _playerOrientation;
    
    CGFloat _lastOffsetY;
    
    WLVideoPost *_originPost;
    WLTrackerFeedSource _originSource;
    WLTrackerFeedSubType _originSubType;
    
    CFTimeInterval beginTime;
    CFTimeInterval endTime;
}

@property (nonatomic, strong) WLVideoSimilarManager *manager;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, strong) NSMutableArray<WLVideoPost *> *dataArray;

@property (nonatomic, weak) UIView *sourceView;

@end

@implementation WLPlayerCollectionView

@synthesize mixedPlayerView;

- (instancetype)initWithPostID:(NSString *)postID {
    if (self = [super initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight)]) {
        _postID = [postID copy];
        _isDisplay = NO;
        _isLast = NO;
        _isLoading = NO;
        _playerOrientation = WLPlayerViewOrientation_Vertical;
        
        [[WLLoginHintView instance] setStyle:WLLoginHintViewStyle_Light];
        
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    self.backgroundColor = [UIColor blackColor];
    
    [self.contentView addSubview:self.collectionView];
    [self.contentView addSubview:self.closeBtn];
    [self p_displayGuideView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.closeBtn.transform = CGAffineTransformIdentity;
    CGFloat statusBarHeight = kIsiPhoneX ? 44 : 20;
    CGFloat y = kIsiPhoneX ? statusBarHeight : 0;
    self.closeBtn.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds) - kSingleNavBarHeight, y, kSingleNavBarHeight, kSingleNavBarHeight);
    
    self.collectionView.frame = self.contentView.bounds;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    
    if (_isDisplay && self.mixedPlayerView) {
        if (!newWindow) {
            [[WLLoginHintView instance] setStyle:WLLoginHintViewStyle_Dark];
            
            _position = self.mixedPlayerView.playerView.position;
            
            if (self.mixedPlayerView.playerView.playerViewStatus == WLPlayerViewStatus_ReadyToPlay
                || self.mixedPlayerView.playerView.operateView.cacheProgress <= kMarginalCacheValue) {
                [self.mixedPlayerView.playerView stop];
            } else {
                [self.mixedPlayerView.playerView pause];
            }
        } else {
            [[WLLoginHintView instance] setStyle:WLLoginHintViewStyle_Light];
        }
    } else {
        if (newWindow && self.dataArray.count > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self mixedPlayerViewAutoPlay];
            });
        }
    }
}

- (void)dealloc {
    [[WLLoginHintView instance] setStyle:WLLoginHintViewStyle_Dark];
    
    if ([[AppContext currentViewController] isKindOfClass:[WLNavBarBaseViewController class]]) {
        [(WLNavBarBaseViewController *)[AppContext currentViewController] setNavigationBarAlwaysFront:YES];
    }
}

#pragma mark - Public

- (void)displayWithSubView:(UIView *)subView {
    [self displayWithSubView:subView videoModel:nil];
}

- (void)displayWithSubView:(UIView *)subView videoModel:(WLVideoPost *)videoModel {
    [WLTrackerPlayer setOpenType:WLTrackerPlayerOpenType_Clicked];
    
    _isDisplay = YES;
    self.sourceView = subView;
    
    if ([[AppContext currentViewController] isKindOfClass:[WLNavBarBaseViewController class]]) {
        [(WLNavBarBaseViewController *)[AppContext currentViewController] setNavigationBarAlwaysFront:NO];
    }
    
    [[AppContext currentViewController] setStatusBarHidden:YES];
    
    UIView *tempView = [[UIView alloc] initWithFrame:kScreenBounds];
    tempView.backgroundColor = [UIColor clearColor];
    [[AppContext currentViewController].view addSubview:tempView];
    
    [[AppContext currentViewController].view addSubview:self];
    
    if ([subView isKindOfClass:[WLMixedPlayerView class]]) {
        self.mixedPlayerView = (WLMixedPlayerView *)subView;
        self.mixedPlayerView.delegate = self;
        
        CGRect frame = [self.mixedPlayerView convertRect:self.mixedPlayerView.bounds
                                                  toView:[AppContext currentViewController].view];
        [[AppContext currentViewController].view addSubview:self.mixedPlayerView];
        self.mixedPlayerView.frame = frame;
        [UIView animateWithDuration:kAnimationDuration
                         animations:^{
                             self.mixedPlayerView.frame = self.bounds;
                         }
                         completion:^(BOOL finished) {
                             self.mixedPlayerView.playerView.windowMode = WLPlayerViewWindowMode_Screen;
                             if (self.mixedPlayerView.videoModel) {
                                 self->_originPost = self.mixedPlayerView.videoModel;
                                 self->_originSource = self->_originPost.trackerSource;
                                 self->_originSubType = self->_originPost.trackerSubType;
                                 
                                 self.mixedPlayerView.videoModel.trackerSource = WLTrackerFeedSource_VideoPlayer;
                                 self.mixedPlayerView.videoModel.trackerSubType = nil;
                                 [self.dataArray addObject:self.mixedPlayerView.videoModel];
                             }
                             [self.collectionView reloadData];
                             
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                 self.mixedPlayerView.frame = self.collectionView.visibleCells.firstObject.contentView.bounds;
                                 [[(WLPlayerCollectionCell *)self.collectionView.visibleCells.firstObject bgImgView] addSubview:self.mixedPlayerView];
                                 
                                 [self.mixedPlayerView layoutIfNeeded];
                             });
                         }];
        
        [WLTrackerPlayer appendTrackerWithPlayerOperateType:WLTrackerPlayerOperateType_FullScreen];
        
    } else {
        if (videoModel) {
            _originPost = videoModel;
            _originSource = _originPost.trackerSource;
            _originSubType = _originPost.trackerSubType;
            
            videoModel.trackerSource = WLTrackerFeedSource_VideoPlayer;
            videoModel.trackerSubType = nil;
            [self.dataArray addObject:videoModel];
        }
        [self.collectionView reloadData];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self mixedPlayerViewAutoPlay];
        });
    }
    
    [UIView animateWithDuration:kAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.top = 0;
                     }
                     completion:^(BOOL finished) {
                         [tempView removeFromSuperview];
                         [self loadData];
                     }];
    
    [self p_trackerAppear];
}

- (void)dismiss {
    if (self.orientation != UIDeviceOrientationPortrait) {
        [self setOrientation:UIDeviceOrientationPortrait];
    }
    _isDisplay = NO;
    [[AppContext currentViewController] setStatusBarHidden:NO];
    
    BOOL isSource = NO;
    if (self.sourceView
        && [self.mixedPlayerView.videoModel.pid isEqualToString:self->_postID]
        && (self.mixedPlayerView.playerView.playerViewStatus == WLPlayerViewStatus_Playing
            || self.mixedPlayerView.playerView.playerViewStatus == WLPlayerViewStatus_CachingPaused)) {
        
        isSource = YES;
        [self.mixedPlayerView dismiss];
    }
    
    _originPost.trackerSource = _originSource;
    _originPost.trackerSubType = _originSubType;
    
    [UIView animateWithDuration:kAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         if (!isSource) {
                             self.top = CGRectGetHeight(self.contentView.bounds);
                         } else {
                             self.alpha = 0.0;
                         }
                     }
                     completion:^(BOOL finished) {
                         if (!isSource) {
                             [self destroyMixedPlayerView];
                         }
                         
                         [self removeFromSuperview];
                     }];
    
    [self p_trackerTransition];
}

#pragma mark - Network

- (void)loadData {
    [self.manager tryRefreshVideos];
}

- (void)loadMoreData {
    [self.manager tryHisVideos];
}

#pragma mark - WLVideoSimilarManagerDelegate

- (void)onRefreshManager:(WLVideoSimilarManager *)manager videos:(NSArray *)videos last:(BOOL)last errCode:(NSInteger)errCode {
    if (errCode != ERROR_SUCCESS) {
        [self.collectionView reloadData];
        return;
    }
    
    [WLTrackerFeed appendTrackWithAction:self.dataArray.count == 0 ? WLTrackerFeedAction_Default_Refresh : WLTrackerFeedAction_Drag_Refresh
                                    type:[AppContext getInstance].accountManager.isLogin ? WLTrackerFeedSource_Discover_Hot : WLTrackerFeedSource_UnLogin
                                 subType:kWLTrackerFeedSubType_VideoSimilar
                              fetchCount:videos.count];
    
    _isLast = last;
    
    [self.dataArray addObjectsFromArray:videos];
    [self.collectionView reloadData];
}

- (void)onReceiveHisManager:(WLVideoSimilarManager *)manager videos:(NSArray *)videos last:(BOOL)last errCode:(NSInteger)errCode {
    _isLoading = NO;
    
    if (errCode != ERROR_SUCCESS) {
        _isLast = YES;
        return;
    }
    
    [WLTrackerFeed appendTrackWithAction:WLTrackerFeedAction_More
                                    type:[AppContext getInstance].accountManager.isLogin ? WLTrackerFeedSource_Discover_Hot : WLTrackerFeedSource_UnLogin
                                 subType:kWLTrackerFeedSubType_VideoSimilar
                              fetchCount:videos.count];
    
    _isLast = last;
    
    if (videos.count > 0) {
        [self.dataArray addObjectsFromArray:videos];
        [self.collectionView reloadData];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self mixedPlayerViewAutoPlay];
        });
    }
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WLPlayerCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseVideoCellID forIndexPath:indexPath];
    
    if (indexPath.row < self.dataArray.count) {
        [cell setItemModel:self.dataArray[indexPath.row]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.dataArray.count - 3) {
        if (_isLast) {
            return;
        }
        
        if (_isLoading) {
            return;
        }
        
        _isLoading = YES;
        [self loadMoreData];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_isLoading) {
        return;
    }
    [self mixedPlayerViewAutoPlay];
    [self p_scrollDirection:scrollView.contentOffset.y];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self mixedPlayerViewAutoPlay];
        [self p_scrollDirection:scrollView.contentOffset.y];
    }
}

#pragma mark - WLMixedPlayerViewProtocol

- (void)mixedPlayerViewAutoPlay {
    if ((nil == (_displayVideoCell = [self p_questDisplayingCell]))) {
        [self destroyMixedPlayerView];
        return;
    }
    
    WLVideoPost *videoModel = _displayVideoCell.itemModel;
    
    if ([self.mixedPlayerView.urlString isEqualToString:videoModel.videoUrl]
        && (self.mixedPlayerView.playerView.playerViewStatus == WLPlayerViewStatus_Playing
            || self.mixedPlayerView.playerView.playerViewStatus == WLPlayerViewStatus_CachingPaused)) {
            return;
        }
    
    [self destroyMixedPlayerView];
    self.mixedPlayerView = [[WLMixedPlayerViewManager instance] generateMixedPlayerView];
    self.mixedPlayerView.delegate = self;
    self.mixedPlayerView.videoModel = videoModel;
    self.mixedPlayerView.playerView.operateView.playerOrientation = _playerOrientation;
    self.mixedPlayerView.playerView.windowMode = WLPlayerViewWindowMode_Screen;
    
    self.mixedPlayerView.frame = _displayVideoCell.contentView.bounds;
    [_displayVideoCell.bgImgView addSubview:self.mixedPlayerView];
    
    [self.mixedPlayerView.playerView play];
}

- (void)destroyMixedPlayerView {
    if (self.mixedPlayerView) {
        self.mixedPlayerView.playerView.operateView.cacheProgress = 0.0;
        [self.mixedPlayerView.playerView stop];
        [self.mixedPlayerView removeFromSuperview];
        self.mixedPlayerView = nil;
    }
}

#pragma mark - WLMixedPlayerViewDelegate

- (void)mixedPlayerViewOrientationDidChanged:(WLMixedPlayerView *)playerView {
    if (self.orientation != UIDeviceOrientationPortrait) {
        self.orientation = UIDeviceOrientationPortrait;
    } else {
        if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
            self.orientation = UIDeviceOrientationLandscapeRight;
        } else {
            self.orientation = UIDeviceOrientationLandscapeLeft;
        }
    }
    
    [self setOrientation:self.orientation];
}

#pragma mark - Private

- (WLPlayerCollectionCell *)p_questDisplayingCell {
    __block WLPlayerCollectionCell *displayingCell = nil;
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[WLPlayerCollectionCell class]]) {
            WLPlayerCollectionCell *cell = (WLPlayerCollectionCell *)obj;
            
            CGRect frame = [cell.contentView convertRect:cell.contentView.bounds
                                                  toView:[AppContext currentViewController].view];
            if (CGRectGetMinY(frame) >= 0 && CGRectGetMaxY(frame) <= (CGRectGetHeight(self.frame))) {
                displayingCell = cell;
                *stop = YES;
            }
        }
    }];
    
    return displayingCell;
}

- (void)p_displayGuideView {
    BOOL isFirst = (nil == [[NSUserDefaults standardUserDefaults] objectForKey:kIsFirstPlayKey]);
    if (isFirst) {
        [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:kIsFirstPlayKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIView *guideView = [[UIView alloc] initWithFrame:kScreenBounds];
        guideView.backgroundColor = kUIColorFromRGBA(0x000000, 0.7);
        [self.contentView addSubview:guideView];
        
        CGFloat width = 134.0, height = 350.0;
        CGFloat y = (CGRectGetHeight(guideView.bounds) - height) * 0.5;
        LOTAnimationView *animationView = [[LOTAnimationView alloc] initWithFrame:CGRectMake(0, y, width, height)];
        animationView.center = CGPointMake(CGRectGetWidth(guideView.bounds) * 0.5, animationView.center.y);
        animationView.backgroundColor = [UIColor clearColor];
        [animationView setAnimationNamed:@"player_guide"];
        [guideView addSubview:animationView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, CGRectGetWidth(guideView.bounds) - 12 * 2, 0)];
        label.backgroundColor = [UIColor clearColor];
        label.text = [AppContext getStringForKey:@"video_guide" fileName:@"common"];
        label.font = kRegularFont(16.0);
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 0;
        [label sizeToFit];
        label.center = CGPointMake(animationView.center.x, CGRectGetMaxY(animationView.frame) + CGRectGetHeight(label.bounds) * 0.5);
        [guideView addSubview:label];
        
        [animationView playWithCompletion:^(BOOL animationFinished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [animationView playWithCompletion:^(BOOL animationFinished) {
                    [UIView animateWithDuration:0.25
                                          delay:0.25
                                        options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         guideView.alpha = 0.0;
                                     }
                                     completion:^(BOOL finished) {
                                         [guideView removeFromSuperview];
                                     }];
                }];
            });
        }];
    }
}

- (void)p_scrollDirection:(CGFloat)currentOffsetY {
    if (currentOffsetY > _lastOffsetY) {
        [WLTrackerPlayer setOpenType:WLTrackerPlayerOpenType_SlideUp];
    } else {
        [WLTrackerPlayer setOpenType:WLTrackerPlayerOpenType_SlideDown];
    }
    _lastOffsetY = currentOffsetY;
}

- (void)p_trackerAppear {
    beginTime = CACurrentMediaTime();
    [WLTrackerActivity appendTrackerWithActivityType:WLTrackerActivityType_Appear
                                                 cls:[self class]
                                            duration:0];
}

- (void)p_trackerTransition {
    endTime = CACurrentMediaTime();
    CFTimeInterval duration = (endTime - beginTime) * 1000;
    [WLTrackerActivity appendTrackerWithActivityType:WLTrackerActivityType_Transition
                                                cls:[self class]
                                            duration:duration];
}

#pragma mark - Event

- (void)closeBtnClicked {
    [self dismiss];
    
    [WLTrackerPlayer appendTrackerWithPlayerOperateType:WLTrackerPlayerOperateType_Close];
}

#pragma mark - Setter

- (void)setOrientation:(UIDeviceOrientation)orientation {
    [super setOrientation:orientation];
    
    CGSize contentSize = self.collectionView.contentSize;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:_displayVideoCell];
    CGPoint contentOffset = self.collectionView.contentOffset;
    
    switch (orientation) {
        case UIDeviceOrientationPortrait: {
            [self.mixedPlayerView.playerView setVideoGravity:WLPlayerViewGravity_ResizeAspect];
            [self.mixedPlayerView.playerView.operateView setPlayerOrientation:WLPlayerViewOrientation_Vertical];
            _playerOrientation = WLPlayerViewOrientation_Vertical;
            
            [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setItemSize:CGSizeMake(self.viewWidth, self.viewHeight)];
            contentSize.width = self.viewWidth;
            contentSize.height = self.viewHeight * self.dataArray.count;
            
            contentOffset.y = self.viewHeight * indexPath.row;
        }
            break;
        case UIDeviceOrientationLandscapeLeft: {
            [self.mixedPlayerView.playerView setVideoGravity:WLPlayerViewGravity_ResizeAspect];
            [self.mixedPlayerView.playerView.operateView setPlayerOrientation:WLPlayerViewOrientation_Horizontal];
            _playerOrientation = WLPlayerViewOrientation_Horizontal;
            
            [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setItemSize:CGSizeMake(self.viewHeight, self.viewWidth)];
            contentSize.width = self.viewHeight;
            contentSize.height = self.viewWidth * self.dataArray.count;
            
            contentOffset.y = self.viewWidth * indexPath.row;
        }
            break;
        case UIDeviceOrientationLandscapeRight: {
            [self.mixedPlayerView.playerView setVideoGravity:WLPlayerViewGravity_ResizeAspect];
            [self.mixedPlayerView.playerView.operateView setPlayerOrientation:WLPlayerViewOrientation_Horizontal];
            _playerOrientation = WLPlayerViewOrientation_Horizontal;
            
            [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setItemSize:CGSizeMake(self.viewHeight, self.viewWidth)];
            contentSize.width = self.viewHeight;
            contentSize.height = self.viewWidth * self.dataArray.count;
            
            contentOffset.y = self.viewWidth * indexPath.row;
        }
            break;
        default:
            break;
    }
    
    self.collectionView.contentSize = contentSize;
    [self.collectionView setContentOffset:contentOffset];
    
    [WLTrackerPlayer appendTrackerWithPlayerOperateType:WLTrackerPlayerOperateType_Rotate];
}

#pragma mark - Getter

- (WLVideoSimilarManager *)manager {
    if (!_manager) {
        _manager = [[WLVideoSimilarManager alloc] initWithPostID:_postID];
        _manager.delegate = self;
    }
    return _manager;
}

- (NSMutableArray<WLVideoPost *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[AppContext getImageForKey:@"common_close_white"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) collectionViewLayout:self.collectionViewLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[WLPlayerCollectionCell class] forCellWithReuseIdentifier:reuseVideoCellID];
        
        if (@available(iOS 11.0, *)){
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } 
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionViewLayout {
    if (!_collectionViewLayout) {
        _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionViewLayout.itemSize = CGSizeMake(self.viewWidth, self.viewHeight);
        _collectionViewLayout.minimumLineSpacing = 0;
        _collectionViewLayout.minimumInteritemSpacing = 0;
        _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _collectionViewLayout;
}

@end
