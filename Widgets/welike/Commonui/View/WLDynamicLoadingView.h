//
//  WLDynamicLoadingView.h
//  welike
//
//  Created by fan qi on 2018/7/10.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLDynamicLoadingView : UIView

@property (nonatomic, assign, readonly) BOOL isAnimating;

@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic, assign) CGFloat strokeEnd;

- (void)startAnimating;
- (void)stopAnimating;

@end
