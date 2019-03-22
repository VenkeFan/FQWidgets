//
//  WLHomeViewController.h
//  WeLike
//
//  Created by fan qi on 2018/3/27.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLHomeViewController;
@protocol FQTabBarControllerProtocol;

@protocol WLHomeViewControllerDelegate <NSObject>

- (void)homeViewControllerDidEmptyClicked:(WLHomeViewController *)ctr;

@end

@interface WLHomeViewController : RDBaseViewController <FQTabBarControllerProtocol>

@property (nonatomic, weak) id<WLHomeViewControllerDelegate> delegate;

@end
