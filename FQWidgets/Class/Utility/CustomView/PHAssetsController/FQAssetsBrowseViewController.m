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

@interface FQAssetsBrowseCell : UICollectionViewCell <FQPlayerViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) FQPlayerView *playerView;
//@property (nonatomic, strong) UIButton *playBtn;

@property (nonatomic, strong) FQAssetModel *itemModel;

@end

@implementation FQAssetsBrowseCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.scrollView];
        [self.scrollView addSubview:self.imgView];
        [self.scrollView addSubview:self.playerView];
        
//        [self.contentView addSubview:self.playBtn];
    }
    return self;
}

- (void)setItemModel:(FQAssetModel *)itemModel {
    _itemModel = itemModel;
    
    self.scrollView.contentSize = CGSizeZero;
    [self.scrollView setZoomScale:1.0 animated:YES];
    
//    self.playBtn.hidden = itemModel.asset.mediaType != PHAssetMediaTypeVideo;
//    self.playerView.hidden = YES;
    
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
                                                    self.imgView.hidden = NO;
                                                    self.imgView.image = result;
                                                    [self p_resizeImageView];
                                                    
                                                    self.playerView.hidden = YES;
                                                    self.playerView.previewImage = nil;
                                                    
                                                } else if (itemModel.asset.mediaType == PHAssetMediaTypeVideo) {
                                                    self.imgView.hidden = YES;
                                                    self.imgView.image = nil;
                                                    
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
    switch (status) {
        case FQPlayerViewStatus_ReadyToPlay:
//            self.playBtn.hidden = YES;
            self.playerView.hidden = NO;
            break;
        case FQPlayerViewStatus_Playing:
//            self.playBtn.hidden = YES;
            self.playerView.hidden = NO;
            break;
        case FQPlayerViewStatus_Stopped:
        case FQPlayerViewStatus_Completed:
//            self.playBtn.hidden = NO;
            self.playerView.hidden = NO;
            break;
        default:
//            self.playBtn.hidden = self.playerView.hidden = YES;
            break;
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imgView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;

    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;

    self.imgView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                      scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - Event

//- (void)playBtnClicked:(UIButton *)sender {
//    sender.hidden = YES;
//    self.playerView.hidden = NO;
//    [[PHImageManager defaultManager] requestAVAssetForVideo:self.itemModel.asset
//                                                    options:nil
//                                              resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
//                                                  dispatch_async(dispatch_get_main_queue(), ^{
//                                                      [self.playerView playWithAsset:asset];
//                                                  });
//                                              }];
//}

#pragma mark - Private

- (void)p_resizeImageView {
    if (!self.imgView.image) {
        return;
    }
    CGSize imgSize = self.imgView.image.size;
    
    CGFloat newWidth = kScreenWidth;
    CGFloat newHeight = imgSize.height / imgSize.width * newWidth;
    
    self.imgView.frame = CGRectMake(0, 0, newWidth, newHeight);
    if (newHeight > kScreenHeight) {
        self.scrollView.contentSize = CGSizeMake(newWidth, newHeight);
        self.scrollView.contentOffset = CGPointZero;
    } else {
        self.imgView.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5, (CGRectGetHeight(self.frame)) * 0.5);
    }
}

#pragma mark - Getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.contentOffset = CGPointZero;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = YES;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.zoomScale = 1.0;
    }
    return _scrollView;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:self.bounds];
    }
    return _imgView;
}

- (FQPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[FQPlayerView alloc] initWithFrame:self.bounds];
        _playerView.delegate = self;
    }
    return _playerView;
}

//- (UIButton *)playBtn {
//    if (!_playBtn) {
//        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_playBtn setBackgroundImage:[UIImage imageNamed:@"camera_video_icon"] forState:UIControlStateNormal];
//        [_playBtn sizeToFit];
//        _playBtn.center = CGPointMake(CGRectGetWidth(self.bounds) * 0.5, (CGRectGetHeight(self.bounds)) * 0.5);
//        [_playBtn addTarget:self action:@selector(playBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _playBtn;
//}

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
    // Do any additional setup after loading the view.
    
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
    
//    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnDoubleTap:)];
//    doubleTap.numberOfTapsRequired = 2;
//    [self.view addGestureRecognizer:doubleTap];
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

- (void)selfOnDoubleTap:(UITapGestureRecognizer *)gesture {
    FQAssetsBrowseCell *cell = (FQAssetsBrowseCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    if (!cell) {
        return;
    }
    if (cell.scrollView.zoomScale > cell.scrollView.minimumZoomScale) {
        [cell.scrollView setZoomScale:cell.scrollView.minimumZoomScale animated:YES];
    } else {
        CGFloat maxZoomScale = cell.scrollView.maximumZoomScale;
        CGPoint point = [gesture locationInView:cell.imgView];
        
        CGFloat newWidth = self.view.frame.size.width / maxZoomScale;
        CGFloat newHeight = self.view.frame.size.height / maxZoomScale;
        
        CGFloat newX = point.x - newWidth / 2;
        CGFloat newY = point.y - newHeight / 2;
        
        [cell.scrollView zoomToRect:CGRectMake(newX, newY, newWidth, newHeight) animated:YES];
    }
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
