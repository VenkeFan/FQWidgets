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
        case FQImageButtonOrientation_Left: {
            frame = CGRectMake(0,
                               (contentRect.size.height - imgSize.height) * 0.5,
                               imgSize.width,
                               imgSize.height);
        }
            break;
        case FQImageButtonOrientation_Right: {
            frame = CGRectMake(contentRect.size.width - imgSize.width,
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
        case FQImageButtonOrientation_Bottom: {
            frame = CGRectMake((contentRect.size.width - imgSize.width) * 0.5,
                               contentRect.size.height - imgSize.height,
                               imgSize.width,
                               imgSize.height);
        }
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
    UIEdgeInsets imgEdge = self.imageEdgeInsets;
    
    switch (_imageOrientation) {
        case FQImageButtonOrientation_Left: {
            frame = CGRectMake(imgSize.width + imgEdge.right,
                               0,
                               contentRect.size.width - imgSize.width - imgEdge.right,
                               contentRect.size.height);
        }
            break;
        case FQImageButtonOrientation_Right: {
            frame = CGRectMake(0,
                               0,
                               contentRect.size.width - imgSize.width - imgEdge.left,
                               contentRect.size.height);
        }
            break;
        case FQImageButtonOrientation_Top: {
            frame = CGRectMake(0,
                               imgEdge.bottom + imgSize.height,
                               contentRect.size.width,
                               contentRect.size.height - imgEdge.bottom - imgSize.height);
        }
            break;
        case FQImageButtonOrientation_Bottom: {
            frame = CGRectMake(0,
                               0,
                               contentRect.size.width,
                               contentRect.size.height - imgEdge.top - imgSize.height);
        }
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

- (void)sizeToFit {
    [super sizeToFit];

    CGRect frame = self.frame;
    switch (_imageOrientation) {
        case FQImageButtonOrientation_Left:
            frame.size.width += self.imageEdgeInsets.right;
            break;
        case FQImageButtonOrientation_Right:
            frame.size.width += self.imageEdgeInsets.left;
            break;
        case FQImageButtonOrientation_Top:
            frame.size.height += (self.imageEdgeInsets.bottom + self.currentImage.size.height);
            break;
        case FQImageButtonOrientation_Bottom:
            frame.size.height += (self.imageEdgeInsets.top + self.currentImage.size.height);
            break;
        case FQImageButtonOrientation_Center:
            break;
    }

    self.frame = frame;
}

@end
