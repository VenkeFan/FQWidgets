//
//  WLUsersProviderBase.m
//  welike
//
//  Created by 刘斌 on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLUsersProviderBase.h"
#import "WLUser.h"

@implementation WLUsersProviderBase

- (id)init
{
    self = [super init];
    if (self)
    {
        self.cacheList = [NSMutableDictionary dictionary];
        self.onePageList = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSArray *)filterUsers:(NSArray *)source
{
    if ([self.cacheList count] > 0)
    {
        return [WLUsersProviderBase filterUsers:source filter:self.cacheList];
    }
    else
    {
        return source;
    }
}

- (void)cacheFirstPage:(NSArray *)source
{
    [self.onePageList removeAllObjects];
    if ([source count] > 0)
    {
        for (NSInteger i = 0; i < [source count]; i++)
        {
            WLUser *user = [source objectAtIndex:i];
            [self.onePageList setObject:user forKey:user.uid];
        }
    }
}

- (NSInteger)refreshNewCount:(NSArray *)source
{
    if ([source count] > 0)
    {
        NSInteger count = [source count];
        for (NSInteger i = 0; i < [source count]; i++)
        {
            WLUser *user = [source objectAtIndex:i];
            if ([self.onePageList objectForKey:user.uid] != nil)
            {
                count--;
            }
        }
        if (count < 0) count = 0;
        return count;
    } else {
        return 0;
    }
}

+ (NSArray *)filterUsers:(NSArray *)source filter:(NSMutableDictionary *)filter
{
    NSMutableArray *target = [NSMutableArray array];
    for (NSInteger i = 0; i < [source count]; i++)
    {
        WLUser *user = [source objectAtIndex:i];
        if ([filter objectForKey:user.uid] == nil)
        {
            [target addObject:user];
            [filter setObject:user forKey:user.uid];
        }
    }
    return [NSArray arrayWithArray:target];
}

@end
