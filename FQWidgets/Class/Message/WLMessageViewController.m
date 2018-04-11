//
//  WLMessageViewController.m
//  WeLike
//
//  Created by fan qi on 2018/3/28.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLMessageViewController.h"
#import "FQAssetsViewController.h"

#import "FQThumbnailView.h"
#import "FQImageButton.h"

@interface WLMessageViewController () <FQAssetsViewControllerDelegate>

@property (nonatomic, weak) FQThumbnailView *thumbView;
@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation WLMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor cyanColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.borderWidth = 1.0;
    btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    btn.frame = CGRectMake(20, kNavBarHeight + 10, 120, 45);
    [btn setTitle:@"拍照摄像" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    [btn addBlockForControlEvents:UIControlEventTouchUpInside
                            block:^(id  _Nonnull sender) {
                                FQAssetsViewController *ctr = [FQAssetsViewController new];
                                ctr.delegate = self;
                                [self presentViewController:[[UINavigationController alloc] initWithRootViewController:ctr] animated:YES completion:nil];
                            }];
    [self.view addSubview:btn];
 
    {
        FQThumbnailView *thumView = [[FQThumbnailView alloc] init];
        thumView.frame = CGRectMake(20, kNavBarHeight + 65, 0, 0);
        [self.view addSubview:thumView];
        self.thumbView = thumView;
    }
    
    {
//        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, kNavBarHeight + 65, kScreenWidth - 40, kScreenHeight - (kNavBarHeight + 65 + kTabBarHeight + kNavBarHeight + 10))];
//        imgView.backgroundColor = [UIColor lightGrayColor];
//        imgView.contentMode = UIViewContentModeScaleAspectFit;
//        [self.view addSubview:imgView];
//        self.imageView = imgView;
    }
    
    
    {
//        FQImageButton *imgBtn = [FQImageButton buttonWithType:UIButtonTypeCustom];
//        imgBtn.backgroundColor = [UIColor magentaColor];
//        imgBtn.titleLabel.backgroundColor = [UIColor redColor];
//        imgBtn.imageView.backgroundColor = [UIColor greenColor];
//        
//        imgBtn.frame = CGRectMake(20, kNavBarHeight + 230, 150, 30);
//        imgBtn.imageOrientation = FQImageButtonOrientation_Right;
//        imgBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
//        [imgBtn setImage:[UIImage imageNamed:@"camera_photo_selected"] forState:UIControlStateSelected];
//        [imgBtn setImage:[UIImage imageNamed:@"camera_photo_unselected"] forState:UIControlStateNormal];
//        [imgBtn setTitleColor:kBodyFontColor forState:UIControlStateNormal];
//        imgBtn.titleLabel.font = [UIFont systemFontOfSize:kSizeScale(11)];
//        imgBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
//        [imgBtn setTitle:@"1" forState:UIControlStateNormal];
//        
//        [imgBtn sizeToFit];
//        CGRect frame = imgBtn.frame;
//        frame.size.width += 30;
//        imgBtn.frame = frame;
//        
//        [self.view addSubview:imgBtn];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FQAssetsViewControllerDelegate

- (void)assetsViewCtr:(FQAssetsViewController *)viewCtr didSelectedWithAssetArray:(NSArray *)assetArray {
    CGRect frame = [self.thumbView frameWithImgArray:assetArray];
    frame.origin.x = self.thumbView.frame.origin.x;
    frame.origin.y = self.thumbView.frame.origin.y;
    self.thumbView.frame = frame;
    
//    self.imageView.image = (UIImage *)assetArray.firstObject;
//    NSLog(@"%zd %f -- %f", self.imageView.image.imageOrientation, self.imageView.image.size.width, self.imageView.image.size.height);
}

@end
