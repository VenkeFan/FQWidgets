//
//  NSAttributedString+WLNilExamine.m
//  welike
//
//  Created by fan qi on 2019/2/26.
//  Copyright © 2019 redefine. All rights reserved.
//

#import "NSAttributedString+WLNilExamine.h"
#import "WLTrackerUtility.h"

@implementation NSAttributedString (WLNilExamine)

+ (void)load {
    id concreteAttrStr = [NSAttributedString alloc];
    swizzleInstanceMethod([concreteAttrStr class], @selector(initWithString:), @selector(safe_initWithString:));
    
    id concreteAttrStrM = [NSMutableAttributedString alloc];
    swizzleInstanceMethod([concreteAttrStrM class], @selector(initWithString:), @selector(safeM_initWithString:));
    
    swizzleClassMethod([NSAttributedString class], @selector(attributedStringWithAttachment:), @selector(safe_attributedStringWithAttachment:));
}

- (instancetype)safe_initWithString:(NSString *)str {
    if (nil == str || [str isEqual:[NSNull null]]) {
        return nil;
    }
    return [self safe_initWithString:str];
}

- (instancetype)safeM_initWithString:(NSString *)str {
    if (nil == str || [str isEqual:[NSNull null]]) {
        return nil;
    }
    return [self safeM_initWithString:str];
}

+ (NSAttributedString *)safe_attributedStringWithAttachment:(NSTextAttachment *)attachment {
    if (nil == attachment) {
        return nil;
    }
    return [self safe_attributedStringWithAttachment:attachment];
}

@end
