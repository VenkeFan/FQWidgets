//
//  WLUserViewController.m
//  WeLike
//
//  Created by fan qi on 2018/3/28.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLUserViewController.h"
#import "FQPlayerView.h"
#import "FQCarouselView.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import "FQVideoComposition.h"

static NSString *reusCellID = @"reusCellID";

@interface WLUserViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    FQPlayerView *_playerView;
    
    AVAsset *_asset1;
    AVAsset *_asset2;
}

@end

@implementation WLUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor greenColor];
    
    NSString * videoDemo = @"https://www.apple.com/105/media/cn/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-cn-20170912_1280x720h.mp4";

//    videoDemo = @"http://dev-file.welike.in/download/video-9238a4c424f14ffb8194417f4bfab677.mp4/";
//
//    videoDemo = @"https://www.youtube.com/embed/mbtrVs7pAs0";
//
//    videoDemo = @"https://youtu.be/9g2YPmzDfkI";
    
//    videoDemo = @"https://r2---sn-a5mekner.googlevideo.com/videoplayback?signature=6B118DC39D10EC80956B9AAE5B60F465627CCCBC.54D38C7FBAF0A15B3B04D30CD573437069CD4E45&fvip=2&dur=507.820&ei=iDwfW4u6DMbCigTclJ-oBQ&gir=yes&lmt=1527819976832662&sparams=clen,dur,ei,expire,gir,id,initcwndbps,ip,ipbits,ipbypass,itag,lmt,mime,mip,mm,mn,ms,mv,pl,ratebypass,requiressl,source&id=o-APstyXVZlrTSVIyY9mjN21BXjF7WL_OglXUYD9btgqwu&expire=1528795368&ip=205.204.117.50&mime=video%2Fmp4&requiressl=yes&pl=20&source=youtube&itag=18&clen=33585030&c=MWEB&key=cms1&ipbits=0&ratebypass=yes&cpn=ZmGFixtkhYJPAWeF&cver=2.20180609.199848069-RC0_new_canary_experiment&ptk=youtube_single&oid=vfB0Kg4Sc2HLZOLBdWwuOA&ptchn=TY7QED-uxqgUtU0COknFdg&pltype=content&redirect_counter=1&rm=sn-a5mdy7l&fexp=23714780&req_id=39d3fdd13526a3ee&cms_redirect=yes&ipbypass=yes&mip=97.64.38.21&mm=31&mn=sn-a5mekner&ms=au&mt=1528782238&mv=m";

    FQPlayerView *playerView = [[FQPlayerView alloc] initWithURLString:videoDemo];
    playerView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kSizeScale(350));
    [self.view addSubview:playerView];
    
    
//    FQCarouselView *carouselView = [[FQCarouselView alloc] init];
//    carouselView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kSizeScale(200));
//    carouselView.allowAutoNextPage = YES;
//    carouselView.allowInfiniteBanner = YES;
//    [self.view addSubview:carouselView];
    
    
    __weak typeof(self) weakSelf = self;
    UIButton *btn = [self buttonWithTitle:@"选择视频" block:^(id sender) {
        UIImagePickerController *ctr = [[UIImagePickerController alloc] init];
        ctr.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
        ctr.delegate = weakSelf;
        [weakSelf.navigationController presentViewController:ctr animated:YES completion:nil];
    }];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(playerView.mas_bottom).offset(20);
        make.left.mas_equalTo(self.view).offset(20);
        make.size.mas_equalTo(CGSizeMake(120, 45));
    }];
    
    UIButton *composeBtn = [self buttonWithTitle:@"合成" block:^(id sender) {
        FQVideoComposition *composition = [FQVideoComposition new];
//        [composition composeVideo:_asset1 secondVideoAsset:_asset2];
//        [composition composeVideo:_asset1 audio:_asset2];
//        [composition composeVideo:_asset1 image:[UIImage imageNamed:@"awesomeface"]];
        [composition composeVideo:_asset1 gifPath:[[NSBundle mainBundle] pathForResource:@"banana" ofType:@"gif"]];
    }];
    [self.view addSubview:composeBtn];
    [composeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(btn.mas_right).offset(15);
        make.size.mas_equalTo(btn);
        make.centerY.mas_equalTo(btn);
    }];
    
    UIButton *clearBtn = [self buttonWithTitle:@"清除" block:^(id sender) {
        _asset1 = nil;
        _asset2 = nil;
    }];
    [self.view addSubview:clearBtn];
    [clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(composeBtn.mas_right).offset(15);
        make.size.mas_equalTo(btn);
        make.centerY.mas_equalTo(btn);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    if (!_asset1) {
        [[PHImageManager defaultManager] requestAVAssetForVideo:info[UIImagePickerControllerPHAsset]
                                                        options:nil
                                                  resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                                                      _asset1 = asset;
                                                  }];
        
    } else if (!_asset2) {
        [[PHImageManager defaultManager] requestAVAssetForVideo:info[UIImagePickerControllerPHAsset]
                                                        options:nil
                                                  resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                                                      _asset2 = asset;
                                                  }];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
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
