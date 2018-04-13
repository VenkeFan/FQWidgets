//
//  FQSystemHelper.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/12.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQSystemHelper.h"
#import <sys/sysctl.h>
#import <UserNotifications/UserNotifications.h>
#import <AVFoundation/AVFoundation.h>

NSString * const kSystemUpTimeOffsetUserKey = @"kSystemUpTimeOffsetUserKey";

@implementation FQSystemHelper

+ (UIViewController *)currentViewController {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *currentVC = [self p_getCurrentCtrFrom:rootViewController];
    
    return currentVC;
}

+ (NSString *)appName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

+ (NSString *)appVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

//+ (NSString *)deviceName {
//    return [UIDevice currentDevice].model;
//}

+ (NSString *)deviceName {
    static dispatch_once_t one;
    static NSString *name;
    dispatch_once(&one, ^{
        NSString *model = [self machineModel];
        if (!model) return;
        NSDictionary *dic = @{
                              @"iPod1,1" : @"iPod touch 1G",
                              @"iPod2,1" : @"iPod touch 2G",
                              @"iPod3,1" : @"iPod touch 3G",
                              @"iPod4,1" : @"iPod touch 4G",
                              @"iPod5,1" : @"iPod touch 5G",
                              @"iPod7,1" : @"iPod touch 6G",
                              
                              @"iPhone1,1" : @"iPhone 1G",
                              @"iPhone1,2" : @"iPhone 3G",
                              @"iPhone2,1" : @"iPhone 3GS",
                              @"iPhone3,1" : @"iPhone 4 (GSM)",
                              @"iPhone3,2" : @"iPhone 4 (GSM Rev A)",
                              @"iPhone3,3" : @"iPhone 4 (CDMA)",
                              @"iPhone4,1" : @"iPhone 4S",
                              @"iPhone5,1" : @"iPhone 5 (GSM)",
                              @"iPhone5,2" : @"iPhone 5 (Global)",
                              @"iPhone5,3" : @"iPhone 5c (GSM)",
                              @"iPhone5,4" : @"iPhone 5c (Global)",
                              @"iPhone6,1" : @"iPhone 5s (GSM)",
                              @"iPhone6,2" : @"iPhone 5s (Global)",
                              @"iPhone7,1" : @"iPhone 6 Plus",
                              @"iPhone7,2" : @"iPhone 6",
                              @"iPhone8,1" : @"iPhone 6s",
                              @"iPhone8,2" : @"iPhone 6s Plus",
                              @"iPhone8,4" : @"iPhone SE",
                              @"iPhone9,1" : @"iPhone 7",
                              @"iPhone9,2" : @"iPhone 7 Plus",
                              @"iPhone9,3" : @"iPhone 7",
                              @"iPhone9,4" : @"iPhone 7 Plus",
                              
                              @"iPad1,1" : @"iPad 1G",
                              @"iPad2,1" : @"iPad 2 (WiFi)",
                              @"iPad2,2" : @"iPad 2 (GSM)",
                              @"iPad2,3" : @"iPad 2 (CDMA)",
                              @"iPad2,4" : @"iPad 2 (Rev A)",
                              @"iPad2,5" : @"iPad mini 1G (Wi-Fi)",
                              @"iPad2,6" : @"iPad mini 1G (GSM)",
                              @"iPad2,7" : @"iPad mini 1G (Global)",
                              @"iPad3,1" : @"iPad 3 (Wi-Fi)",
                              @"iPad3,2" : @"iPad 3 (GSM)",
                              @"iPad3,3" : @"iPad 3 (Global)",
                              @"iPad3,4" : @"iPad 4 (Wi-Fi)",
                              @"iPad3,5" : @"iPad 4 (GSM)",
                              @"iPad3,6" : @"iPad 4 (Global)",
                              @"iPad4,1" : @"iPad Air (Wi-Fi)",
                              @"iPad4,2" : @"iPad Air (Cellular)",
                              @"iPad4,3" : @"iPad Air",
                              @"iPad4,4" : @"iPad mini 2G (Wi-Fi)",
                              @"iPad4,5" : @"iPad mini 2G (Cellular)",
                              @"iPad4,6" : @"iPad mini 2G (Cellular)",
                              @"iPad4,7" : @"iPad mini 3G (Wi-Fi)",
                              @"iPad4,8" : @"iPad mini 3G (Cellular)",
                              @"iPad4,9" : @"iPad mini 3G (Cellular)",
                              @"iPad5,1" : @"iPad mini 4G (Wi-Fi)",
                              @"iPad5,2" : @"iPad mini 4G (Cellular)",
                              @"iPad5,3" : @"iPad Air 2 (Wi-Fi)",
                              @"iPad5,4" : @"iPad Air 2 (Cellular)",
                              @"iPad6,3" : @"iPad Pro (9.7 inch) 1G (Wi-Fi)",
                              @"iPad6,4" : @"iPad Pro (9.7 inch) 1G (Cellular)",
                              @"iPad6,7" : @"iPad Pro (12.9 inch) 1G (Wi-Fi)",
                              @"iPad6,8" : @"iPad Pro (12.9 inch) 1G (Cellular)",
                              
                              @"AppleTV1,1" : @"Apple TV 1G",
                              @"AppleTV2,1" : @"Apple TV 2G",
                              @"AppleTV3,1" : @"Apple TV 3G",
                              @"AppleTV3,2" : @"Apple TV 3G",
                              @"AppleTV5,3" : @"Apple TV 4G",
                              
                              @"i386" : @"Simulator x86",
                              @"x86_64" : @"Simulator x64",
                              };
        name = dic[model];
        if (!name) name = model;
    });
    return name;
}

+ (NSString *)machineModel {
    static dispatch_once_t one;
    static NSString *model;
    dispatch_once(&one, ^{
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        model = [NSString stringWithUTF8String:machine];
        free(machine);
    });
    return model;
}

+ (NSString *)deviceSystemVersion {
    return [UIDevice currentDevice].systemVersion;
}

+ (void)getAuthorizationStatusWithFinished:(void (^)(BOOL))finished {
    
    BOOL cameraAuthorized = ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized);
    BOOL microphoneAuthorized = ([AVAudioSession sharedInstance].recordPermission == AVAudioSessionRecordPermissionGranted);
    
    if (kiOS10Later) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            BOOL granted = (settings.authorizationStatus == UNAuthorizationStatusAuthorized)
            && cameraAuthorized && cameraAuthorized;
            
            if (finished) {
                finished(granted);
            }
        }];
    } else {
//        [UIApplication sharedApplication].isRegisteredForRemoteNotifications;
        BOOL granted = ([[[UIApplication sharedApplication] currentUserNotificationSettings] types] != UIUserNotificationTypeNone)
        && cameraAuthorized && microphoneAuthorized;
        
        if (finished) {
            finished(granted);
        }
    }
}

+ (dispatch_source_t)startCountDownWithSeconds:(NSUInteger)seconds
                                     executing:(void(^)(NSUInteger current))executing
                                      finished:(void(^)(void))finished {
    return [self startCountDownWithBegin:seconds end:0 executing:executing finished:finished];
}

+ (dispatch_source_t)startCountDownWithBegin:(NSUInteger)begin
                                         end:(NSUInteger)end
                                   executing:(void(^)(NSUInteger current))executing
                                    finished:(void(^)(void))finished {
    BOOL isAscend = begin < end ? YES : NO;
    
    __block NSUInteger duration = begin;
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (duration == end) {
            dispatch_source_cancel(timer);
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (executing) {
                    executing(duration);
                }
            });
            
            isAscend ? duration ++ : duration--;
        }
    });
    
    dispatch_source_set_cancel_handler(timer, ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (finished) {
                finished();
            }
        });
    });
    
    dispatch_resume(timer);
    
    return timer;
}

+ (CGFloat)visibleKeyboardHeight {
    
    // UITextEffectsWindow / UIRemoteKeyboardWindow
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if (![testWindow isMemberOfClass:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    for (UIView *possibleKeyboard in [keyboardWindow subviews]) {
        if([possibleKeyboard isKindOfClass:NSClassFromString(@"UIPeripheralHostView")] || [possibleKeyboard isKindOfClass:NSClassFromString(@"UIKeyboard")]) {
            return CGRectGetHeight(possibleKeyboard.bounds);
        } else if([possibleKeyboard isKindOfClass:NSClassFromString(@"UIInputSetContainerView")]) {
            for (UIView *possibleKeyboardSubview in [possibleKeyboard subviews]) {
                if([possibleKeyboardSubview isKindOfClass:NSClassFromString(@"UIInputSetHostView")]) {
                    return CGRectGetHeight(possibleKeyboardSubview.bounds);
                }
            }
        }
    }
    
    return 0;
}

+ (void)setServerTimeIntervalOffset:(NSTimeInterval)serverTimestamp {
    if ([FQSystemHelper objectForKey:kSystemUpTimeOffsetUserKey]) {
        return;
    }
    
    NSTimeInterval upTime = [[NSProcessInfo processInfo] systemUptime] * 1000;
    NSTimeInterval timestamp = serverTimestamp;
    NSTimeInterval timeOffset = timestamp - upTime;
    
    [FQSystemHelper setObject:@(timeOffset) forKey:kSystemUpTimeOffsetUserKey];
}

+ (NSTimeInterval)currentTimestamp {
    NSTimeInterval upTime = [[NSProcessInfo processInfo] systemUptime] * 1000;
    
    NSTimeInterval currentTime = 0;
    
    id obj = [FQSystemHelper objectForKey:kSystemUpTimeOffsetUserKey];
    if (obj) {
        NSTimeInterval timeOffset = [obj doubleValue];
        currentTime = timeOffset + upTime;
    }
    
    return currentTime;
}

+ (BOOL)changeKeyWindowRootViewControllerWithNewClass:(Class)newClass {
    if ([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:newClass]) {
        return NO;
    }
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootViewController = [newClass new];
    rootViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [UIView transitionWithView:window
                      duration:0.25f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        BOOL oldState = [UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        window.rootViewController = rootViewController;
                        [UIView setAnimationsEnabled:oldState];
                    }
                    completion:nil];
    
    return YES;
}

#pragma mark - Private

+ (UIViewController *)p_getCurrentCtrFrom:(UIViewController *)rootVC {
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        currentVC = [self p_getCurrentCtrFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        currentVC = [self p_getCurrentCtrFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        currentVC = rootVC;
    }
    
    return currentVC;
}

+ (void)setObject:(id)object forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)objectForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

@end
