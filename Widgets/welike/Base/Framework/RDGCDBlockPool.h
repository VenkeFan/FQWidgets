//
//  RDGCDBlockPool.h
//  welike
//
//  Created by 刘斌 on 2018/6/13.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^queueBlock) (void);

@interface RDGCDBlockPool : NSObject

- (id)initWithQueue:(dispatch_queue_t)queue;

- (void)asyncBlock:(queueBlock)block;
- (void)asyncBlock:(queueBlock)block flags:(dispatch_block_flags_t)flags;
- (void)syncBlock:(queueBlock)block;
- (void)syncBlock:(queueBlock)block flags:(dispatch_block_flags_t)flags;
- (void)cancelAll;

@end
