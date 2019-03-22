//
//  WLFeedDetailViewController+WLTracker.m
//  welike
//
//  Created by fan qi on 2018/11/1.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLFeedDetailViewController+WLTracker.h"
#import "WLTrackerPostRead.h"

static CFTimeInterval beginTime = 0.0;
static CFTimeInterval endTime = 0.0;

@implementation WLFeedDetailViewController (WLTracker)

+ (void)load {
    swizzleInstanceMethod(self, @selector(viewDidLoad), @selector(swizzle_viewDidLoad));
    swizzleInstanceMethod(self, NSSelectorFromString(@"dealloc"), @selector(swizzle_dealloc));
}

#pragma mark - Swizzle-Method

- (void)swizzle_viewDidLoad {
    [self swizzle_viewDidLoad];
    
    beginTime = CACurrentMediaTime();
}

- (void)swizzle_dealloc {
    endTime = CACurrentMediaTime();
    
    CFTimeInterval duration = endTime - beginTime;
    if (duration > kWLTrackerPostReadDuration) {
        [WLTrackerPostRead appendTrackerWithReadAction:WLTrackerPostReadAction_Detail
                                                  post:self.postModel
                                              duration:duration];
    }
    
    [self swizzle_dealloc];
}

@end
