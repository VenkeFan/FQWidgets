//
//  NSDate+LuuBase.h
//  yshushu
//
//  Created by liubin on 16/3/29.
//  Copyright © 2016年 luu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (LuuBase)

- (NSInteger)converToAge;
+ (NSDate *)dateWithTimeIntervalInMilliSecondSince1970:(double)timeIntervalInMilliSecond;
+ (NSString *)feedTimeStringFromTimestamp:(NSTimeInterval)timestamp;
+ (NSString *)commentTimeStringFromTimestamp:(NSTimeInterval)timestamp;
+ (NSString *)fullTimeStringFromTimestamp:(NSTimeInterval)timestamp;


@end
