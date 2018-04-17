//
//  FQImagePickerController.h
//  FQWidgets
//
//  Created by fan qi on 2018/4/16.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FQImagePickerController;

@protocol FQImagePickerControllerDelegate <NSObject>

- (void)imagePickerController:(FQImagePickerController *)ctr didPickedImage:(UIImage *)image;

@end

@interface FQImagePickerController : UIViewController

@property (nonatomic, weak) id<FQImagePickerControllerDelegate> delegate;

@end
