//
//  FQAssetsBrowseViewController.m
//  WeLike
//
//  Created by fan qi on 2018/4/8.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQAssetsBrowseViewController.h"
#import "FQZoomScaleView.h"
#import "FQPlayerView.h"
#import "FQImageButton.h"

#pragma mark - ************************* FQAssetsBrowseCell *************************

@interface FQAssetsBrowseCell : UICollectionViewCell <FQPlayerViewDelegate>

@property (nonatomic, strong) FQZoomScaleView *scaleView;
@property (nonatomic, strong) FQPlayerView *playerView;

@property (nonatomic, strong) FQAssetModel *itemModel;

@end

@implementation FQAssetsBrowseCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.scaleView];
        [self.contentView addSubview:self.playerView];
    }
    return self;
}

- (void)setItemModel:(FQAssetModel *)itemModel {
    _itemModel = itemModel;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = NO;
    options.synchronous = NO;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    PHAsset *asset = itemModel.asset;
    CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
    CGFloat pixelWidth = kScreenWidth * kScreenScale;
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:imageSize
                                              contentMode:PHImageContentModeAspectFit
                                                  options:options
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                if (itemModel.asset.mediaType == PHAssetMediaTypeImage) {
                                                    self.scaleView.hidden = NO;
                                                    self.scaleView.image = result;
                                                    
                                                    self.playerView.hidden = YES;
                                                    self.playerView.previewImage = nil;
                                                    
                                                } else if (itemModel.asset.mediaType == PHAssetMediaTypeVideo) {
                                                    self.scaleView.hidden = YES;
                                                    self.scaleView.image = nil;
                                                    
                                                    self.playerView.hidden = NO;
                                                    self.playerView.previewImage = result;
                                                    
                                                    [[PHImageManager defaultManager] requestAVAssetForVideo:itemModel.asset
                                                                                                    options:nil
                                                                                              resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                                                                                                  [self.playerView setAsset:asset];
                                                                                              }];
                                                    
                                                }
                                            }];
    
    
}

#pragma mark - FQPlayerViewDelegate

- (void)playerView:(FQPlayerView *)playerView statusDidChanged:(FQPlayerViewStatus)status {
    
}

#pragma mark - Getter

- (FQZoomScaleView *)scaleView {
    if (!_scaleView) {
        _scaleView = [[FQZoomScaleView alloc] initWithFrame:self.bounds];
    }
    return _scaleView;
}

- (FQPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[FQPlayerView alloc] initWithFrame:self.bounds];
        _playerView.delegate = self;
        _playerView.hidden = YES;
    }
    return _playerView;
}

@end

#pragma mark - ************************* FQAssetsBrowseViewController *************************

static NSString * const reusCellID = @"FQAssetsBrowseCell";

@interface FQAssetsBrowseViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, copy) NSArray<FQAssetModel *> *itemArray;

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) FQImageButton *checkBtn;

@end

@implementation FQAssetsBrowseViewController

- (instancetype)initWithItemArray:(NSArray<FQAssetModel *> *)itemArray checkedNumber:(NSInteger)checkedNumber {
    if (self = [super init]) {
        _itemArray = itemArray;
        _checkedNumber = checkedNumber;
        _currentIndex = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(self.currentIndex * CGRectGetWidth(self.collectionView.bounds), 0)];
    
    [self.view addSubview:self.checkBtn];
    [self p_setCheckButtonWithItemModel:_itemArray[self.currentIndex]];
    
    {
        UIView *bottomView = [[UIView alloc] init];
        bottomView.backgroundColor = kUIColorFromRGB(0xEDEDED);
        [self.view addSubview:bottomView];
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.view);
            make.height.mas_equalTo(BottomViewHeight);
            make.bottom.mas_equalTo(self.view).offset(-kSafeAreaBottomY);
        }];
        
        self.confirmBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = kMainColor;
            [btn setTitle:ConfirmBtnTitle(_checkedNumber) forState:UIControlStateNormal];
            [btn setTitleColor:kBodyFontColor forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:kBodyFontSize];
            btn.layer.cornerRadius = kSizeScale(25);
            [btn addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            btn;
        });
        [bottomView addSubview:self.confirmBtn];
        [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(bottomView).offset(kSizeScale(16));
            make.right.mas_equalTo(bottomView).offset(-kSizeScale(16));
            make.top.mas_equalTo(bottomView).offset(kSizeScale(8));
            make.bottom.mas_equalTo(bottomView).offset(-kSizeScale(8));
        }];
    }
}

- (void)dealloc {
    NSLog(@"FQAssetsBrowseViewController dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _itemArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FQAssetsBrowseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusCellID forIndexPath:indexPath];
    [cell setItemModel:_itemArray[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_itemArray[indexPath.row].asset.mediaType == PHAssetMediaTypeVideo) {
        FQPlayerView *playerView = [(FQAssetsBrowseCell *)cell playerView];
        if (playerView.playerViewStatus == FQPlayerViewStatus_Playing || playerView.playerViewStatus == FQPlayerViewStatus_ReadyToPlay) {
            [playerView stop];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    CGPoint offset = scrollView.contentOffset;
    int pageIndex = ceil((offset.x - pageWidth / 2) / pageWidth);
    
    if (pageIndex >= _itemArray.count) {
        return;
    }
    self.currentIndex = pageIndex;
    
    FQAssetModel *itemModel = _itemArray[pageIndex];
    [self p_setCheckButtonWithItemModel:itemModel];
}

#pragma mark - Event

- (void)checkBtnClicked:(UIButton *)sender {
    [_checkBtn.layer removeAnimationForKey:@"checkBtnAnimation"];
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    [_checkBtn.layer addAnimation:transition forKey:@"checkBtnAnimation"];
    
    if ([self.delegate respondsToSelector:@selector(assetsBrowseViewCtr:didClickedWithCurrentIndex:)]) {
        [self.delegate assetsBrowseViewCtr:self didClickedWithCurrentIndex:self.currentIndex];

        FQAssetModel *itemModel = _itemArray[self.currentIndex];
        [self p_setCheckButtonWithItemModel:itemModel];
        
        itemModel.isChecked ? _checkedNumber++ : _checkedNumber--;
        _checkedNumber = _checkedNumber > 0 ? _checkedNumber : 0;
        
        [self.confirmBtn setTitle:ConfirmBtnTitle(_checkedNumber) forState:UIControlStateNormal];
    }
}

- (void)confirmBtnClicked {
    
}

#pragma mark - Private

- (void)p_setCheckButtonWithItemModel:(FQAssetModel *)itemModel {
    if (!itemModel) {
        return;
    }
    
    self.checkBtn.selected = itemModel.isChecked;
    if (self.checkBtn.selected) {
        [self.checkBtn setTitle:[NSString stringWithFormat:@"%zd", itemModel.checkedIndex] forState:UIControlStateNormal];
    } else {
        [self.checkBtn setTitle:nil forState:UIControlStateNormal];
    }
}

#pragma mark - Getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionView *collView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - kNavBarHeight - BottomViewHeight - kSafeAreaBottomY) collectionViewLayout:self.flowLayout];
        collView.backgroundColor = [UIColor blackColor];
        collView.delegate = self;
        collView.dataSource = self;
        collView.pagingEnabled = YES;
        collView.showsHorizontalScrollIndicator = NO;
        collView.showsVerticalScrollIndicator = NO;
        [collView registerClass:[FQAssetsBrowseCell class] forCellWithReuseIdentifier:reusCellID];
        [self.view addSubview:collView];
        _collectionView = collView;
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.itemSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height - kNavBarHeight - BottomViewHeight - kSafeAreaBottomY);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}

- (FQImageButton *)checkBtn {
    if (!_checkBtn) {
        CGFloat padding = kSizeScale(12);
        _checkBtn = [FQImageButton buttonWithType:UIButtonTypeCustom];
        _checkBtn.imageOrientation = FQImageButtonOrientation_Center;
        _checkBtn.selected = NO;
        [_checkBtn setImage:[UIImage imageNamed:@"camera_photo_selected"] forState:UIControlStateSelected];
        [_checkBtn setImage:[UIImage imageNamed:@"camera_photo_unselected"] forState:UIControlStateNormal];
        [_checkBtn setTitleColor:kBodyFontColor forState:UIControlStateNormal];
        _checkBtn.titleLabel.font = [UIFont systemFontOfSize:kSizeScale(11)];
        _checkBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_checkBtn addTarget:self action:@selector(checkBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_checkBtn sizeToFit];
        _checkBtn.frame = CGRectMake(0, 0, CGRectGetWidth(_checkBtn.bounds) + padding * 2, CGRectGetHeight(_checkBtn.bounds) + padding * 2);
        _checkBtn.center = CGPointMake(CGRectGetWidth(self.view.bounds) - CGRectGetWidth(_checkBtn.bounds) * 0.5, CGRectGetHeight(_checkBtn.bounds) * 0.5);
    }
    return _checkBtn;
}

@end
