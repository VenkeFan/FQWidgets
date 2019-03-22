//
//  NSString+LuuBase.h
//  Luuphone
//
//  Created by liubin on 15/5/12.
//  Copyright (c) 2015年 luuphone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LuuBase)

+ (NSString *)stringWithObject:(id)obj;
- (NSString *)stringEncodeBase64;
- (NSString *)stringDecodeBase64;
- (NSString *)urlEncode:(NSStringEncoding)stringEncoding;
- (NSString *)urlDecode:(NSStringEncoding)stringEncoding;
- (NSInteger)checkUserNameLength;
- (BOOL)convertToBool;

- (NSString *)convertToHttps;

- (CGSize)sizeWithFont:(UIFont *)font size:(CGSize)size;

- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode;

//change A, B, C ---> a,b,c ....
+(NSString *)toLower:(NSString *)str;

//regularExpression
+(NSArray *)matcheInString:(NSString *)string regularExpressionWithPattern:(NSString *)regularExpressionWithPattern;

//去掉标点符号
+(NSString *)deleteCharacters:(NSString *)targetString;

//字节数
+(NSInteger)getToInt:(NSString *)str;



@end
