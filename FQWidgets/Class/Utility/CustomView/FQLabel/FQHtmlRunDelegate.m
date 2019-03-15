//
//  FQHtmlRunDelegate.m
//  FQWidgets
//
//  Created by fan qi on 2019/3/7.
//  Copyright © 2019 fan qi. All rights reserved.
//

#import "FQHtmlRunDelegate.h"

#pragma mark - CTRunDelegateCallbacks Method

static CGFloat HeightCallBack(void *ref) {
    FQHtmlRunDelegate *delegate = (__bridge FQHtmlRunDelegate *)ref;
    return delegate.height;
}

static CGFloat DescentCallBack(void *ref) {
    return 0;
}

static CGFloat WidthCallBack(void *ref) {
    FQHtmlRunDelegate *delegate = (__bridge FQHtmlRunDelegate *)ref;
    return delegate.width;
}

static void DeallocCallBack(void *ref) {
    FQHtmlRunDelegate *delegate = (__bridge FQHtmlRunDelegate *)ref;
    delegate = nil;
}

@implementation FQHtmlRunDelegate {
    CTRunDelegateRef _delegateRef;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)dealloc {
    NSLog(@"FQHtmlRunDelegate dealloc $$$$$$$$$$$$");
}

- (CTRunDelegateRef)delegateRef {
    if (!_delegateRef) {
        CTRunDelegateCallbacks callbacks;
        callbacks.version = kCTRunDelegateCurrentVersion;
        callbacks.getAscent = HeightCallBack;
        callbacks.getDescent = DescentCallBack;
        callbacks.getWidth = WidthCallBack;
        callbacks.dealloc = DeallocCallBack;
        
        _delegateRef = CTRunDelegateCreate(&callbacks, (__bridge void *)self);
    }
    return _delegateRef;
}

@end
