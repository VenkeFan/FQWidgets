//
//  WLEULAViewController.h
//  welike
//
//  Created by 刘斌 on 2018/5/30.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseViewController.h"

typedef void(^accept)(void);
typedef void(^cancel)(void);

@interface WLEULAViewController : RDBaseViewController

@property (nonatomic, strong) accept accept;
@property (nonatomic, strong) cancel cancel;

@end
