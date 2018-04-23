//
//  FQThumbnailView.h
//  WeLike
//
//  Created by fan qi on 2018/3/28.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WLPicture;

@interface FQThumbnailView : UIView

- (CGRect)frameWithImgArray:(NSArray *)imgArray;
- (void)setImages:(NSArray<WLPicture *> *)images
         imgWidth:(CGFloat)imgWidth
        imgHeight:(CGFloat)imgHeight
          spacing:(CGFloat)spacing;

@end
