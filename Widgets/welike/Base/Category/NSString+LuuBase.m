//
//  NSString+LuuBase.m
//  Luuphone
//
//  Created by liubin on 15/5/12.
//  Copyright (c) 2015年 luuphone. All rights reserved.
//

#import "NSString+LuuBase.h"
#import "GTMBase64.h"

@implementation NSString (LuuBase)

+ (NSString *)stringWithObject:(id)obj
{
    if (obj)
    {
        return [NSString stringWithFormat:@"%@", obj];
    }
    
    return @"";
}

- (NSString *)stringEncodeBase64
{
    NSData * data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    // 转换到base64
    data = [GTMBase64 encodeData:data];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)stringDecodeBase64
{
    NSData * data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    // 转换到string
    data = [GTMBase64 decodeData:data];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)urlEncode:(NSStringEncoding)stringEncoding
{
    NSArray *escapeChars = [NSArray arrayWithObjects:@";", @"/", @"?", @":",
                            @"@", @"&", @"=", @"+", @"$", @",", @"!",
                            @"'", @"(", @")", @"*", @"-", @"~", @"_", nil];
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B", @"%2F", @"%3F", @"%3A",
                             @"%40", @"%26", @"%3D", @"%2B", @"%24", @"%2C", @"%21",
                             @"%27", @"%28", @"%29", @"%2A", @"%2D", @"%7E", @"%5F", nil];
    
    int len = (int)[escapeChars count];
    NSString *tempStr = [self stringByAddingPercentEscapesUsingEncoding:stringEncoding];
    
    if (tempStr == nil) return nil;
    
    NSMutableString *temp = [tempStr mutableCopy];
    
    for (int i = 0; i < len; i++)
    {
        [temp replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
                              withString:[replaceChars objectAtIndex:i]
                                 options:NSLiteralSearch
                                   range:NSMakeRange(0, [temp length])];
    }
    
    return [NSString stringWithString:temp];
}

- (NSString *)urlDecode:(NSStringEncoding)stringEncoding
{
    NSArray *escapeChars = [NSArray arrayWithObjects:@";", @"/", @"?", @":",
                            @"@", @"&", @"=", @"+", @"$", @",", @"!",
                            @"'", @"(", @")", @"*", @"-", @"~", @"_", nil];
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B", @"%2F", @"%3F", @"%3A",
                             @"%40", @"%26", @"%3D", @"%2B", @"%24", @"%2C", @"%21",
                             @"%27", @"%28", @"%29", @"%2A", @"%2D", @"%7E", @"%5F", nil];
    
    int len = (int)[escapeChars count];
    NSMutableString *temp = [self mutableCopy];
    
    if (temp == nil) return nil;
    
    for (int i = 0; i < len; i++)
    {
        [temp replaceOccurrencesOfString:[replaceChars objectAtIndex:i]
                              withString:[escapeChars objectAtIndex:i]
                                 options:NSLiteralSearch
                                   range:NSMakeRange(0, [temp length])];
    }
    
    return [[NSString stringWithString:temp] stringByReplacingPercentEscapesUsingEncoding:stringEncoding];
}

- (NSInteger)checkUserNameLength
{
    NSInteger strlength = 0;
    if ([self length] > 0)
    {
        char* p = (char *)[self cStringUsingEncoding:NSUnicodeStringEncoding];
        NSInteger count = [self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding];
        for (NSInteger i = 0; i < count; i++)
        {
            if (*p)
            {
                p++;
                strlength++;
            }
            else
            {
                p++;
            }
        }
    }
    return strlength;
}

- (BOOL)convertToBool
{
    if (self != nil)
    {
        if ([self isEqualToString:@"0"] == YES)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else
    {
        return NO;
    }
}

- (NSString *)convertToHttps
{
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", linkRegular];
    if ([urlTest evaluateWithObject:self] == YES)
    {
        NSURL *u = [[NSURL alloc] initWithString:self];
        if ([u.scheme isEqualToString:@"http"] == YES)
        {
            return [NSString stringWithFormat:@"https%@", [self substringWithRange:NSMakeRange(4, [self length] - 4)]];
            
        }
        return self;
    }
    else
    {
        return self;
    }
}

- (CGSize)sizeWithFont:(UIFont *)font size:(CGSize)size
{
    NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByCharWrapping];
    NSDictionary *attributes = @{ NSFontAttributeName:font, NSParagraphStyleAttributeName:style };
    CGRect rect = [self boundingRectWithSize:size options:opts attributes:attributes context:nil];
    return CGSizeMake(ceil(rect.size.width), ceil(rect.size.height));
}

- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    CGSize result;
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = lineBreakMode;
            attr[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        CGRect rect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return result;
}

+(NSString *)toLower:(NSString *)str{
    for (NSInteger i=0; i<str.length; i++) {
        if ([str characterAtIndex:i]>='A'&[str characterAtIndex:i]<='Z') {
            //A  65  a  97
            char  temp=[str characterAtIndex:i]+32;
            NSRange range=NSMakeRange(i, 1);
            str=[str stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"%c",temp]];
        }
    }
    return str;
}

+(NSArray *)matcheInString:(NSString *)string regularExpressionWithPattern:(NSString *)regularExpressionWithPattern
{
    NSError *error;
    NSRange range = NSMakeRange(0,[string length]);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpressionWithPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray* matches = [regex matchesInString:string options:0 range:range];
    return matches;
}


//去掉标点符号
+(NSString *)deleteCharacters:(NSString *)targetString
{
    if (targetString.length==0 || !targetString) {
        return nil;
    }
    
    NSError *error = nil;
    NSString *pattern = @"[\\p{P}~^<>+=|$`]";
    NSRegularExpression *regularExpress = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];//这个正则可以去掉所有特殊字符和标点
    NSString *string = [regularExpress stringByReplacingMatchesInString:targetString options:0 range:NSMakeRange(0, [targetString length]) withTemplate:@""];
    
    return string;
    
}

//字节数
+(NSInteger)getToInt:(NSString *)str
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* da = [str dataUsingEncoding:enc];
    return [da length];
}


@end
