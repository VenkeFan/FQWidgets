//
//  WLSplashViewController.m
//  welike
//
//  Created by 刘斌 on 2018/4/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLSplashViewController.h"
#import "WLRegisterSelectLanguageViewController.h"
#import "WLRegisterMobileViewController.h"
#import "WLRegisterProfileViewController.h"
#import "WLRegisterInterestsViewController.h"
#import "WLRegisterUserSugViewController.h"
#import "RDRootViewController.h"
#import "WLMainViewController.h"
#import "WLUnloginTabController.h"
#import "WLStartHandler.h"
#import "WLNewVersionInfo.h"

@interface WLSplashViewController () <WLStartHandlerDelegate>

@end

@implementation WLSplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[AppContext getInstance].startHandler registerWithDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[AppContext getInstance].startHandler unregister:self];
}

- (void)loadView
{
    [super loadView];
    
    UIImage *logoImage = [AppContext getImageForKey:@"welike_reg_logo"];
    
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:logoImage];
//    CGFloat x = self.view.center.x - (logoView.width / 2.f);
//    CGFloat y = self.view.center.y - logoView.height;
    logoView.frame = CGRectMake(0, 0, logoImage.size.width, logoImage.size.height);
    logoView.center = self.view.center;
    
    [self.view addSubview:logoView];
    
    //在这里加载文案
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onStart) object:nil];
    [self performSelector:@selector(onStart) withObject:nil afterDelay:3.f];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onStart) object:nil];
}

#pragma mark WLStartHandlerDelegate methods
- (void)goProcess:(WELIKE_STARTUP_STATE)state
{
    switch (state)
    {
        case WELIKE_STARTUP_STATE_MAIN:
        {
            [[AppContext rootViewController] pushViewControllerAfterClearAll:[AppContext mainViewController] animated:NO];
            [self checkNewVersionAndPrompt];
            break;
        }
        case WELIKE_STARTUP_STATE_LANG:
        {
            WLRegisterSelectLanguageViewController *vc = [[WLRegisterSelectLanguageViewController alloc] init];
            [[AppContext rootViewController] pushViewControllerAfterClearAll:vc animated:NO];
            [self checkNewVersionAndPrompt];
            break;
        }
        case WELIKE_STARTUP_STATE_LOGIN_MOBILE:
        {
            WLRegisterMobileViewController *vc = [[WLRegisterMobileViewController alloc] init];
            [[AppContext rootViewController] pushViewControllerAfterClearAll:vc animated:NO];
            [self checkNewVersionAndPrompt];
            break;
        }
        case WELIKE_STARTUP_STATE_REGISTER_USERINFO:
        {
            WLRegisterProfileViewController *vc = [[WLRegisterProfileViewController alloc] init];
            [[AppContext rootViewController] pushViewControllerAfterClearAll:vc animated:NO];
            [self checkNewVersionAndPrompt];
            break;
        }
        case WELIKE_STARTUP_STATE_REGISTER_INTERESTS:
        {
            WLRegisterInterestsViewController *vc = [[WLRegisterInterestsViewController alloc] init];
            [[AppContext rootViewController] pushViewControllerAfterClearAll:vc animated:NO];
             [self checkNewVersionAndPrompt];
            break;
        }
        case WELIKE_STARTUP_STATE_REGISTER_SUG_USERS:
        {
            WLRegisterUserSugViewController *vc = [[WLRegisterUserSugViewController alloc] init];
            [[AppContext rootViewController] pushViewControllerAfterClearAll:vc animated:NO];
              [self checkNewVersionAndPrompt];
            break;
        }
        case WELIKE_STARTUP_STATE_EXEMPT_LOGIN:
        {
            [[AppContext rootViewController] pushViewControllerAfterClearAll:[WLUnloginTabController new] animated:NO];
            [self checkNewVersionAndPrompt];
            break;
        }
            
        default:
        {
            break;
        }
    }
}

- (void)onStart
{
    [[AppContext getInstance].startHandler start];
}

-(void)checkNewVersionAndPrompt
{
    [self.appInfoManager appInfo:^(NSDictionary *infoDic, NSInteger errCode) {
        
        //NSLog(@"%@",[[AppContext currentViewController] class]);
        
        if (infoDic)
        {
              [[AppContext currentViewController] showUpdate:infoDic];
        }
        
    }];
}

- (WLAppInfoManager *)appInfoManager {
    if (!_appInfoManager) {
        _appInfoManager = [[WLAppInfoManager alloc] init];
    }
    return _appInfoManager;
}


@end
