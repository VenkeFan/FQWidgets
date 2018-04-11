//
//  FQImageButton.h
//  WeLike
//
//  Created by fan qi on 2018/4/5.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Button中图片相对文本的位置
 */
typedef NS_ENUM(NSInteger, FQImageButtonOrientation) {
    FQImageButtonOrientation_Left,
    FQImageButtonOrientation_Right,
    FQImageButtonOrientation_Top,
    FQImageButtonOrientation_Bottom,
    FQImageButtonOrientation_Center
};

@interface FQImageButton : UIButton

@property (nonatomic, assign) FQImageButtonOrientation imageOrientation;

@end
