//
//  WLMagicEffectView.m
//  welike
//
//  Created by fan qi on 2018/11/27.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLMagicEffectView.h"
#import "WLMagicEffectViewModel.h"
#import "WLMagicEffectDownloadManager.h"
#import "WLMagicFilterModel.h"
#import "WLMagicPasterModel.h"
#import "WLMagicFilterCell.h"
#import "WLDynamicLoadingView.h"

@interface WLMagicEffectView () <UICollectionViewDelegate, UICollectionViewDataSource, WLMagicEffectDownloadManagerDelegate> {
    BOOL _isLoaded;
    NSInteger _selectedIndex;
}

@property (nonatomic, strong) WLMagicEffectViewModel *viewModel;
@property (nonatomic, strong) WLMagicEffectDownloadManager *downloadManager;
@property (nonatomic, strong) NSArray<WLMagicBasicModel *> *dataArray;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) WLDynamicLoadingView *loadingView;

@property (nonatomic, strong) NSMutableDictionary *downloadingDic;

@end

@implementation WLMagicEffectView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _isLoaded = NO;
        _selectedIndex = 0;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[WLMagicFilterCell class] forCellWithReuseIdentifier:reuseCellID];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_collectionView];
        
        _loadingView = [[WLDynamicLoadingView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        _loadingView.center = CGPointMake(CGRectGetWidth(self.bounds) * 0.5, 12 + CGRectGetHeight(_loadingView.bounds) * 0.5);
        _loadingView.lineWidth = 3.0;
        [self addSubview:_loadingView];
    }
    return self;
}

- (void)dealloc {
    [_downloadManager cancelAll];
}

#pragma mark - Public

- (void)display {
    if (_isLoaded) {
        return;
    }
    
    _isLoaded = YES;
    
    [self fetchData];
}

- (void)fetchData {
    [self.loadingView startAnimating];
    
    switch (self.effectType) {
        case WLMagicEffectViewType_Filter: {
            [self.viewModel fetchEffectFilterArray:^(NSArray<WLMagicFilterModel *> *list, NSError *error) {
                [self.loadingView stopAnimating];
                
                if (error) {
                    return;
                }
                self.dataArray = list;
                [self.collectionView reloadData];
            }];
        }
            break;
        case WLMagicEffectViewType_Paster: {
            [self.viewModel fetchEffectPasterArray:^(NSArray<WLMagicPasterModel *> *list, NSError *error) {
                [self.loadingView stopAnimating];
                
                if (error) {
                    return;
                }
                self.dataArray = list;
                [self.collectionView reloadData];
            }];
        }
            break;
    }
}

- (WLMagicBasicModel *)previousFilter {
    if (self.effectType == WLMagicEffectViewType_Paster) {
        return nil;
    }
    
    if (self.dataArray.count == 0) {
        return nil;
    }
    
    _selectedIndex--;
    
    if (_selectedIndex < 0) {
        _selectedIndex = self.dataArray.count - 1;
    }
    
    if (_selectedIndex >= 0 && _selectedIndex < self.dataArray.count) {
        return self.dataArray[_selectedIndex];
    }
    
    return nil;
}

- (WLMagicBasicModel *)nextFilter {
    if (self.effectType == WLMagicEffectViewType_Paster) {
        return nil;
    }
    
    if (self.dataArray.count == 0) {
        return nil;
    }
    
    _selectedIndex++;
    
    if (_selectedIndex >= self.dataArray.count) {
        _selectedIndex = 0;
    }
    
    if (_selectedIndex >= 0 && _selectedIndex < self.dataArray.count) {
        return self.dataArray[_selectedIndex];
    }
    
    return nil;
}

- (void)setCollectionLayout:(UICollectionViewFlowLayout *)collectionLayout {
    [self.collectionView setCollectionViewLayout:collectionLayout];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WLMagicFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseCellID forIndexPath:indexPath];
    if (indexPath.row < self.dataArray.count) {
        [cell setCellModel:self.dataArray[indexPath.row]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WLMagicFilterCell *cell = (WLMagicFilterCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (indexPath.row >= self.dataArray.count) {
        return;
    }
    
    WLMagicBasicModel *model = self.dataArray[indexPath.row];
    
    if (model.isDownloaded || model.resourceUrl.length == 0) {
        if (model.isSelected) {
            return;
        }
        
        NSInteger perIndex = [self p_unselectModel:model];
        NSIndexPath *preIndexPath = nil;
        if (perIndex >= 0 && perIndex < self.dataArray.count) {
            preIndexPath = [NSIndexPath indexPathForRow:perIndex inSection:0];
        }
        
        model.selected = YES;
        _selectedIndex = indexPath.row;
        
        if ([self.delegate respondsToSelector:@selector(magicEffectView:selectedModel:)]) {
            [self.delegate magicEffectView:self selectedModel:model];
        }
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        if (preIndexPath) {
            [indexPaths addObject:preIndexPath];
        }
        [indexPaths addObject:indexPath];
        
        [UIView animateWithDuration:0 animations:^{
            [collectionView performBatchUpdates:^{
                [collectionView reloadItemsAtIndexPaths:indexPaths];
            } completion:nil];
        }];
    } else if (model.isDownloading) {
        
    } else if (model.resourceUrl.length > 0) {
        [self.downloadingDic setObject:indexPath forKey:model.resourceUrl];
        
        [self.downloadManager downloadEffect:model];
        
        cell.progressLayer.strokeEnd = 0.01;
        cell.progressLayer.hidden = NO;
        cell.downloadLayer.hidden = YES;
    }
}

#pragma mark - WLMagicEffectDownloadManagerDelegate

- (void)magicEffectDownloadManagerDidCompleted:(NSString *)requestUrlPath
                                       dstPath:(NSString *)dstPath
                                         error:(NSError *)error {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [self.downloadingDic objectForKey:requestUrlPath];
        if (!indexPath) {
            return;
        }
        
        WLMagicFilterCell *cell = (WLMagicFilterCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        cell.progressLayer.hidden = YES;
        cell.downloadLayer.hidden = YES;
        
        if (indexPath.row < self.dataArray.count) {
            WLMagicBasicModel *model = self.dataArray[indexPath.row];
            model.downloading = NO;
            
            if (error) {
//                model.downloaded = NO;
                model.downloadProgress = 0.0;
                model.localPath = nil;
            } else {
//                model.downloaded = YES;
                model.downloadProgress = 1.0;
                model.localPath = dstPath;
            }
        }
        
        [self.downloadingDic removeObjectForKey:requestUrlPath];
    });
}

- (void)magicEffectDownloadManagerDownloading:(NSString *)requestUrlPath
                                     progress:(CGFloat)progress {
    NSIndexPath *indexPath = [self.downloadingDic objectForKey:requestUrlPath];
    WLMagicFilterCell *cell = (WLMagicFilterCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    cell.progressLayer.strokeEnd = progress;
    
    if (indexPath.row < self.dataArray.count) {
        WLMagicBasicModel *model = self.dataArray[indexPath.row];
//        model.downloaded = NO;
        model.downloading = YES;
        model.downloadProgress = progress;
    }
}

#pragma mark - Private

- (NSInteger)p_unselectModel:(WLMagicBasicModel *)model {
    __block NSInteger index = -1;
    [self.dataArray enumerateObjectsWithOptions:NSEnumerationConcurrent
                                     usingBlock:^(WLMagicBasicModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                         if (![obj.ID isEqualToString:model.ID] && obj.isSelected) {
                                             index = idx;
                                             obj.selected = NO;
                                             
                                             *stop = YES;
                                         }
                                     }];
    return index;
}

#pragma mark - Getter

- (WLMagicEffectViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[WLMagicEffectViewModel alloc] init];
    }
    return _viewModel;
}

- (WLMagicEffectDownloadManager *)downloadManager {
    if (!_downloadManager) {
        _downloadManager = [[WLMagicEffectDownloadManager alloc] init];
        _downloadManager.delegate = self;
    }
    return _downloadManager;
}

- (NSMutableDictionary *)downloadingDic {
    if (!_downloadingDic) {
        _downloadingDic = [NSMutableDictionary dictionary];
    }
    return _downloadingDic;
}

@end
