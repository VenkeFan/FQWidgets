//
//  WLHomeViewController.m
//  WeLike
//
//  Created by fan qi on 2018/3/27.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLHomeViewController.h"

#import "FQThumbnailView.h"

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
    FQThumbnailView *thumView = [[FQThumbnailView alloc] init];
    CGRect frame = [thumView frameWithImgArray:self.imgArray];
    thumView.frame = CGRectMake(20, kNavBarHeight + 30, frame.size.width, frame.size.height);
    [self.view addSubview:thumView];
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
