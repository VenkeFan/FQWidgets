//
//  WLTextPost.m
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTextPost.h"

@implementation WLTextPost

- (id)init
{
    self = [super init];
    if (self)
    {
        self.type = WELIKE_POST_TYPE_TEXT;
    }
    return self;
}

@end
