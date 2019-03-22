//
//  WLImageCompress.m
//  welike
//
//  Created by gyb on 2018/5/8.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLImageHelper.h"

@implementation WLImageHelper


+(void)imageCompressAndLocalSave:(PHAsset *)asset withSavePath:(NSString *)pathStr result:(void (^)(BOOL,CGSize,CGFloat))callback
{
        if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"])
        {
            PHImageRequestOptions *option = [PHImageRequestOptions new];
            option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            option.synchronous = YES;
            option.networkAccessAllowed = NO;
            option.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                BOOL result = [imageData writeToFile:pathStr atomically:NO];
                UIImage *image = [UIImage imageWithData:imageData];
                
                if(callback)
                {
                    callback(result,image.size,imageData.length/1024.0);
                }
            }];
        }
        else
        {
            PHImageRequestOptions *option = [PHImageRequestOptions new];
            option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            option.synchronous = YES;
            option.networkAccessAllowed = NO;
            option.resizeMode = PHImageRequestOptionsResizeModeFast;

            CGFloat imageWightScale = (CGFloat)asset.pixelWidth / (CGFloat)asset.pixelHeight;
            CGFloat imageHeightScale = (CGFloat)asset.pixelHeight / (CGFloat)asset.pixelWidth;
            CGFloat screenScale = kScreenHeight/kScreenWidth;

            if ((CGFloat)asset.pixelWidth <= 1280 && (CGFloat)asset.pixelHeight <= 1280)
            {
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    
                    if (imageData.length / 1024.0 < 100)
                    {
                        BOOL compressResult = [imageData writeToFile:pathStr atomically:NO];
                         UIImage *image = [UIImage imageWithData:imageData];
                        if(callback)
                        {
                            callback(compressResult,image.size,imageData.length/1024.0);
                        }
                    }
                    else
                    {
                        NSData  *compressImageData = UIImageJPEGRepresentation([UIImage imageWithData:imageData], 0.5);
                        BOOL compressResult = [compressImageData writeToFile:pathStr atomically:NO];
                         UIImage *image = [UIImage imageWithData:compressImageData];
                        if(callback)
                        {
                           callback(compressResult,image.size,compressImageData.length/1024.0);
                        }
                    }
                }];
            }
            else
            if (imageWightScale > screenScale)
            {
                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(1280*imageWightScale, 1280) contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {

                    NSData  *compressImageData = UIImageJPEGRepresentation(result, 0.5);
                    BOOL compressResult = [compressImageData writeToFile:pathStr atomically:NO];
                     UIImage *image = [UIImage imageWithData:compressImageData];
                    if(callback)
                    {
                         callback(compressResult,image.size,compressImageData.length/1024.0);
                    }
                }];
            }
            else
                if (imageHeightScale > screenScale)
                {
                    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(1280, 1280*imageHeightScale) contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {

                        NSData  *compressImageData = UIImageJPEGRepresentation(result, 0.5);
                        BOOL compressResult = [compressImageData writeToFile:pathStr atomically:NO];
                        UIImage *image = [UIImage imageWithData:compressImageData];
                        if(callback)
                        {
                             callback(compressResult,image.size,compressImageData.length/1024.0);
                        }
                    }];
                }
                else
                {
                    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(1280, 1280.0*screenScale) contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                        BOOL compressResult = [result storeToJPEG:pathStr quality:0.5f];
                        UIImage *image = [UIImage imageWithContentsOfFile:pathStr];
                        if(callback)
                        {
                            callback(compressResult,image.size,UIImageJPEGRepresentation(image, 1).length/1024.0);
                        }

                    }];
                }
        }
}

+(void)imageFromAsset:(PHAsset *)asset size:(CGSize)thumbSize result:(void (^)(UIImage *))callback
{
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    option.synchronous = YES;
    option.networkAccessAllowed = NO;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(thumbSize.width, thumbSize.height) contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if(callback)
        {
            callback(result);
        }
        
    }];
}



@end
