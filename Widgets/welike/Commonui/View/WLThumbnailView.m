//
//  WLThumbnailView.m
//  WeLike
//
//  Created by fan qi on 2018/3/28.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLThumbnailView.h"
#import "WLImageBrowseView.h"
#import "UIImageView+Extension.h"
#import "WLPicInfo.h"
#import "WLTrackerPostRead.h"

@interface WLThumbnailView () <UIScrollViewDelegate> {
    NSArray *_imgArray;
}

@property (nonatomic, strong) NSMutableArray *imgViewArray;
@property (nonatomic, assign) NSInteger numberInRow;

@end

@implementation WLThumbnailView

#pragma mark - LifeCycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

#pragma mark - Public

- (void)setImages:(NSArray<WLPicInfo *> *)images
     imgViewWidth:(CGFloat)imgViewWidth
    imgViewHeight:(CGFloat)imgViewHeight
          spacing:(CGFloat)spacing {
    _imgArray = images;
    
    [self.imgViewArray removeAllObjects];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (images.count == 0) {
        return;
    }
    
    NSInteger numberInRow = 3;
    
    if (images.count == 4) {
        numberInRow = 2;
    }
    
    for (int i = 0; i < images.count; i++) {
        WLPicInfo *pic = images[i];
        
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.backgroundColor = kUIColorFromRGB(0xE9E9E9);
        imgView.frame = CGRectMake((i % numberInRow) * (imgViewWidth + spacing),
                                   ( i / numberInRow) * (imgViewHeight + spacing),
                                   imgViewWidth, imgViewHeight);
        imgView.contentMode = UIViewContentModeScaleToFill;
        imgView.clipsToBounds = YES;
        [imgView fq_setImageWithURLString:pic.thumbnailPicUrl
                                completed:^(UIImage *image, NSURL *url, NSError *error) {
                                    if (image) {
                                        
                                        if (pic.width == 0 || pic.height == 0) {
                                            if (image.size.width / image.size.height > 1.0) {
                                                CGFloat scaleWidth = image.size.width / image.size.height * imgViewHeight;
                                                imgView.layer.contentsRect = CGRectMake(0, 0, imgViewWidth / scaleWidth, 1.0);
                                                
                                            } else {
                                                CGFloat scaleHeight = image.size.height / image.size.width * imgViewWidth;
                                                imgView.layer.contentsRect = CGRectMake(0, 0, 1.0, imgViewHeight / scaleHeight);
                                            }
                                        } else {
                                            if (pic.badgeType == WLPicInfoBadgeType_Horizontal) {
                                                CGFloat scaleWidth = image.size.width / image.size.height * imgViewHeight;
                                                imgView.layer.contentsRect = CGRectMake(0, 0, imgViewWidth / scaleWidth, 1.0);
                                                
                                            } else if (pic.badgeType == WLPicInfoBadgeType_Horizontal_Long) {
                                                CGFloat scaleWidth = image.size.width / image.size.height * imgViewHeight;
                                                CGFloat ratio = imgViewWidth / scaleWidth;
                                                imgView.layer.contentsRect = CGRectMake((1 - ratio) / 2.0, 0, ratio, 1.0);
                                                
                                            } else if (pic.badgeType == WLPicInfoBadgeType_Vertical || pic.badgeType == WLPicInfoBadgeType_Vertical_Long) {
                                                CGFloat scaleHeight = image.size.height / image.size.width * imgViewWidth;
                                                imgView.layer.contentsRect = CGRectMake(0, 0, 1.0, imgViewHeight / scaleHeight);
                                            } else if (pic.badgeType == WLPicInfoBadgeType_Square) {
                                                imgView.layer.contentsRect = CGRectMake(0, 0, 1.0, 1.0);
                                            }
                                        }
                                    }
                                }];
        [self addSubview:imgView];
        
        if ([pic.picUrl hasSuffix:@".gif"] || [pic.picUrl hasSuffix:@".gif/"]
            || [pic.picUrl hasSuffix:@".webp"] || [pic.picUrl hasSuffix:@".webp/"]) {
            UIImage *image = imgViewWidth >= kScreenWidth * 0.5
                            ? [AppContext getImageForKey:@"feed_gif_icon_large"]
                            : [AppContext getImageForKey:@"feed_gif_icon_small"];
            CGFloat padding = 8;
            
            CALayer *layer = [CALayer layer];
            layer.frame = CGRectMake(CGRectGetWidth(imgView.frame) - padding - image.size.width,
                                     CGRectGetHeight(imgView.frame) - padding - image.size.height,
                                     image.size.width,
                                     image.size.height);
            layer.contents = (__bridge id)image.CGImage;
            layer.contentsGravity = kCAGravityResizeAspect;
            [imgView.layer addSublayer:layer];
        }
        
        imgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgViewTap:)];
        [imgView addGestureRecognizer:tap];

        [self.imgViewArray addObject:imgView];
    }
}

#pragma mark - Event

- (void)imgViewTap:(UITapGestureRecognizer *)gesture {
    if (_imgArray.count != self.imgViewArray.count) {
        return;
    }
    
    UIImageView *imgView = (UIImageView *)gesture.view;
    UIView *rootView = ([UIApplication sharedApplication].keyWindow.rootViewController).view;
    
    NSMutableArray *itemArray = [NSMutableArray array];
    [_imgArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FQImageBrowseItemModel *item = [[FQImageBrowseItemModel alloc] init];
        item.thumbView = self.imgViewArray[idx];
        item.imageInfo = obj;
        item.userName = self.userName;

        [itemArray addObject:item];
    }];
    
    WLImageBrowseView *groupView = [[WLImageBrowseView alloc] initWithItemArray:itemArray];
    [groupView displayWithFromView:imgView toView:rootView];
    
    [WLTrackerPostRead appendTrackerWithClickedArea:WLTrackerPostClickedArea_Picture
                                               post:self.feedModel];
}

#pragma mark - Getter

- (NSMutableArray *)imgViewArray {
    if (!_imgViewArray) {
        _imgViewArray = [NSMutableArray array];
    }
    return _imgViewArray;
}

- (NSInteger)numberInRow {
    if (_numberInRow > 0) {
        return _numberInRow;
    }
    
    if (_imgArray.count == 0) {
        return 0;
    }
    
    return _imgArray.count == 4 ? 2 : 3;
}

@end
