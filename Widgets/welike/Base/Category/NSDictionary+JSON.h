//
//  NSDictionary+JSON.h
//  welike
//
//  Created by 刘斌 on 2018/4/25.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSDictionary (JSON)

- (BOOL)containForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key def:(NSInteger)defVal;
- (CGFloat)floatForKey:(NSString *)key def:(CGFloat)defVal;
- (double)doubleForKey:(NSString *)key def:(double)defVal;
- (long long)longLongForKey:(NSString *)key def:(long long)defVal;
- (BOOL)boolForKey:(NSString *)key def:(BOOL)defVal;
+ (NSData *)JSONRepresentation:(NSDictionary *)dic;//直接将dic转为二进制,方便压缩
+ (NSString *)dicToJsonStr:(NSDictionary *)dic;
+ (NSDictionary *)stringToDictionnary:(NSString *)jsonStr;


@end
