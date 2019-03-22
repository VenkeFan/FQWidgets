//
//  WLMentionPostViewController.h
//  welike
//
//  Created by gyb on 2018/4/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseViewController.h"
#import "WLBasePostViewController.h"
@class WLComment;
@interface WLRepostViewController : WLBasePostViewController


//回复评论使用
@property (strong,nonatomic)  WLComment *comment;

@end
