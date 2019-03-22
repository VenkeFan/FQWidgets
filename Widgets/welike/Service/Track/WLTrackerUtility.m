//
//  WLTrackerUtility.m
//  welike
//
//  Created by fan qi on 2018/11/1.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLTrackerUtility.h"
#import "WLPostBase.h"
#import <objc/runtime.h>

NSString * trackerFeedSource(WLTrackerFeedSource source, __nullable WLTrackerFeedSubType subType) {
    NSString *strType = nil;
    if (subType.length != 0 && (source == WLTrackerFeedSource_Discover_Hot || source == WLTrackerFeedSource_UnLogin)) {
        strType = [NSString stringWithFormat:@"%d_%@", (int)source, subType];
    } else {
        strType = [NSString stringWithFormat:@"%d", (int)source];
    }
    return strType;
}

WLTrackerRepostType trackerPostType(WLPostBase *postModel) {
    WLTrackerRepostType postType = WLTrackerRepostType_Text;
    
    switch (postModel.type) {
        case WELIKE_POST_TYPE_TEXT:
            postType = WLTrackerRepostType_Text;
            break;
        case WELIKE_POST_TYPE_PIC:
            postType = WLTrackerRepostType_Picture;
            break;
        case WELIKE_POST_TYPE_VIDEO:
            postType = WLTrackerRepostType_Video;
            break;
        case WELIKE_POST_TYPE_POLL:
            postType = WLTrackerRepostType_Poll;
            break;
        default:
            postType = WLTrackerRepostType_Other;
            break;
    }
    
    return postType;
}

BOOL swizzleInstanceMethod(Class cls, SEL originalSel, SEL swizzledSel) {
    Method originalMethod = class_getInstanceMethod(cls, originalSel);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSel);
    if (!originalMethod || !swizzledMethod) {
        return NO;
    }
    
    BOOL didAdded = class_addMethod(cls,
                                    originalSel,
                                    method_getImplementation(swizzledMethod),
                                    method_getTypeEncoding(swizzledMethod));
    if (didAdded) {
        class_replaceMethod(cls,
                            swizzledSel,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
    return YES;
}

BOOL swizzleClassMethod(Class cls, SEL originalSel, SEL swizzledSel) {
    Method originalMethod = class_getClassMethod(cls, originalSel);
    Method swizzledMethod = class_getClassMethod(cls, swizzledSel);
    if (!originalMethod || !swizzledMethod) {
        return NO;
    }
    
    BOOL didAdded = class_addMethod(objc_getMetaClass([NSStringFromClass(cls) UTF8String]),
                                    originalSel,
                                    method_getImplementation(swizzledMethod),
                                    method_getTypeEncoding(swizzledMethod));
    if (didAdded) {
        class_replaceMethod(objc_getMetaClass([NSStringFromClass(cls) UTF8String]),
                            swizzledSel,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
    return YES;
}
