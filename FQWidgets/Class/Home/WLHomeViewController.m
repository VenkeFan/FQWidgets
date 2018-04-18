//
//  WLHomeViewController.m
//  WeLike
//
//  Created by fan qi on 2018/3/27.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLHomeViewController.h"

#import "FQThumbnailView.h"
#import "FQImageButton.h"

@interface WLHomeViewController ()

@property (nonatomic, copy) NSArray *imgArray;

@end

@implementation WLHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor purpleColor];

    [self layoutUI];
}

- (void)layoutUI {
    {
        FQImageButton *imgBtn = [FQImageButton buttonWithType:UIButtonTypeCustom];
        imgBtn.layer.borderWidth = 1;
        imgBtn.layer.borderColor = [UIColor blackColor].CGColor;
        imgBtn.titleLabel.backgroundColor = [UIColor redColor];
        imgBtn.imageView.backgroundColor = [UIColor greenColor];
        
        imgBtn.frame = CGRectMake(20, kNavBarHeight * 0.5, 0, 0);
        imgBtn.imageOrientation = FQImageButtonOrientation_Right;
        imgBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [imgBtn setImage:[UIImage imageNamed:@"camera_photo_selected"] forState:UIControlStateSelected];
        [imgBtn setImage:[UIImage imageNamed:@"camera_photo_unselected"] forState:UIControlStateNormal];
        [imgBtn setTitleColor:kBodyFontColor forState:UIControlStateNormal];
        imgBtn.titleLabel.font = [UIFont systemFontOfSize:kSizeScale(11)];
        imgBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [imgBtn setTitle:@"9" forState:UIControlStateNormal];
        [imgBtn sizeToFit];
        
        [self.view addSubview:imgBtn];
    }
    
    {
        FQThumbnailView *thumView = [[FQThumbnailView alloc] init];
        CGRect frame = [thumView frameWithImgArray:self.imgArray];
        thumView.frame = CGRectMake(20, kNavBarHeight + 30, frame.size.width, frame.size.height);
        [self.view addSubview:thumView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter

- (NSArray *)imgArray {
    if (!_imgArray) {
        NSMutableArray *mutArray = [NSMutableArray array];
        for (int i = 0; i < 9; i++) {
            [mutArray addObject:[NSString stringWithFormat:@"WL_%zd.jpg", i]];
        }
        
        _imgArray = mutArray;
    }
    return _imgArray;
}

@end
