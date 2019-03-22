//
//  WLImageCompress.h
//  welike
//
//  Created by gyb on 2018/5/8.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>


@interface WLImageHelper : NSObject

//png, jpg, gif compress
+(void)imageCompressAndLocalSave:(PHAsset *)asset withSavePath:(NSString *)pathStr result:(void (^)(BOOL,CGSize,CGFloat))callback;
+(void)imageFromAsset:(PHAsset *)asset size:(CGSize)thumbSize result:(void (^)(UIImage *))callback;
//截屏



@end
