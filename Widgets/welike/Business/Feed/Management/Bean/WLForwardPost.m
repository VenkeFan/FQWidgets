//
//  WLForwardPost.m
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLForwardPost.h"

@implementation WLForwardPost

- (id)init
{
    self = [super init];
    if (self)
    {
        self.type = WELIKE_POST_TYPE_FORWARD;
    }
    return self;
}

@end
