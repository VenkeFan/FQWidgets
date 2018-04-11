//
//  FQThumbnailView.m
//  WeLike
//
//  Created by fan qi on 2018/3/28.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQThumbnailView.h"
#import "FQImageBrowseView.h"

#define ThumbnailWidth              kSizeScale(98)
#define Spacing                     5

@interface FQThumbnailView () <UIScrollViewDelegate> {
    NSArray *_imgArray;
}

@property (nonatomic, strong) NSMutableArray *imgViewArray;
@property (nonatomic, assign) NSInteger numberInRow;

@end

@implementation FQThumbnailView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor redColor];
    }
    
    return self;
}

#pragma mark - Public

- (CGRect)frameWithImgArray:(NSArray *)imgArray {
    _imgArray = imgArray;
    
    [self.imgViewArray removeAllObjects];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (imgArray.count == 0) {
        return CGRectZero;
    }
    
    UIView *contentView = [[UIView alloc] init];
    [self addSubview:contentView];
    
    if (imgArray.count == 1) {
        UIImageView *imgView = [self p_imageViewWithImageName:imgArray[0]];
        [contentView addSubview:imgView];
        CGSize size = [self p_resizeImageView:imgView];
        imgView.frame = CGRectMake(0, 0, size.width, size.height);
        contentView.frame = imgView.frame;
        
        return contentView.frame;;
    }
    
    
    CGFloat width = ThumbnailWidth;
    CGRect frame = contentView.frame;
    frame.size.width = imgArray.count >= self.numberInRow
    ? self.numberInRow * (width + Spacing) - Spacing
    : imgArray.count * (width + Spacing) - Spacing;
    frame.size.height = ceilf((imgArray.count / (float)self.numberInRow)) * (width + Spacing) - Spacing;
    contentView.frame = frame;
    
    for (int i = 0; i < imgArray.count; i++) {
        UIImageView *imgView = [self p_imageViewWithImageName:imgArray[i]];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.frame = CGRectMake((i % self.numberInRow) * (width + Spacing), ( i /self.numberInRow) * (width + Spacing), width, width);
        [contentView addSubview:imgView];
    }
    
    return contentView.frame;
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
        FQImageBrowseItem *item = [[FQImageBrowseItem alloc] init];
        item.thumbView = self.imgViewArray[idx];
        item.imgURL = _imgArray[idx];
        
        [itemArray addObject:item];
    }];
    
    FQImageBrowseView *groupView = [[FQImageBrowseView alloc] initWithItemArray:itemArray];
    [groupView displayWithFromView:imgView toView:rootView];
}

#pragma mark - Private

- (CGSize)p_resizeImageView:(UIImageView *)imgView {
    CGSize imgSize = imgView.image.size;
    CGSize newSize = CGSizeZero;
    
    if (imgSize.width == imgSize.height) {
        // 方图
        CGFloat squareWidth = kScreenWidth * 2 / 3.0;
        newSize = CGSizeMake(squareWidth, squareWidth);
    } else if (imgSize.width > imgSize.height) {
        // 宽图
        CGFloat width = kScreenWidth * 2 / 3.0;
        CGFloat height = kScreenWidth * 0.5;
        CGFloat scaleWidth = imgSize.width / imgSize.height * height;
        imgView.layer.contentsRect = CGRectMake(0, 0, width / scaleWidth, 1.0);
        newSize = CGSizeMake(width, height);
    } else {
        // 长图
        CGFloat width = kScreenWidth * 0.5;
        CGFloat height = kScreenWidth * 2 / 3.0;
        CGFloat scaleHeight = imgSize.height / imgSize.width * width;
        imgView.layer.contentsRect = CGRectMake(0, 0, 1.0, height / scaleHeight);
        newSize = CGSizeMake(width, height);
    }
    
    return newSize;
}

- (UIImageView *)p_imageViewWithImageName:(NSString *)imageName {
    TODO("应该把下载的图片缩放到控件大小再显示");
    
    UIImage *img = nil;
    if ([imageName isKindOfClass:[NSString class]]) {
        img = [UIImage imageNamed:imageName];
    } else if ([imageName isKindOfClass:[UIImage class]]) {
        img = (UIImage *)imageName;
    }
    
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.backgroundColor = [UIColor lightGrayColor];
    imgView.image = img;
    imgView.clipsToBounds = YES;
    
    imgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgViewTap:)];
    [imgView addGestureRecognizer:tap];
    
    [self.imgViewArray addObject:imgView];
    
    return imgView;
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
