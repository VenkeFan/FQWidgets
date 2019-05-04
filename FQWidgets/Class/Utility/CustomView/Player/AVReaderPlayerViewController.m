//
//  AVReaderPlayerViewController.m
//  FQWidgets
//
//  Created by fanqi on 2019/5/1.
//  Copyright © 2019年 fan qi. All rights reserved.
//

#import "AVReaderPlayerViewController.h"
#import "FQReaderPlayerView.h"
#import "FQVideoExportSession.h"

@interface AVReaderPlayerViewController ()

@property (nonatomic, strong) FQReaderPlayerView *playerView;

@end

@implementation AVReaderPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"IMG_2686.MOV" ofType:nil];
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
    
//    FQReaderPlayerView *playerView = [[FQReaderPlayerView alloc] initWithAsset:asset];
//    playerView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kSizeScale(350));
//    [self.view addSubview:playerView];
    
    
    FQVideoExportSession *session = [FQVideoExportSession new];
    [session compressWithAsset:asset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
