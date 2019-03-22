//
//  WLCutImageViewController.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/14.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLCutImageViewController.h"
#import "WLZoomScaleView.h"

#define CutImageFrame   CGRectMake(0, (kScreenHeight - kNavBarHeight - kSafeAreaBottomY - kScreenWidth) * 0.5, kScreenWidth, kScreenWidth)

@interface WLCutImageViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scaleView;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, strong) CAShapeLayer *maskLayer;

@property (nonatomic, strong) UIView *operateView;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *confirmBtn;

@end

@implementation WLCutImageViewController

#pragma mark - LifeCycle

- (instancetype)initWithPHAsset:(PHAsset *)phAsset {
    if (self = [super init]) {
        _phAsset = phAsset;
    }
    return self;
}

- (instancetype)initWithOriginalImage:(UIImage *)originalImage {
    if (self = [super init]) {
        _originalImage = originalImage;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.scaleView];
    [self.view.layer addSublayer:self.maskLayer];
    [self.view addSubview:self.operateView];
    
    if (self.originalImage) {
        [self p_setImageViewWithImage:self.originalImage];
        
    } else if (self.phAsset) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.networkAccessAllowed = NO;
        options.synchronous = NO;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        
        CGFloat aspectRatio = self.phAsset.pixelWidth / (CGFloat)self.phAsset.pixelHeight;
        CGFloat pixelWidth = kScreenWidth * kScreenScale;
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);
        
        [[PHImageManager defaultManager] requestImageForAsset:self.phAsset
                                                   targetSize:imageSize
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:options
                                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                    self->_originalImage = result;
                                                    [self p_setImageViewWithImage:result];
                                                }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;

    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;

    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                    scrollView.contentSize.height * 0.5 + offsetY);
    
    if (self.imageView.frame.size.height <= CGRectGetHeight(scrollView.bounds)) {
        scrollView.contentSize = scrollView.bounds.size;
        scrollView.contentOffset = CGPointZero;
        self.imageView.center = CGPointMake(CGRectGetWidth(self.scaleView.frame) * 0.5,
                                        CGRectGetHeight(self.scaleView.frame) * 0.5);
    }

    [self p_setContentInsets];
    
//    NSLog(@"imageViewFrame: (%f, %f, %f, %f)", self.imageView.frame.origin.x, self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height);
//    NSLog(@"contentInset: (%f, %f, %f, %f)", scrollView.contentInset.top, scrollView.contentInset.left, scrollView.contentInset.bottom, scrollView.contentInset.right);
//    NSLog(@"contentSize: (%f, %f)", scrollView.contentSize.width, scrollView.contentSize.height);
//    NSLog(@"contentOffset: (%f, %f)", scrollView.contentOffset.x, scrollView.contentOffset.y);
//    NSLog(@"******************************************************************************************************");
}

#pragma mark - Private

- (void)p_setImageViewWithImage:(UIImage *)image {
    self.imageView.image = image;
    [self p_resizeImageView];
}

- (void)p_resizeImageView {
    if (!self.imageView.image) {
        self.scaleView.contentSize = self.scaleView.bounds.size;
        self.scaleView.contentOffset = CGPointZero;
        return;
    }
    CGSize imgSize = self.imageView.image.size;
    
    CGFloat newWidth = kScreenWidth;
    CGFloat newHeight = imgSize.height / imgSize.width * newWidth;
    
    self.imageView.frame = CGRectMake(0, 0, newWidth, newHeight);
    if (newHeight > CGRectGetHeight(self.scaleView.bounds)) {
        self.scaleView.contentSize = CGSizeMake(newWidth, newHeight);
        self.scaleView.contentOffset = CGPointZero;
    } else {
        self.scaleView.zoomScale = 1.0;
        self.scaleView.contentSize = self.scaleView.bounds.size;
        self.scaleView.contentOffset = CGPointZero;
        self.imageView.center = CGPointMake(CGRectGetWidth(self.scaleView.frame) * 0.5, CGRectGetHeight(self.scaleView.frame) * 0.5);
    }
    
    [self p_setContentInsets];
}

- (void)p_setContentInsets {
    CGFloat left = ABS(CutImageFrame.origin.x - self.imageView.frame.origin.x);
    CGFloat top = ABS(CutImageFrame.origin.y - self.imageView.frame.origin.y);
    
    self.scaleView.contentInset = UIEdgeInsetsMake(top, left, top, left);
}

#pragma mark - Event

- (void)confirmBtnClicked {
    CGRect frame = CutImageFrame;
    CGRect relativeImageViewCutFrame = [self.view convertRect:frame toView:self.imageView];
    
    CGFloat originalImageWidth = self.originalImage.size.width * self.originalImage.scale;
    CGFloat originalImageHeight = self.originalImage.size.height * self.originalImage.scale;
    
    CGFloat width = frame.size.width / self.view.bounds.size.width * originalImageWidth / self.scaleView.zoomScale;
    CGFloat height = frame.size.height / frame.size.width * width;
    CGFloat x = originalImageWidth / self.imageView.frame.size.width * relativeImageViewCutFrame.origin.x * self.scaleView.zoomScale;
    CGFloat y = originalImageHeight / self.imageView.frame.size.height * relativeImageViewCutFrame.origin.y * self.scaleView.zoomScale;
    CGRect cutArea = CGRectMake(x, y, width, height);
    
    CGImageRef sourceImageRef = self.originalImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(sourceImageRef, cutArea);
    UIImage *cuttedImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    
    if ([self.delegate respondsToSelector:@selector(cutImageController:didConfirmWithCuttedImage:)]) {
        [self.delegate cutImageController:self didConfirmWithCuttedImage:cuttedImage];
    }
}

- (void)cancelBtnClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Getter

- (UIScrollView *)scaleView {
    if (!_scaleView) {
        _scaleView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kNavBarHeight - kSafeAreaBottomY)];
        _scaleView.delegate = self;
        _scaleView.clipsToBounds = NO;
        _scaleView.backgroundColor = [UIColor blackColor];
        _scaleView.contentOffset = CGPointZero;
        _scaleView.showsVerticalScrollIndicator = YES;
        _scaleView.showsHorizontalScrollIndicator = NO;
        _scaleView.bounces = YES;
        _scaleView.alwaysBounceVertical = NO;
        _scaleView.minimumZoomScale = 1.0;
        _scaleView.maximumZoomScale = 3.0;
        
        if (@available(iOS 11.0, *)){
            _scaleView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:_scaleView.bounds];
        imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_scaleView addSubview:imgView];
        self.imageView = imgView;
    }
    return _scaleView;
}

- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(-10, -10, kScreenWidth + 20, kScreenHeight + 20)];
        [path appendPath:[UIBezierPath bezierPathWithRect:CutImageFrame]];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.fillRule = kCAFillRuleEvenOdd;
        shapeLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.6].CGColor;
        shapeLayer.lineWidth = 1;
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        
        shapeLayer.path = path.CGPath;
        
        self.view.layer.masksToBounds = YES;
        _maskLayer = shapeLayer;
    }
    return _maskLayer;
}

- (UIView *)operateView {
    if (!_operateView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - kNavBarHeight - (60) - kSafeAreaBottomY, kScreenWidth, (60))];
        _operateView = view;
        
        CGFloat paddingX = (15);
        
        _cancelBtn = [self buttonWithTitle:[AppContext getStringForKey:@"common_cancel" fileName:@"common"] action:@selector(cancelBtnClicked)];
        [view addSubview:_cancelBtn];
        [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(view).offset(paddingX);
            make.centerY.mas_equalTo(view);
            make.size.mas_equalTo(CGSizeMake((100), (30)));
        }];
        
        _confirmBtn = [self buttonWithTitle:[AppContext getStringForKey:@"regist_jion_weLike" fileName:@"register"] action:@selector(confirmBtnClicked)];
        [view addSubview:_confirmBtn];
        [_confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(view).offset(-paddingX);
            make.centerY.mas_equalTo(self->_cancelBtn);
            make.size.mas_equalTo(self->_cancelBtn);
        }];
    }
    return _operateView;
}

- (UIButton *)buttonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

@end
