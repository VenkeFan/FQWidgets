//
//  WLUserAlbumCollectionViewCell.m
//  welike
//
//  Created by fan qi on 2018/12/14.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLUserAlbumCollectionViewCell.h"
#import "WLAlbumPicModel.h"

@interface WLUserAlbumCollectionViewCell ()

@property (nonatomic, strong, readwrite) UIImageView *imgView;
@property (nonatomic, strong) CALayer *gifLayer;

@end

@implementation WLUserAlbumCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imgView = [[UIImageView alloc] initWithFrame:frame];
        _imgView.backgroundColor = kUIColorFromRGB(0xE9E9E9);
        _imgView.clipsToBounds = YES;
        [self.contentView addSubview:_imgView];
        
        UIImage *image = [AppContext getImageForKey:@"feed_gif_icon_small"];
        CGFloat padding = 8;
        
        _gifLayer = [CALayer layer];
        _gifLayer.frame = CGRectMake(CGRectGetWidth(_imgView.frame) - padding - image.size.width,
                                 CGRectGetHeight(_imgView.frame) - padding - image.size.height,
                                 image.size.width,
                                 image.size.height);
        _gifLayer.contents = (__bridge id)image.CGImage;
        _gifLayer.contentsGravity = kCAGravityResizeAspect;
        [self.contentView.layer addSublayer:_gifLayer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _imgView.frame = self.bounds;
}

- (void)setCellModel:(WLAlbumPicModel *)cellModel {
    _cellModel = cellModel;
    
    self.gifLayer.hidden = YES;
    
    __weak typeof(self) weakSelf = self;
    self.imgView.contentMode = UIViewContentModeScaleToFill;
    self.imgView.layer.contentsRect = CGRectMake(0.0, 0.0, 1.0, 1.0);
    [self.imgView fq_setImageWithURLString:cellModel.thumbnailPicUrl
                                 completed:^(UIImage *image, NSURL *url, NSError *error) {
                                     cellModel.thumbImg = image;
                                     [self p_clipImgView:weakSelf.imgView image:image cellModel:cellModel];
                                 }];
    
    if ([cellModel.picUrl hasSuffix:@".gif"] || [cellModel.picUrl hasSuffix:@".gif/"]
        || [cellModel.picUrl hasSuffix:@".webp"] || [cellModel.picUrl hasSuffix:@".webp/"]) {
        
        self.gifLayer.hidden = NO;
    }
}

- (void)p_clipImgView:(UIImageView *)imgView image:(UIImage *)image cellModel:(WLPicInfo *)cellModel {
    CGSize imgViewSize = imgView.size;
    CGFloat imgViewWidth = imgViewSize.width;
    CGFloat imgViewHeight = imgViewSize.height;
    
    if (image) {
        if (cellModel.width == 0 || cellModel.height == 0) {
            if (image.size.width / image.size.height > 1.0) {
                CGFloat scaleWidth = image.size.width / image.size.height * imgViewSize.height;
                imgView.layer.contentsRect = CGRectMake(0, 0, imgViewSize.width / scaleWidth, 1.0);
                
            } else {
                CGFloat scaleHeight = image.size.height / image.size.width * imgViewWidth;
                imgView.layer.contentsRect = CGRectMake(0, 0, 1.0, imgViewHeight / scaleHeight);
            }
        } else {
            if (cellModel.badgeType == WLPicInfoBadgeType_Horizontal) {
                CGFloat scaleWidth = image.size.width / image.size.height * imgViewHeight;
                imgView.layer.contentsRect = CGRectMake(0, 0, imgViewWidth / scaleWidth, 1.0);
                
            } else if (cellModel.badgeType == WLPicInfoBadgeType_Horizontal_Long) {
                CGFloat scaleWidth = image.size.width / image.size.height * imgViewHeight;
                CGFloat ratio = imgViewWidth / scaleWidth;
                imgView.layer.contentsRect = CGRectMake((1 - ratio) / 2.0, 0, ratio, 1.0);
                
            } else if (cellModel.badgeType == WLPicInfoBadgeType_Vertical || cellModel.badgeType == WLPicInfoBadgeType_Vertical_Long) {
                CGFloat scaleHeight = image.size.height / image.size.width * imgViewWidth;
                imgView.layer.contentsRect = CGRectMake(0, 0, 1.0, imgViewHeight / scaleHeight);
            } else if (cellModel.badgeType == WLPicInfoBadgeType_Square) {
                imgView.layer.contentsRect = CGRectMake(0, 0, 1.0, 1.0);
            }
        }
    }
}

@end
