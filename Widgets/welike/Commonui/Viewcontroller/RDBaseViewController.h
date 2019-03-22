//
//  RDBaseViewController.h
//  welike
//
//  Created by 刘斌 on 2018/4/13.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RDBaseViewController : UIViewController

@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, strong) NSDictionary *routerParams;
@property (nonatomic, assign) BOOL isLightStatusBar;

- (void)showToast:(NSString *)content;
- (void)showToastWithNetworkErr:(NSInteger)errcode;

- (void)showLoading;
- (void)hideLoading;


-(void)showUpdate:(NSDictionary *)dic;

@end
