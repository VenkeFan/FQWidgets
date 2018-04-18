//
//  UIImage+FQExtension.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/17.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "UIImage+FQExtension.h"

@implementation UIImage (FQExtension)

- (UIImage *)fixOrientation {
    if (self.imageOrientation == UIImageOrientationUp) {
        return self;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             self.size.width,
                                             self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage),
                                             0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.height, self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage *)compress {
    NSData *imgData = [self compressQuality];
    UIImage *compressImage = [UIImage imageWithData:imgData];
    
    UIImage *image = [compressImage compressSize];
    
    return image;
}

- (NSData *)compressQuality {
    CGFloat maxLength = kMaxVideoUploadQuality * 1024 * 1024;
    CGFloat compression = 1.0;
    
    NSData *imgData = UIImageJPEGRepresentation(self, compression);
    NSLog(@"图片压缩前质量: %f M", imgData.length / (1024 * 1024.0));
    
    if (imgData.length < maxLength) {
        return imgData;
    }
    
    CGFloat min = 0.0, max = 1.0;
    while (min < max) {
        compression = (min + max) / 2.0;
        NSData *tmpData = UIImageJPEGRepresentation(self, compression);
        if (tmpData.length > maxLength) {
            max = compression;
        } else {
            imgData = tmpData;
            break;
        }
    }
    
    NSLog(@"图片压缩后质量: %f M", imgData.length / (1024 * 1024.0));
    return imgData;
}

- (UIImage *)compressSize {
    /*
     静态图（jpg、png、gif、webp）
     压缩策略：本地尺寸和质量压缩；保证长图的体验；大图进行更多的压缩；输出格式为jpg；
     普通尺寸图如：宽和高小于等于1280则：尺寸不变，像素压缩到70%；
     普通尺寸长图和宽图如：宽或高大于1280，且0.5<=宽高比<=2 则： 长边压缩到1280，短边按比例缩放，像素压缩到70%；
     大尺寸长图和宽图如：宽或高大于1280，且宽高比>2或<0.5，且短边小于等于1280则：尺寸不变，像素压缩到50%（大图压缩）
     大尺寸图如：宽或高大于1280，且宽高比>2或<0.5，且短边大于1280则：短边压缩到1280，长边按比例缩放，像素压缩到50%；（保证图片比例同时压缩大图）
     
     动态图（gif）
     长边<=500像素，如超过5M，压缩到5M
     长边>500 压缩到500像素，如超过5M，压缩到5M
     */
    
    UIImage *image = self;
    CGFloat originalWidth = image.size.width;
    CGFloat originalHeight = image.size.height;
    
    if (originalWidth <= 1280 && originalHeight <= 1280) {
        return image;
    }
    
    
    return image;
}

- (UIImage *)resizeToSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
