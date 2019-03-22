//
//  NSPointerArray+LuuBase.h
//  welike
//
//  Created by 刘斌 on 2018/5/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPointerArray (LuuBase)

- (void)addObject:(id)object;
- (BOOL)containsObject:(id)object;
- (void)removeObject:(id)object;
- (void)removeAllNulls;

@end
