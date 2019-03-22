//
//  WLUserAlbumView.m
//  welike
//
//  Created by fan qi on 2018/12/14.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLUserAlbumView.h"
#import "WLUserAlbumManager.h"
#import "WLUserAlbumCollectionViewCell.h"
#import "WLAlbumPicModel.h"
#import "WLRefreshFooterView.h"
#import "WLAlbumDetailViewController.h"

static NSString * const reuseUserAlbumCellID = @"WLUserAlbumCollectionViewCellKey";
static NSString * const reuseUserAlbumHeaderID = @"WLUserAlbumHeaderViewKey";

@interface WLUserAlbumReuseHeader : UICollectionReusableView

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, copy) NSString *title;

@end

@implementation WLUserAlbumReuseHeader

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.frame = CGRectMake(12, 0, CGRectGetWidth(frame) - 12 * 2, CGRectGetHeight(frame));
        _titleLab.textColor = kNameFontColor;
        _titleLab.font = kRegularFont(kNameFontSize);
        [self addSubview:_titleLab];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    _titleLab.text = title;
}

@end

@interface WLUserAlbumView () <UICollectionViewDelegate, UICollectionViewDataSource, WLUserAlbumManagerDelegate, UIScrollViewEmptyDelegate, UIScrollViewEmptyDataSource>

@property (nonatomic, strong) WLUserAlbumManager *albumManager;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<WLAlbumPicModel *> *> *dataArray;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) WLRefreshFooterView *refreshFooterView;

@end

@implementation WLUserAlbumView {
    BOOL _isLoading;
}

@synthesize hasRefreshed;
@synthesize superCell;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGFloat spacing = 3.0;
        NSInteger numberInRow = 3;
        CGFloat width = (kScreenWidth - (numberInRow - 1) * spacing) / (float)numberInRow;
        
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.itemSize = CGSizeMake(width, width);
        _layout.minimumLineSpacing = spacing;
        _layout.minimumInteritemSpacing = spacing;
        _layout.headerReferenceSize = CGSizeMake(kScreenWidth, 30);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:_layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.emptyDelegate = self;
        _collectionView.emptyDataSource = self;
        _collectionView.emptyTop = kDefaultEmptyTop;
        _collectionView.showsVerticalScrollIndicator = YES;
        [_collectionView registerClass:[WLUserAlbumCollectionViewCell class]
            forCellWithReuseIdentifier:reuseUserAlbumCellID];
        [_collectionView registerClass:[WLUserAlbumReuseHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:reuseUserAlbumHeaderID];
        [self addSubview:_collectionView];
        
        _refreshFooterView = [[WLRefreshFooterView alloc] init];
        [_refreshFooterView addTarget:self refreshAction:@selector(loadMoreData)];
        [_collectionView addSubview:_refreshFooterView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _collectionView.frame = self.bounds;
}

#pragma mark - WLScrollContentViewProtocol

- (void)refreshData {
    if (!self.hasRefreshed) {
        self.hasRefreshed = YES;
        [self loadData];
    }
}

- (void)forceRefresh {
    self.hasRefreshed = NO;
    [self refreshData];
}

#pragma mark - Network

- (void)loadData {
    self.collectionView.loading = YES;
    [self.albumManager refreshAlbumsWithUserID:self.userID];
}

- (void)loadMoreData {
    [self.albumManager loadMoreAlbums];
}

#pragma mark - WLUserAlbumManagerDelegate

- (void)albumManagerRefresh:(WLUserAlbumManager *)manager
                   pictures:(NSArray *)pictures
                       last:(BOOL)last
                    errCode:(NSInteger)errCode {
    self.collectionView.loading = NO;
    
    if (errCode != ERROR_SUCCESS) {
        self.collectionView.emptyType = WLScrollEmptyType_Empty_Network;
        [self.collectionView reloadData];
        [self.collectionView reloadEmptyData];
        return;
    }
    
    self.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
    
    if (pictures.count > 0) {
        [self.dataArray removeAllObjects];
        [self addToDataArray:pictures];
    }
    
    if (self.dataArray.count == 0) {
        self.collectionView.emptyType = WLScrollEmptyType_Empty_Data;
    }
    
    [self.collectionView reloadData];
    [self.collectionView reloadEmptyData];
}

- (void)albumManagerMore:(WLUserAlbumManager *)manager
                pictures:(NSArray *)pictures
                    last:(BOOL)last
                 errCode:(NSInteger)errCode {
    _isLoading = NO;
    self.refreshFooterView.status = WLRefreshFooterStatus_Idle;
    
    if (errCode != ERROR_SUCCESS) {
        self.refreshFooterView.result = WLRefreshFooterResult_Error;
        return;
    }
    
    self.refreshFooterView.result = last ? WLRefreshFooterResult_NoMore : WLRefreshFooterResult_HasMore;
    
    if (pictures.count > 0) {
        [self addToDataArray:pictures];
        [self.collectionView reloadData];
    }
    
    [self.collectionView reloadEmptyData];
}

- (void)addToDataArray:(NSArray *)pictures {
    for (int i = 0; i < pictures.count; i++) {
        if (![pictures[i] isKindOfClass:[WLAlbumPicModel class]]) {
            continue;
        }
        
        WLAlbumPicModel *picModel = (WLAlbumPicModel *)pictures[i];
        if ([self.dataArray.lastObject.firstObject.createdMonth isEqualToString:picModel.createdMonth]) {
            [self.dataArray.lastObject addObject:picModel];
        } else {
            NSMutableArray *subArray = [NSMutableArray array];
            [subArray addObject:picModel];
            [self.dataArray addObject:subArray];
        }
    }
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray[section].count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        WLUserAlbumReuseHeader *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                          withReuseIdentifier:reuseUserAlbumHeaderID
                                                                 forIndexPath:indexPath];
        [reusableView setTitle:self.dataArray[indexPath.section].firstObject.createdMonth];
        return reusableView;
    }
    
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WLUserAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseUserAlbumCellID forIndexPath:indexPath];
    [cell setCellModel:self.dataArray[indexPath.section][indexPath.row]];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WLUserAlbumCollectionViewCell *cell = (WLUserAlbumCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    WLAlbumDetailViewController *ctr = [[WLAlbumDetailViewController alloc] initWithPicModel:cell.cellModel itemArray:self.dataArray];
    [[AppContext rootViewController] pushViewController:ctr animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
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
    
    if (_isLoading) {
        return;
    }
    
    if (self.refreshFooterView.result == WLRefreshFooterResult_NoMore) {
        return;
    }
    
    if (self.refreshFooterView.status == WLRefreshFooterStatus_Refreshing) {
        return;
    }
    
    if (scrollView.contentSize.height > CGRectGetHeight(scrollView.bounds)) {
        if (scrollView.contentOffset.y > scrollView.contentSize.height - CGRectGetHeight(scrollView.bounds) - CGRectGetHeight(self.refreshFooterView.frame)) {
            self.refreshFooterView.status = WLRefreshFooterStatus_Refreshing;
        }
    } else if (scrollView.contentOffset.y >= 0) {
        self.refreshFooterView.status = WLRefreshFooterStatus_Refreshing;
    }
    
    
}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

#pragma mark - Getter

- (WLUserAlbumManager *)albumManager {
    if (!_albumManager) {
        _albumManager = [[WLUserAlbumManager alloc] init];
        _albumManager.delegate = self;
    }
    return _albumManager;
}

- (NSMutableArray<NSMutableArray<WLAlbumPicModel *> *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
