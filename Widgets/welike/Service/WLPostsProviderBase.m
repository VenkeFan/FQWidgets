//
//  WLPostsProviderBase.m
//  welike
//
//  Created by 刘斌 on 2018/5/3.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPostsProviderBase.h"
#import "WLPostBase.h"

@implementation WLPostsProviderBase

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

- (NSArray *)filterPosts:(NSArray *)source
{
    if ([self.cacheList count] > 0)
    {
        return [WLPostsProviderBase filterPosts:source filter:self.cacheList];
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
            WLPostBase *post = [source objectAtIndex:i];
            [self.onePageList setObject:post forKey:post.pid];
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
            WLPostBase *post = [source objectAtIndex:i];
            if ([self.onePageList objectForKey:post.pid] != nil)
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

+ (NSArray *)filterPosts:(NSArray *)source filter:(NSMutableDictionary *)filter
{
    NSMutableArray *target = [NSMutableArray array];
    for (NSInteger i = 0; i < [source count]; i++)
    {
        WLPostBase *post = [source objectAtIndex:i];
        if ([filter objectForKey:post.pid] == nil)
        {
            [target addObject:post];
            [filter setObject:post forKey:post.pid];
        }
    }
    return [NSArray arrayWithArray:target];
}

@end
