//
//  WLTabBar.h
//  welike
//
//  Created by fan qi on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLTabBar;

@protocol WLTabBarDelegate <NSObject>

- (void)tabBarDidTappedCustomView:(WLTabBar *)tabBar;

@end

@interface WLTabBar : UITabBar

@property (nonatomic, weak) id<WLTabBarDelegate> myDelegate;

@end
