//
//  WLShareViewController.h
//  welike
//
//  Created by fan qi on 2018/5/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLShareModel.h"

@interface WLShareViewController : RDBaseViewController

@property (nonatomic, strong) WLShareModel *shareModel;

- (void)dismiss;

@end
