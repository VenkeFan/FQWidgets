//
//  WLLoginHintView.h
//  welike
//
//  Created by fan qi on 2018/7/25.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WLLoginHintViewStyle) {
    WLLoginHintViewStyle_Dark,
    WLLoginHintViewStyle_Light
};

@interface WLLoginHintView : UIView

+ (instancetype)instance;
- (void)display;

@property (nonatomic, assign) WLLoginHintViewStyle style;

@end
