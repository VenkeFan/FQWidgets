//
//  NSNumber+LuuBase.m
//  yshushu
//
//  Created by liubin on 16/3/28.
//  Copyright © 2016年 luu. All rights reserved.
//

#import "NSNumber+LuuBase.h"

@implementation NSNumber (LuuBase)

+ (NSNumber *)convertFromBool:(BOOL)val
{
    if (val == NO)
    {
        return [NSNumber numberWithInteger:0];
    }
    else
    {
        return [NSNumber numberWithInteger:1];
    }
}

@end
