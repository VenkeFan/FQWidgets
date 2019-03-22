//
//  RDRootViewController.h
//  welike
//
//  Created by 刘斌 on 2018/4/13.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RDRootViewController : UINavigationController

- (void)pushViewControllerAfterClearAll:(UIViewController *)viewController animated:(BOOL)animated;
- (void)popToViewControllerByClass:(Class)vcClass animated:(BOOL)animated;

@property (nonatomic, assign) BOOL disableInteractivePopGestureRecognizer;

@end
