//
//  FQAssetsViewController.m
//  WeLike
//
//  Created by fan qi on 2018/4/3.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQAssetsViewController.h"
#import "FQCameraViewController.h"
#import "FQAssetsBrowseViewController.h"
#import "FQImageButton.h"

#pragma mark - ************************* FQAssetsCollectionCell *************************

@class FQAssetsCollectionCell;

@protocol FQAssetsCollectionCellDelegate <NSObject>

- (void)assetsCollectionCell:(FQAssetsCollectionCell *)cell didClickedWithItemModel:(FQAssetModel *)itemModel;

@end

@interface FQAssetsCollectionCell : UICollectionViewCell

@property (nonatomic, strong) FQAssetModel *itemModel;

@property (nonatomic, weak) CALayer *imgLayer;
@property (nonatomic, weak) CALayer *videoIconLayer;
@property (nonatomic, weak) FQImageButton *checkBtn;

@property (nonatomic, strong) CABasicAnimation *springAnimation;

@property (nonatomic, weak) id<FQAssetsCollectionCellDelegate> delegate;

@end

@implementation FQAssetsCollectionCell

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
        self.checkBtn.hidden = YES;
        self.imgLayer.contentsGravity = kCAGravityCenter;
        self.imgLayer.contents =(__bridge id)[UIImage imageNamed:@"camera_icon"].CGImage;
        
    } else {
        self.checkBtn.hidden = NO;
        self.checkBtn.selected = itemModel.isChecked;
        
        if (self.checkBtn.selected) {
            [self.checkBtn setTitle:[NSString stringWithFormat:@"%zd", itemModel.checkedIndex] forState:UIControlStateNormal];
        } else {
            [self.checkBtn setTitle:nil forState:UIControlStateNormal];
        }
        
        self.imgLayer.contentsGravity = kCAGravityResizeAspectFill;
        self.videoIconLayer.hidden = itemModel.asset.mediaType != PHAssetMediaTypeVideo;
        
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

#pragma mark - Event

- (void)checkBtnClicked:(FQImageButton *)sender {
//    if ([UIDevice currentDevice].systemVersion.doubleValue >= 9.0) {
//        [sender.layer removeAnimationForKey:@"FQAssetCheckButtonSpringAnimation"];
//        [sender.layer addAnimation:self.springAnimation forKey:@"FQAssetCheckButtonSpringAnimation"];
//    }
    
    if ([self.delegate respondsToSelector:@selector(assetsCollectionCell:didClickedWithItemModel:)]) {
        [self.delegate assetsCollectionCell:self didClickedWithItemModel:self.itemModel];
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

- (CALayer *)videoIconLayer {
    if (!_videoIconLayer) {
        CALayer *videoLayer = [CALayer layer];
        videoLayer.hidden = YES;
        videoLayer.contents = (__bridge id)[UIImage imageNamed:@"camera_video_icon"].CGImage;
        videoLayer.contentsGravity = kCAGravityCenter;
        videoLayer.contentsScale = [UIScreen mainScreen].scale;
        videoLayer.position = CGPointMake(CGRectGetWidth(self.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5);
        [self.imgLayer addSublayer:videoLayer];
        _videoIconLayer = videoLayer;
    }
    return _videoIconLayer;
}

- (FQImageButton *)checkBtn {
    if (!_checkBtn) {
        CGFloat padding = kSizeScale(6);
        FQImageButton *btn = [FQImageButton buttonWithType:UIButtonTypeCustom];
        btn.imageOrientation = FQImageButtonOrientation_Center;
        btn.selected = NO;
        [btn setImage:[UIImage imageNamed:@"camera_photo_selected"] forState:UIControlStateSelected];
        [btn setImage:[UIImage imageNamed:@"camera_photo_unselected"] forState:UIControlStateNormal];
        [btn setTitleColor:kBodyFontColor forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:kSizeScale(11)];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn addTarget:self action:@selector(checkBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn sizeToFit];
        btn.frame = CGRectMake(0, 0, CGRectGetWidth(btn.bounds) + padding * 2, CGRectGetHeight(btn.bounds) + padding * 2);
        btn.center = CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(btn.bounds) * 0.5, CGRectGetHeight(btn.bounds) * 0.5);
        [self.contentView addSubview:btn];
        _checkBtn = btn;
    }
    return _checkBtn;
}

- (CABasicAnimation *)springAnimation {
    if (!_springAnimation) {
        CASpringAnimation * animation = [CASpringAnimation animation];
        animation.keyPath = @"transform";
        animation.valueFunction = [CAValueFunction functionWithName:kCAValueFunctionScale];
        animation.fromValue = @[@(1.0), @(1.0), @(1.0)];
        animation.toValue = @[@(1.2), @(1.2), @(1.0)];
        animation.mass = 10.0;
        animation.stiffness = 5000;
        animation.damping = 100.0;
        animation.initialVelocity = 5.0;
        animation.duration = animation.settlingDuration;
        animation.autoreverses = YES;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _springAnimation = animation;
    }
    return _springAnimation;
}

@end

#pragma mark - ************************* FQAssetsAlbumView *************************

#define ContentViewHeight           kSizeScale(220)
#define TableViewHeight             kSizeScale(190)
#define DefaultRowHeight            kSizeScale(50)

@class FQAssetsAlbumView;

@protocol FQAssetsAlbumViewDelegate <NSObject>

- (void)assetsAlbumView:(FQAssetsAlbumView *)albumView didSelectedWithItemModel:(PHAssetCollection *)itemModel;
- (void)assetsAlbumViewDidDismiss:(FQAssetsAlbumView *)albumView;

@end

@interface FQAssetsAlbumView : UIView <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, copy) NSArray<PHAssetCollection *> *dataArray;
@property (nonatomic, weak) id<FQAssetsAlbumViewDelegate> delegate;
@property (nonatomic, assign, readonly, getter=isDisplayed) BOOL displayed;

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UITableView *tableView;

- (void)displayWithAnimation:(void(^)(void))animation;
- (void)dismissWithAnimation:(void(^)(void))animation;

@end

@implementation FQAssetsAlbumView

- (instancetype)initWithDataArray:(NSArray *)dataArray {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnTapped)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        _dataArray = dataArray;
        
        if (_dataArray.count > 0) {
            [self.tableView reloadData];
        }
    }
    return self;
}

#pragma mark - Public

- (void)displayWithAnimation:(void (^)(void))animation {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.hidden = NO;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.contentView.transform = CGAffineTransformMakeTranslation(0, TableViewHeight);
                         if (animation) {
                             animation();
                         }
                     }
                     completion:^(BOOL finished) {
                         _displayed = YES;
                     }];
}

- (void)dismissWithAnimation:(void (^)(void))animation {
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.contentView.transform = CGAffineTransformIdentity;
                         self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
                         if (animation) {
                             animation();
                         }
                     }
                     completion:^(BOOL finished) {
                         self.hidden = YES;
                         _displayed = NO;
                     }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"FQComboxCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = self.dataArray[indexPath.row].localizedTitle;
    cell.textLabel.textColor = kBodyFontColor;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PHAssetCollection *album = self.dataArray[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(assetsAlbumView:didSelectedWithItemModel:)]) {
        [self.delegate assetsAlbumView:self didSelectedWithItemModel:album];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self];
    CGPoint newPoint = [self.tableView convertPoint:point fromView:self];
    if (CGRectContainsPoint(self.tableView.bounds, newPoint)) {
        return NO;
    }
    
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

#pragma mark - Event

- (void)selfOnTapped {
    if ([self.delegate respondsToSelector:@selector(assetsAlbumViewDidDismiss:)]) {
        [self.delegate assetsAlbumViewDidDismiss:self];
    }
}

#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -ContentViewHeight, kScreenWidth, ContentViewHeight)];
        view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        [self addSubview:view];
        _contentView = view;
    }
    return _contentView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ContentViewHeight - TableViewHeight, kScreenWidth, TableViewHeight)];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.rowHeight = DefaultRowHeight;
        [self.contentView addSubview:tableView];
        _tableView = tableView;
    }
    return _tableView;
}

@end

#pragma mark - ************************* FQAssetsViewController *************************

static NSString * const reusCellID = @"FQAssetsCollectionCell";

@interface FQAssetsViewController () <FQCameraViewControllerDelegate, FQAssetsCollectionCellDelegate, FQAssetsBrowseViewControllerDelegate, FQAssetsAlbumViewDelegate,
UICollectionViewDelegate, UICollectionViewDataSource> {
    PHAssetCollection *_selectedAlbum;
}

@property (nonatomic, weak) FQImageButton *titleBtn;
@property (nonatomic, weak) FQAssetsAlbumView *albumTableView;

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) UIButton *confirmBtn;

@property (nonatomic, strong) FQAssetsManager *assetsManager;
@property (nonatomic, strong) NSMutableArray<PHAssetCollection *> *albumArray;
@property (nonatomic, strong) NSMutableArray<FQAssetModel *> *assetArray;
@property (nonatomic, strong) NSMutableArray<FQAssetModel *> *checkedPhotoArray;
@property (nonatomic, strong) NSMutableDictionary<FQAssetModel *, NSIndexPath *> *checkedCellDic;
@property (nonatomic, strong) FQAssetModel *checkedVideo;

@property (nonatomic, strong) PHAssetCollection *selectedAlbum;

@end

@implementation FQAssetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    {
        self.navigationItem.rightBarButtonItem = ({
            UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [closeBtn setTitle:@"Close" forState:UIControlStateNormal];
            closeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
            [closeBtn setTitleColor:kHeaderFontColor forState:UIControlStateNormal];
            [closeBtn sizeToFit];
            [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            
            UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
            rightBarBtn;
        });
        
        self.navigationItem.titleView = ({
            // CGRectMake(0, 0, kSizeScale(150), kNavBarHeight - kStatusBarHeight)
            FQImageButton *btn = [[FQImageButton alloc] init];
            btn.imageOrientation = FQImageButtonOrientation_Right;
            btn.selected = NO;
            [btn setTitle:self.selectedAlbum.localizedTitle forState:UIControlStateNormal];
            [btn setTitleColor:kHeaderFontColor forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:kSizeScale(17)];
            [btn setImage:[UIImage imageNamed:@"camera_triangle"] forState:UIControlStateNormal];
            [btn sizeToFit];
            [btn addTarget:self action:@selector(titleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            _titleBtn = btn;
            
            btn;
        });
    }
    
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
            [btn setTitle:ConfirmBtnTitle(0) forState:UIControlStateNormal];
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
    
    [self.collectionView reloadData];
}

- (void)dealloc {
    NSLog(@"FQAssetsViewController delloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FQCameraViewControllerDelegate

- (void)cameraViewCtr:(FQCameraViewController *)viewCtr didConfirmWithOutputType:(FQCameraOutputType)outputType image:(UIImage *)image {
    if ([self.delegate respondsToSelector:@selector(assetsViewCtr:didSelectedWithAssetArray:)]) {
        [self.delegate assetsViewCtr:self didSelectedWithAssetArray:@[image]];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - FQAssetsCollectionCellDelegate

- (void)assetsCollectionCell:(FQAssetsCollectionCell *)cell didClickedWithItemModel:(FQAssetModel *)itemModel {
    if (self.checkedVideo && !itemModel.isChecked) {
        [FQProgressHUDHelper showErrorWithMessage:@"只能选择一个视频"];
        return;
    }

    if (itemModel.asset.mediaType == PHAssetMediaTypeVideo) {
        if (self.checkedPhotoArray.count != 0) {
            [FQProgressHUDHelper showErrorWithMessage:@"已选图片后不能选择视频"];
            return;
        }
        
        itemModel.checked = !itemModel.isChecked;
        if (itemModel.isChecked) {
            itemModel.checkedIndex = 1;
            self.checkedVideo = itemModel;
            [self.confirmBtn setTitle:ConfirmBtnTitle(1) forState:UIControlStateNormal];
        } else {
            itemModel.checkedIndex = -1;
            self.checkedVideo = nil;
            [self.confirmBtn setTitle:ConfirmBtnTitle(0) forState:UIControlStateNormal];
        }

        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        if (!indexPath) {
            return;
        }
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        return;
    }
    
    if (self.checkedPhotoArray.count >= MaxCheckedNumberLimit && !itemModel.isChecked) {
        [FQProgressHUDHelper showErrorWithMessage:[NSString stringWithFormat:@"最多只能选择%zd张图片", MaxCheckedNumberLimit]];
        return;
    }
    
    itemModel.checked = !itemModel.isChecked;
    
    if (itemModel.isChecked) {
        if ([self.checkedPhotoArray containsObject:itemModel]) {
            return;
        }
        
        itemModel.checkedIndex = self.checkedPhotoArray.count + 1;
        [self.checkedPhotoArray addObject:itemModel];
        
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        if (!indexPath) {
            return;
        }
        
        [self.checkedCellDic setObject:indexPath forKey:itemModel];
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    } else {
        NSInteger index = -1;
        
        for (NSInteger i = self.checkedPhotoArray.count - 1; i >= 0; i--) {
            if (self.checkedPhotoArray[i] == itemModel) {
                index = i;
            }
        }
        if (index == -1) {
            return;
        }
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (NSInteger i = index; i < self.checkedPhotoArray.count; i++) {
            [indexPaths addObject:[self.checkedCellDic objectForKey:self.checkedPhotoArray[i]]];
        }
        
        [self.checkedCellDic removeObjectForKey:itemModel];
        for (NSInteger i = index; i < self.checkedPhotoArray.count; i++) {
            self.checkedPhotoArray[i].checkedIndex -= 1;
        }
        [self.checkedPhotoArray removeObjectAtIndex:index];
        
        [self.collectionView reloadItemsAtIndexPaths:indexPaths];
    }
    
    [self.confirmBtn setTitle:ConfirmBtnTitle(self.checkedPhotoArray.count) forState:UIControlStateNormal];
}

#pragma mark - FQAssetsBrowseViewControllerDelegate

- (void)assetsBrowseViewCtr:(FQAssetsBrowseViewController *)ctr didClickedWithCurrentIndex:(NSInteger)currentIndex {
    if (currentIndex + 1 >= self.assetArray.count) {
        return;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentIndex + 1 inSection:0];
    FQAssetsCollectionCell *cell = (FQAssetsCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (!cell) {
        return;
    }
    
    [self assetsCollectionCell:cell didClickedWithItemModel:self.assetArray[currentIndex + 1]];
}

#pragma mark - FQAssetsAlbumViewDelegate

- (void)assetsAlbumView:(FQAssetsAlbumView *)albumView didSelectedWithItemModel:(PHAssetCollection *)itemModel {
    if ([itemModel.localizedTitle isEqualToString:_titleBtn.titleLabel.text]) {
        return;
    }
    
    self.selectedAlbum = itemModel;
}

- (void)assetsAlbumViewDidDismiss:(FQAssetsAlbumView *)albumView {
    [self titleBtnClicked:_titleBtn];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FQAssetsCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusCellID forIndexPath:indexPath];
    cell.delegate = self;
    [cell setItemModel:self.assetArray[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FQAssetModel *itemModel = self.assetArray[indexPath.row];
    if (itemModel.type == FQAssetModelType_Camera) {
        FQCameraViewController *ctr = [FQCameraViewController new];
        ctr.delegate = self;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    ctr.outputType = FQCameraOutputType_Photo;
                                                    [self.navigationController pushViewController:ctr animated:YES];
                                                }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"视频" style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    ctr.outputType = FQCameraOutputType_Video;
                                                    [self.navigationController pushViewController:ctr animated:YES];
                                                }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        NSArray *tmpArray = [self.assetArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, self.assetArray.count - 1)]];
        FQAssetsBrowseViewController *ctr = [[FQAssetsBrowseViewController alloc] initWithItemArray:tmpArray checkedNumber:self.checkedPhotoArray.count];
        ctr.currentIndex = indexPath.row - 1;
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

- (void)closeBtnClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)confirmBtnClicked {
    if (self.checkedPhotoArray.count == 0 && !self.checkedVideo) {
        return;
    }
    
    if (![self.delegate respondsToSelector:@selector(assetsViewCtr:didSelectedWithAssetArray:)]) {
        return;
    }
    
    NSMutableArray *imgArray = [NSMutableArray array];
    
    dispatch_apply(self.checkedPhotoArray.count, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t index) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.networkAccessAllowed = NO;
        options.synchronous = YES;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        
        PHAsset *asset = self.checkedPhotoArray[index].asset;
        CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
        CGFloat pixelWidth = kScreenWidth * kScreenScale;
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);
        
        [[PHImageManager defaultManager] requestImageForAsset:asset
                                                   targetSize:imageSize
                                                  contentMode:PHImageContentModeAspectFit
                                                      options:options
                                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                    [imgArray addObject:result];
                                                }];
    });
    [self.delegate assetsViewCtr:self didSelectedWithAssetArray:imgArray];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Setter

- (void)setSelectedAlbum:(PHAssetCollection *)selectedAlbum {
    _selectedAlbum = selectedAlbum;
    
    [_titleBtn setTitle:selectedAlbum.localizedTitle forState:UIControlStateNormal];
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
        UICollectionView *collView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - kNavBarHeight - BottomViewHeight - kSafeAreaBottomY) collectionViewLayout:self.flowLayout];
        collView.backgroundColor = [UIColor whiteColor];
        collView.delegate = self;
        collView.dataSource = self;
        collView.showsHorizontalScrollIndicator = NO;
        collView.showsVerticalScrollIndicator = NO;
        [collView registerClass:[FQAssetsCollectionCell class] forCellWithReuseIdentifier:reusCellID];
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

- (NSMutableArray<FQAssetModel *> *)checkedPhotoArray {
    if (!_checkedPhotoArray) {
        _checkedPhotoArray = [NSMutableArray array];
    }
    return _checkedPhotoArray;
}

- (NSMutableDictionary<FQAssetModel *, NSIndexPath *> *)checkedCellDic {
    if (!_checkedCellDic) {
        _checkedCellDic = [NSMutableDictionary dictionary];
    }
    return _checkedCellDic;
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
