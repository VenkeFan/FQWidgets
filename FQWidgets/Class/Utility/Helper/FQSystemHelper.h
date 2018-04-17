//
//  FQSystemHelper.h
//  FQWidgets
//
//  Created by fan qi on 2018/4/12.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FQSystemHelper : NSObject

+ (UIViewController *)currentViewController;

+ (NSString *)appName;
+ (NSString *)appVersion;
+ (NSString *)deviceName;
+ (NSString *)deviceSystemVersion;

+ (dispatch_source_t)startCountDownWithSeconds:(NSUInteger)seconds
                                     executing:(void(^)(NSUInteger current))executing
                                      finished:(void(^)(void))finished;
+ (dispatch_source_t)startCountDownWithBegin:(NSUInteger)begin
                                         end:(NSUInteger)end
                                   executing:(void(^)(NSUInteger current))executing
                                    finished:(void(^)(void))finished;

+ (CGFloat)visibleKeyboardHeight;

+ (void)setServerTimeIntervalOffset:(NSTimeInterval)serverTimestamp;
+ (NSTimeInterval)currentTimestamp;

+ (BOOL)changeKeyWindowRootViewControllerWithNewClass:(Class)newClass;

@end
