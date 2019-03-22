//
//  UIImage+LuuBase.h
//  Luuphone
//
//  Created by liubin on 15/5/12.
//  Copyright (c) 2015年 luuphone. All rights reserved.
//

#import <UIKit/UIKit.h>

static inline CGFloat WLDegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}

@interface UIImage (LuuBase)

- (UIImage *)middleStretchableImage;
- (UIImage *)resizeWithSize:(CGSize)size;
- (BOOL)storeToPNG:(NSString *)fileName;
- (BOOL)storeToJPEG:(NSString *)fileName quality:(CGFloat)quality;
+ (UIImage *)imageWithColor:(UIColor *)color;
- (UIImage *)fixOrientation;
- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius;
- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                          borderWidth:(CGFloat)borderWidth
                          borderColor:(UIColor *)borderColor;
- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                              corners:(UIRectCorner)corners
                          borderWidth:(CGFloat)borderWidth
                          borderColor:(UIColor *)borderColor
                       borderLineJoin:(CGLineJoin)borderLineJoin;
+ (UIImage *)placeholder:(UIImage *)icon backgroundColor:(UIColor *)backgroundColor size:(CGSize)size;

- (UIImage *)imageByRotate:(CGFloat)radians fitSize:(BOOL)fitSize;

- (UIImage *)imageByRotateRight90;

@property (nonatomic, assign) BOOL isPlaceholder;

@end
