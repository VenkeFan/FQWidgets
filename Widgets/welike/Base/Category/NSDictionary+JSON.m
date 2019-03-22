//
//  NSDictionary+JSON.m
//  welike
//
//  Created by 刘斌 on 2018/4/25.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)

- (BOOL)containForKey:(NSString *)key
{
    if (key == nil || [key length] == 0) return NO;
    id obj = [self objectForKey:key];
    if (obj != nil && ![obj isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    return NO;
}

- (NSString *)stringForKey:(NSString *)key
{
    if (key == nil || [key length] == 0) return nil;
    id obj = [self objectForKey:key];
    if (obj != nil && ![obj isKindOfClass:[NSNull class]])
    {
        return [NSString stringWithFormat:@"%@", obj];
    }
    return nil;
}

- (NSInteger)integerForKey:(NSString *)key def:(NSInteger)defVal
{
    if (key == nil || [key length] == 0) return defVal;
    id obj = [self objectForKey:key];
    if (obj != nil && ![obj isKindOfClass:[NSNull class]])
    {
        return [obj integerValue];
    }
    return defVal;
}

- (CGFloat)floatForKey:(NSString *)key def:(CGFloat)defVal
{
    if (key == nil || [key length] == 0) return defVal;
    id obj = [self objectForKey:key];
    if (obj != nil && ![obj isKindOfClass:[NSNull class]])
    {
        return [obj floatValue];
    }
    return defVal;
}

- (double)doubleForKey:(NSString *)key def:(double)defVal
{
    if (key == nil || [key length] == 0) return defVal;
    id obj = [self objectForKey:key];
    if (obj != nil && ![obj isKindOfClass:[NSNull class]])
    {
        return [obj doubleValue];
    }
    return defVal;
}

- (long long)longLongForKey:(NSString *)key def:(long long)defVal
{
    if (key == nil || [key length] == 0) return defVal;
    id obj = [self objectForKey:key];
    if (obj != nil && ![obj isKindOfClass:[NSNull class]])
    {
        return [obj longLongValue];
    }
    return defVal;
}

- (BOOL)boolForKey:(NSString *)key def:(BOOL)defVal
{
    if (key == nil || [key length] == 0) return defVal;
    id obj = [self objectForKey:key];
    if (obj != nil && ![obj isKindOfClass:[NSNull class]])
    {
        return [obj boolValue];
    }
    return defVal;
}

+ (NSData *)JSONRepresentation:(NSDictionary *)dic
{
    NSError *parseError = nil;
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    //Data转换为JSON
    //NSString* str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return  jsonData;
}


+ (NSString *)dicToJsonStr:(NSDictionary *)dic
{
    NSError *parseError = nil;
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    //Data转换为JSON
    NSString* str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return  str;
}

+ (NSDictionary *)stringToDictionnary:(NSString *)jsonStr
{
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
   
    if (result != nil && [result isKindOfClass:[NSDictionary class]] == YES)
    {
        NSDictionary *jsonDic = (NSDictionary *)result;
        return jsonDic;
    }
    return nil;
}


@end
