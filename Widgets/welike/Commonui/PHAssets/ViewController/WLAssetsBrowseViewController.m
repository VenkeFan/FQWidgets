//
//  WLAssetsBrowseViewController.m
//  WeLike
//
//  Created by fan qi on 2018/4/8.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLAssetsBrowseViewController.h"
#import "WLImageButton.h"
#import "WLPlayerViewController.h"
#import "FQAssetsBrowseCell.h"
#import "WLAssetsManager.h"

static NSString * const reusCellID = @"FQAssetsBrowseCell";

@interface WLAssetsBrowseViewController () <UICollectionViewDelegate, UICollectionViewDataSource, FQAssetsBrowseCellDelegate>

@property (nonatomic, copy) NSArray<WLAssetModel *> *itemArray;

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) WLImageButton *checkBtn;

@end

@implementation WLAssetsBrowseViewController

#pragma mark - LifeCycle

- (instancetype)initWithItemArray:(NSArray<WLAssetModel *> *)itemArray checkedNumber:(NSInteger)checkedNumber {
    if (self = [super init]) {
        _itemArray = itemArray;
        _checkedNumber = checkedNumber;
        _currentIndex = 0;
        _isPhotoAlbum = YES;
    }
    return self;
}

- (instancetype)initWithItemArray:(NSArray<WLAssetModel *> *)itemArray currentIndex:(NSInteger)currentIndex {
    if (self = [super init]) {
        _itemArray = itemArray;
        _checkedNumber = 0;
        _currentIndex = currentIndex;
        _isPhotoAlbum = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self layoutUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)layoutUI {
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(self.currentIndex * CGRectGetWidth(self.collectionView.bounds), 0)];
    
    [self.view addSubview:self.checkBtn];
    [self p_setCheckButtonWithItemModel:self.itemArray[self.currentIndex]];
    
    self.confirmBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageWithColor:kLargeBtnDisableColor] forState:UIControlStateDisabled];
        btn.enabled = _checkedNumber > 0;
        btn.frame = CGRectMake(kLargeBtnXMargin, kScreenHeight - kLargeBtnYMargin - kLargeBtnHeight - kSafeAreaBottomY, kScreenWidth - kLargeBtnXMargin * 2, kLargeBtnHeight);
        
        WLAssetModel *itemModel = self.currentIndex < self.itemArray.count ? self.itemArray[self.currentIndex] : nil;
        if (itemModel.type == WLAssetModelType_Video) {
            [btn setTitle:AssetsConfirmBtnTitle(_checkedNumber, kMaxCheckedVideoLimit) forState:UIControlStateNormal];
        } else {
            [btn setTitle:AssetsConfirmBtnTitle(_checkedNumber, kMaxCheckedNumberLimit) forState:UIControlStateNormal];
        }
        
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = kBoldFont(kNameFontSize);
        btn.layer.cornerRadius = kLargeBtnRadius;
        btn.layer.masksToBounds = YES;
        [btn addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:self.confirmBtn];
    
    if (_isPhotoAlbum == NO) {
        self.checkBtn.hidden = YES;
        self.confirmBtn.hidden = YES;
        self.navigationBar.hidden = YES;
        
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.frame = CGRectMake(0, kSystemStatusBarHeight, kSingleNavBarHeight, kSingleNavBarHeight);
        [leftBtn setImage:[AppContext getImageForKey:@"common_icon_back"] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(closeBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:leftBtn];
    }
}

#pragma mark - Public

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    
    self.navigationBar.title = [NSString stringWithFormat:@"%ld / %ld", (long)(currentIndex + 1), (long)self.itemArray.count];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.itemArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FQAssetsBrowseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusCellID forIndexPath:indexPath];
    [cell setItemModel:self.itemArray[indexPath.row]];
    cell.delegate = self;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.itemArray[indexPath.row].asset.mediaType == PHAssetMediaTypeVideo) {
//        WLAVPlayerView *playerView = [(FQAssetsBrowseCell *)cell playerView];
//        if (playerView.playerViewStatus == WLPlayerViewStatus_Playing || playerView.playerViewStatus == WLPlayerViewStatus_ReadyToPlay) {
//            [playerView stop];
//        }
//    }
}

#pragma mark - FQAssetsBrowseCellDelegate

- (void)assetsBrowseCellDidTapped:(FQAssetsBrowseCell *)cell {
    if (self.isPhotoAlbum == YES) {
        if (self.navigationBar.top != 0) {
            [self showController:YES];
        } else {
            [self hiddenTopAndBottom];
        }
    } else {
        WLAssetModel *itemModel = self.itemArray[0];
        
        if (itemModel.type != WLAssetModelType_Video) {
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}

- (void)assetsBrowseCellDidClickPlay:(FQAssetsBrowseCell *)cell {
    if (cell.itemModel.avAsset) {
        WLPlayerViewController *ctr = [[WLPlayerViewController alloc] initWithAsset:cell.itemModel.avAsset];
        [self presentViewController:ctr animated:YES completion:nil];
        
    } else if (cell.itemModel.asset) {
        [[PHImageManager defaultManager] requestAVAssetForVideo:cell.itemModel.asset
                                                        options:nil
                                                  resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          WLPlayerViewController *ctr = [[WLPlayerViewController alloc] initWithAsset:asset];
                                                          [self presentViewController:ctr animated:YES completion:nil];
                                                      });
                                                  }];
    }
}

//- (void)assetsBrowseCellPlayingStatusChanged:(WLPlayerViewStatus)status {
//    if (status == WLPlayerViewStatus_Playing) {
//        if (self.navigationBar.top == 0) {
//            [self hiddenTopAndBottom];
//        }
//    } else {
//        if (self.navigationBar.top != 0) {
//            [self showController:YES];
//        }
//    }
//}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    CGPoint offset = scrollView.contentOffset;
    int pageIndex = ceil((offset.x - pageWidth / 2) / pageWidth);
    
    if (pageIndex >= self.itemArray.count) {
        return;
    }
    self.currentIndex = pageIndex;
    
    WLAssetModel *itemModel = self.itemArray[pageIndex];
    [self p_setCheckButtonWithItemModel:itemModel];
}

#pragma mark - Event

- (void)closeBtnPressed {
//    if (_isPhotoAlbum == NO) {  //是发布器内选择后的图片的浏览的话
//        WLAssetModel *itemModel = _itemArray[0];
//
//        if (itemModel.type == WLAssetModelType_Video) {
//            FQAssetsBrowseCell *cell = (FQAssetsBrowseCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//            WLAVPlayerView *playerView = [cell playerView];
//            if (playerView.playerViewStatus == WLPlayerViewStatus_Playing || playerView.playerViewStatus == WLPlayerViewStatus_ReadyToPlay) {
//                [playerView stop];
//            }
//        }
//    }
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)checkBtnClicked:(UIButton *)sender {
    [sender.layer removeAnimationForKey:@"checkBtnAnimation"];
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    [sender.layer addAnimation:transition forKey:@"checkBtnAnimation"];
    
    if ([self.delegate respondsToSelector:@selector(assetsBrowseViewCtr:didClickedWithCurrentIndex:)]) {
        BOOL checked = [self.delegate assetsBrowseViewCtr:self didClickedWithCurrentIndex:self.currentIndex];
        if (!checked) {
            return;
        }
        
        WLAssetModel *itemModel = self.itemArray[self.currentIndex];
        [self p_setCheckButtonWithItemModel:itemModel];
        
        itemModel.isChecked ? _checkedNumber++ : _checkedNumber--;
        _checkedNumber = _checkedNumber > 0 ? _checkedNumber : 0;
        
        self.confirmBtn.enabled = _checkedNumber > 0;
        
        if (itemModel.asset.mediaType == PHAssetMediaTypeVideo) {
            if (itemModel.isChecked) {
                [self.confirmBtn setTitle:AssetsConfirmBtnTitle(1, kMaxCheckedVideoLimit) forState:UIControlStateNormal];
            } else {
                [self.confirmBtn setTitle:AssetsConfirmBtnTitle(0, kMaxCheckedNumberLimit) forState:UIControlStateNormal];
            }
        } else {
            [self.confirmBtn setTitle:AssetsConfirmBtnTitle(_checkedNumber, kMaxCheckedNumberLimit) forState:UIControlStateNormal];
        }
    }
}

- (void)confirmBtnClicked {
    if ([self.delegate respondsToSelector:@selector(assetsBrowseViewCtrDidConfirmed:)]) {
        [self.delegate assetsBrowseViewCtrDidConfirmed:self];
    }
}

- (void)showController:(BOOL)animated {
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        self.navigationBar.top = 0;
        self.confirmBtn.top = kScreenHeight - kLargeBtnYMargin - kLargeBtnHeight - kSafeAreaBottomY;
        self.checkBtn.centerY = self.navigationBar.height + CGRectGetHeight(self.checkBtn.bounds) * 0.5;
    }];
}

- (void)hiddenTopAndBottom {
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationBar.top = self.navigationBar.height *(-1);
        self.confirmBtn.top = kScreenHeight;
        self.checkBtn.centerY = kSystemStatusBarHeight + CGRectGetHeight(self.checkBtn.bounds) * 0.5;
    }];
}

#pragma mark - Private

- (void)p_setCheckButtonWithItemModel:(WLAssetModel *)itemModel {
    if (!itemModel) {
        return;
    }
    
    self.checkBtn.selected = itemModel.isChecked;
    if (self.checkBtn.selected) {
        [self.checkBtn setTitle:[NSString stringWithFormat:@"%ld", (long)itemModel.checkedIndex] forState:UIControlStateNormal];
    } else {
        [self.checkBtn setTitle:nil forState:UIControlStateNormal];
    }
}

#pragma mark - Getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionView *collView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) collectionViewLayout:self.flowLayout];
        collView.backgroundColor = [UIColor blackColor];
        collView.delegate = self;
        collView.dataSource = self;
        collView.pagingEnabled = YES;
        collView.showsHorizontalScrollIndicator = NO;
        collView.showsVerticalScrollIndicator = NO;
        [collView registerClass:[FQAssetsBrowseCell class] forCellWithReuseIdentifier:reusCellID];
        [self.view addSubview:collView];
        _collectionView = collView;
        
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.itemSize = CGSizeMake(kScreenWidth, kScreenHeight);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}

- (WLImageButton *)checkBtn {
    if (!_checkBtn) {
        _checkBtn = [WLImageButton buttonWithType:UIButtonTypeCustom];
        _checkBtn.imageOrientation = WLImageButtonOrientation_Center;
        _checkBtn.selected = NO;
        [_checkBtn setImage:[AppContext getImageForKey:@"asset_checked"] forState:UIControlStateSelected];
        [_checkBtn setImage:[AppContext getImageForKey:@"asset_unchecked"] forState:UIControlStateNormal];
        [_checkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _checkBtn.titleLabel.font = kRegularFont(kAssetCheckBtnFontSize);
        _checkBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_checkBtn addTarget:self action:@selector(checkBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_checkBtn sizeToFit];
        
        CGFloat padding = 15;
        _checkBtn.width += padding;
        _checkBtn.height += padding;
        
        _checkBtn.center = CGPointMake(CGRectGetWidth(self.view.bounds) - CGRectGetWidth(_checkBtn.bounds) * 0.5, self.navigationBar.height + CGRectGetHeight(_checkBtn.bounds) * 0.5);
    }
    return _checkBtn;
}

@end
