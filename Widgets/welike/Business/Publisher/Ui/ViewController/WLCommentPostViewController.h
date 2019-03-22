//
//  WLCommentPostViewController.h
//  welike
//
//  Created by gyb on 2018/4/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseViewController.h"
#import "WLBasePostViewController.h"

@class WLComment;
@interface WLCommentPostViewController : WLBasePostViewController

@property (strong,nonatomic)  WLComment *comment; //一级
@property (strong,nonatomic)  WLComment *secondeComment;//二级


@end
