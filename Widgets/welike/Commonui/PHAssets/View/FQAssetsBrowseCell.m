//
//  FQAssetsBrowseCell.m
//  welike
//
//  Created by fan qi on 2018/12/24.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "FQAssetsBrowseCell.h"
#import "WLZoomScaleView.h"
#import "FLAnimatedImage.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "WLAssetModel.h"

@interface FQAssetsBrowseCell () <WLZoomScaleViewDelegate>

@property (nonatomic, strong) WLZoomScaleView *scaleView;
@property (nonatomic, strong) UIButton *playBtn;

@end

@implementation FQAssetsBrowseCell

#pragma mark - LifeCycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.scaleView];
        [self.contentView addSubview:self.playBtn];
        
        UITapGestureRecognizer *singleRecognizer= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnTapped)];
        [self addGestureRecognizer:singleRecognizer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scaleView.frame = self.bounds;
    self.playBtn.center = CGPointMake(CGRectGetWidth(self.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5);
}

#pragma mark - Public

- (void)setItemModel:(WLAssetModel *)itemModel {
    _itemModel = itemModel;
    
    self.playBtn.hidden = YES;
    
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
                                              contentMode:PHImageContentModeAspectFill
                                                  options:options
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                if ([info[@"PHImageFileUTIKey"] isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                                                    [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                                                                      options:options
                                                                                                resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                                                                                                    self.scaleView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:imageData];
                                                                                                }];
                                                    
                                                } else {
                                                    self.scaleView.image = result;
                                                }
                                                
                                                if (itemModel.asset.mediaType == PHAssetMediaTypeVideo) {
                                                    self.playBtn.hidden = NO;
                                                }
                                            }];
}

#pragma mark - WLPlayerViewDelegate

//- (void)playerView:(WLAVPlayerView *)playerView statusDidChanged:(WLPlayerViewStatus)status {
//    if ([self.delegate respondsToSelector:@selector(assetsBrowseCellPlayingStatusChanged:)]) {
//        [self.delegate assetsBrowseCellPlayingStatusChanged:status];
//    }
//}

#pragma mark - WLZoomScaleViewDelegate

- (void)zoomScaleViewDidTapped:(WLZoomScaleView *)scaleView {
    [self selfOnTapped];
}

#pragma mark - Event

- (void)selfOnTapped {
    if ([self.delegate respondsToSelector:@selector(assetsBrowseCellDidTapped:)]) {
        [self.delegate assetsBrowseCellDidTapped:self];
    }
}

- (void)playBtnClicked {
    if ([self.delegate respondsToSelector:@selector(assetsBrowseCellDidClickPlay:)]) {
        [self.delegate assetsBrowseCellDidClickPlay:self];
    }
}

#pragma mark - Getter

- (WLZoomScaleView *)scaleView {
    if (!_scaleView) {
        _scaleView = [[WLZoomScaleView alloc] initWithFrame:self.bounds];
        _scaleView.zoomScaleDelegate = self;
    }
    return _scaleView;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[AppContext getImageForKey:@"common_play"] forState:UIControlStateNormal];
        [btn sizeToFit];
        [btn addTarget:self action:@selector(playBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        _playBtn = btn;
    }
    return _playBtn;
}

@end
