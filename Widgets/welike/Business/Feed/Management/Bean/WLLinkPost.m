//
//  WLLinkPost.m
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLinkPost.h"

@implementation WLLinkPost

- (id)init
{
    self = [super init];
    if (self)
    {
        self.type = WELIKE_POST_TYPE_LINK;
    }
    return self;
}

@end
