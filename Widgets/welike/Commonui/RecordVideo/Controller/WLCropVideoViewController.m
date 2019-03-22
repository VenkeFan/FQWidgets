//
//  WLCropVideoViewController.m
//  welike
//
//  Created by gyb on 2019/1/7.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "WLCropVideoViewController.h"
#import "WLCropVideoView.h"
#import <AliyunVideoSDKPro/AliyunCrop.h>
#import "WLRecordConfig.h"
#import "WLAssetsManager.h"

static NSString *const PlayerItemStatus = @"_playerItem.status";

typedef NS_ENUM(NSInteger, WLCropPlayerStatus) {
    WLCropPlayerStatusPause,             // 结束或暂停
    WLCropPlayerStatusPlaying,           // 播放中
    WLCropPlayerStatusPlayingBeforeSeek  // 拖动之前是播放状态
};

@interface WLCropVideoViewController ()<UIScrollViewDelegate,AliyunCropDelegate>
{
    WLRecordConfig *recordConfig;
    
    
    
    
    UIButton *closeBtn;
    UIButton *sendBtn;
}
//@property (nonatomic, strong) UIScrollView *previewScrollView;
//@property (nonatomic, strong) AliyunCropThumbnailView *thumbnailView;




//@property (nonatomic, assign) CGFloat previewHeight;
//@property (nonatomic, assign) CGFloat previewWidth;
//@property (nonatomic, assign) CGPoint preViewOffset;
//

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) WLCropVideoView *cropVideoView;



//@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;
//@property (nonatomic, strong) id timeObserver;
//@property (nonatomic, assign) CMTime currentTime;
//
//@property (nonatomic, assign) CGFloat destRatio;
//@property (nonatomic, assign) CGFloat orgVideoRatio;
//@property (nonatomic, assign) CGSize originalMediaSize;
//
@property (nonatomic, strong) AliyunCrop *cutPanel;
//@property (nonatomic, assign) BOOL shouldStartCut;
//@property (nonatomic, assign) BOOL hasError;
//@property (nonatomic, assign) BOOL isCancel;
@property (nonatomic, assign) WLCropPlayerStatus playerStatus;




@end

@implementation WLCropVideoViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    recordConfig = [WLRecordConfig defaultConfig];
    
    [self initPlayer];
    [self setupSubViews];
   
    
    
    
    
//    if (_cutInfo.phAsset) {//是图片资源
//        if (_cutInfo.phImage) {
//            _originalMediaSize = CGSizeMake(_cutInfo.phImage.size.width, _cutInfo.phImage.size.height);
//            _destRatio = _cutInfo.outputSize.width / _cutInfo.outputSize.height;
//            _orgVideoRatio = _originalMediaSize.width / _originalMediaSize.height;
//        }else {
//            _originalMediaSize = CGSizeMake(_cutInfo.phAsset.pixelWidth, _cutInfo.phAsset.pixelHeight);
//            _destRatio = _cutInfo.outputSize.width / _cutInfo.outputSize.height;
//            _orgVideoRatio = _originalMediaSize.width / _originalMediaSize.height;
//        }
//
//
//        [self setupStillImageLayer];
//    } else {
//        NSURL *sourceURL = [NSURL fileURLWithPath:_cutInfo.sourcePath];
//        _avAsset = [AVAsset assetWithURL:sourceURL];
//        _originalMediaSize = [_avAsset avAssetNaturalSize];
//        _destRatio = _cutInfo.outputSize.width / _cutInfo.outputSize.height;
//        _orgVideoRatio = _originalMediaSize.width / _originalMediaSize.height;
//
//        [self setAVPlayer];
//        [self addNotification];
//        _thumbnailView.avAsset = _avAsset;
//    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

- (void)setupSubViews {
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UIButton *screenBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [screenBtn addTarget:self action:@selector(playOrPauseBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:screenBtn];
 
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(0, kSystemStatusBarHeight, 44, 44);
    [closeBtn setImage:[AppContext getImageForKey:@"common_close_white"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 60 - 10, kSystemStatusBarHeight + 6, 60, 28)];
    [sendBtn addTarget:self action:@selector(sendBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    sendBtn.layer.cornerRadius = 3.0;
    sendBtn.backgroundColor = kMainColor;
    sendBtn.titleLabel.font = kBoldFont(14);
    [sendBtn setTitle:[AppContext getStringForKey:@"regist_next_btn" fileName:@"register"] forState:UIControlStateNormal];
    [self.view addSubview:sendBtn];
    

    _cropVideoView = [[WLCropVideoView alloc] initWithFrame:CGRectMake(8, kScreenHeight - 60 - 32, kScreenWidth - 16, 32)];
    _cropVideoView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_cropVideoView];
    
    
    
    
    
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapGesture)];
//
//    [playerLayer add];
    
    //    self.previewScrollView = [[UIScrollView alloc] init];
//    self.previewScrollView.bounces = NO;
//
//    self.previewScrollView.frame = CGRectMake(0, SafeTop+44, ScreenWidth, SizeHeight(426));
//    self.previewScrollView.backgroundColor = _cutInfo.backgroundColor ? :[UIColor blackColor];
//    self.previewScrollView.delegate = self;
//    [self.view addSubview:self.previewScrollView];
//    [self.previewScrollView addGestureRecognizer:tapGesture];
//
//    if (!_cutInfo.phAsset) {
//        self.thumbnailView = [[AliyunCropThumbnailView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 40 - ScreenWidth/8.0 - 12 - SafeBottom, ScreenWidth, ScreenWidth / 8 + 12) withCutInfo:_cutInfo];
//        self.thumbnailView.delegate = (id<AliyunCutThumbnailViewDelegate>)self;
//        [self.view addSubview:self.thumbnailView];
//    }
//
//    self.bottomView = [[AliyunCropViewBottomView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 40 - SafeBottom, ScreenWidth, 40)];
//    self.bottomView.delegate = (id<AliyunCropViewBottomViewDelegate>)self;
//    [self.view addSubview:self.bottomView];
//
//    if (!_cutInfo.phAsset) {
//        self.progressView = [[AliyunCycleProgressView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
//        self.progressView.backgroundColor = [UIColor clearColor];
//        self.progressView.center = self.view.center;
//        self.progressView.progressColor = RGBToColor(230, 60, 91);
//        self.progressView.progressBackgroundColor = RGBToColor(160, 168, 183);
//        [self.view addSubview:self.progressView];
//    }
}

//初始化播放器
-(void)initPlayer
{
    _playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:_urlStr]];
    
    [self addObserver:self forKeyPath:PlayerItemStatus options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    _avPlayer = [AVPlayer playerWithPlayerItem:_playerItem];
    
    AVPlayerLayer *playerLayer  = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
    
    playerLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    
    [self.view.layer addSublayer:playerLayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:PlayerItemStatus])
    {
        if ([object isKindOfClass:[WLCropVideoViewController class]])
        {
            WLCropVideoViewController *controller = (WLCropVideoViewController *)object;
            AVPlayerItem * item = controller.playerItem;
            if (item.status == AVPlayerItemStatusReadyToPlay)
            {
                 _playerStatus = WLCropPlayerStatusPlaying;
                [_avPlayer play];
                
                seconds = CMTimeGetSeconds(_avPlayer.currentItem.duration);
                
                [self removeObserver:self forKeyPath:PlayerItemStatus];
            }
            else
                if (item.status == AVPlayerItemStatusFailed)
                {
                    NSLog(@"failed");
                }
                else
                {
                    
                }
        }
    }
}


- (void)playVideo {
//    if (_playerStatus == AliyunCropPlayerStatusPlayingBeforeSeek) {
//        [_avPlayer seekToTime:CMTimeMake(_cutInfo.startTime * 1000, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
//    }
    
    [_avPlayer play];
    _playerStatus = WLCropPlayerStatusPlaying;
    
//    if (_timeObserver) return;
//    __weak typeof(self) weakSelf = self;
//    _timeObserver = [_avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 10)
//                                                            queue:dispatch_get_main_queue()
//                                                       usingBlock:^(CMTime time) {
//
//                                                           __strong typeof(self) strong = weakSelf;
//                                                           CGFloat crt = CMTimeGetSeconds(time);
//
//                                                           if (strong.cutInfo.sourceDuration) {
//                                                               [strong.thumbnailView updateProgressViewWithProgress:crt/strong.cutInfo.sourceDuration];
//                                                           }
//                                                       }];
}

- (void)pauseVideo
{
    if (_playerStatus == WLCropPlayerStatusPlaying)
    {
        _playerStatus = WLCropPlayerStatusPause;
        [_avPlayer pause];
    }
}

-(void)moviePlayDidEnd
{
    NSLog(@"播放完毕,重播");
    
    //__weak typeof(self) weakSelf = self;
    [_avPlayer seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
      //  [weakSelf.videoSlider setValue:0.0 animated:YES];
      //  [weakSelf.stateButton setTitle:@"Play" forState:UIControlStateNormal];
    }];
    
    [_avPlayer play];
}

#pragma mark - Event
- (void)closeBtnClicked
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)sendBtnClicked
{
    [self pauseVideo];
    
    if (_cutPanel) {
        [_cutPanel cancel];
    }
    _cutPanel = [[AliyunCrop alloc] init];
    _cutPanel.delegate = (id<AliyunCropDelegate>)self;
    _cutPanel.inputPath = recordConfig.outputPath;
    _cutPanel.outputPath = recordConfig.cropOutputPath;
    
    _cutPanel.outputSize = recordConfig.outputSize;
    _cutPanel.fps = recordConfig.fps;
    _cutPanel.gop = recordConfig.gop;
    _cutPanel.bitrate = recordConfig.bitrate;
    //_cutPanel.videoQuality = recordConfig.videoQuality;
    
    if (recordConfig.cutMode == 1) {
        _cutPanel.rect = [self evenRect:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];//TODO:需要改
    }
    _cutPanel.cropMode = recordConfig.cutMode;
    
    _cutPanel.startTime = 0; //TODO:需要改
    _cutPanel.endTime = 3;//TODO:需要改
    
    _cutPanel.fadeDuration = 0;
    _cutPanel.encodeMode = recordConfig.encodeMode;
    _cutPanel.fillBackgroundColor = [UIColor blackColor];
    _cutPanel.useHW = YES;
    [_cutPanel startCrop];
}

-(void)playOrPauseBtnPressed:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    if (_playerStatus == WLCropPlayerStatusPlaying)
    {
        [self pauseVideo];
        [btn setImage:[AppContext getImageForKey:@"publish_video_thumb"] forState:UIControlStateNormal];
    }
    else
    {
        [self playVideo];
        [btn setImage:nil forState:UIControlStateNormal];
    }
}

//裁剪必须为偶数
- (CGRect)evenRect:(CGRect)rect {
    return CGRectMake((int)rect.origin.x / 2 * 2, (int)rect.origin.y / 2 * 2, (int)rect.size.width / 2 * 2, (int)rect.size.height / 2 * 2);
}


#pragma mark --- AliyunCropDelegate

- (void)cropTaskOnProgress:(float)progress {
    NSLog(@"~~~~~progress:%@", @(progress));
//    if (_isCancel) {
//        return;
//    } else {
//        self.progressView.progress = progress;
//    }
}

- (void)cropOnError:(int)error {
    NSLog(@"~~~~~~~crop error:%@", @(error));
//    if (_isCancel) {
//        _isCancel = NO;
//    } else {
//        _hasError = YES;
//        NSString *err = [NSString stringWithFormat:@"错误码: %d",error];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"裁剪失败" message:err delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
//        [alert show];
//        self.thumbnailView.userInteractionEnabled = YES;
//        self.progressView.progress = 0;
//        self.bottomView.cropButton.userInteractionEnabled = YES;
//        [self destoryAVPlayer];
//        [self setAVPlayer];
//
//    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [_cutPanel cancel];
   // _alertView = nil;
   // _hasError = YES;
}

- (void)cropTaskOnComplete {
    NSLog(@"TestLog, %@:%@", @"log_crop_complete_time", @([NSDate date].timeIntervalSince1970));
    
    
    
    //完成剪裁
    
    
    //删除老视频
    
    
    //保存至相册
    [WLAssetsManager saveVideoToCameraRollWithFilePath:recordConfig.cropOutputPath
                                              finished:^(PHAsset *asset) {
                                                  
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      
                                                      __weak typeof(self) weakSelf = self;
                                                      [LuuUtils removeFilesInPath:self->recordConfig.outputPath];
                                                      [weakSelf dismissViewControllerAnimated:YES completion:^{
                                                          
                                                          if ([self->_delegate respondsToSelector:@selector(shortVideoCtr:didConfirmWithVideoAsset:)])
                                                          {
                                                              [self.delegate shortVideoCtr:self didConfirmWithVideoAsset:asset];
                                                              
                                                             // [self->_delegate didConfirmWithVideoAsset:asset];
                                                          }
                                                      }];
                                                  });
                                              }];
    
    //关闭页面.并跳转到发布器
    
    
    //self.progressView.progress = 0;
//    if (_isCancel)
//    {
//        _isCancel = NO;
//    }
//    else
    {
//        [_alertView dismissWithClickedButtonIndex:0 animated:YES];
//        _alertView = nil;
//        if (_hasError) {
//            _hasError = NO;
//            return;
//        }
//        _cutInfo.endTime = _cutInfo.endTime - _cutInfo.startTime;
//        _cutInfo.startTime = 0;
//        if (self.delegate)
//        {
//            [self.delegate cropViewControllerFinish:self.cutInfo viewController:self];
//        }
    }
}

- (void)cropTaskOnCancel {
    NSLog(@"cancel");
}



@end
