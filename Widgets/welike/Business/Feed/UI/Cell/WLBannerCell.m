//
//  WLBannerCell.m
//  welike
//
//  Created by fan qi on 2018/5/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLBannerCell.h"
#import "WLBannerModel.h"
#import "WLRouter.h"
#import "UIImageView+Extension.h"
#import "WLTrackerBanner.h"

@interface WLBannerCollectionCell : UICollectionViewCell

@property (nonatomic, strong) WLBannerModel *itemModel;

@end

@implementation WLBannerCollectionCell {
    UIImageView *_imgView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = kUIColorFromRGB(0xEFEFEF);
        
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kWLBannerContentHeight)];
    _imgView.clipsToBounds = YES;
    [self.contentView addSubview:_imgView];
}

#pragma mark - Public

- (void)setItemModel:(WLBannerModel *)itemModel {
    _itemModel = itemModel;
    
    _imgView.contentMode = UIViewContentModeScaleToFill;
    [_imgView fq_setImageWithURLString:itemModel.picUrl
                           placeholder:[AppContext getImageForKey:@"default_banner"]
                          cornerRadius:0.0
                             completed:^(UIImage *image, NSURL *url, NSError *error) {
                                 if (!image) {
                                     self->_imgView.image = [AppContext getImageForKey:@"default_banner"];
                                 }
                             }];
}

@end

#define kCarouselViewNumberOfSections       100

static NSString * const reuseCarouselCellID = @"reuseCarouselCellID";

@interface WLBannerCell () <UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic, assign) BOOL allowInfiniteBanner;
@property(nonatomic, assign) BOOL allowAutoNextPage;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) NSIndexPath *nextIndexPath;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;

@property(nonatomic, assign) NSInteger timeInterval;

@end

@implementation WLBannerCell {
    BOOL _beenInitialPosition;
    NSTimer *_timer;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    [self.contentView addSubview:self.collectionView];
    [self.contentView addSubview:self.pageControl];
    
    [self initialization];
}

- (void)initialization {
    _timeInterval = 2.0;
    
    _beenInitialPosition = NO;
    _allowInfiniteBanner = NO;
    _allowAutoNextPage = NO;
}

- (void)dealloc {
    [self removeTimer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.collectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), kWLBannerContentHeight);
    self.pageControl.frame = CGRectMake(0, kWLBannerContentHeight - 20, CGRectGetWidth(self.bounds), 20);
}

#pragma mark - Public

- (void)setDataArray:(NSMutableArray *)dataArray {
    _dataArray = dataArray;
    
    self.allowInfiniteBanner = dataArray.count > 1;
    self.allowAutoNextPage = dataArray.count > 1;
    
    self.pageControl.numberOfPages = dataArray.count;
    
    [self scrollToInitialAnimated:NO];
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    int section = kCarouselViewNumberOfSections;
    return self.allowInfiniteBanner ? section : 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WLBannerCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseCarouselCellID forIndexPath:indexPath];
    [cell setItemModel:self.dataArray[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WLBannerModel *m = [self.dataArray objectAtIndex:indexPath.row];
    WLRouterBuilder *builder = [WLRouterBuilder createByUri:m.linkUrl];
    [WLRouter go:builder];
    
    [WLTrackerBanner appendTrackerWithBannerAction:WLTrackerBannerAction_Click
                                            source:WLTrackerBannerSource_Unknow
                                       bannerModel:m];
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return self.collectionViewLayout.itemSize;
//}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_timer setFireDate:[NSDate distantFuture]];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_timeInterval]];
    [self reloadCurrentPageControl];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self reloadCurrentPageControl];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self reloadCurrentPageControl];
}

#pragma mark - Setter

- (void)setAllowAutoNextPage:(BOOL)allowAutoNextPage {
    if (_allowAutoNextPage == allowAutoNextPage) {
        return;
    }
    
    _allowAutoNextPage = allowAutoNextPage;
    if (allowAutoNextPage) {
        [self removeTimer];
        [self addTimer];
    } else {
        [self removeTimer];
    }
}

#pragma mark - Private

- (void)addTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval target:self selector:@selector(timerStep) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)timerStep {
    [self scrollToIndexPath:self.nextIndexPath animated:YES];
}

- (void)removeTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)scrollToIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
//    UICollectionViewCell *cell = [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
//    CGFloat f1_minX = cell.frame.origin.x;
//    CGPoint point = CGPointZero;
//    point.x = f1_minX;
//    CGPoint nextPoint = [self.collectionViewLayout targetContentOffsetForProposedContentOffset:point withScrollingVelocity:CGPointZero];
//    [self.collectionView setContentOffset:nextPoint animated:animated];
    
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:animated];
    
    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_timeInterval]];
}

- (void)scrollToInitialAnimated:(BOOL)animated {
    if (_beenInitialPosition == NO) {
        _beenInitialPosition = YES;
    } else {
        return;
    }
    int section = (self.allowInfiniteBanner ? kCarouselViewNumberOfSections : 1) / 2;
    NSIndexPath *indePath = [NSIndexPath indexPathForItem:0 inSection:section];
    
    [self.collectionView scrollToItemAtIndexPath:indePath atScrollPosition:UICollectionViewScrollPositionLeft animated:animated];
}

- (void)reloadCurrentPageControl {
    if (self.pageControl.hidden || self.pageControl.alpha == 0) {
        return;
    }
    NSInteger currentPage = self.currentIndexPath.row;
    self.pageControl.currentPage = currentPage;
}

#pragma mark - Getter

- (NSIndexPath *)currentIndexPath {
    CGPoint point = CGPointZero;
    point.x = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width / 2;
    point.y = self.collectionView.bounds.size.height / 2;
    NSIndexPath *indePath = [self.collectionView indexPathForItemAtPoint:point];
    return indePath;
}
- (NSIndexPath *)nextIndexPath {
    NSIndexPath *indexPath = nil;
    NSInteger sections = self.currentIndexPath.section;
    NSInteger row = self.currentIndexPath.row;
    if (row >= [self.collectionView numberOfItemsInSection:sections] - 1) {
        if (sections >= self.collectionView.numberOfSections - 1) {
            sections = (self.allowInfiniteBanner ? kCarouselViewNumberOfSections : 1) / 2;
        } else {
            sections++;
        }
        row = 0;
    } else {
        row ++;
    }
    indexPath = [NSIndexPath indexPathForRow:row inSection:sections];
    return indexPath;
}

- (NSIndexPath *)lastIndexPath {
    NSIndexPath *indexPath = nil;
    NSInteger sections = self.currentIndexPath.section;
    NSInteger row = self.currentIndexPath.row;
    if (row <= 0) {
        if (sections <= 0) {
            sections = (self.allowInfiniteBanner ? kCarouselViewNumberOfSections : 1) / 2;
        } else {
            sections --;
        }
        row = [self.collectionView numberOfItemsInSection:sections] - 1;
    } else {
        row --;
    }
    indexPath = [NSIndexPath indexPathForRow:row inSection:sections];
    return indexPath;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        //        _collectionView.prefetchingEnabled = NO;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[WLBannerCollectionCell class] forCellWithReuseIdentifier:reuseCarouselCellID];
    }
    return _collectionView;
}
- (UICollectionViewFlowLayout *)collectionViewLayout {
    if (!_collectionViewLayout) {
        _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionViewLayout.itemSize = CGSizeMake(kScreenWidth, kWLBannerContentHeight);
        _collectionViewLayout.minimumLineSpacing = 0;
        _collectionViewLayout.minimumInteritemSpacing = 0;
        _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _collectionViewLayout;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        _pageControl.hidesForSinglePage = YES;
    }
    return _pageControl;
}

@end
