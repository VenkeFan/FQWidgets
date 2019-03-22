//
//  WLPicPost.m
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPicPost.h"

@implementation WLPicPost

- (id)init
{
    self = [super init];
    if (self)
    {
        self.type = WELIKE_POST_TYPE_PIC;
        self.picInfoList = [NSMutableArray arrayWithCapacity:POST_PIC_MAX_COUNT];
    }
    return self;
}

@end
