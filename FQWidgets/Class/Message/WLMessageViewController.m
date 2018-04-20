//
//  WLMessageViewController.m
//  WeLike
//
//  Created by fan qi on 2018/3/28.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLMessageViewController.h"
#import "FQAssetsViewController.h"
#import "FQImagePickerController.h"

#import "FQThumbnailView.h"
#import "FQReaderPlayerView.h"

@interface WLMessageViewController () <FQAssetsViewControllerDelegate, FQImagePickerControllerDelegate>

@property (nonatomic, weak) FQThumbnailView *thumbView;
@property (nonatomic, weak) FQReaderPlayerView *playerView;

@end

@implementation WLMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor cyanColor];
    
    __weak typeof(self) weakSelf = self;
    UIButton *btn = [self buttonWithTitle:@"拍照摄像" block:^(id sender) {
        FQAssetsViewController *ctr = [FQAssetsViewController new];
        ctr.delegate = weakSelf;
        [weakSelf.navigationController pushViewController:ctr animated:YES];
    }];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(20);
        make.top.mas_equalTo(self.view).offset(20);
        make.size.mas_equalTo(CGSizeMake(120, 45));
    }];
    
    
    UIButton *cutBtn = [self buttonWithTitle:@"头像裁剪" block:^(id sender) {
        FQImagePickerController *ctr = [FQImagePickerController new];
        ctr.delegate = weakSelf;
        [weakSelf.navigationController pushViewController:ctr animated:YES];
    }];
    [self.view addSubview:cutBtn];
    [cutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(btn.mas_bottom).offset(20);
        make.left.mas_equalTo(btn);
        make.size.mas_equalTo(btn);
    }];
    
 
    {
        FQThumbnailView *thumView = [[FQThumbnailView alloc] init];
        thumView.frame = CGRectMake(20, kNavBarHeight + 70, 0, 0);
        [self.view addSubview:thumView];
        self.thumbView = thumView;
    }
    
    {
        FQReaderPlayerView *playerView = [[FQReaderPlayerView alloc] initWithFrame:CGRectMake(20, kNavBarHeight + 70, kScreenWidth - 40, 350)];
        [self.view addSubview:playerView];
        self.playerView = playerView;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FQAssetsViewControllerDelegate

- (void)assetsViewCtr:(FQAssetsViewController *)viewCtr didSelectedWithAssetArray:(NSArray *)assetArray {
    
    if ([assetArray.firstObject isKindOfClass:[FQAssetModel class]]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.playerView playWithAsset:[(FQAssetModel *)assetArray.firstObject avAsset]];
        });
        
        return;
    }
    
    
    CGRect frame = [self.thumbView frameWithImgArray:assetArray];
    frame.origin.x = self.thumbView.frame.origin.x;
    frame.origin.y = self.thumbView.frame.origin.y;
    self.thumbView.frame = frame;
}

#pragma mark - FQImagePickerControllerDelegate

- (void)imagePickerController:(FQImagePickerController *)ctr didPickedImage:(UIImage *)image {
    CGRect frame = [self.thumbView frameWithImgArray:@[image]];
    frame.origin.x = self.thumbView.frame.origin.x;
    frame.origin.y = self.thumbView.frame.origin.y;
    self.thumbView.frame = frame;
}

#pragma mark - Getter

- (UIButton *)buttonWithTitle:(NSString *)title block:(void(^)(id sender))block {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.borderWidth = 1.0;
    btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    [btn addBlockForControlEvents:UIControlEventTouchUpInside block:block];
    
    return btn;
}

@end
