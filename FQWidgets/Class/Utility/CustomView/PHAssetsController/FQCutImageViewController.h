//
//  FQCutImageViewController.h
//  FQWidgets
//
//  Created by fan qi on 2018/4/14.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class FQCutImageViewController;

@protocol FQCutImageViewControllerDelegate <NSObject>

- (void)cutImageController:(FQCutImageViewController *)ctr didConfirmWithCuttedImage:(UIImage *)cuttedImage;

@end

@interface FQCutImageViewController : UIViewController

- (instancetype)initWithOriginalImage:(UIImage *)originalImage;
- (instancetype)initWithPHAsset:(PHAsset *)phAsset;

@property (nonatomic, strong, readonly) PHAsset *phAsset;
@property (nonatomic, strong, readonly) UIImage *originalImage;

@property (nonatomic, weak) id<FQCutImageViewControllerDelegate> delegate;

@end
