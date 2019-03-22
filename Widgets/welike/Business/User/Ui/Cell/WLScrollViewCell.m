//
//  WLScrollViewCell.m
//  welike
//
//  Created by fan qi on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLScrollViewCell.h"

@interface WLScrollViewCell () <UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;

@end

@implementation WLScrollViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    for (int i = 0; i < self.subViews.count; i++) {
        UIView *subView = (UIView *)self.subViews[i];
        subView.frame = CGRectMake(i * CGRectGetWidth(self.scrollView.bounds), 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds));
    }
}

#pragma mark - Public

- (void)setSubViews:(NSArray<id<WLScrollContentViewProtocol>> *)subViews {
    _subViews = subViews;
    
    [self.scrollView removeAllSubviews];
    
    for (int i = 0; i < subViews.count; i++) {
        UIView *subView = (UIView *)self.subViews[i];
        [self.scrollView addSubview:subView];
    }
    self.scrollView.contentSize = CGSizeMake(kScreenWidth * self.subViews.count, 0);
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    [self.scrollView setContentOffset:CGPointMake(kScreenWidth * currentIndex, 0)];
    
    if (currentIndex < self.subViews.count) {
        [self.subViews[currentIndex] refreshData];
    }
}

- (void)forceRefresh {
    if (self.currentIndex < self.subViews.count) {
        [self.subViews[self.currentIndex] forceRefresh];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UITableView class]]) {
        
    } else {
        if (self.superScrollViewScrolling) {
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(userDetailCellHorizontalScrollViewDidScroll:)]) {
            [self.delegate userDetailCellHorizontalScrollViewDidScroll:scrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UITableView class]]) {
        
    } else {
        if ([self.delegate respondsToSelector:@selector(userDetailCellHorizontalScrollViewDidEndDecelerating:)]) {
            [self.delegate userDetailCellHorizontalScrollViewDidEndDecelerating:scrollView];
        }
    }
}

#pragma mark - Getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, CGRectGetHeight(self.bounds))];
        sv.delegate = self;
        sv.showsVerticalScrollIndicator = NO;
        sv.showsHorizontalScrollIndicator = NO;
        sv.pagingEnabled = YES;
        sv.directionalLockEnabled = YES;
        [self.contentView addSubview:sv];
        _scrollView = sv;
    }
    return _scrollView;
}

@end


@implementation WLScrollContentView

@synthesize hasRefreshed = _hasRefreshed;
@synthesize superCell;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _hasRefreshed = NO;
        
        _tableView = [[WLBasicTableView alloc] initWithFrame:frame];
        _tableView.disableHeaderRefresh = YES;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDelegate = self;
        _tableView.emptyDataSource = self;
        _tableView.emptyTop = kDefaultEmptyTop;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        
        [self addSubview:_tableView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.tableView.frame = self.bounds;
}

#pragma mark - Public

- (void)refreshData {
    self.tableView.loading = YES;
}

- (void)forceRefresh {
    self.hasRefreshed = NO;
    [self refreshData];
}

- (void)reloadMyData {
    self.tableView.loading = NO;
    
    [self.tableView reloadData];
    [self.tableView reloadEmptyData];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UITableViewCell new];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.tableView scrollViewDidScroll:scrollView];

    if (self.superCell.superScrollViewScrolling) {
        scrollView.contentOffset = CGPointZero;
        return;
    }
    
    if (scrollView.contentOffset.y <= 0) {
        scrollView.contentOffset = CGPointZero;
        self.superCell.subScrollViewScrolling = NO;
    } else {
        self.superCell.subScrollViewScrolling = YES;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.tableView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.tableView scrollViewDidEndDecelerating:scrollView];
}

#pragma mark - UIScrollViewEmptyDelegate

- (void)emptyScrollViewDidClickedBtn:(UIScrollView *)scrollView {
    [self forceRefresh];
}

@end
