//
//  WLPostStatusViewController.h
//  welike
//
//  Created by gyb on 2018/11/13.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLNavBarBaseViewController.h"

@class WLPostStatusBar;
@class WLSelectStatusBgView;
@class WLStatusEditTableView;
@interface WLPostStatusViewController : WLNavBarBaseViewController
{
    WLPostStatusBar *postStatusBar;
    
    WLSelectStatusBgView *selectStatusBgView;
    WLStatusEditTableView *statusEditTableView;
    
}
@end
