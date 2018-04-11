//
//  FQAssetsViewController.h
//  WeLike
//
//  Created by fan qi on 2018/4/3.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FQAssetsManager.h"

@class FQAssetsViewController;

@protocol FQAssetsViewControllerDelegate <NSObject>

- (void)assetsViewCtr:(FQAssetsViewController *)viewCtr didSelectedWithAssetArray:(NSArray *)assetArray;

@end

@interface FQAssetsViewController : UIViewController

@property (nonatomic, weak) id<FQAssetsViewControllerDelegate> delegate;

@end
