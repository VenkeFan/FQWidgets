//
//  WLTextParse.h
//  GBRichLabel
//
//  Created by gyb on 2018/4/14.
//  Copyright © 2018年 gyb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLTextParse : NSObject



/**
 *  处理字符串中关键字@
 *
 *  @param attachments 服务端返回的attachments字段
 *
 *  @return   所有的@某人的range数组
 */
+ (NSArray *)keywordRangesOfAtPersonInString:(NSArray *)attachments;




/**
 *  处理字符串中的表情格式
 *
 *  @param textStr 富文本字符串
 *
 *  @return   表情的range以及去除表情之后的字符串
 */
+ (NSArray *)keywordRangesOfEmotionInString:(NSString *)textStr;




/**
 *  处理字符串中的网址
 *
 *  @param attachments 服务端返回的attachments字段
 *
 *  @return 网址替换以及网址替换后的字符串
 */
+ (NSArray *)keywordRangesOfURLInString:(NSArray *)attachments;

//从字符串中取出链接
+ (NSArray *)urlsInString:(NSString *)linkString;


/**
 *  处理字符串中话题的格式
 *
 * @param attachments 服务端返回的attachments字段
 *
 *  @return   所有#话题的range数组
 */
+ (NSArray *)keywordRangesOfSharpTrendInString:(NSArray *)attachments;


//字符串中的长文
+ (NSArray *)keywordRangesOfArticalInString:(NSArray *)attachments;


+(NSArray *)matcheInString:(NSString *)string regularExpressionWithPattern:(NSString *)regularExpressionWithPattern;

+(NSString *)replacementStringForResult:(NSTextCheckingResult *)result inString:(NSString *)string regularExpressionWithPattern:(NSString *)regularExpressionWithPattern;

@end
