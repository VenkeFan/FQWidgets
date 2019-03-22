//
//  WLHomeTrendingContentView.m
//  welike
//
//  Created by fan qi on 2018/12/19.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLHomeTrendingContentView.h"
#import "WLInterestCollectionView.h"
#import "WLInterestFeedTableView.h"
#import "WLVerticalItem.h"

@interface WLHomeTrendingContentView () <WLInterestCollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) WLInterestCollectionView *interestView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong, readwrite) NSMutableArray<WLInterestFeedTableView *> *subFeedViews;
@property (nonatomic, assign, readwrite) NSInteger currentIndex;

@end

@implementation WLHomeTrendingContentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = kTableViewBgColor;
        self.currentIndex = 0;
        
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    _interestView = [[WLInterestCollectionView alloc] init];
    _interestView.delegate = self;
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = CGRectMake(0, CGRectGetMaxY(_interestView.bounds), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetMaxY(_interestView.bounds));
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    
    [self addSubview:_scrollView];
    [self addSubview:_interestView];
    
    [_interestView fetchData];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _scrollView.frame = CGRectMake(0, CGRectGetMaxY(_interestView.bounds), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetMaxY(_interestView.bounds));
}

#pragma mark - WLInterestCollectionViewDelegate

- (void)interestCollectionView:(WLInterestCollectionView *)view
             didInitLocalItems:(NSArray<WLVerticalItem *> *)localItems {
    
    [self updateScrollView:localItems subFeedViewCount:self.subFeedViews.count];
    [self.subFeedViews[self.currentIndex] display];
}

- (void)interestCollectionView:(WLInterestCollectionView *)view
               didRecviceItems:(NSArray<WLVerticalItem *> *)items {
    
    [self updateScrollView:items subFeedViewCount:self.subFeedViews.count];
}

- (void)interestCollectionView:(WLInterestCollectionView *)view
            didSetCurrentIndex:(NSInteger)currentIndex
                      preIndex:(NSInteger)preIndex {
    [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollView.bounds) * currentIndex, 0)
                             animated:NO];
    currentIndex < self.subFeedViews.count ? [self.subFeedViews[currentIndex] display] : nil;
    preIndex < self.subFeedViews.count ? [self.subFeedViews[preIndex] destroyMixedPlayerView] : nil;
    self.currentIndex = currentIndex;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat x = scrollView.contentOffset.x;
    NSInteger index = x / kScreenWidth;
    
    self.interestView.currentIndex = index;
}

#pragma mark - Private

- (void)updateScrollView:(NSArray<WLVerticalItem *> *)items subFeedViewCount:(NSInteger)subFeedViewCount {
    __weak typeof(self) weakSelf = self;
    
    for (int i = 0; i < items.count; i++) {
        WLInterestFeedTableView *feedView = [[WLInterestFeedTableView alloc] initWithFrame:CGRectMake((i + subFeedViewCount) * CGRectGetWidth(self.scrollView.bounds), 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds))];
        feedView.interestId = items[i].verticalId;
        feedView.refreshFromTop = ^{
            [weakSelf.interestView refreshIfError];
        };
        [self.scrollView addSubview:feedView];
        [self.subFeedViews addObject:feedView];
    }
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * (items.count + subFeedViewCount), CGRectGetHeight(self.scrollView.bounds));
}

#pragma mark - Getter

- (NSMutableArray<WLInterestFeedTableView *> *)subFeedViews {
    if (!_subFeedViews) {
        _subFeedViews = [NSMutableArray array];
    }
    return _subFeedViews;
}

@end
