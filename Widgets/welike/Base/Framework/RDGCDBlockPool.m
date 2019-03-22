//
//  RDGCDBlockPool.m
//  welike
//
//  Created by 刘斌 on 2018/6/13.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDGCDBlockPool.h"

@interface RDGCDBlockPool ()
{
    dispatch_queue_t _queue;
}

@property (nonatomic, strong) NSMutableArray *blockPool;

@end

@implementation RDGCDBlockPool

- (id)initWithQueue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self)
    {
        _queue = queue;
        _blockPool = [NSMutableArray array];
    }
    return self;
}

- (void)asyncBlock:(queueBlock)block
{
    [self asyncBlock:block flags:0];
}

- (void)asyncBlock:(queueBlock)block flags:(dispatch_block_flags_t)flags
{
    if (block != nil)
    {
        dispatch_async(_queue, block);
//        __weak typeof(self) weakSelf = self;
//        dispatch_block_t __block b = dispatch_block_create(flags, ^{
//            block();
//            @synchronized (weakSelf.blockPool)
//            {
//                [weakSelf.blockPool removeObject:b];
//            }
//        });
//        @synchronized (self.blockPool)
//        {
//            [self.blockPool addObject:b];
//        }
//        dispatch_async(_queue, b);
    }
}

- (void)syncBlock:(queueBlock)block
{
    [self syncBlock:block flags:0];
}

- (void)syncBlock:(queueBlock)block flags:(dispatch_block_flags_t)flags
{
    if (block != nil)
    {
        dispatch_sync(_queue, block);
//        dispatch_block_t b = dispatch_block_create(flags, ^{
//            block();
//        });
//        dispatch_sync(_queue, b);
    }
}

- (void)cancelAll
{
    @synchronized (self.blockPool)
    {
//        for (dispatch_block_t b in self.blockPool)
//        {
//            dispatch_block_cancel(b);
//        }
        [self.blockPool removeAllObjects];
    }
}

@end
