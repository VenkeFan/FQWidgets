//
//  NSDictionary+WLNilExamine.m
//  welike
//
//  Created by fan qi on 2018/11/9.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "NSDictionary+WLNilExamine.h"
#import "WLTrackerUtility.h"

@implementation NSDictionary (WLNilExamine)

+ (void)load {
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
    swizzleInstanceMethod([mutDic class], @selector(setObject:forKey:), @selector(safe_setObject:forKey:));
    
    id placeholderDic = [NSDictionary alloc];
    swizzleInstanceMethod([placeholderDic class], @selector(initWithObjects:forKeys:count:), @selector(safe_initWithObjects:forKeys:count:));
    swizzleInstanceMethod([placeholderDic class], @selector(initWithObjects:forKeys:), @selector(safe_initWithObjects:forKeys:));
    
//    swizzleClassMethod([NSDictionary class], @selector(dictionaryWithObjectsAndKeys:), @selector(safe_dictionaryWithObjectsAndKeys:));
//    swizzleClassMethod([NSDictionary class], @selector(dictionaryWithObjects:forKeys:count:), @selector(safe_dictionaryWithObjects:forKeys:count:));
//    swizzleClassMethod([NSDictionary class], @selector(dictionaryWithObjects:forKeys:), @selector(safe_dictionaryWithObjects:forKeys:));
//    swizzleClassMethod([NSDictionary class], @selector(dictionaryWithObject:forKey:), @selector(safe_dictionaryWithObject:forKey:));
}

- (void)safe_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (nil == anObject || nil == aKey) {
        return;
    }
    
    [self safe_setObject:anObject forKey:aKey];
}

- (instancetype)safe_initWithObjects:(id  _Nonnull const [])objects
                        forKeys:(id<NSCopying>  _Nonnull const [])keys
                          count:(NSUInteger)cnt {
    NSUInteger keyCnt = 0, valueCnt = 0;
    const id __unsafe_unretained *objPtr = objects;
    const id __unsafe_unretained *keyPtr = keys;

    for (   ; keyCnt < cnt; keyCnt++, objPtr++) {
        if (*objPtr == 0) {
            break;
        }
    }

    for (   ; valueCnt < cnt; valueCnt++, keyPtr++) {
        if (*keyPtr == 0) {
            break;
        }
    }

    NSUInteger minCnt = MIN(keyCnt, valueCnt);

    return [self safe_initWithObjects:objects forKeys:keys count:minCnt];
}

- (instancetype)safe_initWithObjects:(NSArray *)objects
                             forKeys:(NSArray<id<NSCopying>> *)keys {
    NSUInteger minCnt = MIN(objects.count, keys.count);
    
    NSMutableArray *mutObjs = [[NSMutableArray alloc] init];
    NSMutableArray *mutKeys = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < minCnt; i++) {
        if (nil == keys[i] || nil == objects[i]) {
            continue;
        }
        
        [mutObjs addObject:objects[i]];
        [mutKeys addObject:keys[i]];
    }
    
    return [self safe_initWithObjects:mutObjs forKeys:mutKeys];
}

+ (instancetype)safe_dictionaryWithObjectsAndKeys:(id)firstObject, ... {
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    id eachObject;
    va_list argumentList;
    if (firstObject) {
        [objects addObject: firstObject];
        va_start(argumentList, firstObject);
        NSUInteger index = 1;
        while ((eachObject = va_arg(argumentList, id))) {
            (index++ & 0x01) ? [keys addObject: eachObject] : [objects addObject: eachObject];
        }
        va_end(argumentList);
    }
    
    
    if (objects.count == keys.count) {
        
    } else {
        (objects.count < keys.count)?[keys removeLastObject]:[objects removeLastObject];
    }
    
    return [self dictionaryWithObjects:objects forKeys:keys];
}

+ (instancetype)safe_dictionaryWithObjects:(const id  _Nonnull __unsafe_unretained *)objects
                                 forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys
                                   count:(NSUInteger)cnt {
    NSUInteger keyCnt = 0, valueCnt = 0;
    const id __unsafe_unretained *objPtr = objects;
    const id __unsafe_unretained *keyPtr = keys;
    
    for (   ; keyCnt < cnt; keyCnt++, objPtr++) {
        if (*objPtr == 0) {
            break;
        }
    }
    
    for (   ; valueCnt < cnt; valueCnt++, keyPtr++) {
        if (*keyPtr == 0) {
            break;
        }
    }
    
    NSUInteger minCnt = MIN(keyCnt, valueCnt);
    
    NSArray *vs = [NSArray arrayWithObjects:objects count:minCnt];
    NSArray *ks = [NSArray arrayWithObjects:keys count:minCnt];
    
    return [self dictionaryWithObjects:vs forKeys:ks];
}

+ (instancetype)safe_dictionaryWithObjects:(NSArray *)objects
                                   forKeys:(NSArray<id<NSCopying>> *)keys {
    NSMutableArray *mutObjs = [[NSMutableArray alloc] init];
    NSMutableArray *mutKeys = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < objects.count; i++) {
        if (keys[i] == [NSNull null] || keys[i] == nil ||
            [objects[i] isEqual:[NSNull null]] || objects[i] == nil) {
            continue;
        }
        
        [mutObjs addObject:objects[i]];
        [mutKeys addObject:keys[i]];
    }
    
    return [self safe_dictionaryWithObjects:mutObjs forKeys:mutKeys];
}

+ (instancetype)safe_dictionaryWithObject:(id)object forKey:(id<NSCopying>)key {
    if (nil == object || nil == key) {
        return [NSDictionary dictionary];
    }
    
    return [self safe_dictionaryWithObject:object forKey:key];
}

@end
