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

static NSString *reusCellID = @"reusCellID";

@interface WLUserViewController ()

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
