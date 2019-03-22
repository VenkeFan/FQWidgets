//
//  NSDate+LuuBase.m
//  yshushu
//
//  Created by liubin on 16/3/29.
//  Copyright © 2016年 luu. All rights reserved.
//

#import "NSDate+LuuBase.h"
#import "NSDateFormatter+Category.h"

#define D_HOUR		3600

@implementation NSDate (LuuBase)

- (NSInteger)converToAge
{
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self];
    NSInteger brithDateYear = [components1 year];
    NSInteger brithDateDay = [components1 day];
    NSInteger brithDateMonth = [components1 month];
    
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger currentDateYear = [components2 year];
    NSInteger currentDateDay = [components2 day];
    NSInteger currentDateMonth = [components2 month];
    
    NSInteger age = currentDateYear - brithDateYear - 1;
    if ((currentDateMonth > brithDateMonth) || (currentDateMonth == brithDateMonth && currentDateDay >= brithDateDay)) {
        age++;
    }
    return age;
}

+ (NSDate *)dateWithTimeIntervalInMilliSecondSince1970:(double)timeIntervalInMilliSecond
{
    NSDate *ret = nil;
    double timeInterval = timeIntervalInMilliSecond;
    if(timeIntervalInMilliSecond > 140000000000)
    {
        timeInterval = timeIntervalInMilliSecond / 1000;
    }
    ret = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    return ret;
}

+ (NSString *)feedTimeStringFromTimestamp:(NSTimeInterval)timestamp {
    
    NSInteger timeNow = (NSInteger)[[NSDate date] timeIntervalSince1970];
    NSInteger totalSeconds = timeNow - timestamp / 1000;
    
    NSString *result = nil;
    
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    
    if (totalSeconds < 60) {
        result = [AppContext getStringForKey:@"now" fileName:@"feed"];;
    } else if (totalSeconds < 60 * 60) {
        result = [NSString stringWithFormat:@"%ldm", (long)((totalSeconds / 60) % 60)];
    } else if (totalSeconds < 60 * 60 * 24) {
        result = [NSString stringWithFormat:@"%ldh", (long)(totalSeconds / (60 * 60))];
    } else if (totalSeconds < 60 * 60 * 24 * 365) {
        [dateFormatter setDateFormat:@"dd-MM HH:mm"];
        result = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp / 1000]];
    } else {
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        result = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp / 1000]];
    }
    
    return  result;
}

+ (NSString *)commentTimeStringFromTimestamp:(NSTimeInterval)timestamp {
    NSInteger timeNow = (NSInteger)[[NSDate date] timeIntervalSince1970];
    NSInteger totalSeconds = timeNow - timestamp / 1000;
    
    NSString *result = nil;
    
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    
    if (totalSeconds < 60 * 60 * 24) {
        [dateFormatter setDateFormat:@"HH:mm"];
        result = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp / 1000]];
    } else if (totalSeconds < 60 * 60 * 24 * 365) {
        [dateFormatter setDateFormat:@"dd-MM HH:mm"];
        result = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp / 1000]];
    } else {
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        result = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp / 1000]];
    }
    
    return  result;
}

+ (NSString *)fullTimeStringFromTimestamp:(NSTimeInterval)timestamp {
   // NSInteger timeNow = (NSInteger)[[NSDate date] timeIntervalSince1970];
   // NSInteger totalSeconds = timeNow - timestamp / 1000;
    
    NSString *result = nil;
    
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    result = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp / 1000]];
    
    return  result;
}

#pragma mark Retrieving Intervals
- (NSInteger)hoursAfterDate:(NSDate *)aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_HOUR);
}

@end
