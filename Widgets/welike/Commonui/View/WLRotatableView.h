//
//  WLRotatableView.h
//  welike
//
//  Created by fan qi on 2018/8/15.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLRotatableView : UIView

@property (nonatomic, assign, getter=isRotatable) BOOL rotatable;

@property (nonatomic, assign) UIDeviceOrientation orientation;
@property (nonatomic, assign, readonly) CGFloat viewWidth;
@property (nonatomic, assign, readonly) CGFloat viewHeight;

@property (nonatomic, strong, readonly) UIView *contentView;

@end
