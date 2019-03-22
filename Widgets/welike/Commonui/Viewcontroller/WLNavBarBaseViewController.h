//
//  WLNavBarBaseViewController.h
//  welike
//
//  Created by gyb on 2018/4/25.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseViewController.h"
#import "WLNavigationBar.h"

@interface WLNavBarBaseViewController : RDBaseViewController

@property (nonatomic, strong, readonly) WLNavigationBar *navigationBar;
@property (nonatomic, assign) BOOL navigationBarAlwaysFront;

@end
