//
//  WLAssetsViewController.h
//  WeLike
//
//  Created by fan qi on 2018/4/3.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLAssetsManager.h"

typedef NS_ENUM(NSInteger, WLAssetsSelectionMode) {
    WLAssetsSelectionMode_Single,
    WLAssetsSelectionMode_Multiple,
    WLAssetsSelectionMode_Single_poll,
     WLAssetsSelectionMode_Single_status
};

@class WLAssetsViewController;

@protocol WLAssetsViewControllerDelegate <NSObject>

@optional
- (void)assetsViewCtr:(WLAssetsViewController *)viewCtr didSelectedWithAssetArray:(NSArray<WLAssetModel *> *)assetArray;
- (void)assetsViewCtr:(WLAssetsViewController *)viewCtr didCuttedImage:(UIImage *)image;

@end

@interface WLAssetsViewController : WLNavBarBaseViewController

- (instancetype)init __attribute__((unavailable("Use -initWithSelectionMode:instead")));
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil __attribute__((unavailable("Use -initWithSelectionMode:instead")));
+ (instancetype)new __attribute__((unavailable("Use -initWithSelectionMode:instead")));

- (instancetype)initWithSelectionMode:(WLAssetsSelectionMode)selectionMode;
- (instancetype)initWithCheckedArray:(NSArray<WLAssetModel *> *)checkedArray;

@property (nonatomic, assign, readonly) WLAssetsSelectionMode currentSelectionMode;
@property (nonatomic, weak) id<WLAssetsViewControllerDelegate> delegate;

@property (nonatomic, assign, getter=isEditable) BOOL editable;

@end
