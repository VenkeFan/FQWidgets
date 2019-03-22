//
//  U3PlayerPreload.h
//  u3playersdk
//
//  Created by mamk on 2017/2/17.
//  Copyright © 2017年 UCMobile. All rights reserved.
//

#ifndef U3PlayerPreload_h
#define U3PlayerPreload_h
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#ifdef U3PLAYER_LIBRARY
#pragma GCC visibility push(default)
#define U3PlayerExport __attribute__((visibility("default")))
#else
#define U3PlayerExport
#endif

U3PlayerExport
@protocol U3PlayerPreloadDelegate <NSObject>

@optional
- (void) onInfo:(int)what Extra:(int)extra;

@end

@protocol U3PlayerPreloadStatisticsDelegate <NSObject>

@optional
- (bool) onUpload:(NSDictionary*) stat;

@end

U3PlayerExport
@interface U3PlayerPreload : NSObject

//- (void)requestStatisticWithCompletion:(void (^)(NSDictionary* stat))completion;
+ (U3PlayerPreload*) getInstance;
+ (void)add:(NSString*)videoId url:(NSString*)url headers:(NSDictionary*)headers delegate:(id<U3PlayerPreloadDelegate>)delegate;
+ (void)setPriority:(NSString*)videoID priority:(int)priority;
+ (void)remove:(NSString*)videoID;
+ (void)setOption:(NSString*)key value:(NSString*)value;
+ (NSString*)getOption:(NSString*)key;
+ (void)setStatisticsUploadDelegate:(id<U3PlayerPreloadStatisticsDelegate>)delegate;
+ (void)onStatistics:(NSDictionary*)statistics;
+ (void)onStaticInfo:(NSString*)videoId info:(int)info ext:(int)ext;
@end

#ifdef U3PLAYER_LIBRARY
#pragma GCC visibility pop
#endif

#endif /* U3PlayerPreload_h */
