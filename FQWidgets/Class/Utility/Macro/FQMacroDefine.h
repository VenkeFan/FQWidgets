//
//  FQMacroDefine.h
//  chongchongtv
//
//  Created by fanqi on 17/6/27.
//  Copyright © 2017年 fanqi. All rights reserved.
//


#ifndef FQMacroDefine_h
#define FQMacroDefine_h

#pragma mark - ******************* 去除警告 *******************

// 去除performSelector警告
#define FQSystemRemovePerformSelectorLeakWarningBegin                   \
_Pragma("clang diagnostic push")                                        \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")

// 去除API废弃的警告
#define FQSystemRemoveDeprecatedWarningBegin                            \
_Pragma("clang diagnostic push")                                        \
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")

// 去除变量未使用的警告
#define FQSystemRemoveUnuseWarningBegin                                 \
_Pragma("clang diagnostic push")                                        \
_Pragma("clang diagnostic ignored \"-Wunused-variable\"")

// 去除找不到方法的警告
#define FQSystemRemoveUndeclaredWarningBegin                            \
_Pragma("clang diagnostic push")                                        \
_Pragma("clang diagnostic ignored \"-Wundeclared-selector\"")

// 移除警告结束
#define FQSystemRemoveWarningEnd                                        \
_Pragma("clang diagnostic pop")

// 类的初始化方法标记
#define FQ_DESIGNATED_INITIALIZER  __attribute__((objc_designated_initializer))

#pragma mark - ******************* 自定义TODO *******************

#define STRINGIFY(S) #S
#define DEFER_STRINGIFY(S) STRINGIFY(S)
#define PRAGMA_MESSAGE(MSG) _Pragma(STRINGIFY(message(MSG)))
#define FORMATTED_MESSAGE(MSG) "[TODO-" DEFER_STRINGIFY(__COUNTER__) "] " MSG " \n" \
DEFER_STRINGIFY(__FILE__) " line " DEFER_STRINGIFY(__LINE__)
#define KEYWORDIFY @try {} @catch (...) {}
// 最终使用下面的宏
#define TODO(MSG) KEYWORDIFY PRAGMA_MESSAGE(FORMATTED_MESSAGE(MSG))

#pragma mark - ******************* 自定义NSLog *******************

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s:%d\t  %s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif

#pragma mark - ******************* 屏幕大小 *******************

// 适配
#define kSizeScale(size)        (size * (kScreenWidth / 375.0))

// screen size
#define kCurrentWindow          ([UIApplication sharedApplication].keyWindow)
#define kScreenBounds           ([UIScreen mainScreen].bounds)
#ifndef kScreenWidth
#define kScreenWidth            ([UIScreen mainScreen].bounds.size.width)
#endif
#ifndef kScreenHeight
#define kScreenHeight           ([UIScreen mainScreen].bounds.size.height)
#endif

#pragma mark - ******************* Version *******************

#ifndef kiOS10Later
#define kiOS10Later ([UIDevice systemVersion] >= 10)
#endif

#define kIsiPhoneX  ((kScreenWidth == 375.f && kScreenHeight == 812.f ? YES : NO))

#pragma mark - ******************* NavBar / TabBar *******************

#define kStatusBarHeight            ([UIApplication sharedApplication].statusBarFrame.size.height)
#define kSingleNavBarHeight         (44)
#define kNavBarHeight               (kStatusBarHeight + kSingleNavBarHeight)
#define kSafeAreaBottomHeight       (34)
#define kSingleTabBarHeight         (49)
#define kTabBarHeight               (kIsiPhoneX ? (kSafeAreaBottomHeight + kSingleTabBarHeight) : kSingleTabBarHeight)
#define kSafeAreaBottomY            (kIsiPhoneX ? kSafeAreaBottomHeight : 0)

#pragma mark - ******************* Color *******************

#define kUIColorFromRGBA(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]
#define kUIColorFromRGB(rgbValue) (kUIColorFromRGBA(rgbValue, 1.0))

#pragma mark - ******************* Custom *******************

// custom
#define kIsNull(obj) ((NSNull *)obj == [NSNull null] || !obj ? YES : NO)
#define kIsNullOrEmpty(obj) (kIsNull(obj) || (obj.length == 0) ? YES : NO)

#define kResignFirstResponder   [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil]
//#define kResignFirstResponder   [[UIApplication sharedApplication].keyWindow endEditing:YES] // 效果等价

#endif /* FQMacroDefine_h */
