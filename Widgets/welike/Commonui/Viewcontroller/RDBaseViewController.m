//
//  RDBaseViewController.m
//  welike
//
//  Created by 刘斌 on 2018/4/13.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseViewController.h"
#import "WLLoadingDlg.h"
#import "MBProgressHUD.h"
#import "WLNewVersionView.h"
#import "WLNewVersionInfo.h"
#import "IQKeyboardManager.h"

@interface RDBaseViewController ()

@property (nonatomic, strong) WLLoadingDlg *loadingDlg;
@property (nonatomic, strong) WLNewVersionView *versionView;


@end

@implementation RDBaseViewController

- (void)loadView
{
    [super loadView];
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    else
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_isLightStatusBar)
    {
         [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
    
    [[IQKeyboardManager sharedManager] setEnable:NO];
    
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_isLightStatusBar)
    {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
}



- (void)showToast:(NSString *)content
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kCurrentWindow animated:YES];
    hud.label.text = content;
    hud.mode = MBProgressHUDModeText;
    hud.label.numberOfLines = 0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2.f * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [hud hideAnimated:YES];
    });
}

- (void)showToastWithNetworkErr:(NSInteger)errcode
{
    [self showToast:[WLErrorHelper getErrCodeTextForErrCode:errcode]];
}

- (void)showLoading
{
    if (self.loadingDlg == nil)
    {
        self.loadingDlg = [[WLLoadingDlg alloc] init];
        [self.loadingDlg show:kCurrentWindow];
    }
}

- (void)hideLoading
{
    if (self.loadingDlg != nil)
    {
        [self.loadingDlg hide];
        self.loadingDlg = nil;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return _statusBarHidden;
}

-(void)setStatusBarHidden:(BOOL)statusBarHidden
{
    _statusBarHidden = statusBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (_isLightStatusBar)
    {
        return UIStatusBarStyleLightContent;
    }
    else
    {
        return UIStatusBarStyleDefault;
    }
}

//show update info
-(void)showUpdate:(NSDictionary *)dic
{
    WLNewVersionInfo *versionInfo = [WLNewVersionInfo parseVersionInfo:dic];
    
    BOOL isShow = [[[NSUserDefaults standardUserDefaults] objectForKey:versionInfo.version] boolValue];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    if ([currentVersion isEqualToString:versionInfo.version]) //和当前版本号一致
    {
        return;
    }
    
    if (isShow == YES && versionInfo.updateType == UpdateWithChoice) //已经弹出过提示
    {
        return;
    }
    
    if (versionInfo.updateType == UpdateWithNoPrompt)
    {
        return;
    }
    
    
    _versionView = [[WLNewVersionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _versionView.versionInfo = versionInfo;
    [self.view addSubview:_versionView];
}

@end
