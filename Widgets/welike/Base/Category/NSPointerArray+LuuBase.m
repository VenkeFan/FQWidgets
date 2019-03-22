//
//  NSPointerArray+LuuBase.m
//  welike
//
//  Created by 刘斌 on 2018/5/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "NSPointerArray+LuuBase.h"

@implementation NSPointerArray (LuuBase)

- (void)addObject:(id)object
{
    [self addPointer:(__bridge void *)object];
}

- (BOOL)containsObject:(id)object
{
    // get passed in object's pointer
    void * objPtr = (__bridge void *)object;
    for (NSUInteger i = 0; i < [self count]; i++)
    {
        void * ptr = [self pointerAtIndex:i];
        if (ptr == objPtr) return YES;
    }
    
    return NO;
}

- (void)removeObject:(id)object
{
    // get pointer to the passed in object
    void * objPtr = (__bridge void *)object;
    NSInteger objIndex = -1;
    for (NSUInteger i = 0; i < [self count]; i++)
    {
        void * ptr = [self pointerAtIndex:i];
        if (ptr == objPtr)
        {
            // pointers equal, found our object!
            objIndex = i;
            break;
        }
    }
    
    // make sure index is non-nil and not outside bounds
    if (objIndex >= 0 && objIndex < [self count])
    {
        [self removePointerAtIndex:objIndex];
    }
}

- (void)removeAllNulls
{
    NSMutableSet *indexesToRemove = [NSMutableSet new];
    for (NSUInteger i = 0; i < [self count]; i++)
    {
        if (![self pointerAtIndex:i])
        {
            // is the pointer null? then remove it
            [indexesToRemove addObject:@(i)];
        }
    }
    
    for (NSNumber *indexToRemove in indexesToRemove)
    {
        [self removePointerAtIndex:[indexToRemove unsignedIntegerValue]];
    }
}

@end
