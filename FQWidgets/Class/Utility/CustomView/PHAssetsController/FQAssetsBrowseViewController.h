//
//  FQAssetsBrowseViewController.h
//  WeLike
//
//  Created by fan qi on 2018/4/8.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FQAssetModel.h"

#define BottomViewHeight            kSizeScale(62)
#define MaxCheckedNumberLimit       9
#define ConfirmBtnTitle(count)      [NSString stringWithFormat:@"CONFIRM (%zd/%zd)", count, MaxCheckedNumberLimit]

@class FQAssetsBrowseViewController;

@protocol FQAssetsBrowseViewControllerDelegate <NSObject>

- (void)assetsBrowseViewCtr:(FQAssetsBrowseViewController *)ctr didClickedWithCurrentIndex:(NSInteger)currentIndex;

@end

@interface FQAssetsBrowseViewController : UIViewController

- (instancetype)initWithItemArray:(NSArray<FQAssetModel *> *)itemArray checkedNumber:(NSInteger)checkedNumber;

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign, readonly) NSInteger checkedNumber;
@property (nonatomic, weak) id<FQAssetsBrowseViewControllerDelegate> delegate;

@end
