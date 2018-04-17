//
//  FQImagePickerController.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/16.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQImagePickerController.h"
#import "FQCameraViewController.h"
#import "FQCutImageViewController.h"
#import "FQImageButton.h"
#import "FQAssetsAlbumView.h"
#import "FQAssetsManager.h"

#pragma mark - ************************* FQImagePickerCollectionCell *************************

@interface FQImagePickerCollectionCell : UICollectionViewCell

@property (nonatomic, strong) FQAssetModel *itemModel;

@property (nonatomic, weak) CALayer *imgLayer;

@end

@implementation FQImagePickerCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setItemModel:(FQAssetModel *)itemModel {
    _itemModel = itemModel;
    
    if (itemModel.type == FQAssetModelType_Camera) {
        self.imgLayer.contentsGravity = kCAGravityCenter;
        self.imgLayer.contents =(__bridge id)[UIImage imageNamed:@"camera_icon"].CGImage;
        
    } else {
        self.imgLayer.contentsGravity = kCAGravityResizeAspectFill;
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.networkAccessAllowed = NO;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        CGSize size = CGSizeMake(self.bounds.size.width * kScreenScale, self.bounds.size.height * kScreenScale);
        
        [[PHImageManager defaultManager] requestImageForAsset:itemModel.asset
                                                   targetSize:size
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:options
                                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                    self.imgLayer.contents = (__bridge id)result.CGImage;
                                                }];
    }
}

#pragma mark - Getter

- (CALayer *)imgLayer {
    if (!_imgLayer) {
        CALayer *layer = [CALayer layer];
        layer.frame = self.bounds;
        layer.contentsGravity = kCAGravityResizeAspectFill;
        layer.contentsScale = [UIScreen mainScreen].scale;
        [self.contentView.layer insertSublayer:layer atIndex:0];
        _imgLayer = layer;
    }
    return _imgLayer;
}

@end

#pragma mark - ************************* FQImagePickerController *************************

static NSString * const reusCellID = @"FQImagePickerCollectionCell";

@interface FQImagePickerController () <FQCameraViewControllerDelegate, FQAssetsAlbumViewDelegate, FQCutImageViewControllerDelegate,
UICollectionViewDelegate, UICollectionViewDataSource> {
    PHAssetCollection *_selectedAlbum;
}

@property (nonatomic, weak) FQImageButton *titleBtn;
@property (nonatomic, weak) FQAssetsAlbumView *albumTableView;

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) FQAssetsManager *assetsManager;
@property (nonatomic, strong) NSMutableArray<PHAssetCollection *> *albumArray;
@property (nonatomic, strong) NSMutableArray<FQAssetModel *> *assetArray;
@property (nonatomic, strong) PHAssetCollection *selectedAlbum;

@end

@implementation FQImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = ({
        FQImageButton *btn = [[FQImageButton alloc] init];
        btn.imageOrientation = FQImageButtonOrientation_Right;
        btn.selected = NO;
        [btn setTitle:self.selectedAlbum.localizedTitle forState:UIControlStateNormal];
        [btn setTitleColor:kHeaderFontColor forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:kSizeScale(17)];
        [btn setImage:[UIImage imageNamed:@"camera_triangle"] forState:UIControlStateNormal];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [btn sizeToFit];
        [btn addTarget:self action:@selector(titleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _titleBtn = btn;
        
        btn;
    });
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"FQImagePickerController delloc");
}

#pragma mark - FQCameraViewControllerDelegate

- (void)cameraViewCtr:(FQCameraViewController *)viewCtr didConfirmWithOutputType:(FQCameraOutputType)outputType image:(UIImage *)image {
    FQCutImageViewController *ctr = [[FQCutImageViewController alloc] initWithOriginalImage:image];
    ctr.delegate = self;
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark - FQAssetsAlbumViewDelegate

- (void)assetsAlbumView:(FQAssetsAlbumView *)albumView didSelectedWithItemModel:(PHAssetCollection *)itemModel {
    if ([itemModel.localizedTitle isEqualToString:_titleBtn.titleLabel.text]) {
        return;
    }
    
    [self setSelectedAlbum:itemModel];
}

- (void)assetsAlbumViewDidDismiss:(FQAssetsAlbumView *)albumView {
    [self titleBtnClicked:_titleBtn];
}

#pragma mark - FQCutImageViewControllerDelegate

- (void)cutImageController:(FQCutImageViewController *)ctr didConfirmWithCuttedImage:(UIImage *)cuttedImage {
    if (!cuttedImage) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(imagePickerController:didPickedImage:)]) {
        [self.delegate imagePickerController:self didPickedImage:cuttedImage];
    }
    
    __block NSInteger preIndex = -1;
    [self.navigationController.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse
                                                                usingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                                    if ([obj isEqual:self]) {
                                                                        preIndex = idx - 1;
                                                                        *stop = YES;
                                                                    }
                                                                }];
    if (preIndex >= 0 && preIndex < self.navigationController.viewControllers.count) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController popToViewController:self.navigationController.viewControllers[preIndex] animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FQImagePickerCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusCellID forIndexPath:indexPath];
    [cell setItemModel:self.assetArray[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FQAssetModel *itemModel = self.assetArray[indexPath.row];
    if (itemModel.type == FQAssetModelType_Camera) {
        FQCameraViewController *ctr = [FQCameraViewController new];
        ctr.outputType = FQCameraOutputType_Photo;
        ctr.delegate = self;
        [self.navigationController pushViewController:ctr animated:YES];
    } else {
        FQCutImageViewController *ctr = [[FQCutImageViewController alloc] initWithPHAsset:itemModel.asset];
        ctr.delegate = self;
        [self.navigationController pushViewController:ctr animated:YES];
    }
}

#pragma mark - Event

- (void)titleBtnClicked:(UIButton *)sender {
    if (self.albumTableView.isDisplayed) {
        [self.albumTableView dismissWithAnimation:^{
            sender.imageView.transform = CGAffineTransformIdentity;
        }];
    } else {
        [self.albumTableView displayWithAnimation:^{
            sender.imageView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
        }];
    }
}

#pragma mark - Setter

- (void)setSelectedAlbum:(PHAssetCollection *)selectedAlbum {
    _selectedAlbum = selectedAlbum;
    
    [_titleBtn setTitle:selectedAlbum.localizedTitle forState:UIControlStateNormal];
    [UIView animateWithDuration:0
                     animations:^{
                         [_titleBtn sizeToFit];
                     }];
    
    [self titleBtnClicked:_titleBtn];
    
    _assetArray = nil;
    [self.assetsManager fetchAssetsWithAssetCollection:selectedAlbum];
    [self.collectionView reloadData];
}

#pragma mark - Getter

- (FQAssetsAlbumView *)albumTableView {
    if (!_albumTableView) {
        FQAssetsAlbumView *tableView = [[FQAssetsAlbumView alloc] initWithDataArray:self.albumArray];
        tableView.delegate = self;
        [self.view addSubview:tableView];
        _albumTableView = tableView;
    }
    return _albumTableView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionView *collView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - kNavBarHeight - kSafeAreaBottomY) collectionViewLayout:self.flowLayout];
        collView.backgroundColor = [UIColor whiteColor];
        collView.delegate = self;
        collView.dataSource = self;
        collView.showsHorizontalScrollIndicator = NO;
        collView.showsVerticalScrollIndicator = NO;
        [collView registerClass:[FQImagePickerCollectionCell class] forCellWithReuseIdentifier:reusCellID];
        [self.view addSubview:collView];
        _collectionView = collView;
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        CGFloat numbersInRow = 4;
        CGFloat spacing = kSizeScale(4);
        CGFloat width = (kScreenWidth - (numbersInRow - 1) * spacing) / numbersInRow;
        
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = spacing;
        _flowLayout.minimumInteritemSpacing = spacing;
        _flowLayout.itemSize = CGSizeMake(width, width);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _flowLayout;
}

- (FQAssetsManager *)assetsManager {
    if (!_assetsManager) {
        _assetsManager = [[FQAssetsManager alloc] init];
    }
    return _assetsManager;
}

- (NSMutableArray<PHAssetCollection *> *)albumArray {
    if (!_albumArray) {
        _albumArray = [NSMutableArray array];
        [_albumArray addObjectsFromArray:self.assetsManager.allAlbums];
    }
    return _albumArray;
}

- (NSMutableArray<FQAssetModel *> *)assetArray {
    if (!_assetArray) {
        _assetArray = [NSMutableArray array];
        [_assetArray addObject:[[FQAssetModel alloc] initWithType:FQAssetModelType_Camera asset:nil]];
        [_assetArray addObjectsFromArray:self.assetsManager.assets];
    }
    return _assetArray;
}

- (PHAssetCollection *)selectedAlbum {
    if (!_selectedAlbum) {
        [self.albumArray enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                _selectedAlbum = obj;
                *stop = YES;
            }
        }];
    }
    return _selectedAlbum;
}

@end
