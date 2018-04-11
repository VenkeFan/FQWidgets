//
//  FQImageButton.m
//  WeLike
//
//  Created by fan qi on 2018/4/5.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQImageButton.h"

@implementation FQImageButton

- (instancetype)init {
    if (self = [super init]) {
        _imageOrientation = FQImageButtonOrientation_Left;
    }
    return self;
}

#pragma mark - Override

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGRect frame = contentRect;
    CGSize imgSize = self.currentImage.size;
    UIEdgeInsets imgEdge = self.imageEdgeInsets;
    
    switch (_imageOrientation) {
        case FQImageButtonOrientation_Left:
            
            break;
        case FQImageButtonOrientation_Right: {
            frame = CGRectMake(contentRect.size.width - imgSize.width - imgEdge.right,
                               (contentRect.size.height - imgSize.height) * 0.5,
                               imgSize.width,
                               imgSize.height);
        }
            break;
        case FQImageButtonOrientation_Top: {
            frame = CGRectMake((contentRect.size.width - imgSize.width) * 0.5,
                               imgEdge.top,
                               imgSize.width,
                               imgSize.height);
        }
            break;
        case FQImageButtonOrientation_Bottom:
            break;
        case FQImageButtonOrientation_Center: {
            frame = CGRectMake((contentRect.size.width - imgSize.width) * 0.5,
                               (contentRect.size.height - imgSize.height) * 0.5,
                               imgSize.width,
                               imgSize.height);
        }
            break;
    }
    
    return frame;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect frame = contentRect;
    CGSize imgSize = self.currentImage.size;
    UIEdgeInsets titleEdge = self.titleEdgeInsets;
    
    switch (_imageOrientation) {
        case FQImageButtonOrientation_Left:
            
            break;
        case FQImageButtonOrientation_Right: {
            frame = CGRectMake(titleEdge.left,
                               titleEdge.top,
                               contentRect.size.width - imgSize.width - titleEdge.right,
                               contentRect.size.height);
        }
            break;
        case FQImageButtonOrientation_Top: {
            frame = CGRectMake(titleEdge.left,
                               titleEdge.top + imgSize.height,
                               contentRect.size.width - titleEdge.left,
                               contentRect.size.height - (titleEdge.top + imgSize.height));
        }
            break;
        case FQImageButtonOrientation_Bottom:
            break;
        case FQImageButtonOrientation_Center: {
            frame = CGRectMake((contentRect.size.width - imgSize.width) * 0.5,
                               (contentRect.size.height - imgSize.height) * 0.5,
                               imgSize.width,
                               imgSize.height);;
        }
            break;
    }
    return frame;
}
@end
