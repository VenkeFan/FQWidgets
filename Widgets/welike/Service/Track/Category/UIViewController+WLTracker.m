//
//  UIViewController+WLTracker.m
//  welike
//
//  Created by fan qi on 2018/11/12.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "UIViewController+WLTracker.h"
#import "WLTrackerActivity.h"
#import "WLAbstractCameraViewController.h"

static CFTimeInterval beginTime = 0.0;
static CFTimeInterval endTime = 0.0;

@implementation UIViewController (WLTracker)

+ (void)load {
    swizzleInstanceMethod([self class], @selector(viewWillAppear:), @selector(swizzle_viewWillAppear:));
    swizzleInstanceMethod([self class], @selector(viewWillDisappear:), @selector(swizzle_viewWillDisappear:));
}

- (void)swizzle_viewWillAppear:(BOOL)animated {
    [self swizzle_viewWillAppear:animated];
    
    if (![self p_isTrackable:[self class]]) {
        return;
    }
    
    beginTime = CACurrentMediaTime();
    
    if ([self isKindOfClass:[WLAbstractCameraViewController class]]) {
        [WLTrackerActivity appendTrackerWithActivityType:WLTrackerActivityType_Appear
                                                     obj:self
                                                duration:0];
    } else {
        [WLTrackerActivity appendTrackerWithActivityType:WLTrackerActivityType_Appear
                                                     cls:[self class]
                                                duration:0];
    }
}

- (void)swizzle_viewWillDisappear:(BOOL)animated {
    [self swizzle_viewWillDisappear:animated];
    
    if (![self p_isTrackable:[self class]]) {
        return;
    }
    
    endTime = CACurrentMediaTime();
    
    CFTimeInterval duration = (endTime - beginTime) * 1000;
    
    if ([self isKindOfClass:[WLAbstractCameraViewController class]]) {
        [WLTrackerActivity appendTrackerWithActivityType:WLTrackerActivityType_Transition
                                                 obj:self
                                                duration:duration];
    } else {
        [WLTrackerActivity appendTrackerWithActivityType:WLTrackerActivityType_Transition
                                                     cls:[self class]
                                                duration:duration];
    }
}

- (BOOL)p_isTrackable:(Class)cls {
    NSString *clsName = NSStringFromClass(cls);
    if ([clsName isEqualToString:@"RDRootViewController"]
        || [clsName isEqualToString:@"WLHomeViewController"]
        || [clsName isEqualToString:@"WLDiscoveryViewController"]
        || [clsName isEqualToString:@"WLMessageViewController"]
        || [clsName isEqualToString:@"WLMeViewController"]
        || [clsName isEqualToString:@"UITextInputController"]
        || [clsName isEqualToString:@"UIInputWindowController"]
        || [clsName isEqualToString:@"UISystemKeyboardDockController"]
        || [clsName isEqualToString:@"UICompatibilityInputViewController"]) {
        return NO;
    }
    
    return YES;
}

+(NSString *)superControllerName:(UIViewController *)controllerTarget
{
    
   NSString *selfClass = NSStringFromClass([controllerTarget class]);
    
    if (selfClass.length > 0)
    {
         return selfClass;
    }
    else
    {
         return @"";
    }
}

@end
