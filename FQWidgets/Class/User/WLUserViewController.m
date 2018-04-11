//
//  WLUserViewController.m
//  WeLike
//
//  Created by fan qi on 2018/3/28.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLUserViewController.h"
#import "FQPlayerView.h"

@interface WLUserViewController () {
    FQPlayerView *_playerView;
}

@end

@implementation WLUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor greenColor];
    
    static NSString * const videoDemo = @"https://www.apple.com/105/media/cn/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-cn-20170912_1280x720h.mp4";
    FQPlayerView *playerView = [[FQPlayerView alloc] initWithURLString:videoDemo];
    playerView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kSizeScale(350));
    [self.view addSubview:playerView];
    _playerView = playerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)buttonWithTitle:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    [btn setTitleColor:kBodyFontColor forState:UIControlStateNormal];
    
    return btn;
}

@end
