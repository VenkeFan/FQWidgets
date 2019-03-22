//
//  UIView+LuuBase.h
//  Luuphone
//
//  Created by liubin on 15/5/12.
//  Copyright (c) 2015年 luuphone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LuuBase)

@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize  size;
@property (nonatomic) CGFloat centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat centerY;     ///< Shortcut for center.y

- (UIViewController *)parentControlloer;
- (void)removeAllSubviews;

@end
