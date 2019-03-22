//
//  WLForwardPost.h
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPostBase.h"

@interface WLForwardPost : WLPostBase

@property (nonatomic, strong) WLPostBase *rootPost;
@property (nonatomic, assign) BOOL forwardDeleted;

@end
