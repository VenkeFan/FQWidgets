//
//  WLAssetsViewController.m
//  WeLike
//
//  Created by fan qi on 2018/4/3.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLAssetsViewController.h"
#import "WLAbstractCameraViewController.h"
#import "WLAssetsBrowseViewController.h"
#import "WLCutImageViewController.h"
#import "WLImageButton.h"
#import "WLAssetsAlbumView.h"
#import "WLAlertController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "WLEditPhotoViewController.h"
#import "WLCameraViewController.h"
//#import "WLPhotoPreviewViewController.h"

#pragma mark - ************************* WLAssetsCollectionCell *************************

@class WLAssetsCollectionCell;

@protocol WLAssetsCollectionCellDelegate <NSObject>

- (BOOL)assetsCollectionCell:(WLAssetsCollectionCell *)cell didClickedWithItemModel:(WLAssetModel *)itemModel;

@end

@interface WLAssetsCollectionCell : UICollectionViewCell

@property (nonatomic, strong) WLAssetModel *itemModel;

@property (nonatomic, weak) CALayer *imgLayer;
//@property (nonatomic, weak) CALayer *videoIconLayer;
@property (nonatomic, weak) CALayer *maskLayer;
@property (nonatomic, weak) CAGradientLayer *gradientLayer;
@property (nonatomic, weak) CATextLayer *durationLayer;
//@property (nonatomic, weak) WLImageButton *checkBtn;

@property (nonatomic, weak) id<WLAssetsCollectionCellDelegate> delegate;

@end

@implementation WLAssetsCollectionCell

#pragma mark - LifeCycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - Public

- (void)setItemModel:(WLAssetModel *)itemModel {
    _itemModel = itemModel;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
//    self.checkBtn.hidden = YES;
//    self.videoIconLayer.hidden = YES;
    self.gradientLayer.hidden = YES;
    self.maskLayer.hidden = YES;
    [CATransaction commit];
    
    if (itemModel.type == WLAssetModelType_Camera) {
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.imgLayer.contentsGravity = kCAGravityCenter;
        self.imgLayer.contents =(__bridge id)[AppContext getImageForKey:@"asset_camera"].CGImage;
        [CATransaction commit];
        
    } else {
        self.maskLayer.hidden = !itemModel.isChecked;
        
//        self.checkBtn.hidden = NO;
//        self.checkBtn.selected = itemModel.isChecked;
//
//        if (self.checkBtn.selected) {
//            [self.checkBtn setTitle:[NSString stringWithFormat:@"%ld", (long)itemModel.checkedIndex] forState:UIControlStateNormal];
//        } else {
//            [self.checkBtn setTitle:nil forState:UIControlStateNormal];
//        }
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.imgLayer.contentsGravity = kCAGravityResizeAspectFill;
//        self.videoIconLayer.hidden = itemModel.asset.mediaType != PHAssetMediaTypeVideo;
        self.gradientLayer.hidden = itemModel.asset.mediaType != PHAssetMediaTypeVideo;
        [CATransaction commit];
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.networkAccessAllowed = NO;
        options.synchronous = NO;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        CGSize size = CGSizeMake(self.bounds.size.width * kScreenScale, self.bounds.size.height * kScreenScale);
        
        [[PHImageManager defaultManager] requestImageDataForAsset:itemModel.asset
                                                          options:options
                                                    resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                                                        if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] == YES) {
                                                            itemModel.isCloud = YES;
                                                        } else {
                                                            itemModel.isCloud = NO;
                                                        }
                                                        
                                                        itemModel.hasSyncCloud = imageData.length > 0;
                                                    }];
        
        [[PHImageManager defaultManager] requestImageForAsset:itemModel.asset
                                                   targetSize:size
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:options
                                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                    [CATransaction begin];
                                                    [CATransaction setDisableActions:YES];
                                                    self.imgLayer.contents = (__bridge id)result.CGImage;
                                                    [CATransaction commit];
                                                    itemModel.image = result;
                                                }];
        
        if (itemModel.asset.mediaType == PHAssetMediaTypeVideo) {
            [[PHImageManager defaultManager] requestAVAssetForVideo:itemModel.asset
                                                            options:nil
                                                      resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                                                          itemModel.avAsset = asset;
                                                          if ([asset isKindOfClass:[AVURLAsset class]]) {
                                                              AVURLAsset *urlAsset = (AVURLAsset *)asset;
                                                              NSNumber *size;
                                                              [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                                                              itemModel.quality = size.floatValue;
                                                              itemModel.avAsset = asset;
                                                          }
                                                          
                                                          [self p_setDuration:asset.duration];
                                                      }];
        }
    }
}

- (void)p_setDuration:(CMTime)duration {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger totalSeconds = CMTimeGetSeconds(duration);
        
        NSInteger hours = totalSeconds / 3600;
        NSInteger minutes = (totalSeconds / 60) % 60;
        NSInteger seconds = totalSeconds % 60;
        
        if (hours > 0) {
            self.durationLayer.string = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld", (long)hours, (long)minutes, (long)seconds];
        } else {
            self.durationLayer.string = [NSString stringWithFormat:@"%.2ld:%.2ld", (long)minutes, (long)seconds];
        }
    });
}

#pragma mark - Event

//- (void)checkBtnClicked:(WLImageButton *)sender {
//    if ([self.delegate respondsToSelector:@selector(assetsCollectionCell:didClickedWithItemModel:)]) {
//        [self.delegate assetsCollectionCell:self didClickedWithItemModel:self.itemModel];
//    }
//}

#pragma mark - Getter

- (CALayer *)imgLayer {
    if (!_imgLayer) {
        CALayer *layer = [CALayer layer];
        layer.frame = self.bounds;
        layer.contentsGravity = kCAGravityResizeAspectFill;
        layer.contentsScale = kScreenScale;
        [self.contentView.layer insertSublayer:layer atIndex:0];
        _imgLayer = layer;
    }
    return _imgLayer;
}

//- (CALayer *)videoIconLayer {
//    if (!_videoIconLayer) {
//        CALayer *videoLayer = [CALayer layer];
//        videoLayer.hidden = YES;
//        videoLayer.contents = (__bridge id)[AppContext getImageForKey:@"asset_play"].CGImage;
//        videoLayer.contentsGravity = kCAGravityCenter;
//        videoLayer.contentsScale = kScreenScale;
//        videoLayer.position = CGPointMake(CGRectGetWidth(self.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5);
//        [self.imgLayer addSublayer:videoLayer];
//        _videoIconLayer = videoLayer;
//    }
//    return _videoIconLayer;
//}

- (CALayer *)maskLayer {
    if (!_maskLayer) {
        CALayer *layer = [CALayer layer];
        layer.frame = self.bounds;
        layer.backgroundColor = kUIColorFromRGBA(0x000000, 0.6).CGColor;
        layer.hidden = YES;
        layer.contents = (__bridge id)[AppContext getImageForKey:@"asset_selected"].CGImage;
        layer.contentsGravity = kCAGravityCenter;
        layer.contentsScale = kScreenScale;
        [self.layer addSublayer:layer];
        _maskLayer = layer;
    }
    return _maskLayer;
}

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        CAGradientLayer *layer = [CAGradientLayer layer];
        layer.frame = CGRectMake(0, self.bounds.size.height - 30, self.bounds.size.width, 30);
        layer.colors = @[(__bridge id)kUIColorFromRGBA(0x000000, 0.8).CGColor, (__bridge id)kUIColorFromRGBA(0x000000, 0.0).CGColor];
        layer.startPoint = CGPointMake(0.5, 1.0);
        layer.endPoint = CGPointMake(0.5, 0.0);
        [self.layer addSublayer:layer];
        _gradientLayer = layer;
        
        CGFloat padding = 4;
        CALayer *imgLayer = [[CALayer alloc] init];
        imgLayer.frame = CGRectMake(0, 0, 16, 16);
        imgLayer.contents = (__bridge id)[AppContext getImageForKey:@"asset_video_icon"].CGImage;
        imgLayer.contentsGravity = kCAGravityCenter;
        imgLayer.contentsScale = kScreenScale;
        imgLayer.position = CGPointMake(padding + CGRectGetWidth(imgLayer.bounds) * 0.5, CGRectGetHeight(layer.bounds) * 0.5);
        [layer addSublayer:imgLayer];
        
        UIFont *font = kRegularFont(kLightFontSize);
        
        CATextLayer *txtLayer = [CATextLayer layer];
        txtLayer.frame = CGRectMake(CGRectGetMaxX(imgLayer.frame) + padding * 0.5, (CGRectGetHeight(layer.bounds) - (font.pointSize + 2)) * 0.5, CGRectGetWidth(layer.bounds) - (CGRectGetMaxX(imgLayer.frame) + padding), font.pointSize + 2);
        txtLayer.contentsScale = kScreenScale;
        txtLayer.alignmentMode = kCAAlignmentLeft;
        txtLayer.truncationMode = kCATruncationEnd;
        txtLayer.foregroundColor = [UIColor whiteColor].CGColor;
        
        CFStringRef fontName = (__bridge CFStringRef)font.fontName;
        CGFontRef fontRef = CGFontCreateWithFontName(fontName);
        txtLayer.font = fontRef;
        txtLayer.fontSize = font.pointSize;
        CGFontRelease(fontRef);
        [layer addSublayer:txtLayer];
        _durationLayer = txtLayer;
    }
    return _gradientLayer;
}

//- (WLImageButton *)checkBtn {
//    if (!_checkBtn) {
//        CGFloat padding = (6);
//        WLImageButton *btn = [WLImageButton buttonWithType:UIButtonTypeCustom];
//        btn.imageOrientation = WLImageButtonOrientation_Center;
//        btn.selected = NO;
//        [btn setImage:[AppContext getImageForKey:@"asset_checked"] forState:UIControlStateSelected];
//        [btn setImage:[AppContext getImageForKey:@"asset_unchecked"] forState:UIControlStateNormal];
//        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        btn.titleLabel.font = kRegularFont(kAssetCheckBtnFontSize);
//        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
//        [btn addTarget:self action:@selector(checkBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [btn sizeToFit];
//        btn.frame = CGRectMake(0, 0, CGRectGetWidth(btn.bounds) + padding * 2, CGRectGetHeight(btn.bounds) + padding * 2);
//        btn.center = CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(btn.bounds) * 0.5, CGRectGetHeight(btn.bounds) * 0.5);
//        [self.contentView addSubview:btn];
//        _checkBtn = btn;
//    }
//    return _checkBtn;
//}

@end

#pragma mark - ************************* WLAssetsViewController *************************

static NSString * const reusCellID = @"WLAssetsCollectionCell";

@interface WLAssetsViewController () <WLAbstractCameraViewControllerDelegate, WLAssetsCollectionCellDelegate, WLAssetsBrowseViewControllerDelegate, WLAssetsAlbumViewDelegate, WLCutImageViewControllerDelegate,
UICollectionViewDelegate, UICollectionViewDataSource, WLCameraViewControllerDelegate> {
    PHAssetCollection *_selectedAlbum;
    BOOL _needReloadData;
}

@property (nonatomic, assign, readwrite) WLAssetsSelectionMode currentSelectionMode;
@property (nonatomic, assign) NSInteger maxCheckedNumberLimit;

@property (nonatomic, weak) WLImageButton *titleBtn;
@property (nonatomic, weak) WLAssetsAlbumView *albumTableView;

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) UIButton *previewBtn;

@property (nonatomic, strong) WLAssetsManager *assetsManager;
@property (nonatomic, strong) NSMutableArray<PHAssetCollection *> *albumArray;
@property (nonatomic, strong) NSMutableArray<WLAssetModel *> *assetArray;
@property (nonatomic, strong) NSMutableArray<WLAssetModel *> *checkedPhotoArray;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSIndexPath *> *checkedCellDic;

@property (nonatomic, strong) PHAssetCollection *selectedAlbum;

@property (nonatomic, strong) NSMutableArray<WLAssetModel *> *previewPhotoArray;

@end

@implementation WLAssetsViewController

#pragma mark - LifeCycle

- (instancetype)initWithSelectionMode:(WLAssetsSelectionMode)selectionMode {
    if (self = [super init]) {
        self.currentSelectionMode = selectionMode;
    }
    return self;
}

- (instancetype)initWithCheckedArray:(NSArray<WLAssetModel *> *)checkedArray {
    if (self = [self initWithSelectionMode:WLAssetsSelectionMode_Multiple]) {
        self.checkedPhotoArray = [[NSMutableArray alloc] initWithArray:checkedArray copyItems:YES];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _needReloadData = NO;
    
    {
//        self.navigationBar.rightBtn.hidden = NO;
//        [self.navigationBar.rightBtn setTitle:AssetsConfirmBtnTitle(self.checkedPhotoArray.count, [self p_hasCheckedVideo] ? kMaxCheckedVideoLimit : self.maxCheckedNumberLimit) forState:UIControlStateNormal];
//        [self.navigationBar.rightBtn setTitleColor:kMainColor forState:UIControlStateNormal];
//        [self.navigationBar.rightBtn setTitleColor:kLightFontColor forState:UIControlStateDisabled];
//        [self.navigationBar.rightBtn sizeToFit];
//        self.navigationBar.rightBtn.enabled = self.checkedPhotoArray.count > 0;
//        self.navigationBar.rightBtn.width += 24;
//        [self.navigationBar.rightBtn addTarget:self action:@selector(navRightBtnOnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationBar.titleView = ({
            WLImageButton *btn = [[WLImageButton alloc] init];
            btn.imageOrientation = WLImageButtonOrientation_Right;
            btn.selected = NO;
            [btn setTitleColor:kNameFontColor forState:UIControlStateNormal];
            btn.titleLabel.font = kBoldFont(kNameFontSize);
            [btn setImage:[AppContext getImageForKey:@"asset_triangle"] forState:UIControlStateNormal];
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
            [btn sizeToFit];
            [btn addTarget:self action:@selector(titleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            _titleBtn = btn;
            
            btn;
        });
        [self.navigationBar setNeedsLayout];
    }
    
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.backgroundColor = [UIColor redColor];
        NSString *btnTitleStr = AssetsConfirmBtnTitle(self.checkedPhotoArray.count, [self p_hasCheckedVideo] ? kMaxCheckedVideoLimit : self.maxCheckedNumberLimit);
        CGSize btnSize = [btnTitleStr sizeWithFont:kRegularFont(kNameFontSize) size:CGSizeMake(110, 20)];
        [btn setTitle:btnTitleStr forState:UIControlStateNormal];
        [btn setTitleColor:kMainColor forState:UIControlStateNormal];
        [btn setTitleColor:kLightFontColor forState:UIControlStateDisabled];
        btn.titleLabel.font = kRegularFont(kNameFontSize);
        btn.enabled = self.checkedPhotoArray.count > 0;
        btn.frame = CGRectMake(kScreenWidth - 10 - btnSize.width, 0, btnSize.width, CGRectGetHeight(self.navigationBar.contentView.bounds));
        [btn addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationBar.contentView addSubview:btn];
        self.confirmBtn = btn;
    }
    
    {
//        CGFloat btnHeight = 48;
//        UIView *bottomView = [[UIView alloc] init];
//        bottomView.backgroundColor = [UIColor whiteColor];
//        [self.view addSubview:bottomView];
//        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(self.view);
//            make.right.mas_equalTo(self.view);
//            make.bottom.mas_equalTo(self.view);
//            make.height.mas_equalTo(btnHeight + kSafeAreaBottomY);
//        }];
//
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [btn setTitle:[AppContext getStringForKey:@"picture_preview" fileName:@"pic_sel"] forState:UIControlStateNormal];
//        [btn setTitleColor:kMainColor forState:UIControlStateNormal];
//        [btn setTitleColor:kLightFontColor forState:UIControlStateDisabled];
//        btn.titleLabel.font = kRegularFont(kNameFontSize);
//        btn.enabled = self.checkedPhotoArray.count > 0;
//        [btn addTarget:self action:@selector(previewBtnOnClicked) forControlEvents:UIControlEventTouchUpInside];
//        [bottomView addSubview:btn];
//        self.previewBtn = btn;
//        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(btnHeight);
//            make.width.mas_equalTo(80);
//            make.top.right.mas_equalTo(bottomView);
//        }];
    }
    
    [self.assetsManager requestPhotoAuthAuthorizationWithFinished:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [self->_titleBtn setTitle:self.selectedAlbum.localizedTitle forState:UIControlStateNormal];
                [self->_titleBtn sizeToFit];
                [self.navigationBar setNeedsLayout];
                
                [self.collectionView reloadData];
                
                self.albumTableView.dataArray = self.albumArray;
            } else {
                [self p_popViewCtr];
            }
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_needReloadData) {
        [self.checkedPhotoArray removeAllObjects];
        for (int i = 0; i < _previewPhotoArray.count; i++) {
            if (_previewPhotoArray[i].isChecked) {
                [self.checkedPhotoArray addObject:_previewPhotoArray[i]];
            }
        }
        
        [_assetArray removeAllObjects];
        _assetArray = nil;
        
        [self.collectionView reloadData];
    }
}

- (void)dealloc {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - WLAssetsCollectionCellDelegate

- (BOOL)assetsCollectionCell:(WLAssetsCollectionCell *)cell didClickedWithItemModel:(WLAssetModel *)itemModel {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    return [self p_verifyCheckedAsset:itemModel indexPath:indexPath];
}

#pragma mark - WLAbstractCameraViewControllerDelegate

- (void)cameraViewCtr:(WLAbstractCameraViewController *)viewCtr didConfirmWithImage:(UIImage *)image {
    if (!image) {
        return;
    }
    
    if (self.currentSelectionMode == WLAssetsSelectionMode_Single_poll && self.editable) {
        WLEditPhotoViewController *ctr = [[WLEditPhotoViewController alloc] init];
         ctr.edit_photo_type = Edit_photo_type_poll;
        [self presentViewController:ctr animated:YES completion:^{
            
        }];
        
        ctr.clickIndex = 0;
        ctr.signalImage = image;
        ctr.photoArrayBlock = ^(NSMutableArray *photoArray) {
            
            if ([self.delegate respondsToSelector:@selector(assetsViewCtr:didSelectedWithAssetArray:)]) {
                [self.delegate assetsViewCtr:self didSelectedWithAssetArray:photoArray];
                [self p_popViewCtr];
            }
        };
        
        return;
    }
    
    if (self.currentSelectionMode == WLAssetsSelectionMode_Single_status && self.editable) {
        WLEditPhotoViewController *ctr = [[WLEditPhotoViewController alloc] init];
        ctr.edit_photo_type = Edit_photo_type_status;
        [self presentViewController:ctr animated:YES completion:^{
            
        }];
        
        ctr.clickIndex = 0;
        ctr.signalImage = image;
        ctr.photoArrayBlock = ^(NSMutableArray *photoArray) {
            
            if ([self.delegate respondsToSelector:@selector(assetsViewCtr:didSelectedWithAssetArray:)]) {
                [self.delegate assetsViewCtr:self didSelectedWithAssetArray:photoArray];
                [self p_popViewCtr];
            }
        };
        
        return;
    }
    
    
    if (self.currentSelectionMode == WLAssetsSelectionMode_Single && self.editable) {
        WLCutImageViewController *ctr = [[WLCutImageViewController alloc] initWithOriginalImage:image];
        ctr.delegate = self;
        [self.navigationController pushViewController:ctr animated:YES];
        return;
    }
    
    [WLAssetsManager saveImageToCameraRoll:image
                                  finished:^(PHAsset *asset) {
                                      if ([self.delegate respondsToSelector:@selector(assetsViewCtr:didSelectedWithAssetArray:)]) {
                                          WLAssetModel *itemModel = [[WLAssetModel alloc]
                                                                     initWithType:WLAssetModelType_Photo
                                                                     asset:asset];
                                          itemModel.checked = YES;
                                          
                                          [self.checkedPhotoArray addObject:itemModel];
                                          
                                          itemModel.checkedIndex = self.checkedPhotoArray.count;
                                          
                                          [self.delegate assetsViewCtr:self didSelectedWithAssetArray:self.checkedPhotoArray];
                                      }
                                  }];
    
    [self p_popViewCtr];
}

- (void)cameraViewCtr:(WLAbstractCameraViewController *)viewCtr didConfirmWithVideoAsset:(PHAsset *)videoAsset {
    if (!videoAsset) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(assetsViewCtr:didSelectedWithAssetArray:)]) {
        WLAssetModel *itemModel = [[WLAssetModel alloc] initWithType:WLAssetModelType_Video asset:videoAsset];
        itemModel.checked = YES;
        itemModel.checkedIndex = 1;
        [self.delegate assetsViewCtr:self didSelectedWithAssetArray:@[itemModel]];
    }
    
    [self p_popViewCtr];
}

#pragma mark - WLCutImageViewControllerDelegate

- (void)cutImageController:(WLCutImageViewController *)ctr didConfirmWithCuttedImage:(UIImage *)cuttedImage {
    if (!cuttedImage) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(assetsViewCtr:didCuttedImage:)]) {
        [self.delegate assetsViewCtr:self didCuttedImage:cuttedImage];
    }
    
    [self p_popViewCtr];
}

#pragma mark - WLAssetsBrowseViewControllerDelegate

- (BOOL)assetsBrowseViewCtr:(WLAssetsBrowseViewController *)ctr didClickedWithCurrentIndex:(NSInteger)currentIndex {
    if (currentIndex + 1 >= self.assetArray.count) {
        return NO;
    }
    
    return [self p_verifyCheckedAsset:self.assetArray[currentIndex + 1] indexPath:nil];
}

- (void)assetsBrowseViewCtrDidConfirmed:(WLAssetsBrowseViewController *)ctr {
    [self confirmBtnClicked];
}

#pragma mark - WLAssetsAlbumViewDelegate

- (void)assetsAlbumView:(WLAssetsAlbumView *)albumView didSelectedWithItemModel:(PHAssetCollection *)itemModel {
    [self setSelectedAlbum:itemModel];
}

- (void)assetsAlbumViewDidDismiss:(WLAssetsAlbumView *)albumView {
    [self titleBtnClicked:_titleBtn];
}

#pragma mark - WLPhotoPreviewViewControllerDelegate

//- (BOOL)photoPreviewViewCtr:(WLPhotoPreviewViewController *)ctr didCheckBtnClicked:(WLAssetModel *)assetModel {
//    return [self p_verifyCheckedAsset:assetModel indexPath:nil];
//}
//
//- (void)photoPreviewViewCtr:(WLPhotoPreviewViewController *)ctr
//           editedAssetModel:(WLAssetModel *)editedAssetModel {
//    _needReloadData = YES;
//}
//
//- (void)photoPreviewViewCtrDidConfirmed:(WLPhotoPreviewViewController *)ctr
//                              dataArray:(NSMutableArray<WLAssetModel *> *)dataArray {
//    [self.checkedPhotoArray removeAllObjects];
//    for (int i = 0; i < dataArray.count; i++) {
//        if (dataArray[i].isChecked) {
//            [self.checkedPhotoArray addObject:dataArray[i]];
//        }
//    }
//    [self confirmBtnClicked];
//}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WLAssetsCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusCellID forIndexPath:indexPath];
    cell.delegate = self;
    [cell setItemModel:self.assetArray[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WLAssetModel *itemModel = self.assetArray[indexPath.row];
    if (itemModel.type == WLAssetModelType_Camera) {
        WLCameraViewController *ctr = [WLCameraViewController new];
        ctr.delegate = self;
        ctr.isLightStatusBar = YES;
        
        WLAlertController *alert = [WLAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"picture_photograph" fileName:@"pic_sel"]
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    if (self.checkedPhotoArray.count >= self.maxCheckedNumberLimit) {
                                                        [[AppContext currentViewController] showToast:[NSString stringWithFormat:[AppContext getStringForKey:@"picture_message_max_num" fileName:@"pic_sel"], self.maxCheckedNumberLimit]];
                                                        return;
                                                    }
                                                    if ([self p_hasCheckedVideo]) {
                                                        [[AppContext currentViewController] showToast:[AppContext getStringForKey:@"picture_rule" fileName:@"pic_sel"]];
                                                        return;
                                                    }
                                                    
                                                    ctr.outputType = FQCameraOutputType_Photo;
                                                    [self.navigationController pushViewController:ctr animated:YES];
                                                }]];
        if (self.currentSelectionMode == WLAssetsSelectionMode_Multiple) {
            [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"picture_record_video" fileName:@"pic_sel"]
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        if (self.checkedPhotoArray.count > 0) {
                                                            if ([self p_hasCheckedVideo]) {
                                                                [[AppContext currentViewController] showToast:[AppContext getStringForKey:@"picture_message_video_max_num" fileName:@"pic_sel"]];
                                                            } else {
                                                                [[AppContext currentViewController] showToast:[AppContext getStringForKey:@"picture_rule" fileName:@"pic_sel"]];
                                                            }
                                                        } else {
                                                            ctr.outputType = FQCameraOutputType_Video;
                                                            [self.navigationController pushViewController:ctr animated:YES];
                                                        }
                                                    }]];
        }
        
        [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"picture_cancel" fileName:@"pic_sel"]
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        [self p_verifyCheckedAsset:itemModel indexPath:indexPath];
        
//        if (self.currentSelectionMode == WLAssetsSelectionMode_Multiple) {
//            NSArray *tmpArray = [self.assetArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, self.assetArray.count - 1)]];
//            WLAssetsBrowseViewController *ctr = [[WLAssetsBrowseViewController alloc] initWithItemArray:tmpArray checkedNumber:self.checkedPhotoArray.count];
//            ctr.currentIndex = indexPath.row - 1;
//            ctr.delegate = self;
//            ctr.statusBarHidden = YES;
//            [self.navigationController pushViewController:ctr animated:YES];
//        } else {
//            WLAssetsCollectionCell *cell = (WLAssetsCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
//            if (!cell) {
//                return;
//            }
//            [self assetsCollectionCell:cell didClickedWithItemModel:itemModel];
//        }
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

- (void)confirmBtnClicked {
    if (self.checkedPhotoArray.count == 0) {
        return;
    }
    
    if (self.currentSelectionMode == WLAssetsSelectionMode_Single_poll && self.editable) {
        WLEditPhotoViewController *ctr = [[WLEditPhotoViewController alloc] init];
         ctr.edit_photo_type = Edit_photo_type_poll;
        [self presentViewController:ctr animated:YES completion:^{
            
        }];
        
        ctr.clickIndex = 0;
        ctr.photoArray = self.checkedPhotoArray;
        ctr.photoArrayBlock = ^(NSMutableArray *photoArray) {
           
            if ([self.delegate respondsToSelector:@selector(assetsViewCtr:didSelectedWithAssetArray:)]) {
                [self.delegate assetsViewCtr:self didSelectedWithAssetArray:photoArray];
                [self p_popViewCtr];
            }
        };
        
        return;
    }
    
    if (self.currentSelectionMode == WLAssetsSelectionMode_Single_status && self.editable) {
        WLEditPhotoViewController *ctr = [[WLEditPhotoViewController alloc] init];
        ctr.edit_photo_type = Edit_photo_type_status;
        [self presentViewController:ctr animated:YES completion:^{
            
        }];
        
        ctr.clickIndex = 0;
        ctr.photoArray = self.checkedPhotoArray;
        ctr.photoArrayBlock = ^(NSMutableArray *photoArray) {
            
            if ([self.delegate respondsToSelector:@selector(assetsViewCtr:didSelectedWithAssetArray:)]) {
                [self.delegate assetsViewCtr:self didSelectedWithAssetArray:photoArray];
                [self p_popViewCtr];
            }
        };
        
        return;
    }
    
    if (self.currentSelectionMode == WLAssetsSelectionMode_Single && self.editable) {
        WLCutImageViewController *ctr = [[WLCutImageViewController alloc] initWithPHAsset:self.checkedPhotoArray.firstObject.asset];
        ctr.delegate = self;
        [self.navigationController pushViewController:ctr animated:YES];
        return;
    }
    
    
    if ([self.delegate respondsToSelector:@selector(assetsViewCtr:didSelectedWithAssetArray:)]) {
        [self.delegate assetsViewCtr:self didSelectedWithAssetArray:self.checkedPhotoArray];
        
        [self p_popViewCtr];
    }
}

- (void)previewBtnOnClicked {
    if ([self p_hasCheckedVideo]) {
        
    } else {
        _previewPhotoArray = [NSMutableArray array];
        [_previewPhotoArray addObjectsFromArray:self.checkedPhotoArray];
        
//        WLPhotoPreviewViewController *ctr = [[WLPhotoPreviewViewController alloc] initWithItemArray:_previewPhotoArray];
//        ctr.delegate = self;
//        [self.navigationController pushViewController:ctr animated:YES];
    }
}

#pragma mark - Private

- (BOOL)p_verifyCheckedAsset:(WLAssetModel *)itemModel indexPath:(NSIndexPath *)indexPath {
    if (itemModel.asset.mediaType == PHAssetMediaTypeVideo) {
        return [self p_verifyVideo:itemModel indexPath:indexPath];
    }
    
    return [self p_verifyPhoto:itemModel indexPath:indexPath];
}

- (BOOL)p_verifyPhoto:(WLAssetModel *)itemModel indexPath:(NSIndexPath *)indexPath {
    if ([self p_hasCheckedVideo] && !itemModel.isChecked) {
        [[AppContext currentViewController] showToast:[AppContext getStringForKey:@"picture_rule" fileName:@"pic_sel"]];
        return NO;
    }
    
    if (self.checkedPhotoArray.count >= self.maxCheckedNumberLimit && !itemModel.isChecked) {
        [[AppContext currentViewController] showToast:[NSString stringWithFormat:[AppContext getStringForKey:@"picture_message_max_num"
                                                                                                  fileName:@"pic_sel"],
                                                     self.maxCheckedNumberLimit]];
        return NO;
    }
    
    itemModel.checked = !itemModel.isChecked;
    
    if (itemModel.isChecked) {
        if ([self p_isGif:itemModel] && itemModel.quality > MAX_IMAGE_UPLOAD_QUALITY) {
            [[AppContext currentViewController] showToast:[AppContext getStringForKey:@"video_too_large" fileName:@"pic_sel"]];
            return NO;
        }
        
        NSInteger index = [self p_indexInCheckedArray:itemModel];
        if (index != -1) {
            return NO;
        }
        
        itemModel.checkedIndex = self.checkedPhotoArray.count + 1;
        [self p_addToCheckedArray:itemModel];
        
        if (indexPath) {
            [self.checkedCellDic setObject:indexPath forKey:itemModel.asset.localIdentifier];
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        } else {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            [self.collectionView reloadData];
            [CATransaction commit];
        }
    } else {
        NSInteger index = [self p_indexInCheckedArray:itemModel];
        if (index == -1) {
            return NO;
        }
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (NSInteger i = index; i < self.checkedPhotoArray.count; i++) {
            NSIndexPath *indexPath = [self.checkedCellDic objectForKey:self.checkedPhotoArray[i].asset.localIdentifier];
            if (!indexPath) {
                continue;
            }
            [indexPaths addObject:indexPath];
        }
        
        [self.checkedCellDic removeObjectForKey:itemModel.asset.localIdentifier];
        
        for (NSInteger i = index; i < self.checkedPhotoArray.count; i++) {
            self.checkedPhotoArray[i].checkedIndex -= 1;
        }
        [self p_removeObjectFromCheckedArray:self.checkedPhotoArray[index]];
        
        if (indexPaths.count > 0) {
            [self.collectionView reloadItemsAtIndexPaths:indexPaths];
        } else {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            [self.collectionView reloadData];
            [CATransaction commit];
        }
    }
    
    [self p_updateConfirmTitle:AssetsConfirmBtnTitle(self.checkedPhotoArray.count, self.maxCheckedNumberLimit)];
    
    return YES;
}

- (BOOL)p_verifyVideo:(WLAssetModel *)itemModel indexPath:(NSIndexPath *)indexPath {
    if (self.checkedPhotoArray.count > 0 && ![self p_hasCheckedVideo]) {
        [[AppContext currentViewController] showToast:[AppContext getStringForKey:@"picture_rule" fileName:@"pic_sel"]];
        return NO;
    }
    
    if ([self p_hasCheckedVideo] && !itemModel.isChecked) {
        [[AppContext currentViewController] showToast:[AppContext getStringForKey:@"picture_message_video_max_num" fileName:@"pic_sel"]];
        return NO;
    }
    
    if (itemModel.quality > MAX_VIDEO_UPLOAD_QUALITY) {
        [[AppContext currentViewController] showToast:[AppContext getStringForKey:@"video_too_large" fileName:@"pic_sel"]];
        return NO;
    }
    
    itemModel.checked = !itemModel.isChecked;
    
    if (itemModel.isChecked) {
        itemModel.checkedIndex = 1;
        [self p_addToCheckedArray:itemModel];
        [self p_updateConfirmTitle:AssetsConfirmBtnTitle(1, kMaxCheckedVideoLimit)];
    } else {
        itemModel.checkedIndex = -1;
        [self p_removeObjectFromCheckedArray:itemModel];
        [self p_updateConfirmTitle:AssetsConfirmBtnTitle(0, self.maxCheckedNumberLimit)];
    }
    
    if (indexPath) {
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    } else {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self.collectionView reloadData];
        [CATransaction commit];
    }
    return YES;
}

- (void)p_addToCheckedArray:(WLAssetModel *)model {
    if (model.asset.mediaType == PHAssetMediaTypeImage && model.isCloud && !model.hasSyncCloud) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        
        [self showLoading];
        [[PHImageManager defaultManager] requestImageDataForAsset:model.asset
                                                          options:options
                                                    resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                                                        [self hideLoading];
                                                        
                                                        if (imageData.length <= 0) {
                                                            model.hasSyncCloud = NO;
                                                            return;
                                                        }
                                                        
                                                        model.hasSyncCloud = YES;
                                                        
                                                        [self.checkedPhotoArray addObject:model];
                                                        self.confirmBtn.enabled = self.checkedPhotoArray.count > 0;
                                                        self.previewBtn.enabled = self.checkedPhotoArray.count > 0;
                                                        
                                                        [self p_updateConfirmTitle:AssetsConfirmBtnTitle(self.checkedPhotoArray.count, self.maxCheckedNumberLimit)];
                                                    }];
    } else {
        [self.checkedPhotoArray addObject:model];
        self.confirmBtn.enabled = self.checkedPhotoArray.count > 0;
        self.previewBtn.enabled = self.checkedPhotoArray.count > 0;
    }
}

- (void)p_removeObjectFromCheckedArray:(WLAssetModel *)model {
    [self.checkedPhotoArray removeObject:model];
    self.confirmBtn.enabled = self.checkedPhotoArray.count > 0;
    self.previewBtn.enabled = self.checkedPhotoArray.count > 0;
}

- (BOOL)p_hasCheckedVideo {
    if (self.checkedPhotoArray.count == 1 && self.checkedPhotoArray.firstObject.type == WLAssetModelType_Video) {
        return YES;
    }
    
    return NO;
}

- (NSInteger)p_indexInCheckedArray:(WLAssetModel *)itemModel {
    NSInteger index = -1;
    
    for (NSInteger i = self.checkedPhotoArray.count - 1; i >= 0; i--) {
        if ([self.checkedPhotoArray[i].asset.localIdentifier isEqualToString:itemModel.asset.localIdentifier]) {
            index = i;
            break;
        }
    }
    return index;
}

- (void)p_popViewCtr {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
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
            [self.navigationController popToViewController:self.navigationController.viewControllers[preIndex] animated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    });
}

- (BOOL)p_isGif:(WLAssetModel *)itemModel {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = NO;
    options.synchronous = YES;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    [[PHImageManager defaultManager] requestImageDataForAsset:itemModel.asset
                                                      options:options
                                                resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                                                    if ([info[@"PHImageFileUTIKey"] isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                                                        itemModel.isGif = YES;
                                                    } else {
                                                        itemModel.isGif = NO;
                                                    }
                                                    itemModel.quality = imageData.length;
                                                }];
    
    return itemModel.isGif;
}

- (void)p_updateConfirmTitle:(NSString *)title {
    [self.confirmBtn setTitle:title forState:UIControlStateNormal];
    CGFloat height = CGRectGetHeight(self.confirmBtn.bounds);
//    [self.confirmBtn sizeToFit];
//    self.confirmBtn.width += 24;
    self.confirmBtn.height = height;
   // self.confirmBtn.centerX = CGRectGetWidth(self.navigationBar.contentView.bounds) - CGRectGetWidth(self.confirmBtn.bounds) * 0.5;
    
   
    CGSize btnSize = [title sizeWithFont:kRegularFont(kNameFontSize) size:CGSizeMake(110, 20)];
    
    self.confirmBtn.width = btnSize.width;
    self.confirmBtn.right = kScreenWidth - 10;
}

#pragma mark - Setter

- (void)setCurrentSelectionMode:(WLAssetsSelectionMode)currentSelectionMode {
    _currentSelectionMode = currentSelectionMode;
    
    switch (currentSelectionMode) {
        case WLAssetsSelectionMode_Single:
            self.maxCheckedNumberLimit = 1;
            self.editable = YES;
            break;
        case WLAssetsSelectionMode_Multiple:
            self.maxCheckedNumberLimit = kMaxCheckedNumberLimit;
            self.editable = NO;
            break;
        case WLAssetsSelectionMode_Single_poll:
        case WLAssetsSelectionMode_Single_status:
            self.maxCheckedNumberLimit = 1;
            self.editable = YES;
            break;
    }
}

- (void)setSelectedAlbum:(PHAssetCollection *)selectedAlbum {
    [self titleBtnClicked:_titleBtn];
    
    if (_selectedAlbum == selectedAlbum) {
        return;
    }
    
    _selectedAlbum = selectedAlbum;
    
    [_titleBtn setTitle:selectedAlbum.localizedTitle forState:UIControlStateNormal];
    [UIView animateWithDuration:0
                     animations:^{
                         [self->_titleBtn sizeToFit];
                         [self.navigationBar setNeedsLayout];
                     }];
    
    _assetArray = nil;
    [self.assetsManager fetchAssetsWithAssetCollection:selectedAlbum];
    [self.collectionView reloadData];
}

#pragma mark - Getter

- (WLAssetsAlbumView *)albumTableView {
    if (!_albumTableView) {
        WLAssetsAlbumView *tableView = [[WLAssetsAlbumView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight - kNavBarHeight)];
        tableView.delegate = self;
        [self.view addSubview:tableView];
        _albumTableView = tableView;
    }
    return _albumTableView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionView *collView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kNavBarHeight,
                                                                                        self.view.bounds.size.width,
                                                                                        kScreenHeight - kNavBarHeight)
                                                        collectionViewLayout:self.flowLayout];
        collView.backgroundColor = [UIColor whiteColor];
        collView.contentInset = UIEdgeInsetsMake(0, 0,  kSafeAreaBottomY, 0);
        collView.delegate = self;
        collView.dataSource = self;
        collView.showsHorizontalScrollIndicator = NO;
        collView.showsVerticalScrollIndicator = NO;
        [collView registerClass:[WLAssetsCollectionCell class] forCellWithReuseIdentifier:reusCellID];
        [self.view addSubview:collView];
        [self.view sendSubviewToBack:collView];
        _collectionView = collView;
        
        if (@available(iOS 11.0, *)){
            collView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        NSInteger numbersInRow = 4;
        CGFloat spacing = 2.0;
        CGFloat width = (kScreenWidth - (numbersInRow - 1) * spacing) / numbersInRow;
        
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = spacing;
        _flowLayout.minimumInteritemSpacing = spacing;
        _flowLayout.itemSize = CGSizeMake(width, width);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _flowLayout;
}

- (WLAssetsManager *)assetsManager {
    return [WLAssetsManager sharedInstance];
}

- (NSMutableArray<PHAssetCollection *> *)albumArray {
    if (!_albumArray) {
        _albumArray = [NSMutableArray array];
        
        for (int i = 0; i < self.assetsManager.allAlbums.count; i++) {
            PHAssetCollection *obj = self.assetsManager.allAlbums[i];
            if (obj.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumVideos) {
                if (self.currentSelectionMode == WLAssetsSelectionMode_Single || self.editable) {
                    continue;
                }
            }
            
            [_albumArray addObject:obj];
        }
    }
    return _albumArray;
}

- (NSMutableArray<WLAssetModel *> *)assetArray {
    if (!_assetArray) {
        _assetArray = [NSMutableArray array];
        [_assetArray addObject:[[WLAssetModel alloc] initWithType:WLAssetModelType_Camera asset:nil]];
        
        for (int i = 0; i < self.assetsManager.assets.count; i++) {
            WLAssetModel *assetModel = self.assetsManager.assets[i];
            
            if (assetModel.type == WLAssetModelType_Video) {
                if (self.currentSelectionMode == WLAssetsSelectionMode_Single || self.editable) {
                    continue;
                }
            }
            
            NSInteger index = [self p_indexInCheckedArray:assetModel];
            if (index != -1) {
                assetModel = self.checkedPhotoArray[index];
            }
            
            assetModel.index = i + 1;
            
            if (assetModel.checked) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:assetModel.index inSection:0];
                if (indexPath) {
                    [self.checkedCellDic setObject:indexPath forKey:assetModel.asset.localIdentifier];
                }
            }
            
            [_assetArray addObject:assetModel];
        }
    }
    return _assetArray;
}

- (NSMutableArray<WLAssetModel *> *)checkedPhotoArray {
    if (!_checkedPhotoArray) {
        _checkedPhotoArray = [NSMutableArray array];
    }
    return _checkedPhotoArray;
}

- (NSMutableDictionary<NSString *, NSIndexPath *> *)checkedCellDic {
    if (!_checkedCellDic) {
        _checkedCellDic = [NSMutableDictionary dictionary];
    }
    return _checkedCellDic;
}

- (PHAssetCollection *)selectedAlbum {
    if (!_selectedAlbum) {
        [self.albumArray enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                self->_selectedAlbum = obj;
                *stop = YES;
            }
        }];
    }
    return _selectedAlbum;
}

@end
