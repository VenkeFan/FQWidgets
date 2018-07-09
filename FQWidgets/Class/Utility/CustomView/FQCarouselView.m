//
//  FQCarouselView.m
//  FQWidgets
//
//  Created by fan qi on 2018/5/20.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQCarouselView.h"
#import "FQCarouselViewFlowLayout.h"
#import "FQCarouselCollectionCell.h"

#define kCarouselViewNumberOfSections       100

static NSString * const reuseCarouselCellID = @"reuseCarouselCellID";

@interface FQCarouselView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) FQCarouselViewFlowLayout *collectionViewLayout;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) NSIndexPath *nextIndexPath;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;

@property(nonatomic, assign) NSInteger timeInterval;

@end

@implementation FQCarouselView {
    BOOL _beenInitialPosition;
    NSTimer *_timer;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:%@", [self class], [super description]];
}

- (instancetype)init {
    if (self = [super init]) {
        [self initialization];
    }
    return self;
}

- (void)initialization {
    _timeInterval = 4.0;
    
    _beenInitialPosition = NO;
    _allowAutoNextPage = YES;
    _allowInfiniteBanner = YES;
}

- (void)dealloc {
    [self removeTimer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.collectionView.frame = self.bounds;
    self.pageControl.frame = CGRectMake(0, self.bounds.size.height - 20, CGRectGetWidth(self.bounds), 20);
    
    [self scrollToInitialAnimated:NO];
    
    [self.collectionView reloadData];
    [self scrollToMostSuitableAnimated:NO];
}

#pragma mark - Public

- (void)setAllowAutoNextPage:(BOOL)allowAutoNextPage {
    _allowAutoNextPage = allowAutoNextPage;
    if (allowAutoNextPage) {
        [self removeTimer];
        [self addTimer];
    } else {
        [self removeTimer];
    }
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    int section = kCarouselViewNumberOfSections;
    return self.allowInfiniteBanner ? section : 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FQCarouselCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseCarouselCellID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:rand()%255/255.0 green:rand()%255/255.0 blue:rand()%255/255.0 alpha:1];
    cell.title = [NSString stringWithFormat:@"测试数据: %zd", indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionViewLayout.itemSize;
}

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
    UICollectionViewCell *cell = [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    CGFloat f1_minX = cell.frame.origin.x;
    CGPoint point = CGPointZero;
    point.x = f1_minX;
    CGPoint nextPoint = [self.collectionViewLayout targetContentOffsetForProposedContentOffset:point withScrollingVelocity:CGPointZero];
    [self.collectionView setContentOffset:nextPoint animated:animated];
    
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

- (void)scrollToMostSuitableAnimated:(BOOL)animated {
    CGPoint point = [self.collectionViewLayout targetContentOffsetForProposedContentOffset:self.collectionView.contentOffset withScrollingVelocity:CGPointZero];
    [self.collectionView setContentOffset:point animated:animated];
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
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
//        _collectionView.prefetchingEnabled = NO;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[FQCarouselCollectionCell class] forCellWithReuseIdentifier:reuseCarouselCellID];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}
- (FQCarouselViewFlowLayout *)collectionViewLayout {
    if (!_collectionViewLayout) {
        _collectionViewLayout = [[FQCarouselViewFlowLayout alloc] init];
        _collectionViewLayout.itemSize = self.bounds.size;
        _collectionViewLayout.minimumLineSpacing = 0;
        _collectionViewLayout.minimumInteritemSpacing = 0;
        _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _collectionViewLayout;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.numberOfPages = 3;
        [self addSubview:_pageControl];
    }
    return _pageControl;
}

@end
