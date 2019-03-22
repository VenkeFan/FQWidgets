//
//  NSString+WLNilExamine.m
//  welike
//
//  Created by fan qi on 2018/11/9.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "NSString+WLNilExamine.h"
#import "WLTrackerUtility.h"

@implementation NSString (WLNilExamine)

+ (void)load {
    id placeholderStr = [NSString alloc];
    swizzleInstanceMethod([placeholderStr class], @selector(initWithString:), @selector(safe_initWithString:));
    
    id placeholderStrM = [NSMutableString alloc];
    swizzleInstanceMethod([placeholderStrM class], @selector(initWithString:), @selector(safeM_initWithString:));
    
    NSMutableString *mutStr = [NSMutableString string];
    swizzleInstanceMethod([mutStr class], @selector(replaceCharactersInRange:withString:), @selector(safe_replaceCharactersInRange:withString:));
    swizzleInstanceMethod([mutStr class], @selector(insertString:atIndex:), @selector(safe_insertString:atIndex:));
    swizzleInstanceMethod([mutStr class], @selector(appendString:), @selector(safe_appendString:));
    swizzleInstanceMethod([mutStr class], @selector(deleteCharactersInRange:), @selector(safe_deleteCharactersInRange:));
    swizzleInstanceMethod([mutStr class], @selector(replaceOccurrencesOfString:withString:options:range:), @selector(safe_replaceOccurrencesOfString:withString:options:range:));
}

- (instancetype)safe_initWithString:(NSString *)aString {
    if (nil == aString || [aString isEqual:[NSNull null]]) {
        return nil;
    }
    return [self safe_initWithString:aString];
}

- (instancetype)safeM_initWithString:(NSString *)aString {
    if (nil == aString || [aString isEqual:[NSNull null]]) {
        return nil;
    }
    return [self safeM_initWithString:aString];
}

- (void)safe_replaceCharactersInRange:(NSRange)range withString:(NSString *)aString {
    if (nil == aString || [aString isEqual:[NSNull null]]) {
        return;
    }
    
    if (range.location < 0
        || range.location > self.length
        || range.location + range.length > self.length) {
        return;
    }
    
    [self safe_replaceCharactersInRange:range withString:aString];
}

- (void)safe_insertString:(NSString *)aString atIndex:(NSUInteger)loc {
    if (nil == aString || [aString isEqual:[NSNull null]]) {
        return;
    }
    
    if (loc < 0 || loc > self.length) {
        return;
    }
    
    [self safe_insertString:aString atIndex:loc];
}

- (void)safe_appendString:(NSString *)aString {
    if (nil == aString || [aString isEqual:[NSNull null]]) {
        return;
    }
    
    if ([[self class] isKindOfClass:[NSString class]])
    {
        return;
    }
    
    [self safe_appendString:aString];
}

- (void)safe_deleteCharactersInRange:(NSRange)range {
    if (range.location < 0
        || range.location > self.length
        || range.location + range.length > self.length) {
        return;
    }
    
    [self safe_deleteCharactersInRange:range];
}

- (NSUInteger)safe_replaceOccurrencesOfString:(NSString *)target
                                   withString:(NSString *)replacement
                                      options:(NSStringCompareOptions)options
                                        range:(NSRange)searchRange {
    if (nil == target || [target isEqual:[NSNull null]]) {
        return -1;
    }
    if (nil == replacement || [replacement isEqual:[NSNull null]]) {
        return -1;
    }
    
    if (searchRange.location < 0
        || searchRange.location > self.length
        || searchRange.location + searchRange.length > self.length) {
        return -1;
    }
    
    return [self safe_replaceOccurrencesOfString:target
                                      withString:replacement
                                         options:options
                                           range:searchRange];
}

@end
