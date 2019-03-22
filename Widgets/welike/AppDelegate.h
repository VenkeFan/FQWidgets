//
//  AppDelegate.h
//  welike
//
//  Created by 刘斌 on 2018/4/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RDRootViewController;
@class WLMainViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) WLMainViewController *mainVC;
@property (nonatomic, strong) RDRootViewController *rootNavVC;

- (void)logout;
- (void)remain;

@end

