//
//  WLZoomScaleView.m
//  WeLike
//
//  Created by fan qi on 2018/4/9.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLZoomScaleView.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView+WLExtension.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreText/CoreText.h>
#import "WLAuthorizationHelper.h"

#import "SDWebImageGIFCoder.h"
#import "UIImage+MultiFormat.h"
#import "SDWebImageCoderHelper.h"

@interface WLZoomScaleView () <UIScrollViewDelegate>

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation WLZoomScaleView {
    BOOL _isMemoryWarning;
}

#pragma mark - LifeCycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _useCache = YES;
        _isMemoryWarning = NO;
        
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
        
        FLAnimatedImageView *imgView = [[FLAnimatedImageView alloc] initWithFrame:self.bounds];
        imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:imgView];
        _imageView = imgView;
        
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = CGRectMake(0, 0, 50, 50);
        _progressLayer.cornerRadius = 5.0;
        _progressLayer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4].CGColor;
        
        CGFloat padding = 13.0;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(_progressLayer.bounds, padding, padding)
                                                        cornerRadius:(CGRectGetHeight(_progressLayer.frame) * 0.5 - padding)];
        
        _progressLayer.path = path.CGPath;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.strokeColor = kMainColor.CGColor;
        _progressLayer.lineWidth = 3;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.strokeStart = 0;
        _progressLayer.strokeEnd = 1.0;
        _progressLayer.hidden = YES;
        [self.layer addSublayer:_progressLayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarningNoti:)
                                                     name:kWLMemoryWarningNotificationName
                                                   object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.progressLayer.position = CGPointMake(CGRectGetWidth(self.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification

- (void)didReceiveMemoryWarningNoti:(NSNotification *)notification {
    _isMemoryWarning = YES;
}

#pragma mark - Public

- (void)setImageWithUrlString:(NSString *)urlString placeholder:(UIImage *)placeholder imageSize:(CGSize)imageSize {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.progressLayer.strokeEnd = 0;
    self.progressLayer.hidden = YES;
    [CATransaction commit];
    
    [_imageView wl_setImageWithURL:urlString
                  placeholderImage:placeholder
                           options:self.useCache ? kNilOptions : SDWebImageRefreshCached
                          progress:^(CGFloat progress, NSURL *targetURL) {
                              if (!self.useCache) {
                                  if (progress > 0.0) {
                                      self.progressLayer.hidden = NO;
                                  }
                              } else {
                                  self.progressLayer.hidden = NO;
                              }
                              
                              self.progressLayer.strokeEnd = progress;
                              
                              if (progress >= 1.0) {
                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                      self.progressLayer.hidden = YES;
                                  });
                              }
                          }
                         completed:^(UIImage *image, FLAnimatedImage *animatedImage, NSError *error, NSURL *targetURL) { 
                             self.progressLayer.hidden = YES;
                             
                             self->_image = image;
                             self->_animatedImage = animatedImage;
                             
                             if (!CGSizeEqualToSize(image.size, imageSize) || placeholder.isPlaceholder) {
                                 [self p_resizeImageView:self->_imageView imageSize:image.size];
                             }
                         }];
    [self p_resizeImageView:_imageView imageSize:imageSize];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    
    if (!image) {
        return;
    }
    
    [_imageView.layer removeAnimationForKey:@"ImageViewAnimationKey"];
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    transition.duration = 0.1;
    [_imageView.layer addAnimation:transition forKey:@"ImageViewAnimationKey"];
    _imageView.image = image;
    
    [self p_resizeImageView:_imageView imageSize:image.size];
}

- (void)setAnimatedImage:(FLAnimatedImage *)animatedImage {
    _animatedImage = animatedImage;
    
    if (!animatedImage) {
        return;
    }
    
    _imageView.animatedImage = animatedImage;
    [self p_resizeImageView:_imageView imageSize:animatedImage.size];
}

- (void)save {
    [WLAuthorizationHelper requestPhotoAuthorizationWithFinished:^(BOOL granted) {
        if (granted) {
            [self p_encodedDataWithAnimatedImage:self.animatedImage
                                           image:self.image
                                        finished:^(NSData *data) {
                                            [self p_saveImageData:data];
                                        }];
        }
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

#pragma mark - Private

- (void)p_resizeImageView:(UIImageView *)imageView imageSize:(CGSize)imageSize {
    /*
     单图：比例图宽=屏宽。
     图片实际宽度>=屏宽像素时，图宽缩放至=屏幕宽度。图高按比例缩放。
     缩放后图高>屏幕高度时，顶部对齐居上显示，可上下滑动。
     缩放后图高<=屏幕高度时，上下居中显示。
     图片实际宽度<屏宽像素时，放大至屏幕宽度。图高按比例缩放。
     缩放后图高>屏幕高度时，顶部对齐居上显示，可上下滑动。
     缩放后图高<=屏幕高度时，上下居中显示。
     */
    
    if (imageView.image.isPlaceholder) {
        imageView.contentMode = UIViewContentModeCenter;
        return;
    }
    
    if (imageSize.width == 0 || imageSize.height == 0) {
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        return;
    }
    
    imageView.contentMode = UIViewContentModeScaleToFill;
    
    CGFloat newWidth = kScreenWidth;
    CGFloat newHeight = imageSize.height / imageSize.width * newWidth;
    
    imageView.frame = CGRectMake(0, 0, newWidth, newHeight);
    if (newHeight > CGRectGetHeight(self.bounds)) {
        self.contentSize = CGSizeMake(newWidth, newHeight);
        self.contentOffset = CGPointZero;
    } else {
        self.zoomScale = 1.0;
        self.contentSize = CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        self.contentOffset = CGPointZero;
        imageView.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5, CGRectGetHeight(self.frame) * 0.5);
    }
}

- (void)p_encodedDataWithAnimatedImage:(FLAnimatedImage *)animatedImage image:(UIImage *)image finished:(void(^)(NSData *data))finished {
    CGSize viewSize = self.imageView.frame.size;
    NSString *text = [NSString stringWithFormat:@"@%@", self.userName];
    
    if (animatedImage) {
        if (finished) {
            finished(animatedImage.data);
        }
        
//        [[AppContext currentViewController] showLoading];
//
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            UIImage *image = [[SDWebImageGIFCoder sharedCoder] decodedImageWithData:animatedImage.data];
//            NSMutableArray *newImages = [NSMutableArray arrayWithCapacity:image.images.count];
//
//            for (int i = 0; i < image.images.count; i++) {
//                if (image.images.count >= 500 && i % 12 != 0) {
//                    continue;
//                }
//
//                UIImage *newFrameImg = [self p_drawWatermarkInAnimatedImage:image.images[i] text:text viewSize:viewSize];
//                if (newFrameImg) {
//                    [newImages addObject:newFrameImg];
//                }
//
//                if (self->_isMemoryWarning) {
//                    //NSLog(@"!!!!!!!!!!!!!! p_drawWatermarkInAnimatedImage MemoryWarning !!!!!!!!!!!!!!");
//                    newImages = nil;
//
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [[AppContext currentViewController] hideLoading];
//
//                        if (finished) {
//                            finished(nil);
//                        }
//                    });
//
//                    return;
//                }
//            }
//
//            UIImage *newAnimatedImage = [UIImage animatedImageWithImages:newImages duration:image.duration];
//            NSData *imgData = [self p_encodedDataWithAnimatedImage:newAnimatedImage];
//
//            if (self->_isMemoryWarning) {
//                imgData = nil;
//
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [[AppContext currentViewController] hideLoading];
//
//                    if (finished) {
//                        finished(nil);
//                    }
//                });
//
//                return;
//            }
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[AppContext currentViewController] hideLoading];
//
//                if (finished) {
//                    finished(imgData);
//                }
//            });
//        });
    } else if (image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *newImg = [self p_drawWatermarkInAnimatedImage:image text:text viewSize:viewSize];
            NSData *imgData = UIImageJPEGRepresentation(newImg, 0.5);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (finished) {
                    finished(imgData);
                }
            });
        });
    }
}

- (NSData *)p_encodedDataWithAnimatedImage:(UIImage *)image {
    if (!image) {
        return nil;
    }
    
    NSMutableData *imageData = [NSMutableData data];
    CFStringRef imageUTType = kUTTypeGIF;
    NSArray<SDWebImageFrame *> *frames = [SDWebImageCoderHelper framesFromAnimatedImage:image];
    
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, imageUTType, frames.count, NULL);
    if (!imageDestination) {
        return nil;
    }
    if (frames.count == 0) {
        CGImageDestinationAddImage(imageDestination, image.CGImage, nil);
    } else {
        NSUInteger loopCount = image.sd_imageLoopCount;
        NSDictionary *gifProperties = @{(__bridge_transfer NSString *)kCGImagePropertyGIFDictionary: @{(__bridge_transfer NSString *)kCGImagePropertyGIFLoopCount : @(loopCount)}};
        CGImageDestinationSetProperties(imageDestination, (__bridge CFDictionaryRef)gifProperties);
        
        for (size_t i = 0; i < frames.count; i++) {
            if (_isMemoryWarning) {
//                NSLog(@"!!!!!!!!!!!!!! p_encodedDataWithAnimatedImage MemoryWarning !!!!!!!!!!!!!!");
                imageData = nil;
                CFRelease(imageDestination);
                return nil;
            }
            SDWebImageFrame *frame = frames[i];
            float frameDuration = frame.duration;
            CGImageRef frameImageRef = frame.image.CGImage;
            NSDictionary *frameProperties = @{(__bridge_transfer NSString *)kCGImagePropertyGIFDictionary : @{(__bridge_transfer NSString *)kCGImagePropertyGIFDelayTime : @(frameDuration)}};
            CGImageDestinationAddImage(imageDestination, frameImageRef, (__bridge CFDictionaryRef)frameProperties);
        }
    }
    if (CGImageDestinationFinalize(imageDestination) == NO) {
        imageData = nil;
    }
    
    CFRelease(imageDestination);
    
    return [imageData copy];
}

- (UIImage *)p_drawWatermarkInAnimatedImage:(UIImage *)image text:(NSString *)text viewSize:(CGSize)viewSize {
    if (_isMemoryWarning) {
        return nil;
    }
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                             image.size.width,
                                             image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage),
                                             0,
                                             CGImageGetColorSpace(image.CGImage),
                                             kCGImageAlphaPremultipliedFirst);
    
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
    
    if (viewSize.width == 0 || viewSize.height == 0) {
        viewSize = [UIScreen mainScreen].bounds.size;
    }
    
    CGFloat scale = MIN(image.size.height / viewSize.height, image.size.width / viewSize.width);
    CGContextConcatCTM(context, CGAffineTransformScale(CGAffineTransformIdentity, scale, scale));
    
    CGFloat left = 12, bottom = 12;
    
    {
        CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 0.0, [UIColor colorWithWhite:0 alpha:0.3].CGColor);
        
        CGFloat fontSize = 12;

        NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                     NSFontAttributeName: kRegularFont(fontSize)};

        CGSize size = [text boundingRectWithSize:viewSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil].size;
        CGFloat width = size.width, height = size.height;

        CFStringRef textString = (__bridge CFStringRef)text;
        CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
        CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), textString);

        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat components[] = {1.0, 1.0, 1.0, 1.0};
        CGColorRef color = CGColorCreate(rgbColorSpace, components);
        CGColorSpaceRelease(rgbColorSpace);

        CFStringRef fontName = (__bridge CFStringRef)kRegularFont(fontSize).fontName;
        CTFontRef font = CTFontCreateWithName(fontName, fontSize, NULL);

        CFAttributedStringSetAttributes(attrString,
                                        CFRangeMake(0, CFAttributedStringGetLength(attrString)),
                                        (__bridge CFDictionaryRef)@{(__bridge NSString *)kCTForegroundColorAttributeName: (__bridge id)color,
                                                                    (__bridge NSString *)kCTFontAttributeName: (__bridge id)font},
                                        YES);

        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);

        CGPathRef path = CGPathCreateWithRect(CGRectMake(left, 12, width, height), NULL);

        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CTFrameDraw(frame, context);

        CFRelease(frame);
        CFRelease(framesetter);
        CFRelease(font);
        CGColorRelease(color);
        CFRelease(attrString);
        CGPathRelease(path);

        bottom += height;
    }
    
    {
        UIImage *watermark = [AppContext getImageForKey:@"common_watermark"];
        CGFloat width = watermark.size.width, height = watermark.size.height;

        CGContextSetBlendMode(context, kCGBlendModeNormal);
        CGContextSetAlpha(context, 1.0);
        CGContextDrawImage(context, CGRectMake(left, bottom, width, height), watermark.CGImage);
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(context);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(context);
    CGImageRelease(cgimg);
    
    return img;
}

- (UIImage *)p_drawWatermarkInImage:(UIImage *)image text:(NSString *)text viewSize:(CGSize)viewSize {
    UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    if (viewSize.width == 0 || viewSize.height == 0) {
        viewSize = [UIScreen mainScreen].bounds.size;
    }
    
    CGFloat scale = MIN(image.size.height / viewSize.height, image.size.width / viewSize.width);
    CGFloat left = 12 * scale, bottom = 12 * scale;
    CGFloat y = image.size.height - bottom;
    
    {
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        shadow.shadowOffset = CGSizeMake(0, -1);
        shadow.shadowBlurRadius = 1.0;
        
        NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                     NSFontAttributeName: kRegularFont(12 * scale),
                                     NSShadowAttributeName: shadow};
        
        CGSize size = [text boundingRectWithSize:viewSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil].size;
        CGFloat width = size.width, height = size.height;
        y -= height;
        
        [text drawInRect:CGRectMake(left, y, width, height) withAttributes:attributes];
    }
    
    {
        UIImage *watermark = [AppContext getImageForKey:@"common_watermark"];
        
        CGFloat width = watermark.size.width * scale, height = watermark.size.height * scale;
        y -= height;
        
        [watermark drawInRect:CGRectMake(left, y, width, height) blendMode:kCGBlendModeNormal alpha:1.0];
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)p_saveImageData:(NSData *)imageData {
    if (!imageData) {
        [self image:nil didFinishSavingWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:nil] contextInfo:nil];
        return;
    }
    
    if (@available(iOS 9.0, *)) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status ) {
            if (status != PHAuthorizationStatusAuthorized) {
                return;
            }
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                [request addResourceWithType:PHAssetResourceTypePhoto
                                        data:imageData
                                     options:nil];
                
            } completionHandler:^(BOOL success, NSError * _Nullable error ) {
                [self image:nil didFinishSavingWithError:error contextInfo:nil];
            }];
        }];
    } else {
        ALAssetsLibrary *lab = [[ALAssetsLibrary alloc] init];
        [lab writeImageDataToSavedPhotosAlbum:imageData
                                     metadata:nil
                              completionBlock:^(NSURL *assetURL, NSError *error) {
                                  [self image:nil didFinishSavingWithError:error contextInfo:nil];
                              }];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(error) {
            [[AppContext currentViewController] showToast:[AppContext getStringForKey:@"picture_save_error"
                                                                             fileName:@"pic_sel"]];
        } else {
            [[AppContext currentViewController] showToast:[AppContext getStringForKey:@"picture_save_success"
                                                                             fileName:@"pic_sel"]];
        }
    });
}

@end
