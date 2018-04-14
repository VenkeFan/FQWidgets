//
//  FQZoomScaleView.m
//  WeLike
//
//  Created by fan qi on 2018/4/9.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQZoomScaleView.h"

@interface FQZoomScaleView () <UIScrollViewDelegate>

@end

@implementation FQZoomScaleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.contentOffset = CGPointZero;
        self.showsVerticalScrollIndicator = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.bounces = YES;
        self.alwaysBounceVertical = NO;
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = 3.0;
        self.zoomScale = 1.0;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnTap:)];
        [self addGestureRecognizer:tap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfOnDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [tap requireGestureRecognizerToFail:doubleTap];
        [self addGestureRecognizer:doubleTap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self                                                                                   action:@selector(selfOnLongPressed:)];
        [self addGestureRecognizer:longPress];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:imgView];
        _imageView = imgView;
    }
    return self;
}

#pragma mark - Public

- (void)setImage:(UIImage *)image {
    _image = image;
    
    [_imageView.layer removeAnimationForKey:@"ImageViewAnimationKey"];
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    transition.duration = 0.1;
    [_imageView.layer addAnimation:transition forKey:@"ImageViewAnimationKey"];
    _imageView.image = image;
    
    [self p_resizeImageView];
}

- (void)setImageWithUrlString:(NSString *)urlString {
    if ([urlString isKindOfClass:[UIImage class]]) {
        UIImage *img = (UIImage *)urlString;
        [self setImage:img];
        return;
    }
    
    NSURL *url = nil;
    if ([urlString isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:urlString];
    } else if ([urlString isKindOfClass:[NSURL class]]) {
        url = (NSURL *)urlString;
    }
    
    if (!url) {
        return;
    }
    
    [_imageView setImageWithURL:url
                        placeholder:nil
                            options:YYWebImageOptionAvoidSetImage
                         completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                             if (!image) {
                                 return;
                             }
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                [self setImage:image];
                             });
                         }];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                  scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - Event

- (void)selfOnTap:(UITapGestureRecognizer *)gesture {
    if ([self.zoomScaleDelegate respondsToSelector:@selector(zoomScaleViewDidTapped:)]) {
        [self.zoomScaleDelegate zoomScaleViewDidTapped:self];
    }
}

- (void)selfOnDoubleTap:(UITapGestureRecognizer *)gesture {
    if (self.zoomScale > self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        CGFloat maxZoomScale = self.maximumZoomScale;
        CGPoint point = [gesture locationInView:_imageView];
        
        CGFloat newWidth = self.frame.size.width / maxZoomScale;
        CGFloat newHeight = self.frame.size.height / maxZoomScale;
        
        CGFloat newX = point.x - newWidth / 2;
        CGFloat newY = point.y - newHeight / 2;
        
        [self zoomToRect:CGRectMake(newX, newY, newWidth, newHeight) animated:YES];
    }
}

- (void)selfOnLongPressed:(UILongPressGestureRecognizer *)gesture {
//    UIImageView *imgView = (UIImageView *)gesture.view;
//    UIImage *img = imgView.image;
//    if (img) {
//        UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//    }
}

// 保存完毕回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil ;
    
    if(error != NULL)
        msg = @"保存图片失败";
    else
        msg = @"保存图片成功";
    NSLog(@"%@", msg);
}

#pragma mark - Private

- (void)p_resizeImageView {
    /*
     单图：比例图宽=屏宽。
     图片实际宽度>=屏宽像素时，图宽缩放至=屏幕宽度。图高按比例缩放。
     缩放后图高>屏幕高度时，顶部对齐居上显示，可上下滑动。
     缩放后图高<=屏幕高度时，上下居中显示。
     图片实际宽度<屏宽像素时，放大至屏幕宽度。图高按比例缩放。
     缩放后图高>屏幕高度时，顶部对齐居上显示，可上下滑动。
     缩放后图高<=屏幕高度时，上下居中显示。
     */
    if (!_imageView.image) {
        return;
    }
    CGSize imgSize = _imageView.image.size;
    
    CGFloat newWidth = kScreenWidth;
    CGFloat newHeight = imgSize.height / imgSize.width * newWidth;
    
    _imageView.frame = CGRectMake(0, 0, newWidth, newHeight);
    if (newHeight > kScreenHeight) {
        self.contentSize = CGSizeMake(newWidth, newHeight);
        self.contentOffset = CGPointZero;
    } else {
        _imageView.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5, CGRectGetHeight(self.frame) * 0.5);
    }
}

@end
