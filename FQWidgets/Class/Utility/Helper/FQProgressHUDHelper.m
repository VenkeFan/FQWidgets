//
//  FQProgressHUDHelper.m
//  WeLike
//
//  Created by fan qi on 2018/4/10.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQProgressHUDHelper.h"
#import "MBProgressHUD.h"

@implementation FQProgressHUDHelper

+ (void)showWithMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kCurrentWindow animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = message;
        [hud hideAnimated:YES afterDelay:1.5];
    });
}

+ (void)showErrorWithMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kCurrentWindow animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = message;
        [hud hideAnimated:YES afterDelay:1.5];
    });
}

+ (void)beginLoading {
    [FQProgressHUDHelper beginLoadingWithMessage:@"Loading..."];
}

+ (void)beginLoadingWithMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kCurrentWindow animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = message;
    });
}

+ (void)endLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD HUDForView:kCurrentWindow];
        [hud hideAnimated:YES];
    });
}

@end
