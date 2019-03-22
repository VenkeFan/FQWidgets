//
//  WLGuideViewController.m
//  welike
//
//  Created by gyb on 2018/8/6.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLGuideViewController.h"
#import "WLLoginBottomView.h"
#import "WLGuideTopVIew.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "WLTrackerLogin.h"

@interface WLGuideViewController () <GIDSignInDelegate, GIDSignInUIDelegate,WLStartHandlerDelegate>
{
    UIButton *backBtn;
    
    WLGuideTopVIew *guideTopVIew;
    
    WLLoginBottomView *loginBottomView;
}

@end

@implementation WLGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    bgView.image = [AppContext getImageForKey:@"guide_bg"];
    bgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:bgView];
    
    //登录块
    loginBottomView = [[WLLoginBottomView alloc] initWithFrame:CGRectMake(0, kScreenHeight - ((kScreenHeight == 480)?110:200), kScreenWidth,  (kScreenHeight == 480)? 110:200) withImageArray:[NSArray arrayWithObjects:@"guide_fb",@"guide_google",@"guide_phone", nil] withTitleArray:[NSArray arrayWithObjects:@"Facebook",@"Google",@"Phone", nil]];
    loginBottomView.delagate = self;
    [self.view addSubview:loginBottomView];
 
    //滚动块
    guideTopVIew = [[WLGuideTopVIew alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - loginBottomView.height) withTitleArray:[NSArray arrayWithObjects:@"Discover and \nShare Interests",@"Select What\n You Like",@"Personalize\n Your Feed", @"Share to\n WhatsApp", @"Express\n Your Opinion",nil]];
    guideTopVIew.desArray = [NSArray arrayWithObjects:@"Your Interests just leveled up. Get ready to win and conquer.", nil];
    guideTopVIew.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:guideTopVIew];
    
    guideTopVIew.layer.shadowColor = kMainColor.CGColor;
    guideTopVIew.layer.shadowOffset = CGSizeMake(4, 4);
    guideTopVIew.layer.shadowOpacity = 0.1;
    guideTopVIew.layer.shadowRadius = 4;
    
    UIImage *backIcon = [AppContext getImageForKey:@"register_back"];
    backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:backIcon forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(0, 20, 44, 44);
    [backBtn addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
//    backBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:backBtn];
    
   // if (kScreenHeight == 480)
    
    if (kIsiPhoneX)
    {
        backBtn.top = 44;
    }
    
    [WLTrackerLogin appendLoginViewAppear:WLTrackerLoginSNSVerifyType_Login
                            loginPageType:WLTrackerLoginPageType_FullScreen];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[AppContext getInstance].startHandler registerWithDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[AppContext getInstance].startHandler unregister:self];
}


-(void)onBack
{
    [self.navigationController popViewControllerAnimated:NO];
}


- (void)clickFacebook
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    
    [login logInWithReadPermissions:@[@"public_profile"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error == nil)
        {
            if (result.isCancelled == NO)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (result.token.tokenString.length > 0) {
                        [self showLoading];
                        [[AppContext getInstance].startHandler setThirdToken:result.token.tokenString];
                        [[AppContext getInstance].startHandler next:WELIKE_STARTUP_STATE_TRY_FACEBOOK_LOGIN];
                        
                        [WLTrackerLogin appendSNSLoginCallback:WLTrackerLoginType_Facebook
                                                      userType:WLTrackerLoginUserType_Invalid
                                                        result:WLTrackerLoginResult_Succeed];
                    } else {
                        [WLTrackerLogin appendSNSLoginCallback:WLTrackerLoginType_Facebook
                                                      userType:WLTrackerLoginUserType_Invalid
                                                        result:WLTrackerLoginResult_Failed];
                    }
                });
            } else {
                [WLTrackerLogin appendSNSLoginCallback:WLTrackerLoginType_Facebook
                                              userType:WLTrackerLoginUserType_Invalid
                                                result:WLTrackerLoginResult_Cancel];
            }
        }
    }];
}

- (void)clickGoogle
{
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    [[GIDSignIn sharedInstance] signIn];
}


#pragma mark - GIDSignInDelegate

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (error.code == kGIDSignInErrorCodeCanceled) {
        [WLTrackerLogin appendSNSLoginCallback:WLTrackerLoginType_Google
                                      userType:WLTrackerLoginUserType_Invalid
                                        result:WLTrackerLoginResult_Cancel];
    }
    
    if (user) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showLoading];
            [[AppContext getInstance].startHandler setThirdToken:user.authentication.idToken];
            [[AppContext getInstance].startHandler next:WELIKE_STARTUP_STATE_TRY_GOOGLE_LOGIN];
        });
        
        [WLTrackerLogin appendSNSLoginCallback:WLTrackerLoginType_Google
                                      userType:WLTrackerLoginUserType_Invalid
                                        result:WLTrackerLoginResult_Succeed];
    } else {
        [WLTrackerLogin appendSNSLoginCallback:WLTrackerLoginType_Google
                                      userType:WLTrackerLoginUserType_Invalid
                                        result:WLTrackerLoginResult_Failed];
    }
}

#pragma mark - GIDSignInUIDelegate

- (void)presentSignInViewController:(UIViewController *)viewController {
    [[self navigationController] pushViewController:viewController animated:YES];
}



#pragma mark WLStartHandlerDelegate methods
- (void)goProcess:(WELIKE_STARTUP_STATE)state
{
    [self hideLoading];
    [[AppContext getInstance].startHandler runNext:state];
}

- (void)goFailed:(NSInteger)errcode
{
    [self hideLoading];
    [self showToastWithNetworkErr:errcode];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
