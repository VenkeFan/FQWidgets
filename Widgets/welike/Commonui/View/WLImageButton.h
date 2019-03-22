//
//  WLImageButton.h
//  WeLike
//
//  Created by fan qi on 2018/4/5.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Button中图片相对文本的位置
 */
typedef NS_ENUM(NSInteger, WLImageButtonOrientation) {
    WLImageButtonOrientation_Left,
    WLImageButtonOrientation_Right,
    WLImageButtonOrientation_Top,
    WLImageButtonOrientation_Bottom,
    WLImageButtonOrientation_Center
};

@interface WLImageButton : UIButton

@property (nonatomic, assign) WLImageButtonOrientation imageOrientation;

@end
