//
//  FQDynamicLoadingView.h
//  FQWidgets
//
//  Created by fan qi on 2018/7/7.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FQDynamicLoadingView : UIView

@property (nonatomic, assign, readonly) BOOL isAnimating;

- (void)startAnimating;
- (void)stopAnimating;

@end
