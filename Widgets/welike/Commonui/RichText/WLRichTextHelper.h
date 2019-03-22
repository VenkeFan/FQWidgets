//
//  WLRichTextHelper.h
//  welike
//
//  Created by gyb on 2018/5/9.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLRichContent.h"


@interface WLRichTextHelper : NSObject

//发布器用:生成最终的一系列高亮点击
+(void)richTextToNormalItems:(NSAttributedString *)attributedText mentionArray:(NSArray *)mentionArray  linkArray:(NSMutableArray *)linkArray topicArray:(NSMutableArray *)topicArray result:(void (^)(NSArray *))callback;



//use for char num
+(void)allRichItems:(NSAttributedString *)attributedText mentionArray:(NSArray *)mentionArray linkArray:(NSMutableArray *)linkArray result:(void (^)(NSArray *))callback;


//use for comment add name:
+(WLRichContent *)mergeContentWithName:(NSString *)name content:(WLRichContent *)richContent;

//用于自动剪切富文本上传的字符串到指定的长度
+(NSString *)clipContentToIndicatelength:(NSInteger)lenght withContent:(WLRichContent *)richContent;

//计算富文本的字数
+(NSInteger)caculateRichContentLength:(WLRichContent *)richContent;

//返回一个普通文本的长度,包含链接和表情
+(NSInteger)caculateNormalTextLength:(NSString *)normalStr;

//处理换行和空格逻辑
+(void)removeSpaceAndHuanhang:(WLRichContent *)richContent;


@end
