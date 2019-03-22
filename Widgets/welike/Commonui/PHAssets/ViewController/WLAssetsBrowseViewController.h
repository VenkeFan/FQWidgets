//
//  WLAssetsBrowseViewController.h
//  WeLike
//
//  Created by fan qi on 2018/4/8.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLAssetModel.h"

#define kAssetCheckBtnFontSize          13.0

@class WLAssetsBrowseViewController;

@protocol WLAssetsBrowseViewControllerDelegate <NSObject>

- (BOOL)assetsBrowseViewCtr:(WLAssetsBrowseViewController *)ctr didClickedWithCurrentIndex:(NSInteger)currentIndex;
- (void)assetsBrowseViewCtrDidConfirmed:(WLAssetsBrowseViewController *)ctr;

@end

@interface WLAssetsBrowseViewController : WLNavBarBaseViewController

- (instancetype)initWithItemArray:(NSArray<WLAssetModel *> *)itemArray checkedNumber:(NSInteger)checkedNumber;

- (instancetype)initWithItemArray:(NSArray<WLAssetModel *> *)itemArray currentIndex:(NSInteger)currentIndex;


@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) BOOL isPhotoAlbum;
@property (nonatomic, assign, readonly) NSInteger checkedNumber;
@property (nonatomic, weak) id<WLAssetsBrowseViewControllerDelegate> delegate;

@end
