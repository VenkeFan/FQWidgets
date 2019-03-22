//
//  EditPhotoViewController.h
//  CuctvWeibo
//
//  Created by cuctv-gyb on 17/2/22.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, Edit_photo_type)
{
    Edit_photo_type_poll = 0,
    Edit_photo_type_status = 1,
};


@protocol WLEditPhotoViewControllerDelegate <NSObject>

-(void)locationBtnPressed;

@end


@interface WLEditPhotoViewController : WLNavBarBaseViewController
{
    UIView *bottomToolBar;
    
    
    UIButton *cutPhotoBtn;
    
    UIButton *rotatePhotoBtn;
    
    UIView *cutToolBar;
    
//    UIView *cutPhotoControlView;
}

@property (nonatomic, assign) NSInteger clickIndex;
@property (strong, nonatomic) NSMutableArray *photoArray;
@property (strong, nonatomic) UIImage *signalImage;

@property (nonatomic, assign) Edit_photo_type edit_photo_type;


@property (copy, nonatomic) void(^photoArrayBlock)(NSMutableArray *photoArray);

@end
