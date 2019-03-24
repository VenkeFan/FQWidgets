//
//  FQTimerManager.m
//  FQWidgets
//
//  Created by fan qi on 2019/3/24.
//  Copyright © 2019 fan qi. All rights reserved.
//

#import "FQTimerManager.h"

@interface FQTimerManager ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation FQTimerManager

- (instancetype)initWithTarget:(id)target aSelector:(SEL)aSelector {
    if (self = [super init]) {
        _target = target;
        _aSelector = aSelector;
        
        _timer = [NSTimer timerWithTimeInterval:5.0
                                         target:self
                                       selector:@selector(timerStep:)
                                       userInfo:nil
                                        repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        [_timer fire];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"FQTimerManager dealloc !!!!!!");
}

#pragma mark - Public

- (void)start {
    [_timer setFireDate:[NSDate date]];
}

- (void)pause {
    [_timer setFireDate:[NSDate distantFuture]];
}

- (void)shutdown {
    [_timer invalidate];
    _timer = nil;
}

#pragma mark - Private

- (void)timerStep:(NSTimer *)timer {
    
    if (_target && [_target respondsToSelector:_aSelector]) {
        IMP imp = [_target methodForSelector:_aSelector];
        void (*fun)(id, SEL) = (void *)imp;
        fun(_target, _aSelector);
    }
}

@end
